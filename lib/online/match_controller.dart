import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api.dart';
import 'models.dart';
import 'online_providers.dart';
import 'realtime.dart';
import 'service.dart';

/// Ce que l'écran d'un match affiche.
class MatchView {
  const MatchView({this.env, this.error, this.busy = false, this.refusal, this.lastAnswerCorrect});

  final MatchEnvelope? env;

  /// Échec du chargement initial (réseau…).
  final Object? error;

  /// Une action est en cours (appui, réponse, lancement…).
  final bool busy;

  /// Dernier refus du serveur à montrer brièvement (« Bruno a pris la main avant vous »).
  final ApiException? refusal;

  final bool? lastAnswerCorrect;

  MatchState? get match => env?.match;
  int? get me => env?.me;

  MatchView copyWith({MatchEnvelope? env, Object? error, bool? busy, ApiException? refusal, bool clearRefusal = false,
      bool? lastAnswerCorrect}) =>
      MatchView(
        env: env ?? this.env,
        error: error,
        busy: busy ?? this.busy,
        refusal: clearRefusal ? null : (refusal ?? this.refusal),
        lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      );
}

final matchControllerProvider =
    NotifierProvider.autoDispose.family<MatchController, MatchView, int>(MatchController.new);

/// Suit un match : temps réel (WebSocket) + sondage de secours + « tick » à chaque échéance.
///
/// Le serveur fait foi. L'application ne fait qu'afficher son état, compter
/// à rebours d'après SON horloge ([ServerClock]), et le prévenir quand une
/// échéance tombe (le premier téléphone qui le fait fait avancer le match).
class MatchController extends Notifier<MatchView> {
  MatchController(this.matchId);

  final int matchId;

  /// État déjà connu avant d'ouvrir l'écran (réponse de création / de jonction).
  static final seeds = <int, MatchEnvelope>{};

  late OnlineService _service;
  StreamSubscription<RealtimeEvent>? _push;
  VoidCallback? _unsubscribe;
  String? _channel;
  Timer? _poll;
  Timer? _tick;
  AppLifecycleListener? _lifecycle;
  bool _disposed = false;
  int _tickMissed = 0;

  @override
  MatchView build() {
    _service = ref.read(onlineServiceProvider);
    _push = _service.hub.events
        .where((e) => e.type == 'bq_match' && e.payload['id'] == matchId)
        .listen((e) => _applyState(MatchState(e.payload), fromPush: true));
    _service.hub.connected.addListener(_schedulePoll);
    _lifecycle = AppLifecycleListener(onResume: () {
      _service.hub.reconnectNow();
      unawaited(refresh());
    });
    ref.onDispose(_dispose);
    final seed = seeds.remove(matchId);
    Future.microtask(() {
      if (seed != null) _apply(seed);
      unawaited(refresh());
    });
    return MatchView(env: seed);
  }

  void _dispose() {
    _disposed = true;
    _push?.cancel();
    _unsubscribe?.call();
    _service.hub.connected.removeListener(_schedulePoll);
    _poll?.cancel();
    _tick?.cancel();
    _lifecycle?.dispose();
  }

  // ------------------------------------------------------------------ état
  Future<void> refresh({bool tick = false}) async {
    if (_disposed) return;
    try {
      final current = state.env;
      final env = await _service.matchState(matchId, version: tick ? null : current?.match.version, tick: tick);
      if (env != null) {
        _apply(env);
      } else {
        _schedule();
      }
    } on ApiException catch (e) {
      if (_disposed) return;
      if (state.env == null) state = state.copyWith(error: e);
      _schedule();
    }
  }

  void _apply(MatchEnvelope env) {
    if (_disposed) return;
    final current = state.env;
    if (current != null && env.match.version < current.match.version) return;
    if (env.channel.isNotEmpty && env.channel != _channel) {
      _unsubscribe?.call();
      _channel = env.channel;
      _unsubscribe = _service.hub.subscribe(env.channel);
    }
    state = state.copyWith(env: env);
    _schedule();
  }

  void _applyState(MatchState match, {bool fromPush = false}) {
    final current = state.env;
    if (current == null || match.version <= current.match.version) return;
    if (fromPush) _service.clock.sampleOneWay(match.serverNow);
    _apply(MatchEnvelope(match, current.me, current.channel));
  }

  void _schedule() {
    _schedulePoll();
    _scheduleTick();
  }

  /// Sondage de secours : lent quand le temps réel fonctionne, rapide sinon.
  void _schedulePoll() {
    _poll?.cancel();
    if (_disposed) return;
    final m = state.match;
    if (m != null && (m.state == 'finished' || m.state == 'cancelled')) return;
    final running = m?.state == 'running';
    final live = _service.hub.connected.value;
    final ms = live ? (running ? 8000 : 15000) : (running ? 1500 : 3000);
    _poll = Timer(Duration(milliseconds: ms), refresh);
  }

  /// Prévient le serveur juste après l'échéance en cours (fin de question, de main, d'affichage).
  void _scheduleTick() {
    _tick?.cancel();
    final m = state.match;
    if (_disposed || m == null || m.state != 'running') return;
    final q = m.question;
    final int? deadline = switch (m.phase) {
      'countdown' || 'reveal' => m.phaseUntil,
      'open' => q?.deadline == null ? null : q!.deadline! + 350,
      'hand' => q?.handDeadline == null ? null : q!.handDeadline! + 900,
      _ => null,
    };
    if (deadline == null) return;
    var delay = deadline - _service.clock.now();
    if (delay < 0) {
      // Échéance passée sans changement : on insiste, sans marteler le serveur.
      _tickMissed++;
      delay = min(5000, 400 * _tickMissed);
    } else {
      _tickMissed = 0;
    }
    // Un léger décalage aléatoire : tous les téléphones ne frappent pas à la même milliseconde.
    _tick = Timer(Duration(milliseconds: delay + 30 + Random().nextInt(250)), () => refresh(tick: true));
  }

  // ------------------------------------------------------------------ actions
  Future<bool> _act(Future<MatchEnvelope?> Function() call) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, clearRefusal: true);
    try {
      final env = await call();
      state = state.copyWith(busy: false);
      if (env != null) _apply(env);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(busy: false, refusal: e);
      unawaited(refresh());
      return false;
    }
  }

  Future<bool> buzz() => _act(() => _service.matchAction('buzz', matchId));

  Future<bool> answer(int choice) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, clearRefusal: true);
    try {
      final r = await _service.write('/match/answer', {'match_id': matchId, 'choice': choice});
      state = state.copyWith(busy: false, lastAnswerCorrect: r['correct'] == true);
      _apply(MatchEnvelope.parse(r));
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(busy: false, refusal: e);
      unawaited(refresh());
      return false;
    }
  }

  Future<bool> start() => _act(() => _service.matchAction('start', matchId));

  Future<bool> kick(int participantId) => _act(() => _service.matchAction('kick', matchId, {'participant_id': participantId}));

  Future<bool> createTeam(String name) => _act(() => _service.matchAction('team/create', matchId, {'name': name}));

  Future<bool> updateSettings(Map<String, dynamic> values) => _act(() => _service.matchAction('settings', matchId, values));

  Future<bool> team(String action, int teamId, [Map<String, dynamic> extra = const {}]) => _act(() async {
    final r = await _service.teamAction(action, teamId, extra);
    return r['match'] is Map ? MatchEnvelope.parse(r) : null;
  });

  Future<bool> leave() async {
    try {
      await _service.leaveMatch(matchId);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(refusal: e);
      return false;
    }
  }

  void clearRefusal() => state = state.copyWith(clearRefusal: true);
}
