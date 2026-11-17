import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/theme.dart';
import '../../core/verse_ref.dart';
import '../../online/match_controller.dart';
import '../../online/models.dart';
import '../../online/online_providers.dart';
import '../../online/realtime.dart';
import '../common.dart';
import '../widgets/verse_sheet.dart';
import 'online_common.dart';
import 'projection_screen.dart';

/// Un match : salle d'attente, puis les questions à la main, puis les résultats.
///
/// Quitter l'écran n'abandonne pas le match (on le retrouve par « Reprendre ») ;
/// seul le bouton « Quitter » le fait.
class MatchScreen extends ConsumerStatefulWidget {
  const MatchScreen({super.key, required this.matchId});

  final int matchId;

  static Future<void> open(BuildContext context, int matchId, {MatchEnvelope? seed}) {
    if (seed != null) MatchController.seeds[matchId] = seed;
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchScreen(matchId: matchId)));
  }

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  bool _wakelock = false;

  @override
  void dispose() {
    if (_wakelock) unawaited(WakelockPlus.disable().catchError((_) {}));
    super.dispose();
  }

  /// Écran allumé pendant un match en cours (on lit, on attend la question suivante).
  void _keepAwake(bool on) {
    if (on == _wakelock) return;
    _wakelock = on;
    unawaited(WakelockPlus.toggle(enable: on).catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = matchControllerProvider(widget.matchId);
    final view = ref.watch(provider);
    ref.listen(provider.select((v) => v.refusal), (_, refusal) {
      if (refusal != null) {
        context.toast(onlineError(context, refusal));
        ref.read(provider.notifier).clearRefusal();
      }
    });
    // Fin du match : le profil (partie en cours, statistiques) change côté serveur.
    ref.listen(provider.select((v) => v.match?.state), (before, now) {
      // Le jeu commence : rien ne doit couvrir le bouton « Je réponds ! ».
      if (now == 'running' && before != 'running') ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (before != null && before != now && (now == 'finished' || now == 'cancelled')) {
        unawaited(ref.read(onlineMeProvider.notifier).refresh());
      }
    });
    final match = view.match;
    _keepAwake(match?.state == 'running');
    final myPlayerId = ref.watch(onlineMeProvider).value?.player?.id;
    final me = match?.participant(view.me);
    final canLeave = me != null && !me.left && (match!.state == 'lobby' || match.state == 'running');
    return Scaffold(
      appBar: AppBar(
        title: Text(switch (match?.state) {
          'lobby' => l.lobbyTitle,
          'finished' => l.resultTitle,
          _ => match?.passagesLabel ?? l.onlineTitle,
        }),
        actions: [
          if (match != null && (match.state == 'lobby' || match.state == 'running'))
            IconButton(
              tooltip: l.projectionCast,
              icon: const Icon(Icons.cast),
              onPressed: () => showProjectionSheet(context, ref, match.code),
            ),
          if (canLeave)
            TextButton(
              onPressed: () async {
                final ok = await confirmDialog(
                  context,
                  l.lobbyLeaveConfirm,
                  body: match.state == 'running' ? l.lobbyLeaveRunning : null,
                  action: l.lobbyLeave,
                );
                if (!ok || !context.mounted) return;
                if (await ref.read(provider.notifier).leave()) {
                  unawaited(ref.read(onlineMeProvider.notifier).refresh());
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
              child: Text(l.lobbyLeave),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: match == null
            ? (view.error != null
                  ? _ErrorBody(message: onlineError(context, view.error!), onRetry: ref.read(provider.notifier).refresh)
                  : const Center(child: CircularProgressIndicator()))
            : switch (match.state) {
                'lobby' => _LobbyView(view: view, myPlayerId: myPlayerId, matchId: widget.matchId),
                'running' => _PlayView(view: view, matchId: widget.matchId),
                'finished' => _ResultView(view: view, myPlayerId: myPlayerId, matchId: widget.matchId),
                _ => _ErrorBody(message: l.lobbyCancelled),
              },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ],
      ),
    ),
  );
}

/// Bandeau discret quand le temps réel est coupé (le sondage prend le relais).
class _RealtimeBanner extends ConsumerWidget {
  const _RealtimeBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hub = ref.watch(onlineServiceProvider).hub;
    return ValueListenableBuilder<bool>(
      valueListenable: hub.connected,
      builder: (context, connected, _) => connected
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(context.l10n.onlineRealtimeOff, style: Theme.of(context).textTheme.bodySmall),
            ),
    );
  }
}

// ================================================================== salle d'attente

class _LobbyView extends ConsumerWidget {
  const _LobbyView({required this.view, required this.myPlayerId, required this.matchId});

  final MatchView view;
  final int? myPlayerId;
  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final m = view.match!;
    final controller = ref.read(matchControllerProvider(matchId).notifier);
    final isCreator = m.creatorId == myPlayerId && m.kind == 'free';
    final creator = m.participants.where((p) => p.playerId == m.creatorId).firstOrNull;
    final me = m.participant(view.me);
    final config = ref.watch(serverConfigProvider).value;
    final canStart = m.isTeam
        ? m.teams.length == 2 &&
              m.teams.every((t) => t.members.length >= (config?.teamMinSize ?? 2))
        : m.active.length >= 2;
    Future<void> teamAction(TeamState team, String action, {int? playerId}) => handleTeamAction(
      context,
      team,
      action,
      playerId,
      (a, extra) => controller.team(a, team.id, extra),
    );
    final unassigned = m.active.where((p) => p.teamId == null).toList();
    return Column(
      children: [
        const _RealtimeBanner(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                if (m.kind == 'free')
                  CodeShareCard(code: m.code, shareText: l.lobbyShareText(m.passagesLabel, m.code, '').trim()),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(m.passagesLabel),
                    subtitle: Text(
                      '${m.isTeam ? l.onlineModeTeam : l.onlineModeSolo} · '
                      '${l.lobbySettings(m.questionCount, m.questionSeconds, '${m.handSeconds}')}',
                    ),
                  ),
                ),
                if (!m.isTeam) ...[
                  SectionTitle('${l.lobbyPlayers} (${m.active.length}/${m.maxPlayers})'),
                  for (final p in m.active)
                    _ParticipantTile(
                      p: p,
                      isCreator: p.playerId == m.creatorId,
                      isMe: p.id == view.me,
                      canKick: isCreator && p.playerId != myPlayerId,
                      onKick: () => controller.kick(p.id),
                    ),
                ] else ...[
                  SectionTitle(l.onlineModeTeam),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      l.teamSizeHint(config?.teamMinSize ?? 2, config?.teamMaxSize ?? 5),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  for (final team in m.teams)
                    TeamPanel(
                      team: team,
                      myPlayerId: myPlayerId,
                      maxSize: config?.teamMaxSize,
                      canAsk: me != null && me.teamId == null,
                      highlight: me?.teamId == team.id,
                      onAction: (a, {playerId}) => teamAction(team, a, playerId: playerId),
                    ),
                  if (m.teams.length < 2 && me != null && me.teamId == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.group_add_outlined),
                        label: Text(l.teamCreate),
                        onPressed: () async {
                          final name = await askName(context, l.teamCreate, label: l.teamName);
                          if (name != null) await controller.createTeam(name);
                        },
                      ),
                    ),
                  if (unassigned.isNotEmpty) ...[
                    SectionTitle(l.lobbyNoTeam),
                    Text(l.lobbyNoTeamHint, style: Theme.of(context).textTheme.bodySmall),
                    for (final p in unassigned)
                      _ParticipantTile(
                        p: p,
                        isCreator: p.playerId == m.creatorId,
                        isMe: p.id == view.me,
                        canKick: isCreator && p.playerId != myPlayerId,
                        onKick: () => controller.kick(p.id),
                        // Le capitaine sans place prise peut inviter ce joueur d'un geste.
                        trailing: _inviteButton(context, m, myPlayerId, p, controller),
                      ),
                  ],
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: isCreator
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!canStart && !m.isTeam)
                      Text(l.lobbyNeedPlayers, style: Theme.of(context).textTheme.bodySmall),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l.lobbyStart),
                        onPressed: canStart && !view.busy ? controller.start : null,
                      ),
                    ),
                  ],
                )
              : Text(
                  m.kind == 'duel' ? l.playCountdown : l.lobbyWaitCreator(creator?.pseudo ?? '…'),
                  textAlign: TextAlign.center,
                ),
        ),
      ],
    );
  }

  Widget? _inviteButton(BuildContext context, MatchState m, int? myPlayerId, Participant p, MatchController c) {
    final myTeam = m.teams.where((t) => t.captainId == myPlayerId).firstOrNull;
    if (myTeam == null || p.playerId == myPlayerId) return null;
    if (myTeam.pending.any((x) => x.playerId == p.playerId)) return null;
    return TextButton(
      onPressed: () => c.team('invite', myTeam.id, {'player_id': p.playerId}),
      child: Text(context.l10n.teamInvite),
    );
  }
}

