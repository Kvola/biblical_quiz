import 'dart:math';

import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/content/content.dart';
import 'package:biblical_quiz/content/models.dart';
import 'package:biblical_quiz/core/books.dart';
import 'package:biblical_quiz/domain/reading_quiz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'content_test.dart' show loadBible, loadContent;

void main() {
  late final Content content;
  late final Bible lsg, kjv;

  setUpAll(() {
    content = loadContent();
    lsg = loadBible(Translation.lsg);
    kjv = loadBible(Translation.kjv);
  });

  /// Vérifie qu'une question tirée du texte est fidèle à la Bible embarquée.
  void expectFaithful(Question q, Bible bible, String lang) {
    expect(q, isA<ChoiceQuestion>());
    final c = q as ChoiceQuestion;
    final options = lang == 'fr' ? c.fr : c.en;
    expect(options.toSet().length, options.length, reason: 'propositions en double : $options');
    expect(c.answer, inInclusiveRange(0, options.length - 1));
    final verse = bible.text(q.ref);
    if (q.id.contains('-cloze-')) {
      final prompt = q.prompt.of(lang);
      final quoted = RegExp(r'[«“]\s?(.*)\s?[»”]$', dotAll: true).firstMatch(prompt)!.group(1)!.trim();
      // Remettre la bonne réponse dans le blanc redonne EXACTEMENT le verset : le texte n'est jamais altéré.
      expect(quoted.replaceFirst('_____', options[c.answer]), verse, reason: q.id);
      for (var i = 0; i < options.length; i++) {
        if (i == c.answer) continue;
        expect(RegExp('(?<![\\p{L}])${RegExp.escape(options[i])}(?![\\p{L}])', unicode: true).hasMatch(verse), isFalse,
            reason: 'distracteur présent dans le verset : ${options[i]} ($verse)');
      }
    } else if (q.id.contains('-book-')) {
      expect(options[c.answer], bookById(q.ref.book).name(lang));
      expect(q.prompt.of(lang), contains(verse));
    } else if (q.id.contains('-order-')) {
      expect(options.length, 4);
    } else {
      fail('type inconnu : ${q.id}');
    }
  }

  test('portée : seulement les chapitres choisis ; relues d\'abord', () {
    const scope = ReadingScope({43: {1, 2, 3, 4, 5, 6}});
    final qs = ReadingQuiz.build(content: content, bible: lsg, lang: 'fr', scope: scope, count: 20, random: Random(1));
    expect(qs, hasLength(20));
    for (final q in qs) {
      expect(q.ref.book, 43);
      expect(q.ref.startChapter, inInclusiveRange(1, 6), reason: q.id);
    }
    final firstGenerated = qs.indexWhere((q) => q.id.startsWith('gen-'));
    if (firstGenerated >= 0) {
      expect(qs.skip(firstGenerated).every((q) => q.id.startsWith('gen-')), isTrue, reason: 'relues d\'abord, puis texte');
    }
  });

  test('livre sans question relue (Nombres) : quiz complet tiré du texte, fidèle', () {
    for (final (bible, lang) in [(lsg, 'fr'), (kjv, 'en')]) {
      for (var seed = 0; seed < 6; seed++) {
        final qs = ReadingQuiz.build(
          content: content, bible: bible, lang: lang, scope: const ReadingScope({4: null}), count: 15, random: Random(seed));
        expect(qs.length, 15);
        for (final q in qs.where((q) => q.id.startsWith(ReadingQuiz.idPrefix))) {
          expectFaithful(q, bible, lang);
        }
      }
    }
  });

  test('plusieurs livres : questions « Dans quel livre ? » parmi les livres choisis', () {
    const scope = ReadingScope({40: null, 41: null, 42: null, 43: null});
    final generated = <Question>[];
    for (var seed = 0; seed < 8; seed++) {
      generated.addAll(ReadingQuiz.build(
        content: content, bible: lsg, lang: 'fr', scope: scope, count: 170, random: Random(seed),
      ).where((q) => q.id.contains('-book-')));
    }
    expect(generated, isNotEmpty);
    for (final q in generated) {
      expectFaithful(q, lsg, 'fr');
      final options = (q as ChoiceQuestion).fr.toSet();
      expect(options, {for (final b in [40, 41, 42, 43]) bookById(b).fr}, reason: 'les quatre évangiles choisis');
    }
  });

  test('ordre du récit : la bonne réponse est le passage le plus tôt du livre', () {
    var checked = 0;
    for (var seed = 0; seed < 10; seed++) {
      final qs = ReadingQuiz.build(
        content: content, bible: lsg, lang: 'fr', scope: const ReadingScope({7: null}), count: 30, random: Random(seed));
      for (final q in qs.where((q) => q.id.contains('-order-'))) {
        final c = q as ChoiceQuestion;
        final refs = q.id.substring(q.id.indexOf('-order-') + 7).split('_');
        expect(refs, hasLength(4));
        final positions = [for (final r in refs) r.split(':').skip(1).map(int.parse).toList()];
        final earliest = positions.reduce((a, b) => a[0] < b[0] || (a[0] == b[0] && a[1] < b[1]) ? a : b);
        expect(q.ref.startChapter, earliest[0]);
        expect(q.ref.startVerse, earliest[1]);
        expect(lsg.text(q.ref).startsWith(c.fr[c.answer].replaceAll('…', '')), isTrue);
        checked++;
      }
    }
    expect(checked, greaterThan(0));
  });

  test('chacun des 66 livres donne un quiz (FR et EN), fidèle au texte', () {
    for (final (bible, lang) in [(lsg, 'fr'), (kjv, 'en')]) {
      for (var b = 1; b <= 66; b++) {
        final qs = ReadingQuiz.build(
          content: content, bible: bible, lang: lang, scope: ReadingScope({b: null}), count: 10, random: Random(b));
        expect(qs.length, greaterThanOrEqualTo(5), reason: '${bookById(b).fr} ($lang) : ${qs.length} questions');
        for (final q in qs) {
          expect(q.ref.book, b);
          if (q.id.startsWith(ReadingQuiz.idPrefix)) expectFaithful(q, bible, lang);
        }
      }
    }
  });

  test('jamais de nom divin ni de réponse évidente à compléter', () {
    for (final b in [1, 19, 43, 45]) {
      for (var seed = 0; seed < 5; seed++) {
        for (final q in ReadingQuiz.build(
          content: content, bible: lsg, lang: 'fr', scope: ReadingScope({b: null}), count: 40, random: Random(seed))) {
          if (!q.id.contains('-cloze-')) continue;
          final c = q as ChoiceQuestion;
          expect(['Dieu', 'Eternel', 'Éternel', 'Seigneur', 'Christ', 'Jésus'], isNot(contains(c.fr[c.answer])), reason: q.id);
        }
      }
    }
  });

  test('portée vide : aucun quiz ; même graine : même quiz', () {
    expect(ReadingQuiz.build(content: content, bible: lsg, lang: 'fr', scope: const ReadingScope({})), isEmpty);
    expect(ReadingQuiz.build(content: content, bible: lsg, lang: 'fr', scope: const ReadingScope({1: <int>{}})), isEmpty);
    List<String> ids(int seed) => ReadingQuiz.build(
      content: content, bible: lsg, lang: 'fr', scope: const ReadingScope({18: null}), count: 12, random: Random(seed),
    ).map((q) => q.id).toList();
    expect(ids(5), ids(5));
  });
}
