import 'dart:math';

import '../content/models.dart';

/// Bilan d'un parcours : une série de questions tirées de toutes ses leçons.
///
/// Une question par leçon d'abord (leçons dans un ordre au hasard), pour que
/// le bilan couvre le parcours ; puis, s'il manque des questions, une deuxième
/// par leçon, etc. Au plus [maxTrueFalse] vrai/faux, pour garder la série
/// exigeante. Les questions gardent l'ordre du parcours : le bilan suit le fil
/// des leçons.
class PathReview {
  static const defaultCount = 10;
  static const maxTrueFalse = 2;

  static List<Question> build(LearningPath path, {int count = defaultCount, Random? random}) {
    final rnd = random ?? Random();
    final pools = [
      for (final l in path.lessons) [...l.questions]..shuffle(rnd),
    ];
    final picked = <Question>{};
    var trueFalse = 0;
    final order = [for (var i = 0; i < pools.length; i++) i]..shuffle(rnd);
    var progress = true;
    while (picked.length < count && progress) {
      progress = false;
      for (final i in order) {
        if (picked.length >= count) break;
        final pool = pools[i];
        final k = pool.indexWhere((q) => q is! TrueFalseQuestion || trueFalse < maxTrueFalse);
        if (k < 0) continue;
        final q = pool.removeAt(k);
        if (q is TrueFalseQuestion) trueFalse++;
        picked.add(q);
        progress = true;
      }
    }
    final rank = <String, int>{};
    for (final l in path.lessons) {
      for (final q in l.questions) {
        rank[q.id] = rank.length;
      }
    }
    return picked.toList()..sort((a, b) => rank[a.id]!.compareTo(rank[b.id]!));
  }
}
