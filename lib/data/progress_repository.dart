import 'package:drift/drift.dart';

import '../domain/book_challenge.dart';
import '../domain/days.dart';
import '../domain/quiz_session.dart';
import '../domain/review.dart';
import 'database.dart';

class ProgressSummary {
  const ProgressSummary({
    required this.lessonsCompleted,
    required this.answered,
    required this.correct,
    required this.mastered,
    required this.currentStreak,
    required this.bestStreak,
    required this.activeToday,
  });

  final int lessonsCompleted;
  final int answered;
  final int correct;
  final int mastered;
  final int currentStreak;
  final int bestStreak;
  final bool activeToday;

  double get accuracy => answered == 0 ? 0 : correct / answered;
}

/// Toute écriture de progression passe par ici, en une transaction : une
/// leçon terminée met à jour d'un bloc la leçon, chaque question et le jour.
class ProgressRepository {
  ProgressRepository(this.db, {int Function()? today}) : _today = today ?? (() => dayKey(DateTime.now()));

  final AppDatabase db;
  final int Function() _today;

  int get today => _today();

  /// Enregistre le résultat d'un quiz.
  ///
  /// [lessonId] : leçon ou fiche « book-N » terminée ; null pour une session
  /// de révision ou un défi (seules les questions et le jour sont comptés).
  /// Les questions fabriquées (défi des livres) ne sont pas suivies en révision.
  Future<void> recordQuiz({String? lessonId, required List<AnswerRecord> records, int? total}) async {
    final day = today;
    await db.transaction(() async {
      for (final r in records) {
        if (r.questionId.startsWith(BookChallenge.idPrefix)) continue;
        final existing = await (db.select(db.questionStats)..where((t) => t.questionId.equals(r.questionId)))
            .getSingleOrNull();
        // Une même question répondue deux fois le même jour (leçon refaite
        // aussitôt) ne fait pas avancer la révision : ce serait de la mémoire
        // immédiate, pas un apprentissage.
        final sameDayRepeat = existing != null && existing.lastDay == day && r.correct;
        final next = sameDayRepeat
            ? (box: existing.box, dueDay: existing.dueDay)
            : Leitner.next(box: existing?.box ?? -1, correct: r.correct, today: day);
        await db.into(db.questionStats).insertOnConflictUpdate(
          QuestionStatsCompanion.insert(
            questionId: r.questionId,
            box: next.box,
            dueDay: Value(next.dueDay),
            correct: Value((existing?.correct ?? 0) + (r.correct ? 1 : 0)),
            wrong: Value((existing?.wrong ?? 0) + (r.correct ? 0 : 1)),
            lastDay: day,
          ),
        );
      }

      final score = records.where((r) => r.correct).length;
      if (lessonId != null) {
        final prev = await (db.select(db.lessonProgress)..where((t) => t.lessonId.equals(lessonId))).getSingleOrNull();
        await db.into(db.lessonProgress).insertOnConflictUpdate(
          LessonProgressCompanion.insert(
            lessonId: lessonId,
            bestScore: prev == null || score > prev.bestScore ? score : prev.bestScore,
            lastScore: score,
            total: total ?? records.length,
            attempts: (prev?.attempts ?? 0) + 1,
            firstCompletedDay: prev?.firstCompletedDay ?? day,
            lastDay: day,
          ),
        );
      }

      await db.customInsert(
        'INSERT INTO activity_days (day, answered, lessons) VALUES (?, ?, ?) '
        'ON CONFLICT(day) DO UPDATE SET answered = answered + excluded.answered, lessons = lessons + excluded.lessons',
        variables: [Variable.withInt(day), Variable.withInt(records.length), Variable.withInt(lessonId == null ? 0 : 1)],
        updates: {db.activityDays},
      );
    });
  }

  /// Marque le jour comme actif (lecture libre de la Bible), sans rien compter d'autre.
  Future<void> markActive() => db.customInsert(
    'INSERT INTO activity_days (day) VALUES (?) ON CONFLICT(day) DO NOTHING',
    variables: [Variable.withInt(today)],
    updates: {db.activityDays},
  );

  Stream<Map<String, LessonProgressData>> watchLessons() =>
      db.select(db.lessonProgress).watch().map((rows) => {for (final r in rows) r.lessonId: r});

  /// Questions dont la révision est due aujourd'hui ou en retard.
  Stream<List<String>> watchDue() {
    final q = db.select(db.questionStats)
      ..where((t) => t.dueDay.isNotNull() & t.dueDay.isSmallerOrEqualValue(today))
      ..orderBy([(t) => OrderingTerm.asc(t.dueDay), (t) => OrderingTerm.asc(t.box)]);
    return q.watch().map((rows) => [for (final r in rows) r.questionId]);
  }

  Stream<ProgressSummary> watchSummary() {
    final query = db.customSelect(
      'SELECT '
      '(SELECT COUNT(*) FROM lesson_progress) AS lessons, '
      '(SELECT COALESCE(SUM(correct + wrong), 0) FROM question_stats) AS answered, '
      '(SELECT COALESCE(SUM(correct), 0) FROM question_stats) AS correct, '
      '(SELECT COUNT(*) FROM question_stats WHERE due_day IS NULL) AS mastered',
      readsFrom: {db.lessonProgress, db.questionStats, db.activityDays},
    );
    return query.watch().asyncMap((rows) async {
      final r = rows.single;
      final days = (await db.select(db.activityDays).get()).map((d) => d.day).toSet();
      final t = today;
      return ProgressSummary(
        lessonsCompleted: r.read<int>('lessons'),
        answered: r.read<int>('answered'),
        correct: r.read<int>('correct'),
        mastered: r.read<int>('mastered'),
        currentStreak: currentStreak(days, t),
        bestStreak: bestStreak(days),
        activeToday: days.contains(t),
      );
    });
  }

  // -- Versets favoris -----------------------------------------------------
  Stream<List<String>> watchFavorites() {
    final q = db.select(db.favorites)..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.watch().map((rows) => [for (final r in rows) r.ref]);
  }

  /// Ajoute ou retire ; renvoie vrai si le verset est désormais favori.
  Future<bool> toggleFavorite(String ref) => db.transaction(() async {
    final deleted = await (db.delete(db.favorites)..where((t) => t.ref.equals(ref))).go();
    if (deleted > 0) return false;
    await db.into(db.favorites).insert(
      FavoritesCompanion.insert(ref: ref, createdAt: DateTime.now().millisecondsSinceEpoch),
    );
    return true;
  });

  /// Efface la progression (pas les favoris ni les réglages).
  Future<void> resetProgress() => db.transaction(() async {
    await db.delete(db.lessonProgress).go();
    await db.delete(db.questionStats).go();
    await db.delete(db.activityDays).go();
  });
}
