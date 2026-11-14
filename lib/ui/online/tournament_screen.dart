import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../online/models.dart';
import '../../online/online_providers.dart';
import '../../online/realtime.dart';
import '../../online/tournament_controller.dart';
import '../common.dart';
import 'match_screen.dart';
import 'online_common.dart';

/// Fiche d'un tournoi : inscriptions, « Votre duel », tableau, vainqueur.
class TournamentScreen extends ConsumerStatefulWidget {
  const TournamentScreen({super.key, required this.tournamentId});

  final int tournamentId;

  /// Ouvre la fiche ; [seed] (état déjà reçu) évite un écran de chargement.
  static Future<void> open(BuildContext context, int tournamentId, {TournamentEnvelope? seed}) {
    if (seed != null) TournamentController.seeds[tournamentId] = seed;
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => TournamentScreen(tournamentId: tournamentId)));
  }

  @override
  ConsumerState<TournamentScreen> createState() => _TournamentScreenState();
}

/// Le duel en attente ou en cours de [entryId] (le plus avancé dans le tableau).
Duel? activeDuelOf(TournamentState t, int? entryId) {
  if (entryId == null) return null;
  final mine = t.duels.where((d) => d.involves(entryId) && (d.state == 'ready_wait' || d.state == 'playing')).toList()
    ..sort((a, b) => b.round.compareTo(a.round));
  return mine.firstOrNull;
}

/// Nombre de tours d'un tableau de [entries] participants.
int roundsFor(int entries) {
  var r = 0;
  while ((1 << r) < entries) {
    r++;
  }
  return r < 1 ? 1 : r;
}

/// Nom d'un tour d'après le nombre de tours restants : « Finale », « Demi-finales »…
String tournamentRoundTitle(AppLocalizations l, int round, int rounds) => switch (rounds - round) {
  0 => l.tourFinal,
  1 => l.tourSemiFinals,
  2 => l.tourQuarterFinals,
  _ => l.tourRound(round),
};

String _clock(int ms) {
  final s = (ms / 1000).ceil();
  String two(int v) => v.toString().padLeft(2, '0');
  final h = s ~/ 3600;
  return h > 0 ? '$h:${two(s % 3600 ~/ 60)}:${two(s % 60)}' : '${two(s ~/ 60)}:${two(s % 60)}';
}

class _TournamentScreenState extends ConsumerState<TournamentScreen> {
  /// Matchs déjà ouverts automatiquement (on ne les rouvre pas).
  final _autoOpened = <int>{};
  bool _inMatch = false;

  TournamentController get _controller => ref.read(tournamentControllerProvider(widget.tournamentId).notifier);

  /// Lance une action ; rend true si le serveur l'a acceptée (sinon le refus est affiché).
  Future<bool> _run(Future<bool> Function(TournamentController c) call, {bool refreshMe = true}) async {
    final ok = await runOnline(context, () => call(_controller)) ?? false;
    if (ok && refreshMe) unawaited(ref.read(onlineMeProvider.notifier).refresh());
    return ok;
  }

  /// Ouvre l'écran du match d'un duel ; au retour, l'état du tournoi est relu.
  Future<void> _openMatch(int matchId) async {
    if (_inMatch || !mounted) return;
    _inMatch = true;
    try {
      await MatchScreen.open(context, matchId);
    } finally {
      _inMatch = false;
      if (mounted) unawaited(_controller.refresh());
    }
  }

