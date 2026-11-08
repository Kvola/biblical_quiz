import 'package:biblical_quiz/data/database.dart';
import 'package:biblical_quiz/data/progress_repository.dart';
import 'package:biblical_quiz/data/settings_repository.dart';
import 'package:biblical_quiz/domain/quiz_session.dart';
import 'package:biblical_quiz/domain/review.dart';
import 'dart:io';

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
    expect(s.themeMode, 'system');
    await settings.setThemeMode('dark');
    expect((await settings.watch().first).themeMode, 'dark');
    await settings.setThemeMode('system');
    expect((await settings.watch().first).themeMode, 'system');
    expect((await settings.raw()).containsKey('theme'), isFalse);
  });

  test('recherches récentes : en tête, sans doublon, bornées, effaçables', () async {
    final settings = SettingsRepository(db);
    for (var i = 0; i < 12; i++) {
      await settings.addRecentSearch('mot $i');
    }
    await settings.addRecentSearch('  MOT 5 ');
    var s = await settings.watch().first;
    expect(s.recentSearches.length, AppSettings.maxRecentSearches);
    expect(s.recentSearches.first, 'MOT 5');
    expect(s.recentSearches.where((x) => x.toLowerCase() == 'mot 5').length, 1);
    await settings.removeRecentSearch('MOT 5');
    s = await settings.watch().first;
    expect(s.recentSearches.contains('MOT 5'), isFalse);
    await settings.clearRecentSearches();
    expect((await settings.watch().first).recentSearches, isEmpty);
    // Valeur illisible : liste vide, pas d'erreur.
    await db
        .into(db.settingsEntries)
        .insertOnConflictUpdate(SettingsEntriesCompanion.insert(key: 'recentSearches', value: '{abîmé'));
    expect((await settings.watch().first).recentSearches, isEmpty);
  });

  group('Chapitres lus', () {
    test('noter, relire, retirer ; un livre entier', () async {
      await repo.markChapterRead(43, 3);
      today = 20261110;
      await repo.markChapterRead(43, 3); // relu : pas de doublon
      await repo.markChaptersRead(65, [1], manual: true);
      expect(await repo.watchReadChapters().first, {43: {3}, 65: {1}});
      final row = await (db.select(db.readChapters)..where((t) => t.book.equals(43))).getSingle();
      expect((row.firstDay, row.lastDay, row.manual), (20261108, 20261110, false), reason: 'première et dernière lecture');

      await repo.markChaptersRead(43, [1, 2, 3, 4], manual: true);
      expect((await repo.watchReadChapters().first)[43], {1, 2, 3, 4});
      await repo.unmarkRead(43, 2);
      expect((await repo.watchReadChapters().first)[43], {1, 3, 4});
      await repo.unmarkRead(43);
      expect(await repo.watchReadChapters().first, {65: {1}});
    });

    test('« Effacer ma progression » efface aussi les chapitres lus', () async {
      await repo.markChapterRead(1, 1);
      await repo.resetProgress();
      expect(await repo.watchReadChapters().first, isEmpty);
    });

    test('les questions tirées du texte ne vont pas en révision', () async {
      await repo.recordQuiz(records: const [
        AnswerRecord('gen-read-cloze-1:1:1-dieu', false),
        AnswerRecord('gen-book-43:3:16', false),
        AnswerRecord('story-creation-q1', false),
      ]);
      expect(await db.select(db.questionStats).get().then((r) => r.map((e) => e.questionId).toList()), ['story-creation-q1']);
    });

    test('migration 1 → 2 : la table apparaît, la progression est conservée', () async {
      final dir = await Directory.systemTemp.createTemp('bq');
      final file = File('${dir.path}/v1.sqlite');
      // Base « 1.2.0 » : mêmes tables sans read_chapters, version de schéma 1.
      final old = AppDatabase.forTesting(NativeDatabase(file));
      await old.into(old.lessonProgress).insert(LessonProgressCompanion.insert(
        lessonId: 'story-creation', bestScore: 4, lastScore: 4, total: 5, attempts: 1, firstCompletedDay: 20261101, lastDay: 20261101));
      await old.customStatement('DROP TABLE read_chapters');
      await old.customStatement('PRAGMA user_version = 1');
      await old.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      final repo2 = ProgressRepository(upgraded, today: () => 20261108);
      expect((await repo2.watchLessons().first).keys, ['story-creation']);
      await repo2.markChapterRead(19, 23);
      expect(await repo2.watchReadChapters().first, {19: {23}});
      final version = await upgraded.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.first, 2);
      await upgraded.close();
      await dir.delete(recursive: true);
    });
  });
}