class _ParticipantTile extends ConsumerWidget {
  const _ParticipantTile({
    required this.p,
    required this.isCreator,
    required this.isMe,
    required this.canKick,
    required this.onKick,
    this.trailing,
  });

  final Participant p;
  final bool isCreator;
  final bool isMe;
  final bool canKick;
  final VoidCallback onKick;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: Icon(Icons.circle, size: 12, color: p.online ? context.palette.success : Colors.grey),
        title: Text(p.pseudo, style: TextStyle(fontWeight: isMe ? FontWeight.w700 : null)),
        subtitle: isCreator ? Text(l.lobbyCreator) : null,
        trailing: isMe
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ?trailing,
                  PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'kick') onKick();
                      if (v == 'report') await reportPlayer(context, ref, p.playerId);
                    },
                    itemBuilder: (_) => [
                      if (canKick) PopupMenuItem(value: 'kick', child: Text(l.lobbyKick)),
                      PopupMenuItem(value: 'report', child: Text(l.report)),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

/// Signaler un pseudo inapproprié (examiné dans le back-office).
Future<void> reportPlayer(BuildContext context, WidgetRef ref, int playerId) async {
  final l = context.l10n;
  final reason = await askName(context, l.report, label: l.reportReason);
  if (reason == null || !context.mounted) return;
  final done = await runOnline(context, () => ref.read(onlineServiceProvider).report(playerId, reason));
  if (done != null && context.mounted) context.toast(l.reportSent);
}

// ================================================================== jeu

class _PlayView extends ConsumerWidget {
  const _PlayView({required this.view, required this.matchId});

  final MatchView view;
  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final m = view.match!;
    final clock = ref.watch(onlineServiceProvider).clock;
    final controller = ref.read(matchControllerProvider(matchId).notifier);
    if (m.phase == 'countdown' || m.question == null) {
      return Column(
        children: [
          const _RealtimeBanner(),
          Expanded(
            child: Center(
              child: ServerCountdown(
                clock: clock,
                deadline: m.phaseUntil,
                builder: (c, ms) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.playCountdown, style: Theme.of(c).textTheme.headlineMedium),
                    const SizedBox(height: 12),
                    Text('${(ms / 1000).ceil()}',
                        style: Theme.of(c).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
          _Scoreboard(match: m, me: view.me),
        ],
      );
    }
    final q = m.question!;
    final me = m.participant(view.me);
    final myHand = me != null && q.handParticipantId == me.id && m.phase == 'hand';
    final locked = me != null && q.locked.contains(m.lockKey(me));
    final canBuzz = me != null && !me.left && m.phase == 'open' && !locked && (!m.isTeam || me.teamId != null);
    final reveal = m.phase == 'reveal';
    return Column(
      children: [
        const _RealtimeBanner(),
        _TimerBar(match: m, clock: clock),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      q.tiebreak ? l.playTiebreak : l.playQuestion(q.index, q.total),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: q.tiebreak ? context.palette.accentText : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (q.source == 'generated')
                    Chip(label: Text(l.playFromText), visualDensity: VisualDensity.compact),
                ],
              ),
              const SizedBox(height: 8),
              Text(q.prompt, style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.35)),
              const SizedBox(height: 12),
              for (var i = 0; i < q.options.length; i++)
                _OptionButton(
                  label: q.options[i],
                  enabled: myHand && !view.busy,
                  state: !reveal
                      ? _OptionState.normal
                      : i == q.answer
                      ? _OptionState.correct
                      : q.answers.any((a) => a.choice == i && a.kind == 'wrong')
                      ? _OptionState.wrong
                      : _OptionState.normal,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    controller.answer(i);
                  },
                ),
              const SizedBox(height: 8),
              _StatusLine(match: m, me: me, locked: locked),
              if (reveal) _RevealCard(match: m),
            ],
          ),
        ),
        _Scoreboard(match: m, me: view.me),
        if (me != null && !reveal)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: QuizColors.gold,
                  foregroundColor: QuizColors.ink,
                  textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                onPressed: canBuzz && !view.busy
                    ? () {
                        HapticFeedback.heavyImpact();
                        controller.buzz();
                      }
                    : null,
                child: Text(myHand ? l.playYourHand : l.playBuzz),
              ),
            ),
          ),
      ],
    );
  }
}

