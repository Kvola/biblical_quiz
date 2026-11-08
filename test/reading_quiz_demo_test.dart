// Démonstration (pas un test) : affiche des quiz de lecture pour relecture humaine.
//   flutter test test/reading_quiz_demo_test.dart --plain-name demo
@Tags(['demo'])
library;

import 'dart:math';

import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/content/models.dart';
import 'package:biblical_quiz/domain/reading_quiz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'content_test.dart' show loadBible, loadContent;

void main() {
  test('demo', () {
    final content = loadContent();
    for (final (lang, t) in [('fr', Translation.lsg), ('en', Translation.kjv)]) {
      final bible = loadBible(t);
      for (final scope in [
        const ReadingScope({4: null}), // Nombres (aucune question relue)
        const ReadingScope({43: {1, 2, 3, 4, 5, 6}}), // Jean 1-6 (chapitres lus)
        const ReadingScope({59: null, 65: null}), // Jacques + Jude
      ]) {
        final qs = ReadingQuiz.build(content: content, bible: bible, lang: lang, scope: scope, count: 8, random: Random(3));
        // ignore: avoid_print
        print('\n==== $lang ${scope.books}');
        for (final q in qs) {
          // ignore: avoid_print
          print('${q.id.startsWith('gen-') ? '[texte]' : '[relue]'} ${q.prompt.of(lang)}');
          if (q is! ChoiceQuestion) continue;
          final c = q;
          for (var i = 0; i < c.fr.length; i++) {
            // ignore: avoid_print
            print('   ${i == c.answer ? '*' : ' '} ${lang == 'fr' ? c.fr[i] : c.en[i]}');
          }
        }
      }
    }
  });
}
