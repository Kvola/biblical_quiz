import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle;

import '../core/background.dart';
import '../core/verse_ref.dart';
import 'gunzip.dart';

/// Les deux traductions embarquées. La langue du contenu choisit la traduction.
enum Translation {
  lsg('fr', 'Louis Segond 1910', 'LSG', 'assets/bible/lsg.tsv.gz'),
  kjv('en', 'King James Version (1769)', 'KJV', 'assets/bible/kjv.tsv.gz');

  const Translation(this.lang, this.fullName, this.shortName, this.asset);

  final String lang;
  final String fullName;
  final String shortName;
  final String asset;

  static Translation forLang(String lang) => lang == 'en' ? kjv : lsg;

  Translation get other => this == lsg ? kjv : lsg;
}

class Verse {
  const Verse(this.book, this.chapter, this.number, this.text, {this.paragraph = false});

  final int book;
  final int chapter;
  final int number;
  final String text;

  /// Début de paragraphe (marque « ¶ » de la source).
  final bool paragraph;
}

/// Une Bible entière en mémoire (≈ 4 Mo de texte), indexée par livre et chapitre.
class Bible {
  Bible._(this.translation, this._books);

  final Translation translation;

  /// _books[livre - 1][chapitre - 1] = versets dans l'ordre.
  final List<List<List<Verse>>> _books;

  static Future<Bible> load(AssetBundle bundle, Translation t) async {
    final data = await bundle.load(t.asset);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // Décompression et découpage hors du fil de l'interface (~300 ms sur un téléphone modeste).
    final books = await runInBackground(() => parseTsv(utf8.decode(gunzip(bytes))));
    return Bible._(t, books);
  }

  /// Visible pour les tests.
  static Bible fromTsv(Translation t, String tsv) => Bible._(t, parseTsv(tsv));

  static List<List<List<Verse>>> parseTsv(String tsv) {
    final books = List.generate(66, (_) => <List<Verse>>[]);
    var lineNo = 0;
    for (final line in const LineSplitter().convert(tsv)) {
      lineNo++;
      if (line.isEmpty) continue;
      final parts = line.split('\t');
      if (parts.length != 5) throw FormatException('Ligne $lineNo : 5 colonnes attendues');
      final b = int.parse(parts[0]), c = int.parse(parts[1]), v = int.parse(parts[2]);
      final chapters = books[b - 1];
      while (chapters.length < c) {
        chapters.add(<Verse>[]);
      }
      final verses = chapters[c - 1];
      if (verses.length != v - 1) throw FormatException('Ligne $lineNo : verset $b:$c:$v hors séquence');
      verses.add(Verse(b, c, v, parts[4], paragraph: parts[3] == '1'));
    }
    for (var i = 0; i < 66; i++) {
      if (books[i].isEmpty || books[i].any((c) => c.isEmpty)) {
        throw FormatException('Livre ${i + 1} incomplet');
      }
    }
    return books;
  }

  /// Tous les versets dans l'ordre canonique (calculé une fois, à la demande).
  late final List<Verse> allVerses = [
    for (final b in _books)
      for (final c in b) ...c,
  ];

  int get verseCount => allVerses.length;

  int chapterCount(int book) => _books[book - 1].length;

  List<Verse> chapter(int book, int chapter) => _books[book - 1][chapter - 1];

  Verse? verse(int book, int chapter, int number) {
    if (book < 1 || book > 66 || chapter < 1 || chapter > chapterCount(book)) return null;
    final verses = _books[book - 1][chapter - 1];
    return number >= 1 && number <= verses.length ? verses[number - 1] : null;
  }

  /// Versets couverts par [ref], dans l'ordre. Vide si la référence n'existe pas.
  List<Verse> passage(VerseRef ref) {
    final out = <Verse>[];
    if (ref.book < 1 || ref.book > 66) return out;
    for (var c = ref.startChapter; c <= ref.endChapter && c <= chapterCount(ref.book); c++) {
      for (final v in chapter(ref.book, c)) {
        if (ref.covers(c, v.number)) out.add(v);
      }
    }
    return out;
  }

  /// Texte d'une référence sur une ligne (pour le partage, les cartes de verset).
  String text(VerseRef ref) => passage(ref).map((v) => v.text).join(' ');
}
