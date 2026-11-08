import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bible/bible.dart';
import '../content/models.dart';
import '../domain/book_challenge.dart';
import '../providers.dart';
import 'common.dart';
import 'quiz/quiz_screen.dart';

/// Nombre maximal de questions par séance de révision : une séance doit rester courte.
const reviewBatch = 12;

/// Ouvre une séance avec les questions dues aujourd'hui (les plus en retard d'abord).
Future<void> openReview(BuildContext context, WidgetRef ref) async {
  final content = await ref.read(contentProvider.future);
  final due = ref.read(dueProvider).value ?? const [];
  final questions = <Question>[for (final id in due) ?content.question(id)].take(reviewBatch).toList();
  if (!context.mounted) return;
  if (questions.isEmpty) {
    context.toast(context.l10n.reviewEmpty);
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => QuizScreen(title: context.l10n.reviewTitle, questions: questions, shuffleQuestions: true),
    ),
  );
}

/// Défi « Dans quel livre ? » : dix versets-clés tirés au hasard.
Future<void> openBookChallenge(BuildContext context, WidgetRef ref) async {
  final lang = context.lang;
  final l = context.l10n;
  final content = await ref.read(contentProvider.future);
  final bible = await ref.read(bibleProvider(Translation.forLang(lang)).future);
  final questions = BookChallenge.build(content: content, bible: bible, lang: lang);
  if (!context.mounted || questions.isEmpty) return;
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          QuizScreen(title: l.challengeTitle, headline: l.challengeQuestion, questions: questions, trackReview: false),
    ),
  );
}
