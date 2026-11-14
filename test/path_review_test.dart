import 'dart:math';

import 'package:biblical_quiz/content/models.dart';
import 'package:biblical_quiz/domain/path_review.dart';
import 'package:flutter_test/flutter_test.dart';

import 'content_test.dart' show loadContent;

void main() {
  final content = loadContent();

  test('bilan : une question par leçon d\'abord, au plus 2 vrai/faux, dans l\'ordre du parcours', () {
    for (final path in content.paths) {
      for (var seed = 0; seed < 20; seed++) {
        final qs = PathReview.build(path, random: Random(seed));
        final available = path.lessons.fold<int>(0, (n, l) => n + l.questions.length);
        expect(qs.length, min(PathReview.defaultCount, available), reason: path.id);
        expect(qs.map((q) => q.id).toSet().length, qs.length, reason: 'sans doublon');
        expect(qs.whereType<TrueFalseQuestion>().length, lessThanOrEqualTo(PathReview.maxTrueFalse));
        final lessonOf = {for (final q in qs) q.id: content.lessonOfQuestion(q.id)};
        expect(lessonOf.values.every((l) => path.lessons.any((x) => x.id == l)), isTrue, reason: 'questions du parcours');
        // Couverture : autant de leçons différentes que possible.
        expect(lessonOf.values.toSet().length, min(qs.length, path.lessons.length), reason: '${path.id} / $seed');
        final order = [for (final l in path.lessons) ...l.questions.map((q) => q.id)];
        final idx = qs.map((q) => order.indexOf(q.id)).toList();
        expect(idx, [...idx]..sort(), reason: 'ordre du parcours');
      }
    }
  });

  test('bilan : plus de questions que de leçons, puis tout le parcours au plus', () {
    final path = content.path('sin')!;
    final qs = PathReview.build(path, count: 20, random: Random(1));
    expect(qs.length, 20);
    final all = PathReview.build(path, count: 1000, random: Random(1));
    final tf = path.lessons.expand((l) => l.questions).whereType<TrueFalseQuestion>().length;
    final total = path.lessons.fold<int>(0, (n, l) => n + l.questions.length);
    expect(all.length, total - max(0, tf - PathReview.maxTrueFalse));
  });
}
