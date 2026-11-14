import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/domain/ref_finder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'content_test.dart' show loadBible;

void main() {
  late final RefFinder f;
  setUpAll(() => f = RefFinder(loadBible(Translation.lsg)));

  List<String> codes(String text) => [for (final r in f.findAll(text)) r.ref.code];

  test('formes courantes d’une référence', () {
    expect(f.parse('Jean 3:16')?.code, '43:3:16');
    expect(f.parse('Jn 3.16')?.code, '43:3:16');
    expect(f.parse('Jean 3, 16')?.code, '43:3:16', reason: 'virgule à la française');
    expect(f.parse('jn 3 16')?.code, '43:3:16');
    expect(f.parse('Jn. 3:16-18')?.code, '43:3:16-18');
    expect(f.parse('Jean 3:16–4:2')?.code, '43:3:16-4:2');
    expect(f.parse('Romains 8')?.code, '45:8:1-39', reason: 'chapitre entier');
    expect(f.parse('Romains 8-9')?.code, '45:8:1-9:33');
    expect(f.parse('1 Co 13:4-7')?.code, '46:13:4-7');
    expect(f.parse('1co 13')?.code, '46:13:1-13');
    expect(f.parse('II Corinthiens 5:17')?.code, '47:5:17');
    expect(f.parse('Ésaïe 53:5')?.code, '23:53:5');
    expect(f.parse('esaie 53:5')?.code, '23:53:5');
    expect(f.parse('Psaume 23')?.code, '19:23:1-6');
    expect(f.parse('Ps 23:1')?.code, '19:23:1');
    expect(f.parse('Cantique des cantiques 2:4')?.code, '22:2:4');
    expect(f.parse('John 3:16')?.code, '43:3:16');
    expect(f.parse('1 John 4:8')?.code, '62:4:8');
    expect(f.parse('Song of Solomon 2:4')?.code, '22:2:4');
  });

  test('références impossibles ou incomplètes refusées', () {
    for (final s in ['Jean 22:1', 'Jean 3:37', 'Jean 3:18-16', 'Jude 26', 'Jean', 'Jean 3:16 et la suite', '', 'Bonjour 3:16']) {
      expect(f.parse(s), isNull, reason: s);
    }
    expect(f.parse('Jude 3')?.code, '65:1:3', reason: 'livre d’un seul chapitre : « Jude 3 » = verset 3 ?');
  });

  test('repérage dans un texte libre', () {
    const note = 'Texte : Jean 3:16-18. Puis Romains 8, 28 et 1 Co 13.4-7 ; voir aussi Ps 23 '
        'et Ésaïe 53:5. Il est 3 heures, ex 2 fois.';
    expect(codes(note), ['43:3:16-18', '45:8:28', '46:13:4-7', '19:23:1-6', '23:53:5']);
    final hits = f.findAll(note);
    expect(note.substring(hits.first.start, hits.first.end), 'Jean 3:16-18');
    expect(note.substring(hits[1].start, hits[1].end), 'Romains 8, 28');
    expect(codes('Est 4:14 : pour un temps comme celui-ci'), ['17:4:14'], reason: 'ambiguë mais avec verset');
    expect(codes('lisons ensemble Marc 10:45 puis Jean 1'), ['41:10:45', '43:1:1-51']);
    expect(codes('pas de référence ici, 3:16 tout seul'), isEmpty);
  });
}
