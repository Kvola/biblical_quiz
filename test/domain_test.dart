import 'dart:math';

import 'package:biblical_quiz/content/models.dart';
import 'package:biblical_quiz/core/verse_ref.dart';
import 'package:biblical_quiz/domain/days.dart';
import 'package:biblical_quiz/domain/quiz_session.dart';
import 'package:biblical_quiz/domain/review.dart';
import 'package:flutter_test/flutter_test.dart';

ChoiceQuestion choice(String id, {int answer = 0}) => ChoiceQuestion(
  id: id,
  prompt: const LText('q', 'q'),
  explain: const LText('e', 'e'),
  ref: VerseRef.parse('1:1:1'),
  fr: const ['a', 'b', 'c', 'd'],
  en: const ['A', 'B', 'C', 'D'],
  answer: answer,
);

void main() {
  group('VerseRef', () {
    test('analyse les trois formes', () {
      expect(VerseRef.parse('43:3:16').isSingle, isTrue);
      final r = VerseRef.parse('1:1:1-31');
      expect((r.startChapter, r.startVerse, r.endChapter, r.endVerse), (1, 1, 1, 31));
      final x = VerseRef.parse('1:1:1-2:3');
      expect((x.endChapter, x.endVerse), (2, 3));
      expect(x.covers(1, 31), isTrue);
      expect(x.covers(2, 3), isTrue);
      expect(x.covers(2, 4), isFalse);
    });

    test('code est l’inverse de parse', () {
      for (final s in ['43:3:16', '1:1:1-31', '1:1:1-2:3']) {
        expect(VerseRef.parse(s).code, s);
      }
    });

    test('refuse les références invalides', () {
      for (final s in ['', '67:1:1', '0:1:1', '1:2:5-1', '1:2:5-1:3', 'Jn 3:16', '1:1']) {
        expect(() => VerseRef.parse(s), throwsFormatException, reason: s);
      }
    });
  });

  group('Jours et séries', () {
    test('addDays traverse les mois et les années', () {
      expect(addDays(20261231, 1), 20270101);
      expect(addDays(20260301, -1), 20260228);
      expect(addDays(20280301, -1), 20280229);
    });

    test('la série ne se perd pas avant la fin de la journée', () {
      expect(currentStreak({20261106, 20261107}, 20261108), 2);
      expect(currentStreak({20261106, 20261107, 20261108}, 20261108), 3);
      expect(currentStreak({20261105, 20261106}, 20261108), 0);
      expect(currentStreak({}, 20261108), 0);
    });

    test('meilleure série', () {
      expect(bestStreak([20261101, 20261102, 20261103, 20261105, 20261106]), 3);
      expect(bestStreak([20261231, 20270101]), 2);
      expect(bestStreak([]), 0);
    });
  });

  group('Leitner', () {
    test('bonne réponse à la première rencontre : boîte 1, dans 3 jours', () {
      final n = Leitner.next(box: -1, correct: true, today: 20261108);
      expect(n.box, 1);
      expect(n.dueDay, 20261111);
    });

    test('erreur : boîte 0, demain', () {
      final n = Leitner.next(box: 3, correct: false, today: 20261108);
      expect(n.box, 0);
      expect(n.dueDay, 20261109);
    });

    test('au-delà de la dernière boîte : acquise, plus de révision', () {
      final n = Leitner.next(box: Leitner.mastered - 1, correct: true, today: 20261108);
      expect(n.box, Leitner.mastered);
      expect(n.dueDay, isNull);
    });
  });

  group('QuizSession', () {
    test('mélange les propositions mais retrouve la bonne réponse', () {
      for (var seed = 0; seed < 20; seed++) {
        final s = QuizSession([choice('q1', answer: 2)], random: Random(seed));
        final options = s.current.options('fr');
        expect(options[s.current.correctPosition], 'c');
        expect(options.toSet(), {'a', 'b', 'c', 'd'});
      }
    });

    test('vrai/faux garde l’ordre Vrai, Faux', () {
      final tf = TrueFalseQuestion(
        id: 't',
        prompt: const LText('q', 'q'),
        explain: const LText('e', 'e'),
        ref: VerseRef.parse('1:1:1'),
        answer: false,
      );
      final s = QuizSession([tf], random: Random(1));
      expect(s.current.order, [0, 1]);
      expect(s.current.correctPosition, 1);
    });

    test('une seule réponse par question, score et ratées', () {
      final s = QuizSession([choice('q1'), choice('q2'), choice('q3')], random: Random(3));
      expect(s.next(), isFalse, reason: 'on ne passe pas sans répondre');
      final good = s.current.correctPosition;
      expect(s.answer(good), isTrue);
      expect(s.answer((good + 1) % 4), isTrue, reason: 'le second appui est ignoré');
      expect(s.next(), isTrue);
      s.answer((s.current.correctPosition + 1) % 4);
      expect(s.next(), isTrue);
      s.answer(s.current.correctPosition);
      expect(s.isLast, isTrue);
      expect(s.next(), isFalse);
      expect(s.isFinished, isTrue);
      expect(s.score, 2);
      expect(s.missed.map((q) => q.id), ['q2']);
      expect(s.records.map((r) => (r.questionId, r.correct)), [('q1', true), ('q2', false), ('q3', true)]);
    });

    test('refuse une position hors limites', () {
      final s = QuizSession([choice('q1')]);
      expect(() => s.answer(4), throwsRangeError);
    });
  });
}
