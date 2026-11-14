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

/// Notes de prédication (1.7.0). Restent sur l'appareil ; [uid] identifie une
/// note d'un appareil à l'autre (sauvegarde puis restauration sans doublon).
@DataClassName('SermonNoteRow')
class SermonNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uid => text().unique()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get preacher => text().withDefault(const Constant(''))();
  TextColumn get place => text().withDefault(const Constant(''))();
  IntColumn get day => integer()(); // AAAAMMJJ : jour de la prédication
  TextColumn get body => text().withDefault(const Constant(''))();
  IntColumn get createdAt => integer()(); // millisecondes
  IntColumn get updatedAt => integer()();
}

/// Passages associés à une note, dans l'ordre choisi.
@DataClassName('SermonNoteRefRow')
class SermonNoteRefs extends Table {
  IntColumn get noteId => integer().references(SermonNotes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get ref => text()(); // « 43:3:16-18 » (numérotation de l'application)

  @override
  Set<Column> get primaryKey => {noteId, position};
}

class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [LessonProgress, QuestionStats, ActivityDays, Favorites, SettingsEntries, ReadChapters, SermonNotes, SermonNoteRefs],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'biblical_quiz', web: webDatabaseOptions()));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Chaque future version ajoute ici sa marche (if (from < 2) …) : on ne
    // recrée jamais une table, la progression des utilisateurs y vit.
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(readChapters); // 1.3.0 : chapitres lus
      if (from < 3) {
        // 1.7.0 : notes de prédication
        await m.createTable(sermonNotes);
        await m.createTable(sermonNoteRefs);
      }
    },
    // Suppression d'une note : ses passages partent avec elle (ON DELETE CASCADE).
    beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
