import 'dart:convert';
import 'dart:io';

import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/domain/search.dart';
import 'package:flutter_test/flutter_test.dart';

Bible loadBible(Translation t) => Bible.fromTsv(t, utf8.decode(gzip.decode(File(t.asset).readAsBytesSync())));

void main() {
  group('Normalisation', () {
    test('accents, majuscules, ligatures et ponctuation', () {
      expect(normalize("Que la lumière soit! Et la lumière fut."), 'que la lumiere soit et la lumiere fut');
      expect(normalize("l'Éternel"), 'l eternel');
      expect(normalize('  Cœur, ÂME…  '), 'coeur ame');
      expect(normalize('L’ESPRIT'), 'l esprit');
    });

    test('la carte des positions renvoie au texte d’origine', () {
      final n = Normalized.of('Cœur: âme');
      expect(n.text, 'coeur ame');
      expect(n.origin.length, n.text.length);
      expect(n.origin[0], 0); // c
      expect(n.origin[1], 1); // o (de œ)
      expect(n.origin[2], 1); // e (de œ)
      expect(n.origin[6], 6); // a de « âme »
    });
  });

  group('Requête', () {
    test('mots, expressions et exclusions', () {
      final q = SearchQuery.parse('berger "bon berger" -loup -"mauvais serviteur"');
      expect(q.required, ['bon berger', 'berger']);
      expect(q.excluded, ['loup', 'mauvais serviteur']);
    });

    test('guillemets typographiques et requête vide', () {
      expect(SearchQuery.parse('« que la lumière soit »').required, ['que la lumiere soit']);
      expect(SearchQuery.parse('“Jesus wept”').required, ['jesus wept']);
      expect(SearchQuery.parse('   ').isEmpty, isTrue);
      expect(SearchQuery.parse('-loup').isEmpty, isTrue, reason: 'une exclusion seule ne cherche rien');
    });

    test('début de mot, mot entier, frontières', () {
      const t = 'il pardonne a ceux qui ont pardonne';
      expect(findTerm(t, 'pardon'), 3);
      expect(findTerm(t, 'pardon', wholeWord: true), -1);
      expect(findTerm(t, 'donne'), -1, reason: 'pas au milieu d’un mot');
      expect(findTerm(t, 'a ceux'), 12);
    });
  });

  group('Recherche dans les Bibles', () {
    late final Bible lsg, kjv;
    late final SearchIndex fr, en;

    setUpAll(() {
      lsg = loadBible(Translation.lsg);
      kjv = loadBible(Translation.kjv);
      fr = SearchIndex(lsg, SearchIndex.normalizeAll([for (final v in lsg.allVerses) v.text]));
      en = SearchIndex(kjv, SearchIndex.normalizeAll([for (final v in kjv.allVerses) v.text]));
    });

    String refOf(SearchIndex idx, int i) {
      final v = idx.verses[i];
      return '${v.book}:${v.chapter}:${v.number}';
    }

    test('expression exacte au travers de la ponctuation', () {
      final r = fr.search(SearchQuery.parse('"que la lumière soit"'));
      expect(r.hits.map((i) => refOf(fr, i)), contains('1:1:3'));
    });

    test('sans accents ni majuscules', () {
      final a = fr.search(SearchQuery.parse('ETERNEL'));
      final b = fr.search(SearchQuery.parse('éternel'));
      expect(a.total, b.total);
      expect(a.total, greaterThan(5000));
    });

    test('tous les mots, dans n’importe quel ordre, et exclusion', () {
      final both = fr.search(SearchQuery.parse('brebis berger'));
      expect(both.hits.map((i) => refOf(fr, i)), contains('43:10:11'));
      final withoutWolf = fr.search(SearchQuery.parse('brebis berger -loup'));
      expect(withoutWolf.total, lessThan(both.total));
      for (final i in withoutWolf.hits) {
        expect(fr.normalized[i].contains('loup'), isFalse);
      }
    });

    test('mot entier contre début de mot', () {
      final prefix = fr.search(SearchQuery.parse('pardon'));
      final whole = fr.search(SearchQuery.parse('pardon'), wholeWords: true);
      expect(prefix.total, greaterThan(whole.total));
      expect(whole.total, greaterThan(0));
    });

    test('filtre de livres et décompte par livre', () {
      final all = en.search(SearchQuery.parse('"Jesus wept"'));
      expect(all.total, 1);
      expect(all.perBook, {43: 1});
      final filtered = en.search(SearchQuery.parse('"Jesus wept"'), books: {1});
      expect(filtered.hits, isEmpty);
      expect(filtered.total, 1, reason: 'le décompte ignore le filtre');
    });

    test('rapide : un mot très fréquent sur toute la Bible', () {
      final sw = Stopwatch()..start();
      final r = fr.search(SearchQuery.parse('et'));
      sw.stop();
      expect(r.total, greaterThan(15000));
      expect(sw.elapsedMilliseconds, lessThan(500), reason: '${sw.elapsedMilliseconds} ms');
    });

    test('surlignage dans le texte d’origine (accents, mot complet)', () {
      const text = "Il pardonne à l'Éternel, et l'Éternel pardonna.";
      final q = SearchQuery.parse('eternel pardon');
      final ranges = highlightRanges(text, q);
      expect([for (final (a, b) in ranges) text.substring(a, b)], ['pardonne', 'Éternel', 'Éternel', 'pardonna']);
    });

    test('références tapées à la main', () {
      expect(parseHumanRef('Jean 3:16', lsg)?.ref.code, '43:3:16');
      expect(parseHumanRef('jn 3 16', lsg)?.ref.code, '43:3:16');
      expect(parseHumanRef('John 3.16-18', kjv)?.ref.code, '43:3:16-18');
      expect(parseHumanRef('1 Co 13', lsg)?.chapterOnly, isTrue);
      expect(parseHumanRef('1co13', lsg)?.ref.code, '46:13:1');
      expect(parseHumanRef('Psaume 23', lsg)?.ref.code, '19:23:1');
      expect(parseHumanRef('Genèse 1:1', lsg)?.ref.code, '1:1:1');
      expect(parseHumanRef('Jean 99', lsg), isNull, reason: 'chapitre inexistant');
      expect(parseHumanRef('Jean 3:99', lsg), isNull, reason: 'verset inexistant');
      expect(parseHumanRef('amour', lsg), isNull);
      expect(parseHumanRef('berger 3', lsg), isNull);
    });
  });
}
