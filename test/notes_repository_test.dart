import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:biblical_quiz/core/verse_ref.dart';
import 'package:biblical_quiz/data/database.dart';
import 'package:biblical_quiz/data/notes_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late NotesRepository repo;
  var clock = DateTime(2026, 11, 15, 10);

  VerseRef r(String code) => VerseRef.parse(code);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    clock = DateTime(2026, 11, 15, 10);
    repo = NotesRepository(db, now: () => clock, random: Random(1));
  });
  tearDown(() => db.close());

  test('créer, modifier, passages dans l’ordre et sans doublon', () async {
    final id = await repo.create(title: 'La foi d’Abraham', refs: [r('45:4:1-8'), r('1:15:6')]);
    var n = (await repo.get(id))!;
    expect(n.day, 20261115, reason: 'jour de la prédication : aujourd’hui par défaut');
    expect(n.refs.map((x) => x.code), ['45:4:1-8', '1:15:6']);
    expect(n.uid, hasLength(32));

    clock = clock.add(const Duration(minutes: 5));
    await repo.update(id, preacher: 'Pasteur K.', body: 'Abraham crut à Dieu…');
    expect(await repo.addRef(id, r('58:11:8-12')), isTrue);
    expect(await repo.addRef(id, r('1:15:6')), isFalse, reason: 'déjà là');
    n = (await repo.get(id))!;
    expect(n.title, 'La foi d’Abraham', reason: 'champ non fourni : inchangé');
    expect(n.preacher, 'Pasteur K.');
    expect(n.refs.map((x) => x.code), ['45:4:1-8', '1:15:6', '58:11:8-12']);
    expect(n.updatedAt, greaterThan(n.createdAt));

    await repo.setRefs(id, [r('1:15:6'), r('1:15:6'), r('45:4:3')]);
    expect((await repo.get(id))!.refs.map((x) => x.code), ['1:15:6', '45:4:3']);
  });

  test('liste : prédication la plus récente d’abord, mise à jour en direct', () async {
    final stream = repo.watchAll();
    final a = await repo.create(title: 'A', day: 20261101);
    await repo.create(title: 'B', day: 20261108);
    expect((await stream.first).map((n) => n.title), ['B', 'A']);
    await repo.addRef(a, r('43:3:16'));
    final notes = await stream.first;
    expect(notes.last.refs.single.code, '43:3:16');
  });

  test('supprimer puis annuler : tout revient, passages compris', () async {
    final id = await repo.create(title: 'Note', body: 'texte', refs: [r('43:3:16'), r('19:23:1-6')]);
    final deleted = (await repo.delete(id))!;
    expect(await repo.get(id), isNull);
    expect(await db.select(db.sermonNoteRefs).get(), isEmpty, reason: 'passages supprimés avec la note');
    final back = (await repo.get(await repo.restore(deleted)))!;
    expect(back.uid, deleted.uid);
    expect(back.body, 'texte');
    expect(back.refs.map((x) => x.code), ['43:3:16', '19:23:1-6']);
  });

  test('une note laissée vide disparaît, une note commencée reste', () async {
    final empty = await repo.create();
    final started = await repo.create(refs: [r('43:3:16')]);
    expect(await repo.deleteIfBlank(empty), isTrue);
    expect(await repo.deleteIfBlank(started), isFalse);
    expect((await repo.all()).map((n) => n.id), [started]);
  });

  test('notes qui citent un verset (recoupement de passages)', () async {
    await repo.create(title: 'Jean 3', refs: [r('43:3:1-21')]);
    await repo.create(title: 'Romains', refs: [r('45:8:28')]);
    expect((await repo.watchCiting(r('43:3:16')).first).map((n) => n.title), ['Jean 3']);
    expect(await repo.watchCiting(r('43:4:1')).first, isEmpty);
    expect(NotesRepository.overlaps(r('43:3:20-4:2'), r('43:4:1')), isTrue);
    expect(NotesRepository.overlaps(r('43:3:16'), r('62:3:16')), isFalse, reason: 'autre livre');
  });

  test('sauvegarde puis restauration : sans doublon, sans écraser plus récent', () async {
    final id = await repo.create(title: 'Original', day: 20261110, refs: [r('43:3:16')]);
    final backup = await repo.exportJson();
    expect(jsonDecode(backup)['kind'], NotesRepository.exportKind);

    // Restaurer sur la même base : rien ne change.
    var res = await repo.importJson(backup);
    expect((res.added, res.updated, res.unchanged), (0, 0, 1));

    // Modifiée ici après la sauvegarde : l'ancienne sauvegarde ne l'écrase pas.
    clock = clock.add(const Duration(hours: 1));
    await repo.update(id, title: 'Modifiée');
    res = await repo.importJson(backup);
    expect(res.unchanged, 1);
    expect((await repo.get(id))!.title, 'Modifiée');

    // Sur un autre appareil (base vide) : tout revient.
    final other = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(other.close);
    final repo2 = NotesRepository(other, now: () => clock, random: Random(2));
    res = await repo2.importJson(backup);
    expect(res.added, 1);
    final copy = (await repo2.all()).single;
    expect((copy.title, copy.day, copy.refs.single.code), ('Original', 20261110, '43:3:16'));

    // Une sauvegarde plus récente remplace l'ancienne version.
    res = await repo2.importJson(await repo.exportJson());
    expect(res.updated, 1);
    expect((await repo2.all()).single.title, 'Modifiée');
  });

  test('fichier invalide : refusé, rien n’est modifié', () async {
    await repo.create(title: 'Gardée');
    for (final bad in [
      'pas du json',
      '{"kind":"autre","notes":[]}',
      '{"kind":"quiz-biblique/notes","version":99,"notes":[]}',
      '{"kind":"quiz-biblique/notes","version":1,"notes":[{"uid":"x","day":"hier"}]}',
      '{"kind":"quiz-biblique/notes","version":1,"notes":[{"uid":"a","day":20261101},{"uid":"","day":20261101}]}',
    ]) {
      await expectLater(repo.importJson(bad), throwsFormatException, reason: bad);
    }
    expect((await repo.all()).map((n) => n.title), ['Gardée'], reason: 'aucune importation partielle');
  });

  test('migration : une base 1.6 (schéma 2) garde ses données et reçoit les notes', () async {
    final dir = await Directory.systemTemp.createTemp('bq_mig');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/db.sqlite');
    // Base au schéma actuel, ramenée au schéma 2 (sans les tables de notes).
    var old = AppDatabase.forTesting(NativeDatabase(file));
    await old.into(old.favorites).insert(FavoritesCompanion.insert(ref: '43:3:16', createdAt: 1));
    await old.customStatement('DROP TABLE sermon_note_refs');
    await old.customStatement('DROP TABLE sermon_notes');
    await old.customStatement('PRAGMA user_version = 2');
    await old.close();

    final upgraded = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(upgraded.close);
    expect((await upgraded.select(upgraded.favorites).get()).single.ref, '43:3:16');
    final repo3 = NotesRepository(upgraded, now: () => clock);
    final id = await repo3.create(title: 'Après mise à jour', refs: [r('43:3:16')]);
    expect((await repo3.get(id))!.refs.single.code, '43:3:16');
    final version = await upgraded.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 3);
  });
}
