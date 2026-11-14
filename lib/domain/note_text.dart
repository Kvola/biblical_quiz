import '../bible/bible.dart';
import '../core/books.dart';
import '../data/notes_repository.dart';

/// Texte d'une note à partager : en-tête, passages avec leur texte (jusqu'à
/// [maxQuotedVerses] versets, au-delà la référence seule), notes.
///
/// [whatsapp] : mise en forme de WhatsApp (*gras* pour le titre, les intitulés
/// et les références, _italique_ pour la ligne jour · prédicateur · lieu).
/// Sans elle, texte brut (e-mail, SMS…), où ces signes s'afficheraient tels quels.
String noteShareText(
  SermonNote note, {
  required Bible bible,
  required String lang,
  required String dateLabel,
  required String untitled,
  required String passagesLabel,
  required String notesLabel,
  required String footer,
  int maxQuotedVerses = 5,
  bool whatsapp = false,
}) {
  String bold(String s) => whatsapp ? '*$s*' : s;
  String italic(String s) => whatsapp ? '_${s}_' : s;
  String heading(String s) => bold(lang == 'fr' ? '$s :' : '$s:');

  final b = StringBuffer()..writeln(bold(note.title.trim().isEmpty ? untitled : note.title.trim()));
  b.writeln(italic([dateLabel, note.preacher.trim(), note.place.trim()].where((s) => s.isNotEmpty).join(' — ')));
  if (note.refs.isNotEmpty) {
    b
      ..writeln()
      ..writeln(heading(passagesLabel));
    for (final r in note.refs) {
      final verses = bible.passage(r);
      final label = bold(refLabel(r, lang));
      if (verses.isEmpty || verses.length > maxQuotedVerses) {
        b.writeln('• $label');
      } else {
        final text = verses.map((v) => v.text).join(' ');
        b.writeln(lang == 'fr' ? '• $label — « $text » (${bible.translation.shortName})' : '• $label — “$text” (${bible.translation.shortName})');
      }
    }
  }
  if (note.body.trim().isNotEmpty) {
    b
      ..writeln()
      ..writeln(heading(notesLabel))
      ..writeln(note.body.trim());
  }
  b
    ..writeln()
    ..write('— $footer');
  return b.toString();
}