/// Le temps : question ouverte (barre qui se vide), main en cours (chrono de la question en pause).
class _TimerBar extends StatelessWidget {
  const _TimerBar({required this.match, required this.clock});

  final MatchState match;
  final ServerClock clock;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = match.question!;
    final total = match.questionSeconds * 1000;
    final scheme = Theme.of(context).colorScheme;
    Widget bar(double value, Color color, String label, {IconData? icon}) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 6)],
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: 10, color: color),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 56, child: Text(label, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
    return switch (match.phase) {
      'open' => ServerCountdown(
        clock: clock,
        deadline: q.deadline,
        builder: (c, ms) => bar(ms / total, ms < 5000 ? scheme.error : scheme.primary, '${(ms / 1000).ceil()} s'),
      ),
      'hand' => ServerCountdown(
        clock: clock,
        deadline: q.handDeadline,
        builder: (c, ms) => Column(
          children: [
            bar((q.remainingMs ?? 0) / total, scheme.outline, '${((q.remainingMs ?? 0) / 1000).ceil()} s',
                icon: Icons.pause),
            bar(ms / (match.handSeconds * 1000), QuizColors.gold, '${(ms / 1000).ceil()} s', icon: Icons.back_hand),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(l.playPaused, style: Theme.of(context).textTheme.bodySmall),
            ),
          ],
        ),
      ),
      _ => const SizedBox(height: 18),
    };
  }
}

