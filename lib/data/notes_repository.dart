import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../core/verse_ref.dart';
import 'database.dart';
import '../domain/days.dart';

/// Une note de prédication et ses passages.
class SermonNote {
  const SermonNote({
    required this.id,
    required this.uid,
    required this.title,
    required this.preacher,
    required this.place,
    required this.day,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    required this.refs,
  });

  final int id;
  final String uid;
  final String title;
  final String preacher;
  final String place;

  /// Jour de la prédication, AAAAMMJJ.
  final int day;
  final String body;
  final int createdAt;
  final int updatedAt;
  final List<VerseRef> refs;

  bool get isBlank => title.trim().isEmpty && preacher.trim().isEmpty && place.trim().isEmpty && body.trim().isEmpty && refs.isEmpty;

  DateTime get date => DateTime(day ~/ 10000, day ~/ 100 % 100, day % 100);

  /// Forme du fichier de sauvegarde.
  Map<String, Object> toJson() => {
    'uid': uid,
    'title': title,
    'preacher': preacher,
    'place': place,
    'day': day,
    'body': body,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'refs': [for (final r in refs) r.code],
  };
}

/// Résultat d'une restauration.
class NotesImport {
  const NotesImport({required this.added, required this.updated, required this.unchanged});

  final int added;

  /// Notes déjà présentes, remplacées par une version plus récente.
  final int updated;

  /// Notes déjà présentes, identiques ou plus récentes ici : gardées telles quelles.
  final int unchanged;
}

/// Lecture et écriture des notes de prédication (base locale, rien ne quitte
/// l'appareil sauf par « Partager » ou « Sauvegarder », à l'initiative de la personne).
class NotesRepository {
  NotesRepository(this.db, {DateTime Function()? now, Random? random})
    : _now = now ?? DateTime.now,
      _random = random ?? Random.secure();

  final AppDatabase db;
  final DateTime Function() _now;
  final Random _random;

  static const exportKind = 'quiz-biblique/notes';
  static const exportVersion = 1;

  int get _millis => _now().millisecondsSinceEpoch;