  /// Mon duel vient de passer « en cours » sur cet écran : on ouvre le match, une seule fois.
  void _watchDuel(TournamentView? prev, TournamentView next) {
    final t = next.tournament;
    final before = prev?.tournament;
    if (t == null || before == null) return;
    final duel = activeDuelOf(t, next.myEntryId);
    final matchId = duel?.matchId;
    if (duel == null || duel.state != 'playing' || matchId == null || _autoOpened.contains(matchId)) return;
    final was = before.duels.where((d) => d.id == duel.id).firstOrNull;
    if (was?.state == 'playing') return;
    _autoOpened.add(matchId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (ModalRoute.of(context)?.isCurrent ?? true)) unawaited(_openMatch(matchId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = tournamentControllerProvider(widget.tournamentId);
    final view = ref.watch(provider);
    ref.listen(provider, _watchDuel);
    final myPlayerId = ref.watch(onlineMeProvider.select((m) => m.value?.player?.id));
    final t = view.tournament;
    return Scaffold(
      appBar: AppBar(title: Text(t?.name ?? l.tourTitle, overflow: TextOverflow.ellipsis)),
      body: SafeArea(
        top: false,
        child: t == null
            ? _loadingOrError(context, view)
            : RefreshIndicator(
                onRefresh: _controller.refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: _content(context, view, t, myPlayerId),
                ),
              ),
      ),
    );
  }

  Widget _loadingOrError(BuildContext context, TournamentView view) {
    final l = context.l10n;
    if (view.error == null) return const Center(child: CircularProgressIndicator());
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 40),
            const SizedBox(height: 12),
            Text(onlineError(context, view.error!), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _controller.refresh, child: Text(l.retry)),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, TournamentView view, TournamentState t, int? myPlayerId) {
    final l = context.l10n;
    final organizer = myPlayerId != null && t.organizerId == myPlayerId;
    final me = view.myEntryId;
    final busy = view.busy;
    return [
      _Header(state: t, organizer: organizer),
      const SizedBox(height: 12),
      if (t.state == 'cancelled')
        Card(
          child: ListTile(
            leading: Icon(Icons.block, color: context.palette.error),
            title: Text(l.tourCancelled),
          ),
        ),
      if (t.state == 'finished') _WinnerBanner(state: t, myEntryId: me),
      if (t.state == 'running') ..._myDuel(context, t, me, busy),
      if (t.state == 'registration') ...[
        CodeShareCard(
          code: t.code,
          title: l.tourCode,
          shareText: l.tourShareText(t.name, t.passagesLabel, t.code),
        ),
        const SizedBox(height: 8),
        _myRegistration(context, t, me, busy),
        SectionTitle(t.isTeam ? l.tourTeams(t.entries.length, t.maxEntries) : l.tourPlayers(t.entries.length, t.maxEntries)),
        TournamentRegistrationList(
          state: t,
          myEntryId: me,
          myPlayerId: myPlayerId,
          onTeamAction: (team, action, playerId) => handleTeamAction(
            context,
            team,
            action,
            playerId,
            (a, extra) => _run((c) => c.team(a, team.id, extra)),
          ),
        ),
      ],
      if (organizer && (t.state == 'registration' || t.state == 'running')) _organizerCard(context, t, busy),
      if (t.state == 'registration')
        _RulesCard(state: t)
      else
        Card(
          margin: const EdgeInsets.only(top: 12),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            leading: const Icon(Icons.rule),
            title: Text(l.tourRules),
            shape: const Border(),
            children: [_RulesCard.lines(context, t)],
          ),
        ),
      if (t.duels.isNotEmpty) ...[
        SectionTitle(l.tourBracket),
        TournamentBracket(state: t, myEntryId: me),
      ],
    ];
  }

  // ------------------------------------------------------------------ inscriptions

  Widget _myRegistration(BuildContext context, TournamentState t, int? me, bool busy) {
    final l = context.l10n;
    final full = t.entries.length >= t.maxEntries;
    final children = <Widget>[];
    if (t.isTeam) {
      if (me == null) {
        children.addAll([
          Text(l.tourTeamHint),
          const SizedBox(height: 4),
          Text(l.teamSizeHint(t.teamMinSize, t.teamMaxSize), style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          if (full)
            Text(l.tourFull, style: TextStyle(color: context.palette.error))
          else
            FilledButton.icon(
              icon: const Icon(Icons.group_add_outlined),
              label: Text(l.teamCreate),
              onPressed: busy
                  ? null
                  : () async {
                      final name = await askName(context, l.teamCreate, label: l.teamName);
                      if (name != null && mounted) await _run((c) => c.action('team/create', {'name': name}));
                    },
            ),
        ]);
      } else {
        children.addAll([
          Text(l.tourRegistered),
          const SizedBox(height: 4),
          Text(l.teamSizeHint(t.teamMinSize, t.teamMaxSize), style: Theme.of(context).textTheme.bodySmall),
        ]);
      }
    } else if (me == null) {
      children.addAll([
        if (full) Text(l.tourFull, style: TextStyle(color: context.palette.error)),
        if (!full)
          FilledButton.icon(
            icon: const Icon(Icons.how_to_reg_outlined),
            label: Text(l.tourRegister),
            onPressed: busy ? null : () => _run((c) => c.action('register')),
          ),
      ]);
    } else {
      children.addAll([
        Row(
          children: [
            Icon(Icons.check_circle, color: context.palette.success),
            const SizedBox(width: 8),
            Expanded(child: Text(l.tourRegistered)),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton(
            onPressed: busy
                ? null
                : () async {
                    if (await confirmDialog(context, l.tourUnregisterConfirm, action: l.tourUnregister) && mounted) {
                      await _run((c) => c.action('unregister'));
                    }
                  },
            child: Text(l.tourUnregister),
          ),
        ),
      ]);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }

  // ------------------------------------------------------------------ mon duel

  List<Widget> _myDuel(BuildContext context, TournamentState t, int? me, bool busy) {
    final l = context.l10n;
    final entry = t.entry(me);
    if (entry == null) {
      return [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(l.tourSpectator)),
            ],
          ),
        ),
      ];
    }
    final duel = activeDuelOf(t, me);
    final widgets = <Widget>[];
    if (duel != null) {
      widgets.add(_YourDuelCard(
        state: t,
        duel: duel,
        myEntryId: me!,
        busy: busy,
        clock: ref.read(onlineServiceProvider).clock,
        onReady: () => _run((c) => c.ready(duel.id), refreshMe: false),
        onJoin: duel.matchId == null ? null : () => _openMatch(duel.matchId!),
      ));
    } else if (entry.state == 'eliminated') {
      widgets.add(Card(
        child: ListTile(
          leading: const Icon(Icons.flag_outlined),
          title: Text(entry.eliminatedRound != null ? l.tourEliminatedAt(entry.eliminatedRound!) : l.tourEliminated),
        ),
      ));
    } else if (entry.state == 'in') {
      widgets.add(Card(
        child: ListTile(
          leading: Icon(Icons.hourglass_top, color: context.palette.accentIcon),
          title: Text(l.tourWaitingNext),
        ),
      ));
    }
    if (entry.state == 'in') {
      widgets.add(Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          icon: const Icon(Icons.logout),
          label: Text(l.tourAbandon),
          style: TextButton.styleFrom(foregroundColor: context.palette.error),
          onPressed: busy
              ? null
              : () async {
                  final ok = await confirmDialog(context, l.tourAbandon,
                      body: t.isTeam ? l.tourAbandonTeamBody : l.tourAbandonBody, action: l.tourAbandon);
                  if (ok && mounted) await _run((c) => c.action('unregister'));
                },
        ),
      ));
    }
    return widgets;
  }

  // ------------------------------------------------------------------ organisateur

  Widget _organizerCard(BuildContext context, TournamentState t, bool busy) {
    final l = context.l10n;
    final need = t.minEntries < 2 ? 2 : t.minEntries;
    // Les équipes incomplètes seront écartées au lancement : on ne compte que les autres.
    final valid = t.isTeam
        ? t.entries.where((e) => (e.team?.members.length ?? 0) >= t.teamMinSize).length
        : t.entries.length;
    final canStart = valid >= need;
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings_outlined, color: context.palette.brandIcon),
                const SizedBox(width: 8),
                Text(l.tourOrganize, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            if (t.state == 'registration') ...[
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l.tourStart),
                onPressed: busy || !canStart
                    ? null
                    : () async {
                        final ok = await confirmDialog(
                          context,
                          l.tourStartConfirm,
                          body: t.isTeam ? l.tourStartBodyTeam(t.teamMinSize) : l.tourStartBody,
                          action: l.tourStart,
                        );
                        if (ok && mounted) await _run((c) => c.action('start'));
                      },
              ),
              if (!canStart)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l.tourNeedEntries(need, valid),
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(l.tourRoundPassages),
              onPressed: busy ? null : () => _RoundPassagesSheet.show(context, widget.tournamentId),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              icon: const Icon(Icons.cancel_outlined),
              label: Text(l.tourCancel),
              style: TextButton.styleFrom(foregroundColor: context.palette.error),
              onPressed: busy
                  ? null
                  : () async {
                      final ok = await confirmDialog(context, l.tourCancelConfirm,
                          body: l.tourCancelBody, action: l.tourCancel);
                      if (ok && mounted) await _run((c) => c.action('cancel'));
                    },
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ en-tête, règlement, vainqueur

