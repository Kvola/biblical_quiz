import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme.dart';
import '../../online/models.dart';
import '../../online/online_providers.dart';
import '../../online/realtime.dart';
import '../common.dart';
import 'online_common.dart';
import 'scan_screen.dart';
import 'tournament_screen.dart';

/// Lien court à ouvrir dans le navigateur d'une télévision ou d'un ordinateur :
/// le serveur renvoie vers l'écran de projection de la version web.
String projectionLink(WidgetRef ref, String code, String lang) {
  final server = ref.read(serverUrlProvider).replaceAll(RegExp(r'/+$'), '');
  return lang == 'en' ? '$server/quiz-biblique/screen/$code' : '$server/quiz-biblique/ecran/$code';
}

/// « Diffuser sur un écran » : ici (puis câble ou partage d'écran), ou sur un autre appareil par un lien.
Future<void> showProjectionSheet(BuildContext context, WidgetRef ref, String code) {
  final l = context.l10n;
  final link = projectionLink(ref, code, context.lang);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheet) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.projectionCast, style: Theme.of(sheet).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.fit_screen_outlined),
                title: Text(l.projectionHere),
                subtitle: Text(l.projectionHereHint),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(sheet).pop();
                  unawaited(ProjectionScreen.open(context, code: code));
                },
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tv_outlined),
                        const SizedBox(width: 16),
                        Expanded(child: Text(l.projectionOther, style: Theme.of(sheet).textTheme.titleMedium)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l.projectionOtherHint),
                    const SizedBox(height: 6),
                    SelectableText(link, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.copy, size: 18),
                          label: Text(l.copy),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: link));
                            if (sheet.mounted) sheet.toast(l.copied);
                          },
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.share, size: 18),
                          label: Text(l.share),
                          onPressed: () => SharePlus.instance.share(ShareParams(text: link)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(l.projectionOtherApp(code), style: Theme.of(sheet).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Écran de projection : un match ou un tournoi en grand (vidéoprojecteur, télévision), sans compte.
///
/// Lecture seule. Rien de secret n'y figure : la bonne réponse n'apparaît
/// qu'une fois la question close, comme pour les joueurs.
class ProjectionScreen extends ConsumerStatefulWidget {
  const ProjectionScreen({super.key, this.code});

  final String? code;

  static Future<void> open(BuildContext context, {String? code}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProjectionScreen(code: code)));

  @override
  ConsumerState<ProjectionScreen> createState() => _ProjectionScreenState();
}

class _ProjectionScreenState extends ConsumerState<ProjectionScreen> {
  final _input = TextEditingController();
  String? _code;
  ({MatchEnvelope? match, TournamentEnvelope? tournament})? _found;
  Object? _error;
  int _attempt = 0;

  @override
  void initState() {
    super.initState();
    if (widget.code != null) _start(widget.code!);
  }

  @override
  void dispose() {
    _input.dispose();
    unawaited(WakelockPlus.disable().catchError((_) {}));
    super.dispose();
  }

  void _start(String raw) {
    final code = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (code.isEmpty) return;
    setState(() {
      _code = code;
      _found = null;
      _error = null;
    });
    unawaited(WakelockPlus.enable().catchError((_) {}));
    unawaited(_resolve(code));
  }

  /// Match ou tournoi ? Le serveur le dit ; l'écran suit ensuite l'un ou l'autre.
  Future<void> _resolve(String code) async {
    final attempt = ++_attempt;
    try {
      final found = await ref.read(onlineServiceProvider).watchCode(code);
      if (mounted && attempt == _attempt) setState(() => _found = found);
    } catch (e) {
      if (mounted && attempt == _attempt) setState(() => _error = e);
    }
  }

  void _reset() => setState(() {
    _attempt++;
    _code = null;
    _found = null;
    _error = null;
  });

  @override
  Widget build(BuildContext context) {
    final found = _found;
    if (_code != null && found?.tournament != null) {
      return _TournamentProjection(code: _code!, seed: found!.tournament!);
    }
    if (_code != null && found?.match != null) {
      return _MatchProjection(code: _code!, seed: found!.match!);
    }
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.onlineProjection)),
      body: SafeArea(
        top: false,
        child: _code == null
            ? _codeForm(context)
            : Center(
                child: _error == null
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(onlineError(context, _error!), textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                TextButton(onPressed: _reset, child: Text(l.resultBack)),
                                FilledButton.tonal(onPressed: () => _start(_code!), child: Text(l.retry)),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _codeForm(BuildContext context) {
    final l = context.l10n;
    return Center(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.onlineProjectionHint, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                TextField(
                  controller: _input,
                  autofocus: true,
                  maxLength: 6,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
                  style: const TextStyle(fontSize: 28, letterSpacing: 6, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(labelText: l.projectionCodePrompt),
                  onSubmitted: _start,
                ),
                FilledButton(onPressed: () => _start(_input.text), child: Text(l.projectionShow)),
                const SizedBox(height: 8),
                // Le QR code d'un match ou d'un tournoi mène à la même chose.
                OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: Text(l.scanQr),
                  onPressed: () async {
                    final scan = await ref.read(gameScannerProvider)(context);
                    final code = scan?.watch ?? scan?.join;
                    if (code != null && mounted) _start(code);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================== match

/// Un match suivi en direct (canal temps réel, et relève périodique en secours).
class _MatchProjection extends ConsumerStatefulWidget {
  const _MatchProjection({super.key, required this.code, this.seed, this.embedded = false});

  final String code;
  final MatchEnvelope? seed;

  /// Dans l'écran d'un tournoi : pas d'en-tête propre.
  final bool embedded;

  @override
  ConsumerState<_MatchProjection> createState() => _MatchProjectionState();
}

class _MatchProjectionState extends ConsumerState<_MatchProjection> {
  MatchState? _match;
  Object? _error;
  Timer? _poll;
  StreamSubscription<RealtimeEvent>? _push;
  VoidCallback? _unsubscribe;

  @override
  void initState() {
    super.initState();
    final seed = widget.seed;
    if (seed != null) {
      _match = seed.match;
      _listen(seed);
      _schedule();
    } else {
      unawaited(_load());
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    _push?.cancel();
    _unsubscribe?.call();
    super.dispose();
  }

  void _listen(MatchEnvelope env) {
    if (_unsubscribe != null || env.channel.isEmpty) return;
    final hub = ref.read(onlineServiceProvider).hub;
    _unsubscribe = hub.subscribe(env.channel);
    _push = hub.events
        .where((e) => e.type == 'bq_match' && e.payload['id'] == env.match.id)
        .listen((e) => _apply(MatchState(e.payload)));
  }

  Future<void> _load() async {
    try {
      final env = await ref.read(onlineServiceProvider).watch(widget.code);
      if (!mounted) return;
      _apply(env.match);
      _listen(env);
    } catch (e) {
      if (mounted && _match == null) setState(() => _error = e);
    }
    _schedule();
  }

  void _schedule() {
    _poll?.cancel();
    if (!mounted) return;
    final m = _match;
    if (m != null && (m.state == 'finished' || m.state == 'cancelled')) return;
    final live = ref.read(onlineServiceProvider).hub.connected.value;
    _poll = Timer(Duration(milliseconds: live ? 6000 : (m?.state == 'running' ? 1500 : 3000)), _load);
  }

  void _apply(MatchState m) {
    if (_match != null && m.version < _match!.version) return;
    setState(() {
      _match = m;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final m = _match;
    final Widget body = m == null
        ? Center(
            child: _error == null
                ? const CircularProgressIndicator()
                : Text(onlineError(context, _error!), textAlign: TextAlign.center),
          )
        : _BigView(match: m, clock: ref.watch(onlineServiceProvider).clock);
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(m == null ? context.l10n.onlineProjection : m.passagesLabel)),
      body: SafeArea(top: false, child: body),
    );
  }
}

class _BigView extends ConsumerWidget {
  const _BigView({required this.match, required this.clock});

  final MatchState match;
  final ServerClock clock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final m = match;
    final q = m.question;
    Widget scores() => Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        if (m.isTeam)
          for (final t in m.teams) _BigChip('${t.name}  ${t.score}', highlight: false)
        else
          for (final p in [...m.active]..sort((a, b) => b.score.compareTo(a.score)))
            _BigChip('${p.pseudo}  ${p.score}', highlight: p.id == q?.handParticipantId),
      ],
    );
    if (m.state == 'lobby') {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(l.projectionWaiting(m.code), style: text.headlineMedium, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              _Qr(data: inviteLink(ref, m.code, context.lang)),
              const SizedBox(height: 16),
              Text(m.code, style: text.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 8)),
              const SizedBox(height: 16),
              scores(),
            ],
          ),
        ),
      );
    }
    if (m.state == 'finished' || m.state == 'cancelled') {
      final winner = m.participant(m.result?.winnerParticipantId)?.pseudo ?? m.team(m.result?.winnerTeamId)?.name;
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 96, color: QuizColors.gold),
              Text(
                m.state == 'cancelled' ? l.lobbyCancelled : (winner == null ? l.resultDraw : l.resultWinner(winner)),
                style: text.displaySmall?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              scores(),
            ],
          ),
        ),
      );
    }
    if (m.phase == 'countdown' || q == null) {
      return Center(
        child: ServerCountdown(
          clock: clock,
          deadline: m.phaseUntil,
          builder: (c, ms) => Text('${(ms / 1000).ceil()}', style: text.displayLarge?.copyWith(fontSize: 120)),
        ),
      );
    }
    final holder = m.participant(q.handParticipantId);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(q.tiebreak ? l.playTiebreak : l.playQuestion(q.index, q.total), style: text.titleLarge),
            ),
            ServerCountdown(
              clock: clock,
              deadline: m.phase == 'hand' ? q.handDeadline : q.deadline,
              builder: (c, ms) => Text(
                m.phase == 'reveal' ? '' : '${(ms / 1000).ceil()} s',
                style: text.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: m.phase == 'hand' ? QuizColors.gold : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(q.prompt, style: text.headlineSmall?.copyWith(height: 1.35)),
        const SizedBox(height: 16),
        for (var i = 0; i < q.options.length; i++)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: m.phase == 'reveal' && i == q.answer ? context.palette.successContainer : null,
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 2),
            ),
            child: Text('${String.fromCharCode(65 + i)}.  ${q.options[i]}', style: text.titleLarge),
          ),
        const SizedBox(height: 12),
        if (m.phase == 'hand' && holder != null)
          Text(
            l.playHandOf(holder.pseudo),
            style: text.headlineSmall?.copyWith(color: QuizColors.gold),
            textAlign: TextAlign.center,
          ),
        if (m.phase == 'reveal') ...[
          Text(
            m.participant(q.winnerParticipantId) != null
                ? l.playWonBy(m.participant(q.winnerParticipantId)!.pseudo)
                : l.playNobody,
            style: text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (q.explain.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(q.explain, style: text.titleMedium),
            ),
        ],
        const SizedBox(height: 24),
        scores(),
      ],
    );
  }
}

