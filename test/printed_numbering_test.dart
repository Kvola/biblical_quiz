import 'dart:convert';
import 'dart:io';

import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/bible/printed_numbering.dart';
import 'package:biblical_quiz/core/verse_ref.dart';
import 'package:flutter_test/flutter_test.dart';

/// Numéros des Segond imprimées (assets/bible/lsg_printed.json, produit par
/// scripts/build_lsg_printed.py ; le validateur vérifie aussi sa forme).
void main() {
  late final PrintedNumbering n;
  late final Bible lsg;

  setUpAll(() {
    n = PrintedNumbering.parse(File(PrintedNumbering.asset).readAsStringSync());
    lsg = Bible.fromTsv(Translation.lsg, utf8.decode(gzip.decode(File(Translation.lsg.asset).readAsBytesSync())));
  });

  String? p(String code) => n.printed(VerseRef.parse(code))?.code;

  test('Psaumes : le titre compté comme verset 1', () {
    expect(p('19:19:7'), '19:19:8', reason: '« La loi de l\'Eternel est parfaite »');
    expect(p('19:19:7-14'), '19:19:8-15');
    expect(p('19:51:10'), '19:51:12', reason: 'titre sur deux versets');
    expect(p('19:51:1'), '19:51:1-3', reason: 'le verset 1 porte aussi le titre');
    expect(p('19:51:1-19'), '19:51:1-21');
    expect(p('19:3:8'), '19:3:9');
  });

  test('chapitres découpés autrement', () {
    expect(p('32:1:17'), '32:2:1', reason: 'Jonas 1:17 = Jonas 2:1');
    expect(p('32:2:1'), '32:2:2');
    expect(p('32:1:1-17'), '32:1:1-2:1');
  });

  test('d’une Segond imprimée vers l’application', () {
    String? back(String code) => n.fromPrinted(VerseRef.parse(code))?.code;
    expect(back('19:51:12'), '19:51:10', reason: '« crée en moi un cœur pur »');
    expect(back('19:19:8'), '19:19:7');
    expect(back('19:19:8-15'), '19:19:7-14');
    expect(back('19:51:2'), '19:51:1', reason: 'titre : verset 1 de l’application');
    expect(back('32:2:1'), '32:1:17', reason: 'Jonas 2:1 imprimé = Jonas 1:17');
    expect(back('32:2:2-11'), '32:2:1-10');
    expect(back('43:3:16'), isNull, reason: 'mêmes numéros');
    expect(back('19:23:1'), isNull);
    // Aller-retour : chaque verset d'un chapitre listé revient sur lui-même.
    for (final code in ['19:19:7', '19:51:10', '32:1:17', '18:41:1', '2:8:5']) {
      final r = VerseRef.parse(code);
      expect(n.fromPrinted(n.printed(r)!), r, reason: code);
    }
  });

  test('numérotation identique : rien à signaler', () {
    for (final code in ['19:1:1', '19:23:1-6', '19:119:97-112', '43:3:16', '1:1:1-31', '41:9:50', '66:22:21']) {
      expect(p(code), isNull, reason: code);
    }
    expect(n.chapterDiffers(19, 23), isFalse);
    expect(n.chapterDiffers(19, 19), isTrue);
    expect(PrintedNumbering.empty.printed(VerseRef.parse('19:19:7')), isNull);
  });

  test('chaque verset d\'un chapitre listé a un numéro imprimé, croissant', () {
    for (var b = 1; b <= 66; b++) {
      for (var c = 1; c <= lsg.chapterCount(b); c++) {
        if (!n.chapterDiffers(b, c)) continue;
        VerseRef? previous;
        for (final v in lsg.chapter(b, c)) {
          final r = VerseRef.single(b, c, v.number);
          final printed = n.printed(r) ?? r;
          if (previous != null) {
            expect(printed.compareTo(previous) >= 0, isTrue, reason: '$b:$c:${v.number}');
          }
          previous = printed;
        }
      }
    }
  });
}
