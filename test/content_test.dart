import 'dart:convert';
import 'dart:io';

import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/content/content.dart';
import 'package:biblical_quiz/content/models.dart';
import 'package:biblical_quiz/core/books.dart';
import 'package:biblical_quiz/domain/book_challenge.dart';
import 'package:biblical_quiz/ui/settings/settings_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lecture directe des fichiers (sans AssetBundle) : rapide, et les tests
/// échouent sur le fichier exact en cause.
Bible loadBible(Translation t) => Bible.fromTsv(t, utf8.decode(gzip.decode(File(t.asset).readAsBytesSync())));

Content loadContent() {
  final paths = (Directory('assets/content/paths').listSync().whereType<File>().where((f) => f.path.endsWith('.json')))
      .map((f) => LearningPath.parse(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>))
      .toList();
  final books = (jsonDecode(File('assets/content/books.json').readAsStringSync()) as List)
      .cast<Map<String, dynamic>>()
      .map(BookInfo.parse)
      .toList();
  return Content(paths, books);
}

void main() {
  late final Bible lsg, kjv;
  late final Content content;

  setUpAll(() {
    lsg = loadBible(Translation.lsg);
    kjv = loadBible(Translation.kjv);
    content = loadContent();
  });

  test('les deux Bibles ont 66 livres et les mêmes versets', () {
    var n = 0;
    for (var b = 1; b <= 66; b++) {
      expect(lsg.chapterCount(b), kjv.chapterCount(b), reason: 'livre $b');
      for (var c = 1; c <= lsg.chapterCount(b); c++) {
        expect(lsg.chapter(b, c).length, kjv.chapter(b, c).length, reason: '$b:$c');
        n += lsg.chapter(b, c).length;
      }
    }
    expect(n, 31102);
    expect(lsg.verse(1, 1, 1)!.text, 'Au commencement, Dieu créa les cieux et la terre.');
    expect(kjv.verse(43, 11, 35)!.text, 'Jesus wept.');
    expect(lsg.verse(66, 22, 22), isNull);
  });

  test('le validateur Python accepte tout le contenu', () {
    final r = Process.runSync('python3', ['scripts/validate_content.py']);
    expect(r.exitCode, 0, reason: '${r.stdout}\n${r.stderr}');
  });

  test('table des livres identique à scripts/books.py', () {
    final py = File('scripts/books.py').readAsStringSync();
    final rows = RegExp(r'\((\d+), "([^"]+)", "([^"]+)", "([^"]+)", "([^"]+)", "(\w+)"\)').allMatches(py).toList();
    expect(rows.length, 66);
    for (final m in rows) {
      final b = bookById(int.parse(m[1]!));
      expect((b.fr, b.frAbbr, b.en, b.enAbbr, b.genre.name), (m[2], m[3], m[4], m[5], m[6]));
    }
  });

  test('chaque référence du contenu existe dans les deux Bibles', () {
    void check(String where, dynamic ref) {
      expect(lsg.passage(ref), isNotEmpty, reason: '$where $ref (LSG)');
      expect(kjv.passage(ref).length, lsg.passage(ref).length, reason: '$where $ref (KJV)');
    }

    for (final l in content.allLessons) {
      for (final p in l.passages) {
        check(l.id, p);
      }
      check(l.id, l.keyVerse);
      for (final q in l.questions) {
        check(q.id, q.ref);
      }
    }
    for (final b in content.books) {
      check('book-${b.id}', b.keyVerse);
      for (final q in b.questions) {
        check(q.id, q.ref);
      }
    }
  });

  test('contenu : parcours ordonnés, ids uniques, 66 fiches', () {
    expect(content.paths.map((p) => p.order).toList(), [...content.paths.map((p) => p.order)]..sort());
    expect(content.books.length, 66);
    final ids = [
      for (final l in content.allLessons) ...l.questions.map((q) => q.id),
      for (final b in content.books) ...b.questions.map((q) => q.id),
    ];
    expect(ids.toSet().length, ids.length);
    expect(content.questionCount, ids.length);
    final first = content.paths.first.lessons.first;
    expect(content.suggestedNext({}, null)?.id, first.id);
    expect(content.suggestedNext({first.id}, null)?.id, content.paths.first.lessons[1].id);
  });

  test('défi des livres : bonne réponse = livre du verset', () {
    final qs = BookChallenge.build(content: content, bible: lsg, lang: 'fr', count: 30);
    expect(qs.length, 30);
    for (final q in qs) {
      expect(BookChallenge.isCompleteSentence(lsg.text(q.ref)), isTrue, reason: q.ref.code);
      expect(q.options('fr')[q.correctIndex], bookById(q.ref.book).fr);
      expect(q.options('fr').toSet().length, 4);
    }
  });

  test('versets du jour lisibles en nombre suffisant dans les deux langues', () {
    expect(BookChallenge.isCompleteSentence('parlé à nos pères par les prophètes, Dieu,'), isFalse);
    expect(BookChallenge.isCompleteSentence('Jésus pleura.'), isTrue);
    expect(BookChallenge.readableCandidates(content, lsg).length, greaterThan(100));
    expect(BookChallenge.readableCandidates(content, kjv).length, greaterThan(100));
  });

  test('la version affichée suit pubspec.yaml', () {
    final m = RegExp(r'^version: (\d+\.\d+\.\d+)', multiLine: true).firstMatch(File('pubspec.yaml').readAsStringSync());
    expect(appVersion, m![1]);
  });
}
