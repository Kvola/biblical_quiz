import 'dart:ui' as ui;

import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/core/verse_ref.dart';
import 'package:biblical_quiz/l10n/gen/app_localizations.dart';
import 'package:biblical_quiz/ui/share/verse_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'content_test.dart' show loadBible;

void main() {
  test('texte de l’image : passage entier, ou coupé proprement au-delà de la limite', () {
    final lsg = loadBible(Translation.lsg);
    final (short, cutShort) = verseImageText(lsg.passage(VerseRef.parse('43:3:16')));
    expect(cutShort, isFalse);
    expect(short, startsWith('Car Dieu a tant aimé le monde'));
    final (long, cutLong) = verseImageText(lsg.passage(VerseRef.parse('45:8:1-39')));
    expect(cutLong, isTrue);
    expect(long.length, lessThanOrEqualTo(482));
    expect(long, endsWith(' …'));
    expect(long, isNot(contains(', …')));
  });

  test('taille du texte : grande pour un verset court, réduite pour un long', () {
    expect(verseImageFontSize(80), greaterThan(verseImageFontSize(250)));
    expect(verseImageFontSize(250), greaterThan(verseImageFontSize(470)));
  });

  testWidgets('la carte se rend en PNG 1080 × 1350', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: FittedBox(
            child: RepaintBoundary(
              key: key,
              child: const VerseCard(text: 'O Dieu! crée en moi un coeur pur', reference: 'Psaumes 51:10 · LSG', title: 'Un cœur nouveau'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('UN CŒUR NOUVEAU'), findsOneWidget);
    expect(find.text('« O Dieu! crée en moi un coeur pur »'), findsOneWidget);
    final png = (await tester.runAsync(() => captureVerseCard(key)))!;
    expect(png.sublist(1, 4), 'PNG'.codeUnits);
    final codec = (await tester.runAsync(() => ui.instantiateImageCodec(png)))!;
    final frame = (await tester.runAsync(codec.getNextFrame))!;
    expect((frame.image.width, frame.image.height), (1080, 1350));
  });

  testWidgets('variante claire : fond crème, texte bleu nuit, rendue elle aussi', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Center(
          child: FittedBox(
            child: RepaintBoundary(
              key: key,
              child: const VerseCard(text: 'Jésus pleura.', reference: 'Jean 11:35 · LSG', light: true),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final verse = tester.widget<Text>(find.text('« Jésus pleura. »'));
    expect(verse.style?.color, const Color(0xFF1E3A5F));
    final png = (await tester.runAsync(() => captureVerseCard(key)))!;
    expect(png.sublist(1, 4), 'PNG'.codeUnits);
  });
}