// ====================================================================== tournoi

/// Un tournoi en grand : inscriptions (QR code), tableau, et le duel en cours
/// affiché de lui-même quand il est seul ; sinon, on touche celui à montrer.
class _TournamentProjection extends ConsumerStatefulWidget {
  const _TournamentProjection({required this.code, required this.seed});

  final String code;
  final TournamentEnvelope seed;

  @override
  ConsumerState<_TournamentProjection> createState() => _TournamentProjectionState();
}

/// Temps pendant lequel le résultat d'un duel reste affiché avant le retour au tableau.
const _resultLinger = Duration(seconds: 12);

class _TournamentProjectionState extends ConsumerState<_TournamentProjection> {
  late TournamentState _t = widget.seed.tournament;
  Timer? _poll;
  Timer? _linger;
  StreamSubscription<RealtimeEvent>? _push;
  VoidCallback? _unsubscribe;

  /// Code du duel affiché en grand ; null : le tableau.
  String? _followed;

  /// Tableau choisi à la main : pas de bascule automatique tant que les duels en cours ne changent pas.
  bool _pinnedBracket = false;
  Set<String> _lastLive = const {};

  @override
  void initState() {
    super.initState();
    final env = widget.seed;
    if (env.channel.isNotEmpty) {
      final hub = ref.read(onlineServiceProvider).hub;
      _unsubscribe = hub.subscribe(env.channel);
      _push = hub.events
          .where((e) => e.type == 'bq_tournament' && e.payload['id'] == env.tournament.id)
          .listen((e) => _apply(TournamentState(e.payload)));
    }
    _follow(_t);
    _schedule();
  }

