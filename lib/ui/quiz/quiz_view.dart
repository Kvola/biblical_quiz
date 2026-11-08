import 'package:flutter/material.dart';

import '../../content/models.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../domain/quiz_session.dart';
import '../common.dart';
import '../widgets/verse_sheet.dart';

/// Pose les questions une à une : choix, correction immédiate, explication
/// et renvoi au verset, puis « Suivant ». Appelle [onFinished] une seule fois.
class QuizView extends StatefulWidget {
  const QuizView({super.key, required this.session, required this.onFinished, this.onProgress, this.headline});

  final QuizSession session;
  final void Function(QuizSession session) onFinished;

  /// Appelé après chaque réponse : l'écran parent sait ainsi qu'une série est
  /// entamée (et demande confirmation avant de la quitter).
  final VoidCallback? onProgress;

  /// Texte fixe au-dessus de chaque question (ex. « Dans quel livre se trouve ce verset ? »).
  final String? headline;

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  final _scroll = ScrollController();
  bool _finished = false;

  QuizSession get s => widget.session;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _choose(int position) {
    if (s.isAnswered) return;
    setState(() => s.answer(position));
    widget.onProgress?.call();
    // L'explication apparaît sous les réponses : on la fait venir à l'écran.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _next() {
    if (s.isLast) {
      if (_finished) return;
      _finished = true;
      widget.onFinished(s);
      return;
    }
    setState(s.next);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final item = s.current;
    final q = item.question;
    final options = q is TrueFalseQuestion ? [l.trueLabel, l.falseLabel] : item.options(lang);
    final answered = s.isAnswered;
    final chosen = s.chosenPosition;
    final correctPos = item.correctPosition;
    final text = Theme.of(context).textTheme;

    return Column(
      children: [
        LinearProgressIndicator(value: (s.index + (answered ? 1 : 0)) / s.length, minHeight: 4),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text(l.questionOf(s.index + 1, s.length), style: text.labelLarge),
              const SizedBox(height: 8),
              if (widget.headline != null) ...[
                Text(widget.headline!, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(q.prompt.of(lang), style: scriptureStyle(context, 1.0).copyWith(fontStyle: FontStyle.italic)),
              ] else
                Text(q.prompt.of(lang), style: text.titleLarge?.copyWith(fontWeight: FontWeight.w600, height: 1.3)),
              const SizedBox(height: 20),
              for (var i = 0; i < options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _OptionButton(
                    key: ValueKey('option-$i'),
                    label: options[i],
                    state: !answered
                        ? _OptionState.idle
                        : i == correctPos
                        ? _OptionState.correct
                        : i == chosen
                        ? _OptionState.wrong
                        : _OptionState.dimmed,
                    onTap: answered ? null : () => _choose(i),
                  ),
                ),
              if (answered) ...[
                const SizedBox(height: 8),
                _Explanation(question: q, correct: chosen == correctPos, correctLabel: options[correctPos]),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: answered ? _next : null,
                child: Text(s.isLast ? l.seeResult : l.next),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  const _OptionButton({super.key, required this.label, required this.state, this.onTap});

  final String label;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color border, Color? fill, IconData? icon) = switch (state) {
      _OptionState.idle => (scheme.outline, null, null),
      _OptionState.correct => (QuizColors.olive, QuizColors.olive.withValues(alpha: 0.14), Icons.check_circle),
      _OptionState.wrong => (QuizColors.crimson, QuizColors.crimson.withValues(alpha: 0.12), Icons.cancel),
      _OptionState.dimmed => (scheme.outlineVariant, null, null),
    };
    return Semantics(
      button: true,
      selected: state == _OptionState.correct || state == _OptionState.wrong,
      child: Material(
        color: fill ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: state == _OptionState.idle ? 1 : 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: state == _OptionState.dimmed ? scheme.onSurfaceVariant : scheme.onSurface,
                      ),
                    ),
                  ),
                  if (icon != null) ...[const SizedBox(width: 8), Icon(icon, color: border)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.question, required this.correct, required this.correctLabel});

  final Question question;
  final bool correct;
  final String correctLabel;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final color = correct ? QuizColors.olive : QuizColors.crimson;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(correct ? Icons.check_circle : Icons.info_outline, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    correct ? l.correct : l.incorrect,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
            if (!correct) ...[
              const SizedBox(height: 6),
              Text(l.correctAnswerWas(correctLabel), style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 8),
            Text(question.explain.of(lang), style: const TextStyle(height: 1.4)),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l.readVerse(refLabel(question.ref, lang))),
                onPressed: () => showVerseSheet(context, question.ref),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