enum _OptionState { normal, correct, wrong }

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.label, required this.enabled, required this.state, required this.onTap});

  final String label;
  final bool enabled;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (Color? bg, Color? fg, IconData? icon) = switch (state) {
      _OptionState.correct => (p.successContainer, p.onSuccessContainer, Icons.check_circle),
      _OptionState.wrong => (p.errorContainer, null, Icons.cancel),
      _ => (null, null, null),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          backgroundColor: bg,
          foregroundColor: fg,
          disabledForegroundColor: fg ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
          side: BorderSide(
            color: enabled ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
            width: enabled ? 2 : 1,
          ),
        ),
        onPressed: enabled ? onTap : null,
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            if (icon != null) Icon(icon, color: fg),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.match, required this.me, required this.locked});

  final MatchState match;
  final Participant? me;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = match.question!;
    String? text;
    if (match.phase == 'hand') {
      final holder = match.participant(q.handParticipantId);
      text = holder?.id == me?.id ? l.playYourHand : l.playHandOf(holder?.pseudo ?? '…');
    } else if (match.phase == 'open' && locked) {
      text = match.isTeam ? l.playLockedTeam : l.playLocked;
    } else if (match.phase == 'open' && me == null) {
      text = l.playSpectator;
    }
    if (text == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

/// Après la question : qui a trouvé, les erreurs, l'explication et le passage.
class _RevealCard extends StatelessWidget {
  const _RevealCard({required this.match});

  final MatchState match;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final q = match.question!;
    final winner = match.participant(q.winnerParticipantId);
    final answer = q.answer != null && q.answer! < q.options.length ? q.options[q.answer!] : '';
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              winner != null ? l.playWonBy(winner.pseudo) : l.playNobody,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: winner != null ? context.palette.success : null,
              ),
            ),
            if (winner == null) Text(l.playAnswerWas(answer)),
            for (final a in q.answers.where((a) => a.kind != 'correct'))
              Text(
                a.kind == 'timeout'
                    ? l.playHandLost(match.participant(a.participantId)?.pseudo ?? '…')
                    : l.playAnsweredWrong(match.participant(a.participantId)?.pseudo ?? '…'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (q.explain.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(q.explain),
            ],
            if (q.ref.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(q.refLabel.isEmpty ? l.resultReadPassage : q.refLabel),
                  onPressed: () {
                    try {
                      showVerseSheet(context, VerseRef.parse(q.ref));
                    } catch (_) {}
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Les scores en bas de l'écran : joueurs (individuel) ou deux équipes.
class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.match, required this.me});

  final MatchState match;
  final int? me;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final myTeam = match.participant(me)?.teamId;
    final chips = match.isTeam
        ? [
            for (final t in match.teams)
              _ScoreChip(label: t.name, score: t.score, mine: t.id == myTeam, muted: false),
          ]
        : [
            for (final p in [...match.participants]..sort((a, b) => b.score.compareTo(a.score)))
              _ScoreChip(
                label: p.left ? '${p.pseudo} (${l.playLeft})' : p.pseudo,
                score: p.score,
                mine: p.id == me,
                muted: p.left,
              ),
          ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Wrap(spacing: 6, runSpacing: 4, alignment: WrapAlignment.center, children: chips),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label, required this.score, required this.mine, required this.muted});

  final String label;
  final int score;
  final bool mine;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      visualDensity: VisualDensity.compact,
      backgroundColor: mine ? scheme.primaryContainer : null,
      label: Text(
        '$label  $score',
        style: TextStyle(
          fontWeight: mine ? FontWeight.w800 : FontWeight.w500,
          color: muted ? scheme.onSurfaceVariant : (mine ? scheme.onPrimaryContainer : null),
          decoration: muted ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

// ================================================================== résultats

class _ResultView extends ConsumerWidget {
  const _ResultView({required this.view, required this.myPlayerId, required this.matchId});

  final MatchView view;
  final int? myPlayerId;
  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final m = view.match!;
    final r = m.result;
    final winnerPart = m.participant(r?.winnerParticipantId);
    final winnerTeam = m.team(r?.winnerTeamId);
    final me = m.participant(view.me);
    final iWon = me != null &&
        ((winnerPart != null && winnerPart.id == me.id) || (winnerTeam != null && me.teamId == winnerTeam.id));
    final title = iWon
        ? l.resultYouWin
        : winnerTeam != null
        ? l.resultWinner(winnerTeam.name)
        : winnerPart != null
        ? l.resultWinner(winnerPart.pseudo)
        : l.resultDraw;
    final note = switch (r?.outcome) {
      'abandon' => l.resultAbandon,
      'idle' => l.resultIdle,
      'tiebreak' => l.resultTiebreak,
      'tiebreak_rule' => l.resultTiebreakRule,
      _ => null,
    };
    final ranked = [...m.participants]..sort((a, b) => (a.rank ?? 99).compareTo(b.rank ?? 99));
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: context.palette.heroBackground,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.emoji_events, size: 48, color: context.palette.heroAccent),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: context.palette.heroForeground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (note != null) ...[
                  const SizedBox(height: 6),
                  Text(note, textAlign: TextAlign.center, style: TextStyle(color: context.palette.heroMuted)),
                ],
              ],
            ),
          ),
        ),
        if (m.isTeam)
          for (final t in m.teams)
            TeamPanel(
              team: t,
              myPlayerId: myPlayerId,
              open: false,
              score: t.score,
              highlight: t.id == winnerTeam?.id,
              onAction: (_, {playerId}) {},
            ),
        SectionTitle(l.playScores),
        for (final p in ranked)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 3),
            child: ListTile(
              leading: CircleAvatar(child: Text(p.rank == 1 ? l.resultFirst : l.resultRank(p.rank ?? 0))),
              title: Text(p.pseudo, style: TextStyle(fontWeight: p.id == view.me ? FontWeight.w700 : null)),
              subtitle: Text('✓ ${p.correct}   ✗ ${p.wrong}${p.left ? ' · ${l.playLeft}' : ''}'),
              trailing: Text(l.playPoints(p.score), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.list_alt),
          label: Text(l.resultReview),
          onPressed: () => _showHistory(context, ref),
        ),
        if (m.kind == 'free' && me != null) ...[
          // Écart franc : deux boutons collés se touchent par erreur (« Revanche » relance une partie).
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.replay),
            label: Text(l.resultRematch),
            onPressed: () async {
              final env = await runOnline(context, () => ref.read(onlineServiceProvider).matchAction('rematch', matchId));
              if (env == null || !context.mounted) return;
              unawaited(ref.read(onlineMeProvider.notifier).refresh());
              context.toast(l.resultRematchSent);
              MatchController.seeds[env.match.id] = env;
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => MatchScreen(matchId: env.match.id)),
              );
            },
          ),
        ],
      ],
    );
  }

  Future<void> _showHistory(BuildContext context, WidgetRef ref) async {
    final questions = await runOnline(context, () => ref.read(onlineServiceProvider).matchHistory(matchId));
    if (questions == null || !context.mounted) return;
    final m = view.match!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        builder: (c, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            for (final q in questions)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.tiebreak ? c.l10n.playTiebreak : c.l10n.playQuestion(q.index, q.total == 0 ? questions.length : q.total),
                          style: Theme.of(c).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(q.prompt, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (q.answer != null && q.answer! < q.options.length)
                        Text('✓ ${q.options[q.answer!]}', style: TextStyle(color: c.palette.success)),
                      Text(
                        m.participant(q.winnerParticipantId) != null
                            ? c.l10n.playWonBy(m.participant(q.winnerParticipantId)!.pseudo)
                            : c.l10n.playNobody,
                        style: Theme.of(c).textTheme.bodySmall,
                      ),
                      if (q.explain.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(q.explain)),
                      if (q.ref.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            try {
                              showVerseSheet(c, VerseRef.parse(q.ref));
                            } catch (_) {}
                          },
                          child: Text(q.refLabel),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
