import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'api.dart';
import 'models.dart';
import 'realtime.dart';

/// Stockage du jeton de session (remplaçable dans les tests).
abstract class TokenStore {
  Future<String?> read();
  Future<void> write(String? token);
}

class SecureTokenStore implements TokenStore {
  const SecureTokenStore();

  static const _key = 'quiz_online_token';
  static const _storage = FlutterSecureStorage();

  @override
  Future<String?> read() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      // Stockage illisible (sauvegarde restaurée sur un autre téléphone) : on se reconnectera.
      return null;
    }
  }

  @override
  Future<void> write(String? token) async {
    try {
      if (token == null) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(key: _key, value: token);
      }
    } catch (_) {}
  }
}

class MemoryTokenStore implements TokenStore {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String? token) async => this.token = token;
}

/// Le jeu en ligne vu de l'application : compte, appels au serveur, temps réel.
///
/// Le reste de l'application ne dépend jamais du réseau : tout ceci n'est
/// utilisé que par les écrans « Jouer avec d'autres ».
class OnlineService {
  OnlineService({required String server, TokenStore? tokens, ApiClient? client})
    : client = client ?? ApiClient(baseUrl: server),
      _tokens = tokens ?? const SecureTokenStore() {
    hub = RealtimeHub(origin: this.client.origin, version: _wsVersion);
  }

  final ApiClient client;
  final TokenStore _tokens;
  final clock = ServerClock();
  late final RealtimeHub hub;

  /// Appelé quand la session est refusée par le serveur (déconnexion locale).
  void Function()? onSignedOut;

