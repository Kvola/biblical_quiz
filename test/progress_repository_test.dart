import 'package:biblical_quiz/data/database.dart';
import 'package:biblical_quiz/data/progress_repository.dart';
import 'package:biblical_quiz/data/settings_repository.dart';
import 'package:biblical_quiz/domain/quiz_session.dart';
import 'package:biblical_quiz/domain/review.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProgressRepository repo;
  var today = 20261108;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    today = 20261108;
    repo = ProgressRepository(db, today: () => today);
  });
  tearDown(() => db.close());

  test('une leçon terminée met à jour leçon, questions et jour', () async {
    await repo.recordQuiz(
      lessonId: 'story-creation',
      records: const [AnswerRecord('a', true), AnswerRecord('b', false)],
      total: 2,
    );
    final lessons = await repo.watchLessons().first;
    expect(lessons['story-creation']!.bestScore, 1);
    expect(lessons['story-creation']!.attempts, 1);
    // La question ratée revient demain ; la réussie dans 3 jours.
    expect(await repo.watchDue().first, isEmpty);
    today = 20261109;
    expect(await repo.watchDue().first, ['b']);
    today = 20261111;
    expect((await repo.watchDue().first).toSet(), {'a', 'b'});

    final s = await repo.watchSummary().first;
    expect(s.lessonsCompleted, 1);
    expect(s.answered, 2);
    expect(s.correct, 1);
  });

  test('meilleur score conservé, tentatives comptées', () async {
    await repo.recordQuiz(lessonId: 'l', records: const [AnswerRecord('a', true), AnswerRecord('b', true)]);
    await repo.recordQuiz(lessonId: 'l', records: const [AnswerRecord('a', false), AnswerRecord('b', true)]);
    final p = (await repo.watchLessons().first)['l']!;
    expect((p.bestScore, p.lastScore, p.attempts), (2, 1, 2));
  });

  test('refaire la même leçon le même jour ne fait pas avancer la révision', () async {
    await repo.recordQuiz(records: const [AnswerRecord('a', true)]);
    final before = await (db.select(db.questionStats)).getSingle();
    await repo.recordQuiz(records: const [AnswerRecord('a', true)]);
    final after = await (db.select(db.questionStats)).getSingle();
    expect(after.box, before.box);
    expect(after.correct, 2);
  });

  test('une question réussie à chaque révision finit acquise', () async {
    for (var i = 0; i < 8; i++) {
      await repo.recordQuiz(records: const [AnswerRecord('a', true)]);
      today += 40;
    }
    final row = await (db.select(db.questionStats)).getSingle();
    expect(row.box, Leitner.mastered);
    expect(row.dueDay, isNull);
    expect((await repo.watchSummary().first).mastered, 1);
  });

  test('les questions du défi ne sont pas suivies, le jour compte quand même', () async {
    await repo.recordQuiz(records: const [AnswerRecord('gen-book-43:3:16', false)]);
    expect(await db.select(db.questionStats).get(), isEmpty);
    final s = await repo.watchSummary().first;
    expect(s.currentStreak, 1);
    expect(s.activeToday, isTrue);
  });

  test('série sur plusieurs jours, lecture libre comprise', () async {
    await repo.recordQuiz(records: const [AnswerRecord('a', true)]);
    today = 20261109;
    await repo.markActive();
    await repo.markActive(); // idempotent
    today = 20261110;
    var s = await repo.watchSummary().first;
    expect((s.currentStreak, s.activeToday), (2, false));
    today = 20261112;
    s = await repo.watchSummary().first;
    expect((s.currentStreak, s.bestStreak), (0, 2));
  });

  test('favoris : ajout, retrait', () async {
    expect(await repo.toggleFavorite('43:3:16'), isTrue);
    expect(await repo.watchFavorites().first, ['43:3:16']);
    expect(await repo.toggleFavorite('43:3:16'), isFalse);
    expect(await repo.watchFavorites().first, isEmpty);
  });

  test('effacer la progression garde favoris et réglages', () async {
    await repo.recordQuiz(lessonId: 'l', records: const [AnswerRecord('a', true)]);
    await repo.toggleFavorite('1:1:1');
    final settings = SettingsRepository(db);
    await settings.setLocale('en');
    await repo.resetProgress();
    expect(await repo.watchLessons().first, isEmpty);
    expect((await repo.watchSummary().first).answered, 0);
    expect(await repo.watchFavorites().first, ['1:1:1']);
    expect((await settings.watch().first).localeCode, 'en');
  });

  test('réglages : valeurs par défaut et bornes', () async {
    final settings = SettingsRepository(db);
    var s = await settings.watch().first;
    expect((s.localeCode, s.textScale, s.parallel, s.onboarded, s.readerBook), (null, 1.0, false, false, 43));
    await settings.setTextScale(9);
    await settings.setReaderPosition(19, 23);
    await settings.setOnboarded();
    s = await settings.watch().first;
    expect((s.textScale, s.readerBook, s.readerChapter, s.onboarded), (AppSettings.maxScale, 19, 23, true));
  });
}
