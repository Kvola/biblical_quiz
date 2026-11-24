import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ai/ai_bank.dart';
import '../../online/api.dart';
import '../../providers.dart';
import '../common.dart';

/// Carte « Questions de compréhension » du quiz sur mes lectures.
///
/// Éteinte tant que la personne ne l'a pas activée (l'application est hors
/// ligne par nature : rien ne part vers le serveur sans son accord). Activée,
/// elle lit la banque du serveur pour les chapitres choisis (gratuit), garde
/// les questions sur l'appareil, et permet de DEMANDER les chapitres absents
/// dans la limite du quota du jour. Sans réseau, elle le dit et le quiz se sert
/// de ce qui a déjà été reçu.
class AiQuestionsCard extends ConsumerStatefulWidget {
  const AiQuestionsCard({super.key, required this.chapters});

  /// Chapitres de la portée (« livre:chapitre »), dans l'ordre de la Bible.
  final List<String> chapters;

  @override
  ConsumerState<AiQuestionsCard> createState() => _AiQuestionsCardState();
}

class _AiQuestionsCardState extends ConsumerState<AiQuestionsCard> {
  static const _debounce = Duration(milliseconds: 700);
  static const _pollEvery = Duration(seconds: 10);
  static const _maxPolls = 36; // six minutes

  AiBankStatus? _status;
  bool _loading = false;
  bool _offline = false;
  bool _asking = false;
  Timer? _timer;
  int _polls = 0;
  int _generation = 0; // ignore la réponse d'une lecture dépassée par un nouveau choix

  bool get _enabled => ref.read(settingsProvider).value?.aiQuestions ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _schedule(Duration.zero));
  }

  @override
  void didUpdateWidget(AiQuestionsCard old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.chapters, widget.chapters)) {
      _polls = 0;
      _schedule(_debounce);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _schedule(Duration delay) {
    _timer?.cancel();
    if (!mounted || !_enabled) return;
    _timer = Timer(delay, _sync);
  }

  Future<void> _sync() async {
    if (!mounted || !_enabled) return;
    final mine = ++_generation;
    if (widget.chapters.isEmpty) {
      setState(() => _status = null);
      return;
    }
    setState(() => _loading = _status == null);
    try {
      final status = await ref.read(aiBankServiceProvider).sync(widget.chapters);
      if (!mounted || mine != _generation) return;
      setState(() {
        _status = status;
        _offline = false;
        _loading = false;
      });
      if (status.count(AiChapterState.preparing) > 0 && _polls++ < _maxPolls) {
        _timer?.cancel();
        _timer = Timer(_pollEvery, _sync);
      }
    } on ApiException {
      if (!mounted || mine != _generation) return;
      setState(() {
        _offline = true;
        _loading = false;
      });
    }
  }

  Future<void> _ask(int count) async {
    final status = _status;
    if (status == null || _asking) return;
    final l = context.l10n;
    setState(() => _asking = true);
    final service = ref.read(aiBankServiceProvider);
    String? problem;
    for (final code in status.requestable.take(count)) {
      try {
        await service.request(code);
      } on ApiException catch (e) {
        // Un chapitre qui ne se prête pas aux questions n'arrête pas les suivants.
        if (e.code == 'AI_NO_QUESTIONS') continue;
        problem = e.code == 'AI_SERVER_QUOTA' ? l.aiServerQuota : l.aiRequestFailed;
        break;
      }
    }
    if (!mounted) return;
    setState(() => _asking = false);
    if (problem != null) context.toast(problem);
    _polls = 0;
    await _sync();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    // Le réglage peut changer ailleurs (Réglages) : relancer la lecture quand il s'allume.
    ref.listen(settingsProvider.select((s) => s.value?.aiQuestions ?? false), (_, on) {
      if (on) _schedule(Duration.zero);
    });
    final enabled = ref.watch(settingsProvider.select((s) => s.value?.aiQuestions ?? false));
    final status = _status;
    final children = <Widget>[
      Row(
        children: [
          Icon(Icons.auto_awesome_outlined, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(l.aiCardTitle, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w700))),
        ],
      ),
      const SizedBox(height: 8),
    ];
    if (!enabled) {
      children.addAll([
        Text(l.aiCardIntro, style: text.bodyMedium),
        const SizedBox(height: 6),
        Text(l.aiCardPrivacy, style: text.bodySmall),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.tonal(
            key: const ValueKey('ai-enable'),
            onPressed: () => ref.read(settingsRepoProvider).setAiQuestions(true),
            child: Text(l.aiEnable),
          ),
        ),
      ]);
    } else if (_offline) {
      children.addAll([
        Text(l.aiOffline, style: text.bodyMedium),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(onPressed: _sync, child: Text(l.retry)),
        ),
      ]);
    } else if (status == null) {
      children.add(
        _loading
            ? Row(
                children: [
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.aiChecking, style: text.bodyMedium)),
                ],
              )
            : Text(l.aiCardIntro, style: text.bodyMedium),
      );
    } else if (!status.quota.enabled && status.count(AiChapterState.ready) == 0) {
      children.add(Text(l.aiUnavailable, style: text.bodyMedium));
    } else {
      final ready = status.count(AiChapterState.ready);
      final preparing = status.count(AiChapterState.preparing);
      final missing = status.requestable.length;
      final canAsk = missing < status.quota.remaining ? missing : status.quota.remaining;
      children.add(Text(l.aiCoverage(ready, status.states.length), style: text.bodyMedium));
      if (preparing > 0) {
        children.addAll([const SizedBox(height: 6), Text(l.aiPreparing(preparing), style: text.bodySmall)]);
      }
      if (missing == 0 && preparing == 0) {
        children.addAll([const SizedBox(height: 6), Text(l.aiAllCovered, style: text.bodySmall)]);
      } else if (missing > 0 && status.quota.enabled) {
        children.addAll([
          const SizedBox(height: 6),
          Text(
            status.quota.limited == 'server_quota' ? l.aiServerQuota : l.aiQuotaLeft(status.quota.remaining),
            style: text.bodySmall,
          ),
          if (canAsk > 0) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const ValueKey('ai-ask'),
                onPressed: _asking ? null : () => _ask(canAsk),
                icon: _asking
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.auto_awesome_outlined, size: 18),
                label: Text(l.aiAsk(canAsk)),
              ),
            ),
          ],
        ]);
      }
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      ),
    );
  }
}
