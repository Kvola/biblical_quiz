import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/models.dart';
import '../../domain/quiz_session.dart';
import '../../providers.dart';
import '../common.dart';
import 'quiz_view.dart';
import 'result_view.dart';

/// Série de questions sans lecture préalable : fiche d'un livre, révision, défi.
///
/// Le résultat est enregistré une seule fois, à la fin de la série. Quitter en
/// cours de route n'enregistre rien (une série à moitié faite fausserait la révision).
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({
    super.key,
    required this.title,
    required this.questions,
    this.lessonId,
    this.headline,
    this.shuffleQuestions = false,
    this.resultExtras,
    this.trackReview = true,
  });

  final String title;
  final List<Question> questions;

  /// Fiche « book-N » : compte comme une leçon terminée.
  final String? lessonId;
  final String? headline;
  final bool shuffleQuestions;
  final List<Widget> Function(BuildContext context)? resultExtras;

  /// Les questions fabriquées (défi) n'ont pas de suivi de révision.
  final bool trackReview;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late QuizSession _session = _newSession();
  bool _done = false;

  QuizSession _newSession() => QuizSession(widget.questions, shuffleQuestions: widget.shuffleQuestions);

  Future<void> _finish(QuizSession s) async {
    setState(() => _done = true);
    await ref.read(progressRepoProvider).recordQuiz(lessonId: widget.lessonId, records: s.records, total: s.length);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final inProgress = !_done && _session.index + (_session.isAnswered ? 1 : 0) > 0;
    return PopScope(
      canPop: !inProgress,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmQuit(context) && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(
          top: false,
          child: _done
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    ResultHeader(session: _session, showMissedHint: widget.trackReview),
                    ...?widget.resultExtras?.call(context),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => setState(() {
                        _session = _newSession();
                        _done = false;
                      }),
                      child: Text(l.retryQuiz),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.finish)),
                  ],
                )
              : QuizView(
                  key: ObjectKey(_session),
                  session: _session,
                  headline: widget.headline,
                  onFinished: _finish,
                  onProgress: () => setState(() {}),
                ),
        ),
      ),
    );
  }
}