  @override
  void dispose() {
    _poll?.cancel();
    _linger?.cancel();
    _push?.cancel();
    _unsubscribe?.call();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final found = await ref.read(onlineServiceProvider).watchCode(widget.code);
      final t = found.tournament?.tournament;
      if (t != null && mounted) _apply(t);
    } catch (_) {
      // Coupure passagère : l'écran garde le dernier état et réessaie.
    }
    _schedule();
  }

  void _schedule() {
    _poll?.cancel();
    if (!mounted || _t.state == 'finished' || _t.state == 'cancelled') return;
    final live = ref.read(onlineServiceProvider).hub.connected.value;
    _poll = Timer(Duration(seconds: live ? 15 : 4), _load);
  }

  void _apply(TournamentState t) {
    if (t.version < _t.version) return;
    setState(() {
      _t = t;
      _follow(t);
    });
    if (t.state == 'finished' || t.state == 'cancelled') _poll?.cancel();
  }

  static List<Duel> _liveDuels(TournamentState t) => [
    for (final d in t.duels)
      if (d.state == 'playing' && (d.matchCode ?? '').isNotEmpty) d,
  ];

  /// Choisit ce qui s'affiche (appelé à chaque nouvel état du tournoi).
  void _follow(TournamentState t) {
    final live = _liveDuels(t);
    final codes = {for (final d in live) d.matchCode!};
    if (!setEquals(codes, _lastLive)) _pinnedBracket = false;
    _lastLive = codes;
    final followed = _followed;
    if (followed != null && !codes.contains(followed)) {
      // Duel terminé : son résultat reste un moment à l'écran.
      _linger ??= Timer(_resultLinger, () {
        if (!mounted) return;
        setState(() {
          _linger = null;
          if (_followed == followed) _followed = null;
          _follow(_t);
        });
      });
      return;
    }
    if (followed == null && !_pinnedBracket && live.length == 1) _followed = live.single.matchCode;
  }

  void _show(Duel d) => setState(() {
    _linger?.cancel();
    _linger = null;
    _followed = d.matchCode;
  });

  void _showBracket() => setState(() {
    _linger?.cancel();
    _linger = null;
    _followed = null;
    _pinnedBracket = true;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = _t;
    final followed = _followed;
    final duel = followed == null ? null : t.duels.where((d) => d.matchCode == followed).firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.name, overflow: TextOverflow.ellipsis),
        actions: [
          if (followed != null)
            TextButton.icon(
              icon: const Icon(Icons.account_tree_outlined),
              label: Text(l.tourBracket),
              onPressed: _showBracket,
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: followed == null
            ? _overview(context, t)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (duel != null)
                    Material(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Text(
                          l.projectionFollowing(t.name, tournamentRoundTitle(l, duel.round, _rounds(t))),
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  Expanded(
                    child: _MatchProjection(key: ValueKey(followed), code: followed, embedded: true),
                  ),
                ],
              ),
      ),
    );
  }

  static int _rounds(TournamentState t) {
    var rounds = t.rounds;
    for (final d in t.duels) {
      if (d.round > rounds) rounds = d.round;
    }
    return rounds;
  }

  Widget _overview(BuildContext context, TournamentState t) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final live = _liveDuels(t);
    final children = <Widget>[
      if (t.passagesLabel.isNotEmpty) Text(t.passagesLabel, style: text.titleMedium, textAlign: TextAlign.center),
      const SizedBox(height: 16),
    ];
    switch (t.state) {
      case 'registration':
        final join = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Qr(data: inviteLink(ref, t.code, context.lang)),
            const SizedBox(height: 8),
            Text(l.projectionTourScan, style: text.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              t.code,
              textAlign: TextAlign.center,
              style: text.displayMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 8),
            ),
          ],
        );
        final entrants = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.isTeam ? l.tourTeams(t.entries.length, t.maxEntries) : l.tourPlayers(t.entries.length, t.maxEntries),
              style: text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [for (final e in t.entries) _BigChip(e.name, highlight: false)],
            ),
          ],
        );
        children.addAll([
          Text(l.projectionTourOpen(t.code), style: text.headlineMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          // Écran large (télévision, vidéoprojecteur) : le QR code et les inscrits côte à côte, sans défiler.
          if (MediaQuery.sizeOf(context).width >= 700)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                join,
                const SizedBox(width: 32),
                Expanded(child: entrants),
              ],
            )
          else ...[
            Center(child: join),
            const SizedBox(height: 24),
            entrants,
          ],
        ]);
      case 'cancelled':
        children.add(Text(l.tourCancelled, style: text.headlineMedium, textAlign: TextAlign.center));
      case 'finished':
        final winner = t.entry(t.winnerEntryId);
        children.addAll([
          const Icon(Icons.emoji_events, size: 96, color: QuizColors.gold),
          Text(
            winner == null ? l.tourNoWinner : l.tourWinner(winner.name),
            style: text.displaySmall?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
        ]);
      default:
        children.add(
          Text(
            live.isEmpty ? l.projectionNoLive : l.projectionLiveDuels,
            style: text.titleLarge,
            textAlign: TextAlign.center,
          ),
        );
        for (final d in live) {
          children.add(
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Icon(Icons.circle, size: 14, color: Theme.of(context).colorScheme.error),
                title: Text(
                  l.tourDuelSemantics(t.entry(d.entryA)?.name ?? '—', t.entry(d.entryB)?.name ?? '—'),
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(tournamentRoundTitle(l, d.round, _rounds(t))),
                trailing: const Icon(Icons.fullscreen),
                onTap: () => _show(d),
              ),
            ),
          );
        }
    }
    if (t.duels.isNotEmpty) {
      children.addAll([SectionTitle(l.tourBracket), TournamentBracket(state: t, onLiveDuelTap: _show)]);
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(padding: const EdgeInsets.all(24), children: children),
      ),
    );
  }
}

// ====================================================================== commun

class _Qr extends StatelessWidget {
  const _Qr({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) => Container(
    // Noir sur blanc, même en thème sombre : lisible par tous les appareils photo.
    color: Colors.white,
    padding: const EdgeInsets.all(12),
    child: QrImageView(data: data, size: 240, backgroundColor: Colors.white),
  );
}

class _BigChip extends StatelessWidget {
  const _BigChip(this.label, {required this.highlight});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: highlight ? QuizColors.gold : Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, color: highlight ? QuizColors.ink : null),
    ),
  );
}