class _Header extends StatelessWidget {
  const _Header({required this.state, required this.organizer});

  final TournamentState state;
  final bool organizer;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (label, icon) = switch (state.state) {
      'registration' => (l.tourStateRegistration, Icons.how_to_reg_outlined),
      'running' => (l.tourStateRunning, Icons.sports_score),
      'finished' => (l.tourStateFinished, Icons.emoji_events_outlined),
      _ => (l.tourStateCancelled, Icons.block),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(state.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(l.tourOrganizedBy(state.organizerPseudo), style: TextStyle(color: scheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            Chip(avatar: Icon(icon, size: 18), label: Text(label), visualDensity: VisualDensity.compact),
            Chip(
              avatar: Icon(state.isTeam ? Icons.groups_outlined : Icons.person_outline, size: 18),
              label: Text(state.isTeam ? l.tourModeTeam : l.tourModeSolo),
              visualDensity: VisualDensity.compact,
            ),
            if (organizer)
              Chip(
                avatar: Icon(Icons.verified_outlined, size: 18, color: context.palette.accentIcon),
                label: Text(l.tourOrganizer),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ],
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.state});

  final TournamentState state;

  static Widget lines(BuildContext context, TournamentState t) {
    final l = context.l10n;
    Widget line(IconData icon, String text) => ListTile(dense: true, leading: Icon(icon, size: 20), title: Text(text));
    return Column(
      children: [
        line(Icons.menu_book_outlined, t.passagesLabel),
        line(Icons.translate, t.lang == 'en' ? l.tourBibleEn : l.tourBibleFr),
        line(Icons.quiz_outlined, l.tourRulesDuel(t.questionCount, t.questionSeconds)),
        line(Icons.pan_tool_outlined, l.tourRulesHand(t.handSeconds)),
        line(Icons.timer_outlined, l.tourRulesForfeit(t.forfeitMinutes)),
        line(t.isTeam ? Icons.groups_outlined : Icons.person_outline, l.tourRulesEntries(t.minEntries, t.maxEntries)),
        line(Icons.account_tree_outlined, l.tourRulesElimination),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(top: 12),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(context.l10n.tourRules, style: Theme.of(context).textTheme.titleMedium),
          ),
          lines(context, state),
        ],
      ),
    ),
  );
}

