import 'package:flutter/material.dart';

import '../../content/models.dart';
import '../../core/theme.dart';
import '../../domain/quiz_session.dart';
import '../common.dart';

/// Haut de l'écran de résultat : score, message, et les questions ratées
/// avec leur bonne réponse. Les écrans y ajoutent leurs propres sections.
class ResultHeader extends StatelessWidget {
  const ResultHeader({super.key, required this.session, this.showMissedHint = true});

  final QuizSession session;
  final bool showMissedHint;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final score = session.score, total = session.length;
    final ratio = score / total;
    final message = ratio == 1
        ? l.resultPerfect
        : ratio >= 0.75
        ? l.resultGood
        : ratio >= 0.5
        ? l.resultFair
        : l.resultLow;
    final p = context.palette;
    final color = ratio >= 0.75 ? p.success : (ratio >= 0.5 ? p.accentIcon : p.error);
    final text = Theme.of(context).textTheme;
    final missed = session.missed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 10,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.15),
                ),
                Center(
                  child: Text(
                    l.resultScore(score, total),
                    style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(message, textAlign: TextAlign.center, style: text.titleMedium),
        if (missed.isNotEmpty) ...[
          SectionTitle(l.missedTitle),
          for (final q in missed) _MissedTile(question: q, lang: lang),
          if (showMissedHint)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(l.missedHint, style: text.bodySmall),
            ),
        ],
      ],
    );
  }
}

class _MissedTile extends StatelessWidget {
  const _MissedTile({required this.question, required this.lang});

  final Question question;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final answer = question is TrueFalseQuestion
        ? ((question as TrueFalseQuestion).answer ? l.trueLabel : l.falseLabel)
        : question.options(lang)[question.correctIndex];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question.prompt.of(lang), maxLines: 4, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.check, size: 18, color: context.palette.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(answer, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dialogue « Quitter ? » quand une série est entamée.
Future<bool> confirmQuit(BuildContext context) async {
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(l.quitTitle),
      content: Text(l.quitBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.stay)),
        TextButton(onPressed: () => Navigator.pop(c, true), child: Text(l.quit)),
      ],
    ),
  );
  return ok ?? false;
}
