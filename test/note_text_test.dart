import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/core/verse_ref.dart';
import 'package:biblical_quiz/data/notes_repository.dart';
import 'package:biblical_quiz/domain/note_text.dart';
import 'package:flutter_test/flutter_test.dart';

import 'content_test.dart' show loadBible;

void main() {
  final lsg = loadBible(Translation.lsg);

  SermonNote note({String title = 'La foi', String body = 'Abraham crut.', List<String> refs = const []}) => SermonNote(
    id: 1,
    uid: 'u',
    title: title,
    preacher: 'Pasteur K.',
    place: '',
    day: 20261115,
    body: body,
    createdAt: 0,
    updatedAt: 0,
    refs: [for (final r in refs) VerseRef.parse(r)],
  );

  String share(SermonNote n, {bool whatsapp = false}) => noteShareText(
    n,
    bible: lsg,
    lang: 'fr',
    dateLabel: 'dimanche 15 novembre 2026',
    untitled: 'Sans titre',
    passagesLabel: 'Passages',
    notesLabel: 'Notes',
    footer: 'Notes prises avec Quiz Biblique',
    whatsapp: whatsapp,
  );

  test('texte partagé : en-tête, passages cités, notes', () {
    final t = share(note(refs: ['43:3:16', '19:23:1-6']));
    expect(t, startsWith('La foi\ndimanche 15 novembre 2026 — Pasteur K.\n'));
    expect(t, contains('• Jean 3:16 — « Car Dieu a tant aimé le monde'));
    expect(t, contains('(LSG)'));
    expect(t, contains('• Psaumes 23:1-6\n'), reason: 'plus de 5 versets : la référence seule');
    expect(t, contains('Notes :\nAbraham crut.'));
    expect(t, endsWith('— Notes prises avec Quiz Biblique'));
  });

  test('passage long : la référence seule ; note sans titre ni notes', () {
    final t = share(note(title: ' ', body: '', refs: ['45:8:1-39']));
    expect(t, startsWith('Sans titre\n'));
    expect(t, contains('• Romains 8:1-39\n'));
    expect(t, isNot(contains('Notes :')));
  });

  test('WhatsApp : titre, intitulés et références en gras, ligne d’en-tête en italique', () {
    final t = share(note(refs: ['43:3:16']), whatsapp: true);
    expect(t, startsWith('*La foi*\n_dimanche 15 novembre 2026 — Pasteur K._\n'));
    expect(t, contains('*Passages :*\n• *Jean 3:16* — « Car Dieu'));
    expect(t, contains('*Notes :*\nAbraham crut.'));
    expect(share(note(refs: ['43:3:16'])), isNot(contains('*')), reason: 'texte brut sans astérisques');
  });
}
