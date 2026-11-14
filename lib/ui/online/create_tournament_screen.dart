import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../online/models.dart';
import '../../online/online_providers.dart';
import '../../online/tournament_controller.dart';
import '../common.dart';
import 'online_common.dart';
import 'tournament_screen.dart';

/// Nouveau tournoi : nom, formule, passages, Bible, participants, réglages des duels.
class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateTournamentScreen()));

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _teamName = TextEditingController();
  String _mode = 'solo';
  List<String> _passages = const [];
  String? _lang;
  int? _minEntries;
  int? _maxEntries;
  int? _count;
  int? _seconds;
  int? _hand;
  int? _forfeit;
  bool _public = true;
  bool _play = true;
  bool _busy = false;

  /// Délais de forfait proposés (minutes).
  static const _forfeitChoices = [2, 5, 10, 15, 20, 30, 45, 60, 120, 240, 720, 1440];

  @override
  void dispose() {
    _name.dispose();
    _teamName.dispose();
    super.dispose();
  }

  String _forfeitLabel(int minutes) {
    final l = context.l10n;
    return minutes >= 60 && minutes % 60 == 0 ? l.tourHoursValue(minutes ~/ 60) : l.tourMinutesValue(minutes);
  }

  Future<void> _submit(Map<String, dynamic> values) async {
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_passages.isEmpty) {
      context.toast(context.l10n.tourNeedPassage);
      return;
    }
    setState(() => _busy = true);
    final TournamentEnvelope? env = await runOnline(context, () => ref.read(onlineServiceProvider).createTournament(values));
    if (!mounted) return;
    setState(() => _busy = false);
    if (env == null) return;
    unawaited(ref.read(onlineMeProvider.notifier).refresh());
    final id = env.tournament.id;
    TournamentController.seeds[id] = env;
    await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TournamentScreen(tournamentId: id)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final config = ref.watch(serverConfigProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.tourCreateTitle)),
      body: SafeArea(
        top: false,
        child: AsyncBody(
          value: config,
          onRetry: () => ref.invalidate(serverConfigProvider),
          builder: (c) {
            final (qMin, qMax) = c.range('question_count', (5, 30));
            final (sMin, sMax) = c.range('question_seconds', (10, 120));
            final (hMin, hMax) = c.range('hand_seconds', (3, 15));
            final count = (_count ?? c.defaultOf('question_count', 10)).clamp(qMin, qMax);
            final seconds = (_seconds ?? c.defaultOf('question_seconds', 30)).clamp(sMin, sMax);
            final hand = (_hand ?? c.defaultOf('hand_seconds', 5)).clamp(hMin, hMax);
            final cap = c.tournamentMaxEntries < 2 ? 2 : c.tournamentMaxEntries;
            final maxEntries = (_maxEntries ?? (cap < 16 ? cap : 16)).clamp(2, cap);
            final minEntries = (_minEntries ?? 2).clamp(2, maxEntries);
            final forfeit = _forfeit ?? c.defaultOf('forfeit_minutes', 10);
            final forfeitChoices = {..._forfeitChoices, forfeit}.toList()..sort();
            final lang = _lang ?? context.lang;
            final team = _mode == 'team';
            final small = Theme.of(context).textTheme.bodySmall;
            return Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  TextFormField(
                    controller: _name,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: l.tourName, hintText: l.tourNameHint),
                    validator: (v) => (v ?? '').trim().length < 3 ? l.tourNameTooShort : null,
                  ),
                  SectionTitle(l.tourFormat),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'solo', icon: const Icon(Icons.person), label: Text(l.tourModeSolo)),
                      ButtonSegment(value: 'team', icon: const Icon(Icons.groups), label: Text(l.tourModeTeam)),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      team
                          ? '${l.tourModeTeamHint} ${l.teamSizeHint(c.teamMinSize, c.teamMaxSize)}'
                          : l.tourModeSoloHint,
                      style: small,
                    ),
                  ),
                  SectionTitle(l.createPassages),
                  PassageListEditor(
                    codes: _passages,
                    lang: lang,
                    requiredCount: count,
                    onChanged: (v) => setState(() => _passages = v),
                  ),
                  SectionTitle(l.tourBible),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'fr', label: Text(l.tourBibleFr)),
                      ButtonSegment(value: 'en', label: Text(l.tourBibleEn)),
                    ],
                    selected: {lang},
                    onSelectionChanged: (s) => setState(() => _lang = s.first),
                  ),
                  SectionTitle(l.tourEntriesRange(minEntries, maxEntries)),
                  if (cap > 2)
                    RangeSlider(
                      values: RangeValues(minEntries.toDouble(), maxEntries.toDouble()),
                      min: 2,
                      max: cap.toDouble(),
                      divisions: cap - 2,
                      labels: RangeLabels('$minEntries', '$maxEntries'),
                      onChanged: (v) => setState(() {
                        _minEntries = v.start.round();
                        _maxEntries = v.end.round();
                      }),
                    ),
                  if (team) Text(l.tourEntriesTeamHint, style: small),
                  const SizedBox(height: 12),
                  Text(l.tourQuestionsPerDuel(count)),
                  Slider(
                    value: count.toDouble(),
                    min: qMin.toDouble(),
                    max: qMax.toDouble(),
                    divisions: qMax - qMin,
                    label: '$count',
                    onChanged: (v) => setState(() => _count = v.round()),
                  ),
                  Text(l.createQuestionTime(seconds)),
                  Slider(
                    value: seconds.toDouble(),
                    min: sMin.toDouble(),
                    max: sMax.toDouble(),
                    divisions: (sMax - sMin) ~/ 5,
                    label: '$seconds s',
                    onChanged: (v) => setState(() => _seconds = ((v / 5).round() * 5).clamp(sMin, sMax)),
                  ),
                  Text(l.createHandTime(hand)),
                  Slider(
                    value: hand.toDouble(),
                    min: hMin.toDouble(),
                    max: hMax.toDouble(),
                    divisions: hMax - hMin,
                    label: '$hand s',
                    onChanged: (v) => setState(() => _hand = v.round()),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: forfeit,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l.tourForfeitDelay,
                      helperText: l.tourForfeitHint,
                      helperMaxLines: 3,
                      prefixIcon: const Icon(Icons.timer_outlined),
                    ),
                    items: [
                      for (final m in forfeitChoices) DropdownMenuItem(value: m, child: Text(_forfeitLabel(m))),
                    ],
                    onChanged: (v) => setState(() => _forfeit = v),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.tourPublic),
                    subtitle: Text(l.tourPublicHint),
                    value: _public,
                    onChanged: (v) => setState(() => _public = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l.tourPlay),
                    subtitle: Text(team ? l.tourPlayTeamHint : l.tourPlaySoloHint),
                    value: _play,
                    onChanged: (v) => setState(() => _play = v),
                  ),
                  if (team && _play)
                    TextFormField(
                      controller: _teamName,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: l.teamName, prefixIcon: const Icon(Icons.groups_outlined)),
                    ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    icon: const Icon(Icons.emoji_events_outlined),
                    label: Text(l.tourCreateSubmit),
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    onPressed: _busy
                        ? null
                        : () => _submit({
                            'name': _name.text.trim(),
                            'mode': _mode,
                            'lang': lang,
                            'passages': _passages,
                            'question_count': count,
                            'question_seconds': seconds,
                            'hand_seconds': hand,
                            'min_entries': minEntries,
                            'max_entries': maxEntries,
                            'forfeit_minutes': forfeit,
                            'is_public': _public,
                            'play': _play,
                            'team_name': team && _play ? _teamName.text.trim() : null,
                          }),
                  ),
                  if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
