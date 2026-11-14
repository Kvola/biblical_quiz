import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme.dart';
import '../../online/models.dart';
import '../../online/online_providers.dart';
import '../../online/realtime.dart';
import '../common.dart';
import 'online_common.dart';
import 'scan_screen.dart';

/// Écran de projection : un match en grand (vidéoprojecteur, télévision), sans compte.
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
  MatchState? _match;
  Object? _error;
  Timer? _poll;
  StreamSubscription<RealtimeEvent>? _push;
  VoidCallback? _unsubscribe;

  @override
  void initState() {
    super.initState();
    if (widget.code != null) _start(widget.code!);
  }

  @override
  void dispose() {
    _stop();
    _input.dispose();
    unawaited(WakelockPlus.disable().catchError((_) {}));
    super.dispose();
  }

  void _stop() {
    _poll?.cancel();
    _push?.cancel();
    _unsubscribe?.call();
    _unsubscribe = null;
  }

  void _start(String code) {
    _stop();
    setState(() {
      _code = code.trim().toUpperCase();
      _match = null;
      _error = null;
    });
    unawaited(WakelockPlus.enable().catchError((_) {}));
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(onlineServiceProvider);
    try {
      final env = await service.watch(_code!);
      if (!mounted) return;
      _apply(env.match);
      if (_unsubscribe == null && env.channel.isNotEmpty) {
        _unsubscribe = service.hub.subscribe(env.channel);
        _push = service.hub.events
            .where((e) => e.type == 'bq_match' && e.payload['id'] == env.match.id)
            .listen((e) => _apply(MatchState(e.payload)));
      }
    } catch (e) {
      if (mounted && _match == null) setState(() => _error = e);
    }
    _poll?.cancel();
    if (!mounted) return;
    final live = service.hub.connected.value;
    final m = _match;
    if (m != null && (m.state == 'finished' || m.state == 'cancelled')) return;
    _poll = Timer(Duration(milliseconds: live ? 6000 : (m?.state == 'running' ? 1500 : 3000)), _load);
  }

  void _apply(MatchState m) {
    if (_match != null && m.version < _match!.version) return;
    setState(() => _match = m);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = _match;
    return Scaffold(
      appBar: AppBar(title: Text(m == null ? l.onlineProjection : m.passagesLabel)),
      body: SafeArea(
        top: false,
        child: _code == null
            ? Center(
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
                        // Le QR code de la salle d'attente mène au même match.
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
              )
            : m == null
            ? Center(
                child: _error == null
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(onlineError(context, _error!)),
                          TextButton(onPressed: () => setState(() => _code = null), child: Text(l.resultBack)),
                        ],
                      ),
              )
            : _BigView(match: m, clock: ref.watch(onlineServiceProvider).clock),
      ),
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
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: QrImageView(data: inviteLink(ref, m.code, context.lang), size: 240, backgroundColor: Colors.white),
              ),
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
          Text(l.playHandOf(holder.pseudo), style: text.headlineSmall?.copyWith(color: QuizColors.gold),
              textAlign: TextAlign.center),
        if (m.phase == 'reveal') ...[
          Text(
            m.participant(q.winnerParticipantId) != null
                ? l.playWonBy(m.participant(q.winnerParticipantId)!.pseudo)
                : l.playNobody,
            style: text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (q.explain.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(q.explain, style: text.titleMedium)),
        ],
        const SizedBox(height: 24),
        scores(),
      ],
    );
  }
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
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: highlight ? QuizColors.ink : null,
      ),
    ),
  );
}
