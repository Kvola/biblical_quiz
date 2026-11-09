import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'web_database.dart';

part 'database.g.dart';

/// Une leçon (ou une fiche de livre « book-N ») terminée au moins une fois.
class LessonProgress extends Table {
  TextColumn get lessonId => text()();
  IntColumn get bestScore => integer()();
  IntColumn get lastScore => integer()();
  IntColumn get total => integer()();
  IntColumn get attempts => integer()();
  IntColumn get firstCompletedDay => integer()(); // AAAAMMJJ
  IntColumn get lastDay => integer()();

  @override
  Set<Column> get primaryKey => {lessonId};
}

/// Historique et révision espacée d'une question du contenu.
class QuestionStats extends Table {
  TextColumn get questionId => text()();
  IntColumn get box => integer()(); // boîte de Leitner ; Leitner.mastered = acquise
  IntColumn get dueDay => integer().nullable()(); // null = plus de révision
  IntColumn get correct => integer().withDefault(const Constant(0))();
  IntColumn get wrong => integer().withDefault(const Constant(0))();
  IntColumn get lastDay => integer()();

  @override
  Set<Column> get primaryKey => {questionId};
}

/// Un jour où la personne a lu ou répondu (pour la série).
class ActivityDays extends Table {
  IntColumn get day => integer()(); // AAAAMMJJ
  IntColumn get answered => integer().withDefault(const Constant(0))();
  IntColumn get lessons => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

/// Versets mis de côté.
class Favorites extends Table {
  TextColumn get ref => text()(); // « 43:3:16 »
  IntColumn get createdAt => integer()(); // millisecondes

  @override
  Set<Column> get primaryKey => {ref};
}

/// Chapitres lus : notés automatiquement par le lecteur (temps passé et fin du
/// chapitre atteinte) ou à la main (lecture dans une Bible papier).
class ReadChapters extends Table {
  IntColumn get book => integer()();
  IntColumn get chapter => integer()();
  IntColumn get firstDay => integer()(); // AAAAMMJJ
  IntColumn get lastDay => integer()();
  BoolColumn get manual => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {book, chapter};
}

class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [LessonProgress, QuestionStats, ActivityDays, Favorites, SettingsEntries, ReadChapters])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'biblical_quiz', web: webDatabaseOptions()));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Chaque future version ajoute ici sa marche (if (from < 2) …) : on ne
    // recrée jamais une table, la progression des utilisateurs y vit.
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(readChapters); // 1.3.0 : chapitres lus
    },
  );
}
