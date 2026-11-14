import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'ws_connect_io.dart' if (dart.library.js_interop) 'ws_connect_web.dart';

/// Un message reçu en temps réel : `bq_match`, `bq_tournament` ou `bq_player`.
class RealtimeEvent {
  RealtimeEvent(this.type, this.payload);

  final String type;
  final Map<String, dynamic> payload;
}

/// Connexion WebSocket au bus d'Odoo (`/websocket`), partagée par tous les écrans.
///
/// Chaque écran s'abonne au canal SECRET que le serveur lui a donné
/// (`bq.match.<jeton>`…). Le serveur ne dit pas de quel canal vient un
/// message : les écrans filtrent sur le type et l'identifiant contenus.
///
/// Sans WebSocket (réseau qui la bloque, coupure), [connected] reste faux et
/// les écrans interrogent le serveur plus souvent : le jeu continue.
class RealtimeHub {
  RealtimeHub({required this.origin, required this.version});

  /// `https://serveur` (ou `http://…` en développement).
  final String origin;

  /// Version du « worker » WebSocket attendue par le serveur (lue dans `/config`).
  final Future<String> Function() version;

  final connected = ValueNotifier<bool>(false);
  final _events = StreamController<RealtimeEvent>.broadcast();
  final _channels = <String, int>{};

  WebSocketChannel? _socket;
  StreamSubscription<dynamic>? _sub;
  Timer? _retry;
  int _attempt = 0;
  int _last = 0;
  bool _disposed = false;
  bool _connecting = false;

  Stream<RealtimeEvent> get events => _events.stream;

  /// S'abonne à [channel] ; la fonction rendue se désabonne.
  VoidCallback subscribe(String channel) {
    if (channel.isEmpty) return () {};
    final first = !_channels.containsKey(channel);
    _channels[channel] = (_channels[channel] ?? 0) + 1;
    if (_socket == null) {
      _connect();
    } else if (first) {
      _sendSubscribe();
    }
    var done = false;
    return () {
      if (done) return;
      done = true;
      final n = (_channels[channel] ?? 1) - 1;
      if (n <= 0) {
        _channels.remove(channel);
        if (_channels.isEmpty) {
          _close();
        } else {
          _sendSubscribe();
        }
      } else {
        _channels[channel] = n;
      }
    };
  }

  /// Reconnexion immédiate (retour au premier plan, réseau revenu).
  void reconnectNow() {
    if (_channels.isEmpty || _disposed) return;
    if (_socket != null && connected.value) return;
    _retry?.cancel();
    _attempt = 0;
    _connect();
  }

  Uri _uri(String v) {
    final base = Uri.parse(origin);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '/websocket',
      queryParameters: {'version': v},
    );
  }

  Future<void> _connect() async {
    if (_disposed || _connecting || _channels.isEmpty) return;
    _connecting = true;
    try {
      final v = await version();
      final socket = connectWebSocket(_uri(v), origin);
      await socket.ready.timeout(const Duration(seconds: 10));
      if (_disposed || _channels.isEmpty) {
        await socket.sink.close();
        return;
      }
      _socket = socket;
      _attempt = 0;
      connected.value = true;
      _sub = socket.stream.listen(_onMessage, onDone: _onClosed, onError: (_) => _onClosed());
      _sendSubscribe();
    } catch (_) {
      _scheduleRetry();
    } finally {
      _connecting = false;
    }
  }

  void _sendSubscribe() {
    final socket = _socket;
    if (socket == null) return;
    try {
      socket.sink.add(jsonEncode({
        'event_name': 'subscribe',
        'data': {'channels': _channels.keys.toList(), 'last': _last},
      }));
    } catch (_) {
      _onClosed();
    }
  }

  void _onMessage(dynamic data) {
    try {
      final decoded = jsonDecode(data is String ? data : utf8.decode(data as List<int>));
      if (decoded is! List) return;
      for (final n in decoded.whereType<Map>()) {
        final id = n['id'];
        if (id is num && id > _last) _last = id.toInt();
        final message = n['message'];
        if (message is Map && message['payload'] is Map) {
          _events.add(RealtimeEvent('${message['type']}', (message['payload'] as Map).cast<String, dynamic>()));
        }
      }
    } catch (_) {
      // Message inattendu : ignoré (le sondage de secours rattrapera l'état).
    }
  }

  void _onClosed() {
    _sub?.cancel();
    _sub = null;
    _socket = null;
    connected.value = false;
    _scheduleRetry();
  }

  void _scheduleRetry() {
    connected.value = false;
    if (_disposed || _channels.isEmpty) return;
    _retry?.cancel();
    final seconds = min(30, 1 << min(_attempt, 5));
    _attempt++;
    _retry = Timer(Duration(milliseconds: seconds * 1000 + Random().nextInt(500)), _connect);
  }

  void _close() {
    _retry?.cancel();
    _sub?.cancel();
    _sub = null;
    final socket = _socket;
    _socket = null;
    connected.value = false;
    if (socket != null) unawaited(socket.sink.close().catchError((_) {}));
  }

  void dispose() {
    _disposed = true;
    _close();
    _events.close();
  }
}

/// Décalage entre l'horloge du téléphone et celle du serveur.
///
/// Mesuré sur les réponses HTTP (milieu de l'aller-retour) : les échéances
/// envoyées par le serveur (ms, horloge serveur) deviennent des instants locaux.
class ServerClock {
  int? _offset;

  int get offset => _offset ?? 0;
  bool get known => _offset != null;

  /// Heure du serveur, maintenant (ms).
  int now() => DateTime.now().millisecondsSinceEpoch + offset;

  /// [serverNow] reçu dans une réponse partie à [sentAt] et revenue à [receivedAt] (heure locale, ms).
  void sample(int serverNow, int sentAt, int receivedAt) {
    if (serverNow <= 0) return;
    final rtt = receivedAt - sentAt;
    if (rtt < 0 || rtt > 10000) return;
    final estimate = serverNow - (sentAt + receivedAt) ~/ 2;
    // Lissage : une mesure isolée (réseau lent) ne fait pas sauter les chronos.
    _offset = _offset == null ? estimate : (_offset! * 3 + estimate) ~/ 4;
  }

  /// Message temps réel : utile seulement tant qu'aucune mesure HTTP n'existe.
  void sampleOneWay(int serverNow) {
    if (_offset == null && serverNow > 0) _offset = serverNow - DateTime.now().millisecondsSinceEpoch;
  }

  /// Millisecondes restantes avant [deadline] (horloge serveur), jamais négatives.
  int remaining(int? deadline) => deadline == null ? 0 : max(0, deadline - now());
}
