import 'dart:math';

import '../bible/bible.dart';
import '../content/content.dart';
import '../content/models.dart';
import '../core/books.dart';
import '../core/verse_ref.dart';

/// « Dans quel livre se trouve ce verset ? »
///
/// Questions fabriquées à partir des versets-clés du contenu : elles sont
/// justes par construction (le texte vient de la Bible embarquée) et
/// apprennent à situer les grands textes. Les distracteurs sont pris de
/// préférence dans le même genre (un évangile contre d'autres évangiles),
/// pour que la question demande de connaître le texte, pas de deviner.
class BookChallenge {
  static const idPrefix = 'gen-book-';

  /// Versets candidats : un verset par verset-clé, sans doublon.
  static List<VerseRef> candidates(Content content) {
    final seen = <String>{};
    final out = <VerseRef>[];
    void add(VerseRef r) {
      final single = VerseRef.single(r.book, r.startChapter, r.startVerse);
      if (seen.add(single.code)) out.add(single);
    }

    for (final l in content.allLessons) {
      add(l.keyVerse);
    }
    for (final b in content.books) {
      add(b.keyVerse);
    }
    return out;
  }

  /// Un verset qui se termine au milieu d'une phrase (« … parlé à nos pères
  /// par les prophètes, Dieu, ») ne se comprend pas seul : on l'écarte.
  static bool isCompleteSentence(String text) => RegExp(r'[.!?»"”]$').hasMatch(text.trim());

  /// Versets candidats qui forment une phrase complète dans [bible].
  static List<VerseRef> readableCandidates(Content content, Bible bible) =>
      [for (final r in candidates(content)) if (isCompleteSentence(bible.text(r))) r];

  static List<Question> build({
    required Content content,
    required Bible bible,
    required String lang,
    int count = 10,
    Random? random,
  }) {
    final rnd = random ?? Random();
    final pool = candidates(content)..shuffle(rnd);
    final questions = <Question>[];
    for (final ref in pool) {
      if (questions.length >= count) break;
      final text = bible.text(ref);
      // Un verset trop court (« Jésus pleura. ») ou trop long ne fait pas une bonne question.
      if (text.length < 40 || text.length > 320 || !isCompleteSentence(text)) continue;
      final correct = bookById(ref.book);
      final distractors = _distractors(correct, rnd);
      final options = [correct, ...distractors]..shuffle(rnd);
      final answer = options.indexOf(correct);
      final label = LText(refLabel(ref, 'fr'), refLabel(ref, 'en'));
      questions.add(
        ChoiceQuestion(
          id: '$idPrefix${ref.code}',
          prompt: LText('« $text »', '“$text”'),
          explain: LText('Ce verset se trouve en ${label.fr}.', 'This verse is found in ${label.en}.'),
          ref: ref,
          fr: [for (final b in options) b.fr],
          en: [for (final b in options) b.en],
          answer: answer,
        ),
      );
    }
    return questions;
  }

  static List<BookName> _distractors(BookName correct, Random rnd) {
    final sameGenre = books.where((b) => b.id != correct.id && b.genre == correct.genre).toList()..shuffle(rnd);
    final sameTestament = books
        .where((b) => b.id != correct.id && b.genre != correct.genre && b.testament == correct.testament)
        .toList()
      ..shuffle(rnd);
    final others = books.where((b) => b.id != correct.id && b.testament != correct.testament).toList()..shuffle(rnd);
    // Deux du même genre si possible, puis le même Testament, puis le reste.
    final picked = <BookName>[...sameGenre.take(2)];
    for (final b in [...sameTestament, ...sameGenre.skip(2), ...others]) {
      if (picked.length == 3) break;
      if (!picked.contains(b)) picked.add(b);
    }
    return picked;
  }
}
