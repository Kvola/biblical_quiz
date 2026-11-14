import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../online/online_providers.dart';
import '../common.dart';
import 'match_screen.dart';
import 'online_common.dart';

/// Nouveau match : formule, passages, Bible, nombre de questions et temps.
class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateMatchScreen()));

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  String _mode = 'solo';
  List<String> _passages = const [];
  String? _lang;
  int? _count;
  int? _seconds;
  int? _hand;
  int? _maxPlayers;
  bool _public = true;
  bool _busy = false;

  Future<void> _submit() async {
    setState(() => _busy = true);
    final env = await runOnline(context, () => ref.read(onlineServiceProvider).createMatch({
      'mode': _mode,
      'lang': _lang ?? context.lang,
      'passages': _passages,
      'question_count': _count,
      'question_seconds': _seconds,
      'hand_seconds': _hand,
      'max_players': _mode == 'solo' ? _maxPlayers : null,
      'is_public': _public,
    }));
    if (!mounted) return;
    setState(() => _busy = false);
    if (env == null) return;
    unawaited(ref.read(onlineMeProvider.notifier).refresh());
    final navigator = Navigator.of(context);
    navigator.pop();
    await MatchScreen.open(navigator.context, env.match.id, seed: env);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final config = ref.watch(serverConfigProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.createMatchTitle)),
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
            final maxPlayers = (_maxPlayers ?? c.maxPlayers).clamp(2, c.maxPlayers);
            final lang = _lang ?? context.lang;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'solo', icon: const Icon(Icons.person), label: Text(l.onlineModeSolo)),
                    ButtonSegment(value: 'team', icon: const Icon(Icons.groups), label: Text(l.onlineModeTeam)),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (s) => setState(() => _mode = s.first),
                ),
                if (_mode == 'team')
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(l.teamSizeHint(c.teamMinSize, c.teamMaxSize), style: Theme.of(context).textTheme.bodySmall),
                  ),
                SectionTitle(l.createPassages),
                PassageListEditor(
                  codes: _passages,
                  lang: lang,
                  requiredCount: count,
                  onChanged: (v) => setState(() => _passages = v),
                ),
                SectionTitle(l.createBible),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'fr', label: Text('Louis Segond 1910')),
                    ButtonSegment(value: 'en', label: Text('King James')),
                  ],
                  selected: {lang},
                  onSelectionChanged: (s) => setState(() => _lang = s.first),
                ),
                const SizedBox(height: 12),
                Text(l.createQuestions(count)),
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
                  onChanged: (v) => setState(() => _seconds = (v / 5).round() * 5),
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
                if (_mode == 'solo') ...[
                  Text(l.createMaxPlayers(maxPlayers)),
                  Slider(
                    value: maxPlayers.toDouble(),
                    min: 2,
                    max: c.maxPlayers.toDouble(),
                    divisions: c.maxPlayers - 2 > 0 ? c.maxPlayers - 2 : 1,
                    label: '$maxPlayers',
                    onChanged: (v) => setState(() => _maxPlayers = v.round()),
                  ),
                ],
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.createPublic),
                  subtitle: Text(l.createPublicHint),
                  value: _public,
                  onChanged: (v) => setState(() => _public = v),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(l.createSubmit),
                  onPressed: _busy || _passages.isEmpty
                      ? null
                      : () {
                          _count = count;
                          _seconds = seconds;
                          _hand = hand;
                          _maxPlayers = maxPlayers;
                          _submit();
                        },
                ),
                if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }
}