  String _newUid() => List.generate(16, (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();

  Future<List<SermonNote>> _assemble(List<SermonNoteRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = [for (final r in rows) r.id];
    final refRows = await (db.select(db.sermonNoteRefs)
          ..where((t) => t.noteId.isIn(ids))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    final byNote = <int, List<VerseRef>>{};
    for (final r in refRows) {
      final ref = _tryParse(r.ref);
      if (ref != null) (byNote[r.noteId] ??= []).add(ref);
    }
    return [
      for (final r in rows)
        SermonNote(
          id: r.id,
          uid: r.uid,
          title: r.title,
          preacher: r.preacher,
          place: r.place,
          day: r.day,
          body: r.body,
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
          refs: byNote[r.id] ?? const [],
        ),
    ];
  }

  static VerseRef? _tryParse(String code) {
    try {
      return VerseRef.parse(code);
    } on FormatException {
      return null;
    }
  }

  SimpleSelectStatement<$SermonNotesTable, SermonNoteRow> _ordered() => db.select(db.sermonNotes)
    ..orderBy([(t) => OrderingTerm.desc(t.day), (t) => OrderingTerm.desc(t.updatedAt)]);

  /// Toutes les notes, la plus récente prédication d'abord. Se met à jour à
  /// chaque modification d'une note ou de ses passages.
  Stream<List<SermonNote>> watchAll() => db
      .customSelect('SELECT 1', readsFrom: {db.sermonNotes, db.sermonNoteRefs})
      .watch()
      .asyncMap((_) async => _assemble(await _ordered().get()));

  Stream<SermonNote?> watch(int id) => db
      .customSelect('SELECT 1', readsFrom: {db.sermonNotes, db.sermonNoteRefs})
      .watch()
      .asyncMap((_) => get(id));

  Future<SermonNote?> get(int id) async {
    final row = await (db.select(db.sermonNotes)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return (await _assemble([row])).single;
  }

  Future<List<SermonNote>> all() async => _assemble(await _ordered().get());

  /// Nouvelle note (jour de la prédication : aujourd'hui par défaut).
  Future<int> create({String title = '', String preacher = '', String place = '', int? day, String body = '', List<VerseRef> refs = const []}) =>
      db.transaction(() async {
        final now = _millis;
        final id = await db
            .into(db.sermonNotes)
            .insert(
              SermonNotesCompanion.insert(
                uid: _newUid(),
                title: Value(title),
                preacher: Value(preacher),
                place: Value(place),
                day: day ?? dayKey(_now()),
                body: Value(body),
                createdAt: now,
                updatedAt: now,
              ),
            );
        await _writeRefs(id, refs);
        return id;
      });

  /// Modifie les champs fournis (les autres restent tels quels).
  Future<void> update(int id, {String? title, String? preacher, String? place, int? day, String? body}) =>
      (db.update(db.sermonNotes)..where((t) => t.id.equals(id))).write(
        SermonNotesCompanion(
          title: title == null ? const Value.absent() : Value(title),
          preacher: preacher == null ? const Value.absent() : Value(preacher),
          place: place == null ? const Value.absent() : Value(place),
          day: day == null ? const Value.absent() : Value(day),
          body: body == null ? const Value.absent() : Value(body),
          updatedAt: Value(_millis),
        ),
      );

  /// Remplace les passages (doublons retirés, ordre gardé).
  Future<void> setRefs(int id, List<VerseRef> refs) => db.transaction(() async {
    await _writeRefs(id, refs);
    await (db.update(db.sermonNotes)..where((t) => t.id.equals(id))).write(SermonNotesCompanion(updatedAt: Value(_millis)));
  });

  /// Ajoute un passage à la fin (sans effet s'il y est déjà). Vrai si ajouté.
  Future<bool> addRef(int id, VerseRef ref) => db.transaction(() async {
    final note = await get(id);
    if (note == null || note.refs.contains(ref)) return false;
    await setRefs(id, [...note.refs, ref]);
    return true;
  });

  Future<void> _writeRefs(int id, List<VerseRef> refs) async {
    await (db.delete(db.sermonNoteRefs)..where((t) => t.noteId.equals(id))).go();
    final seen = <VerseRef>{};
    var position = 0;
    for (final r in refs) {
      if (!seen.add(r)) continue;
      await db.into(db.sermonNoteRefs).insert(SermonNoteRefsCompanion.insert(noteId: id, position: position++, ref: r.code));
    }
  }

  /// Supprime une note et renvoie son contenu (pour « Annuler »).
  Future<SermonNote?> delete(int id) => db.transaction(() async {
    final note = await get(id);
    if (note == null) return null;
    await (db.delete(db.sermonNoteRefs)..where((t) => t.noteId.equals(id))).go();
    await (db.delete(db.sermonNotes)..where((t) => t.id.equals(id))).go();
    return note;
  });

  /// Remet une note supprimée (même identifiant de sauvegarde). Renvoie son nouvel id.
  Future<int> restore(SermonNote note) => db.transaction(() async {
    final id = await db.into(db.sermonNotes).insert(_companion(note));
    await _writeRefs(id, note.refs);
    return id;
  });

  /// Supprime la note si elle est restée vide (ouverte puis quittée sans rien écrire).
  Future<bool> deleteIfBlank(int id) async {
    final note = await get(id);
    if (note == null || !note.isBlank) return false;
    await delete(id);
    return true;
  }

  SermonNotesCompanion _companion(SermonNote n) => SermonNotesCompanion.insert(
    uid: n.uid,
    title: Value(n.title),
    preacher: Value(n.preacher),
    place: Value(n.place),
    day: n.day,
    body: Value(n.body),
    createdAt: n.createdAt,
    updatedAt: n.updatedAt,
  );

  /// Notes dont un passage contient ou recoupe [verse].
  Stream<List<SermonNote>> watchCiting(VerseRef verse) =>
      watchAll().map((notes) => [for (final n in notes) if (n.refs.any((r) => overlaps(r, verse))) n]);

  static bool overlaps(VerseRef a, VerseRef b) {
    if (a.book != b.book) return false;
    int k(int c, int v) => c * 1000 + v;
    return k(a.startChapter, a.startVerse) <= k(b.endChapter, b.endVerse) &&
        k(b.startChapter, b.startVerse) <= k(a.endChapter, a.endVerse);
  }

  // -------------------------------------------------------------------------
  // Sauvegarde et restauration (fichier JSON)
  // -------------------------------------------------------------------------

  /// Toutes les notes, en JSON lisible (fichier de sauvegarde).
  Future<String> exportJson() async {
    final notes = await all();
    return const JsonEncoder.withIndent(' ').convert({
      'kind': exportKind,
      'version': exportVersion,
      'exportedAt': _now().toUtc().toIso8601String(),
      'notes': [for (final n in notes) n.toJson()],
    });
  }

  /// Restaure un fichier de sauvegarde. Une note déjà présente (même uid) n'est
  /// remplacée que si la sauvegarde en a une version plus récente : rien n'est
  /// jamais perdu en restaurant une ancienne sauvegarde.
  ///
  /// Lève [FormatException] si le fichier n'est pas une sauvegarde de notes ;
  /// dans ce cas rien n'est modifié.
  Future<NotesImport> importJson(String source) async {
    final Object? data;
    try {
      data = jsonDecode(source);
    } on FormatException {
      throw const FormatException('not-json');
    }
    if (data is! Map || data['kind'] != exportKind || data['notes'] is! List) {
      throw const FormatException('not-notes');
    }
    if ((data['version'] as num? ?? 0) > exportVersion) throw const FormatException('newer-version');
    final incoming = <SermonNote>[];
    for (final raw in data['notes'] as List) {
      if (raw is! Map) throw const FormatException('bad-note');
      String str(String k) => raw[k] is String ? raw[k] as String : '';
      final uid = str('uid');
      final day = raw['day'];
      if (uid.isEmpty || day is! int || day < 10000101 || day > 99991231) throw const FormatException('bad-note');
      final now = _millis;
      incoming.add(
        SermonNote(
          id: 0,
          uid: uid,
          title: str('title'),
          preacher: str('preacher'),
          place: str('place'),
          day: day,
          body: str('body'),
          createdAt: raw['createdAt'] is int ? raw['createdAt'] as int : now,
          updatedAt: raw['updatedAt'] is int ? raw['updatedAt'] as int : now,
          refs: [
            for (final c in (raw['refs'] is List ? raw['refs'] as List : const []))
              if (c is String) ?_tryParse(c),
          ],
        ),
      );
    }
    var added = 0, updated = 0, unchanged = 0;
    await db.transaction(() async {
      for (final n in incoming) {
        final existing = await (db.select(db.sermonNotes)..where((t) => t.uid.equals(n.uid))).getSingleOrNull();
        if (existing == null) {
          final id = await db.into(db.sermonNotes).insert(_companion(n));
          await _writeRefs(id, n.refs);
          added++;
        } else if (n.updatedAt > existing.updatedAt) {
          await (db.update(db.sermonNotes)..where((t) => t.id.equals(existing.id))).write(
            SermonNotesCompanion(
              title: Value(n.title),
              preacher: Value(n.preacher),
              place: Value(n.place),
              day: Value(n.day),
              body: Value(n.body),
              updatedAt: Value(n.updatedAt),
            ),
          );
          await _writeRefs(existing.id, n.refs);
          updated++;
        } else {
          unchanged++;
        }
      }
    });
    return NotesImport(added: added, updated: updated, unchanged: unchanged);
  }
}