  bool _loaded = false;
  ServerConfig? _config;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    client.token = await _tokens.read();
    client.onUnauthorized = () {
      client.token = null;
      unawaited(_tokens.write(null));
      onSignedOut?.call();
    };
    _loaded = true;
  }

  Future<bool> hasSession() async {
    await _ensureLoaded();
    return client.token != null;
  }

  /// Appel mesuré : chaque réponse portant `server_now` règle l'horloge.
  Future<Map<String, dynamic>> _timed(Future<Map<String, dynamic>> Function() call) async {
    await _ensureLoaded();
    final sent = DateTime.now().millisecondsSinceEpoch;
    final r = await call();
    final received = DateTime.now().millisecondsSinceEpoch;
    final serverNow = r['server_now'] ?? (r['match'] is Map ? (r['match'] as Map)['server_now'] : null) ??
        (r['tournament'] is Map ? (r['tournament'] as Map)['server_now'] : null);
    if (serverNow is num) clock.sample(serverNow.toInt(), sent, received);
    return r;
  }

  Future<Map<String, dynamic>> read(String path, [Map<String, dynamic> p = const {}]) =>
      _timed(() => client.read(path, p));

  Future<Map<String, dynamic>> write(String path, [Map<String, dynamic> p = const {}]) =>
      _timed(() => client.write(path, p));

  Future<ServerConfig> config({bool refresh = false}) async {
    if (_config != null && !refresh) return _config!;
    final r = await read('/config');
    return _config = ServerConfig(r);
  }

  Future<String> _wsVersion() async => (await config()).websocketVersion;

  // ------------------------------------------------------------------ compte
  Future<Map<String, dynamic>> countries(String lang) => read('/auth/countries', {'lang': lang});

  /// Envoie le code par WhatsApp. Rend le numéro tel que le serveur l'a compris (`+225…`).
  Future<String> requestCode(String phone, {String? country}) async {
    final r = await write('/auth/request-code', {'identifier': phone, 'country': ?country});
    final canonical = r['identifier'];
    return canonical is String && canonical.isNotEmpty ? canonical : phone;
  }

  Future<OnlineMe> verifyCode(String phone, String code, {String? country}) async {
    final r = await write('/auth/verify-code', {
      'identifier': phone,
      'code': code,
      'country': ?country,
      'device': 'Quiz Biblique',
    });
    client.token = r['token'] as String;
    await _tokens.write(client.token);
    return OnlineMe(r);
  }

  Future<OnlineMe?> me() async {
    if (!await hasSession()) return null;
    return OnlineMe(await read('/me'));
  }

  Future<OnlineMe> register(String pseudo, String lang) async =>
      OnlineMe(await write('/player/register', {'pseudo': pseudo, 'lang': lang}));

  Future<OnlineMe> updateProfile({String? pseudo, String? lang}) async =>
      OnlineMe(await write('/player/update', {'pseudo': ?pseudo, 'lang': ?lang}));

  /// Inscrit ce téléphone aux notifications du compte connecté.
  Future<bool> registerDevice(String deviceToken, {String platform = 'android'}) async {
    if (!await hasSession()) return false;
    final r = await write('/devices', {'device_token': deviceToken, 'platform': platform, 'device': 'Quiz Biblique'});
    return r['registered'] == true;
  }

  /// [deviceToken] : ce téléphone ne reçoit plus les notifications du compte.
  Future<void> signOut({String? deviceToken}) async {
    await _ensureLoaded();
    try {
      if (client.token != null) await client.write('/auth/logout', {'device_token': ?deviceToken});
    } catch (_) {}
    client.token = null;
    await _tokens.write(null);
  }

  Future<void> deleteAccount() async {
    await write('/player/delete');
    client.token = null;
    await _tokens.write(null);
  }

  // ------------------------------------------------------------------ listes
  Future<({List<OpenMatch> matches, List<OpenTournament> tournaments})> openGames() async {
    final r = await read('/open');
    return (
      matches: [for (final m in (r['matches'] as List? ?? const []).whereType<Map>()) OpenMatch(m.cast())],
      tournaments: [for (final m in (r['tournaments'] as List? ?? const []).whereType<Map>()) OpenTournament(m.cast())],
    );
  }

  Future<List<Invitation>> invitations() async {
    final r = await read('/invitations');
    return [for (final m in (r['invitations'] as List? ?? const []).whereType<Map>()) Invitation(m.cast())];
  }

  Future<List<PastMatch>> history() async {
    final r = await read('/player/history');
    return [for (final m in (r['matches'] as List? ?? const []).whereType<Map>()) PastMatch(m.cast())];
  }

  Future<List<OpenTournament>> myTournaments() async {
    final r = await read('/tournament/mine');
    return [for (final m in (r['tournaments'] as List? ?? const []).whereType<Map>()) OpenTournament(m.cast())];
  }

  Future<List<({int id, String pseudo, bool busy})>> searchPlayers(String q) async {
    final r = await read('/player/search', {'q': q});
    return [
      for (final m in (r['players'] as List? ?? const []).whereType<Map>())
        (id: (m['id'] as num).toInt(), pseudo: '${m['pseudo']}', busy: m['busy'] == true),
    ];
  }

  Future<bool> report(int playerId, String reason) async {
    await write('/player/report', {'player_id': playerId, 'reason': reason});
    return true;
  }

  Future<({List<Passage> passages, int available})> checkPassages(List<String> codes, String lang) async {
    final r = await read('/passages/check', {'passages': codes, 'lang': lang});
    return (passages: Passage.list(r['passages']), available: (r['available'] as num? ?? 0).toInt());
  }

  /// Un code saisi, scanné ou reçu par lien : match (rejoint) ou tournoi (fiche).
  Future<({MatchEnvelope? match, TournamentEnvelope? tournament})> join(String code) async {
    final r = await write('/join', {'code': code});
    if (r['kind'] == 'tournament') return (match: null, tournament: TournamentEnvelope.parse(r));
    return (match: MatchEnvelope.parse(r), tournament: null);
  }

  // ------------------------------------------------------------------ match
  Future<MatchEnvelope> createMatch(Map<String, dynamic> values) async =>
      MatchEnvelope.parse(await write('/match/create', values));

  /// Rend null si l'état n'a pas changé depuis [version].
  Future<MatchEnvelope?> matchState(int matchId, {int? version, bool tick = false}) async {
    final r = await read(tick ? '/match/tick' : '/match/state', {'match_id': matchId, 'version': ?version});
    if (r['unchanged'] == true) return null;
    return MatchEnvelope.parse(r);
  }

  /// Écran de projection : sans compte, par le code du match.
  Future<MatchEnvelope> watch(String code) async => MatchEnvelope.parse(await read('/match/watch', {'code': code}));

  Future<MatchEnvelope> matchAction(String action, int matchId, [Map<String, dynamic> extra = const {}]) async =>
      MatchEnvelope.parse(await write('/match/$action', {'match_id': matchId, ...extra}));

  Future<void> leaveMatch(int matchId) => write('/match/leave', {'match_id': matchId});

  Future<List<QuestionState>> matchHistory(int matchId) async {
    final r = await read('/match/history', {'match_id': matchId});
    return [for (final m in (r['questions'] as List? ?? const []).whereType<Map>()) QuestionState(m.cast())];
  }

  /// Action d'équipe ; rend l'état du match ou du tournoi concerné.
  Future<Map<String, dynamic>> teamAction(String action, int teamId, [Map<String, dynamic> extra = const {}]) =>
      write('/team/$action', {'team_id': teamId, ...extra});

  // ------------------------------------------------------------------ tournoi
  Future<TournamentEnvelope> createTournament(Map<String, dynamic> values) async =>
      TournamentEnvelope.parse(await write('/tournament/create', values));

  Future<TournamentEnvelope> tournamentState(int id) async =>
      TournamentEnvelope.parse(await read('/tournament/state', {'tournament_id': id}));

  Future<TournamentEnvelope> tournamentAction(String action, int id, [Map<String, dynamic> extra = const {}]) async =>
      TournamentEnvelope.parse(await write('/tournament/$action', {'tournament_id': id, ...extra}));

  Future<TournamentEnvelope> duelReady(int duelId) async =>
      TournamentEnvelope.parse(await write('/duel/ready', {'duel_id': duelId}));
}
