import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api.dart';
import 'models.dart';
import 'online_providers.dart';
import 'realtime.dart';
import 'service.dart';

class TournamentView {
  const TournamentView({this.env, this.error, this.busy = false});

  final TournamentEnvelope? env;
  final Object? error;
  final bool busy;

  TournamentState? get tournament => env?.tournament;
  int? get myEntryId => env?.myEntryId;

  TournamentView copyWith({TournamentEnvelope? env, Object? error, bool? busy}) =>
      TournamentView(env: env ?? this.env, error: error, busy: busy ?? this.busy);
}

final tournamentControllerProvider =
    NotifierProvider.autoDispose.family<TournamentController, TournamentView, int>(TournamentController.new);

/// Suit un tournoi : temps réel + sondage de secours + échéances de forfait.
///
/// Les actions rendent `true` si le serveur les a acceptées ; un refus est
/// relancé en [ApiException] pour que l'écran l'affiche ([onlineError]).
class TournamentController extends Notifier<TournamentView> {
  TournamentController(this.tournamentId);

  final int tournamentId;

  static final seeds = <int, TournamentEnvelope>{};

  late OnlineService _service;
  StreamSubscription<RealtimeEvent>? _push;
  VoidCallback? _unsubscribe;
  String? _channel;
  Timer? _poll;
  AppLifecycleListener? _lifecycle;
  bool _disposed = false;

  @override
  TournamentView build() {
    _service = ref.read(onlineServiceProvider);
    _push = _service.hub.events
        .where((e) => e.type == 'bq_tournament' && e.payload['id'] == tournamentId)
        .listen((e) => _applyState(TournamentState(e.payload)));
    _service.hub.connected.addListener(_schedulePoll);
    _lifecycle = AppLifecycleListener(onResume: () {
      _service.hub.reconnectNow();
      unawaited(refresh());
    });
    ref.onDispose(() {
      _disposed = true;
      _push?.cancel();
      _unsubscribe?.call();
      _service.hub.connected.removeListener(_schedulePoll);
      _poll?.cancel();
      _lifecycle?.dispose();
    });
    final seed = seeds.remove(tournamentId);
    Future.microtask(() {
      if (seed != null) _apply(seed);
      unawaited(refresh());
    });
    return TournamentView(env: seed);
  }

  Future<void> refresh() async {
    if (_disposed) return;
    try {
      _apply(await _service.tournamentState(tournamentId));
    } on ApiException catch (e) {
      if (_disposed) return;
      if (state.env == null) state = state.copyWith(error: e);
      _schedulePoll();
    }
  }

  void _apply(TournamentEnvelope env) {
    if (_disposed) return;
    final current = state.env;
    if (current != null && env.tournament.version < current.tournament.version) return;
    if (env.channel.isNotEmpty && env.channel != _channel) {
      _unsubscribe?.call();
      _channel = env.channel;
      _unsubscribe = _service.hub.subscribe(env.channel);
    }
    state = state.copyWith(env: env);
    _schedulePoll();
  }

  void _applyState(TournamentState t) {
    final current = state.env;
    if (current == null || t.version <= current.tournament.version) return;
    // L'état diffusé ne dit pas « mon inscription » : on la recalcule d'après le profil.
    unawaited(refresh());
  }

  void _schedulePoll() {
    _poll?.cancel();
    final t = state.tournament;
    if (_disposed || (t != null && (t.state == 'finished' || t.state == 'cancelled'))) return;
    var ms = _service.hub.connected.value ? 20000 : 5000;
    // Échéance de forfait la plus proche : un sondage juste après, pour l'afficher à temps.
    for (final d in t?.duels ?? const <Duel>[]) {
      if (d.state == 'ready_wait' && d.deadline != null) {
        final wait = d.deadline! - _service.clock.now() + 1500;
        if (wait > 0 && wait < ms) ms = wait;
      }
    }
    _poll = Timer(Duration(milliseconds: ms), refresh);
  }

  /// Action sur le tournoi (`register`, `unregister`, `team/create`, `start`, `cancel`, `round-passages`).
  Future<bool> action(String name, [Map<String, dynamic> extra = const {}]) =>
      _run(() => _service.tournamentAction(name, tournamentId, extra));

  /// « Prêt » pour un duel ; rend l'identifiant du match du duel s'il a démarré.
  Future<bool> ready(int duelId) => _run(() => _service.duelReady(duelId));

  /// Action d'équipe (`invite`, `request`, `accept`, `decline`, `leave`, `rename`).
  Future<bool> team(String action, int teamId, [Map<String, dynamic> extra = const {}]) => _run(() async {
    final r = await _service.teamAction(action, teamId, extra);
    return r['tournament'] is Map ? TournamentEnvelope.parse(r) : null;
  });

  Future<bool> _run(Future<TournamentEnvelope?> Function() call) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    try {
      final env = await call();
      state = state.copyWith(busy: false);
      if (env != null) {
        _apply(env);
      } else {
        unawaited(refresh());
      }
      return true;
    } catch (e) {
      state = state.copyWith(busy: false);
      unawaited(refresh());
      rethrow;
    }
  }
}