class _WinnerBanner extends StatelessWidget {
  const _WinnerBanner({required this.state, required this.myEntryId});

  final TournamentState state;
  final int? myEntryId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final winner = state.entry(state.winnerEntryId);
    final text = winner == null
        ? l.tourNoWinner
        : winner.id == myEntryId
        ? l.tourYouWon
        : l.tourWinner(winner.name);
    return Card(
      color: p.heroBackground,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.emoji_events, size: 56, color: p.heroAccent),
            const SizedBox(height: 8),
            Semantics(
              header: true,
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: p.heroForeground, fontWeight: FontWeight.w800),
              ),
            ),
            if (winner?.team != null) ...[
              const SizedBox(height: 4),
              Text(
                winner!.team!.members.map((m) => m.pseudo).join(', '),
                textAlign: TextAlign.center,
                style: TextStyle(color: p.heroMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ votre duel

class _YourDuelCard extends StatelessWidget {
  const _YourDuelCard({
    required this.state,
    required this.duel,
    required this.myEntryId,
    required this.busy,
    required this.clock,
    required this.onReady,
    required this.onJoin,
  });

  final TournamentState state;
  final Duel duel;
  final int myEntryId;
  final bool busy;
  final ServerClock clock;
  final VoidCallback onReady;
  final VoidCallback? onJoin;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final p = context.palette;
    final sideA = duel.entryA == myEntryId;
    final opponent = state.entry(sideA ? duel.entryB : duel.entryA);
    final opponentName = opponent?.name ?? '—';
    final myReady = sideA ? duel.readyA : duel.readyB;
    final opponentReady = sideA ? duel.readyB : duel.readyA;
    final rounds = state.rounds > 0 ? state.rounds : duel.round;
    final title = TextStyle(color: scheme.onPrimaryContainer);

    Widget status(bool ready, String text) => Row(
      children: [
        Icon(ready ? Icons.check_circle : Icons.hourglass_empty, size: 20, color: ready ? p.success : scheme.onPrimaryContainer),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: title)),
      ],
    );

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.sports_kabaddi, color: scheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      '${l.tourYourDuel} · ${tournamentRoundTitle(l, duel.round, rounds)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.tourAgainst(opponentName),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (opponent?.team != null)
              Text(opponent!.team!.members.map((m) => m.pseudo).join(', '), style: title),
            const SizedBox(height: 12),
            if (duel.state == 'ready_wait') ...[
              ServerCountdown(
                clock: clock,
                deadline: duel.deadline,
                builder: (context, ms) => Row(
                  children: [
                    Icon(Icons.timer_outlined, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ms > 0 ? l.tourForfeitIn(_clock(ms)) : l.tourDeadlinePassed,
                        style: title.copyWith(fontWeight: FontWeight.w700, fontFeatures: const [FontFeature.tabularFigures()]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (myReady) status(true, state.isTeam ? l.tourTeamReady : l.tourYouReady),
              status(opponentReady, opponentReady ? l.tourOpponentReady(opponentName) : l.tourOpponentWaiting(opponentName)),
              if (!myReady) ...[
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(l.tourReady),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  onPressed: busy ? null : onReady,
                ),
                const SizedBox(height: 6),
                Text(l.tourReadyHint, style: title.copyWith(fontSize: 13), textAlign: TextAlign.center),
              ],
            ],
            if (duel.state == 'playing') ...[
              status(true, l.tourDuelPlaying),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: Text(l.tourJoinDuel),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: onJoin,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ passages par tour

class _RoundPassagesSheet extends ConsumerWidget {
  const _RoundPassagesSheet({required this.tournamentId});

  final int tournamentId;

  static Future<void> show(BuildContext context, int tournamentId) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _RoundPassagesSheet(tournamentId: tournamentId),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final view = ref.watch(tournamentControllerProvider(tournamentId));
    final t = view.tournament;
    if (t == null) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
    final known = t.state == 'running' && t.rounds > 0;
    final rounds = known ? t.rounds : roundsFor(t.maxEntries);
    final overrides = t.roundPassages;
    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(l.tourRoundPassages, style: Theme.of(context).textTheme.titleLarge),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Text(l.tourRoundPassagesHint, style: Theme.of(context).textTheme.bodySmall),
          ),
          for (var r = 1; r <= rounds; r++)
            Builder(builder: (context) {
              final custom = overrides['$r'] ?? const <Passage>[];
              final started = t.duels.any((d) => d.round == r && d.matchId != null);
              return ListTile(
                leading: CircleAvatar(child: Text('$r')),
                title: Text(known ? tournamentRoundTitle(l, r, rounds) : l.tourRound(r)),
                subtitle: Text(
                  [
                    if (custom.isEmpty) l.tourRoundDefault else custom.map((p) => p.label).join(' ; '),
                    if (started) l.tourRoundStarted,
                  ].join('\n'),
                ),
                trailing: started ? null : const Icon(Icons.edit_outlined),
                enabled: !started && !view.busy,
                onTap: () => _edit(context, ref, t, r, custom),
              );
            }),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, TournamentState t, int round, List<Passage> custom) async {
    final codes = await showDialog<List<String>>(
      context: context,
      builder: (_) => _RoundPassagesDialog(
        title: t.state == 'running' && t.rounds > 0
            ? tournamentRoundTitle(context.l10n, round, t.rounds)
            : context.l10n.tourRound(round),
        initial: [for (final p in custom) p.code],
        hasOverride: custom.isNotEmpty,
        lang: t.lang,
        questionCount: t.questionCount,
      ),
    );
    if (codes == null || !context.mounted) return;
    final controller = ref.read(tournamentControllerProvider(tournamentId).notifier);
    final ok = await runOnline(context, () => controller.action('round-passages', {'round': round, 'passages': codes}));
    if (ok == true && context.mounted) context.toast(context.l10n.tourSaved);
  }
}

class _RoundPassagesDialog extends StatefulWidget {
  const _RoundPassagesDialog({
    required this.title,
    required this.initial,
    required this.hasOverride,
    required this.lang,
    required this.questionCount,
  });

  final String title;
  final List<String> initial;
  final bool hasOverride;
  final String lang;
  final int questionCount;

  @override
  State<_RoundPassagesDialog> createState() => _RoundPassagesDialogState();
}

class _RoundPassagesDialogState extends State<_RoundPassagesDialog> {
  late List<String> _codes = [...widget.initial];

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: PassageListEditor(
          codes: _codes,
          lang: widget.lang,
          requiredCount: widget.questionCount,
          onChanged: (v) => setState(() => _codes = v),
        ),
      ),
      actions: [
        if (widget.hasOverride)
          TextButton(onPressed: () => Navigator.pop(context, const <String>[]), child: Text(l.tourRoundReset)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(
          onPressed: _codes.isEmpty ? null : () => Navigator.pop(context, _codes),
          child: Text(l.tourSave),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ widgets purs (testés)

/// Les inscrits : joueurs (liste) ou équipes ([TeamPanel] avec leurs actions).
class TournamentRegistrationList extends StatelessWidget {
  const TournamentRegistrationList({
    super.key,
    required this.state,
    required this.myEntryId,
    required this.myPlayerId,
    this.onTeamAction,
  });

  final TournamentState state;
  final int? myEntryId;
  final int? myPlayerId;

  /// Action demandée sur une équipe (`invite`, `request`, `accept`, `decline`, `leave`, `rename`).
  final void Function(TeamState team, String action, int? playerId)? onTeamAction;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final entries = state.entries;
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(l.tourNoEntries, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
    }
    if (state.isTeam) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in entries)
            if (e.team case final team?) ...[
              TeamPanel(
                team: team,
                myPlayerId: myPlayerId,
                open: state.state == 'registration',
                canAsk: myEntryId == null,
                maxSize: state.teamMaxSize,
                highlight: e.id == myEntryId,
                onAction: (action, {playerId}) => onTeamAction?.call(team, action, playerId),
              ),
              if (team.members.length < state.teamMinSize)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: context.palette.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l.tourTeamIncomplete(state.teamMinSize),
                          style: TextStyle(color: context.palette.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
        ],
      );
    }
    return Card(
      child: Column(
        children: [
          for (final e in entries)
            ListTile(
              dense: true,
              leading: Icon(e.id == myEntryId ? Icons.person : Icons.person_outline),
              title: Text(
                e.id == myEntryId ? '${e.name} (${l.tourYou})' : e.name,
                style: TextStyle(fontWeight: e.id == myEntryId ? FontWeight.w700 : null),
              ),
              trailing: e.playerId != null && e.playerId == state.organizerId
                  ? Tooltip(
                      message: l.tourOrganizer,
                      child: Icon(Icons.verified_outlined, color: context.palette.accentIcon, semanticLabel: l.tourOrganizer),
                    )
                  : null,
            ),
        ],
      ),
    );
  }
}

/// Le tableau : un bloc par tour (« Tour 1 », …, « Demi-finales », « Finale »), un duel par carte.
class TournamentBracket extends StatelessWidget {
  const TournamentBracket({super.key, required this.state, this.myEntryId});

  final TournamentState state;
  final int? myEntryId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final duels = state.duels;
    if (duels.isEmpty) return const SizedBox.shrink();
    var rounds = state.rounds;
    for (final d in duels) {
      if (d.round > rounds) rounds = d.round;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 1; r <= rounds; r++) ...[
          Semantics(header: true, child: SectionTitle(tournamentRoundTitle(l, r, rounds))),
          for (final d in duels.where((d) => d.round == r).toList()..sort((a, b) => a.position.compareTo(b.position)))
            _DuelCard(state: state, duel: d, myEntryId: myEntryId, isFinal: r == rounds),
        ],
      ],
    );
  }
}

class _DuelCard extends StatelessWidget {
  const _DuelCard({required this.state, required this.duel, required this.myEntryId, required this.isFinal});

  final TournamentState state;
  final Duel duel;
  final int? myEntryId;
  final bool isFinal;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final mine = duel.involves(myEntryId);
    final (String? status, IconData? statusIcon) = switch ((duel.state, duel.result)) {
      ('done', 'bye') => (l.tourByeWin, Icons.fast_forward),
      ('done', 'forfeit') => (l.tourForfeitResult, Icons.timer_off_outlined),
      ('done', 'double_forfeit') => (l.tourDoubleForfeit, Icons.timer_off_outlined),
      ('done', _) => (null, null),
      ('ready_wait', _) => (l.tourDuelReadyWait, Icons.hourglass_empty),
      ('playing', _) => (l.tourDuelLive, Icons.circle),
      _ => (l.tourDuelPending, Icons.schedule),
    };
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: mine
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: scheme.primary, width: 2))
          : null,
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _side(context, duel.entryA, duel.scoreA, duel.readyA),
              Divider(height: 1, indent: 44, color: scheme.outlineVariant),
              _side(context, duel.entryB, duel.scoreB, duel.readyB),
              if (status != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(44, 4, 12, 2),
                  child: Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: duel.state == 'playing' ? 10 : 16,
                        color: duel.state == 'playing' ? scheme.error : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          status,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _side(BuildContext context, int? entryId, int score, bool ready) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final p = context.palette;
    final entry = state.entry(entryId);
    final done = duel.state == 'done';
    final winner = entryId != null && duel.winner == entryId;
    final lost = done && entryId != null && !winner;
    final greyed = lost || entry?.state == 'eliminated' && !winner;
    final me = entryId != null && entryId == myEntryId;
    final String name;
    if (entry != null) {
      name = me ? '${entry.name} (${l.tourYou})' : entry.name;
    } else if (entryId == null && duel.result == 'bye') {
      name = l.tourBye;
    } else {
      name = '—';
    }
    final Widget leading;
    if (winner) {
      leading = Icon(isFinal ? Icons.emoji_events : Icons.check_circle, size: 20, color: isFinal ? p.accentIcon : p.success);
    } else if (duel.state == 'ready_wait' && entryId != null) {
      leading = Icon(ready ? Icons.check : Icons.hourglass_empty, size: 18, color: ready ? p.success : scheme.onSurfaceVariant);
    } else {
      leading = const SizedBox.shrink();
    }
    final members = entry?.team?.members.map((m) => m.pseudo).join(', ');
    final color = winner ? p.success : greyed ? scheme.onSurfaceVariant : null;
    return Padding(
      key: winner ? ValueKey('duel-${duel.id}-winner') : null,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          SizedBox(width: 24, child: Center(child: leading)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  semanticsLabel: entry == null && name == '—' ? l.tourTbd : null,
                  style: TextStyle(
                    color: color,
                    fontWeight: winner ? FontWeight.w800 : (me ? FontWeight.w700 : null),
                    fontStyle: entry == null ? FontStyle.italic : null,
                  ),
                ),
                if (members != null && members.isNotEmpty)
                  Text(
                    members,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (greyed && entry != null && entry.state == 'eliminated' && !done)
            Text(l.tourEliminatedTag, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          if (done && duel.result == 'played' && entryId != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '$score',
                style: TextStyle(
                  fontWeight: winner ? FontWeight.w800 : FontWeight.w500,
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
