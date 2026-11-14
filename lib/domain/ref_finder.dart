import '../bible/bible.dart';
import '../core/verse_ref.dart';
import 'search.dart';

/// Une référence repérée dans un texte libre (notes de prédication).
class FoundRef {
  const FoundRef(this.ref, this.start, this.end);

  final VerseRef ref;

  /// Position dans le texte d'origine ([start] inclus, [end] exclu).
  final int start;
  final int end;

  @override
  String toString() => '$ref@$start-$end';
}

/// Repère les références bibliques écrites par une personne, telles qu'on les
/// note pendant une prédication :
///
/// * « Jean 3:16 », « Jn 3.16 », « Jean 3, 16 » (virgule à la française),
///   « jn 3 16 » ;
/// * plages : « Jean 3:16-18 », « Jean 3:16–4:2 » ;
/// * chapitres : « Romains 8 » (tout le chapitre), « Romains 8-9 » ;
/// * livres numérotés : « 1 Co 13:4-7 », « 1co 13 », « II Corinthiens 5:17 ».
///
/// Noms et abréviations des livres en français et en anglais (ceux de
/// lib/core/books.dart et quelques variantes : « Psaume », « Esaïe »…).
/// Une référence qui n'existe pas dans [bible] (chapitre ou verset hors du
/// livre) n'est pas retenue.
class RefFinder {
  RefFinder(this.bible);

  final Bible bible;

  /// Abréviations qui sont aussi des mots courants (« il est 3 heures »,
  /// « ex 2 », « os 1 ») : dans un texte libre, elles ne comptent que suivies
  /// d'un verset (« Est 4:14 »), jamais pour un chapitre seul.
  static const _ambiguous = {'est', 'os', 'am', 'ex', 'ag', 'so', 'ne', 'ma', 'col', 'mal', 'job', 'jude', 'jos', 'lam'};

  static final _word = RegExp(r"[A-Za-zÀ-ÖØ-öø-ÿŒœ]+|\d+");
  static final _numbers = RegExp(
    r'^\s*(\d{1,3})(?:\s*([:.,])\s*(\d{1,3}))?(?:\s*[-–—]\s*(\d{1,3})(?:\s*[:.]\s*(\d{1,3}))?)?',
  );

  /// Champ de saisie seulement : « jn 3 16 » (une espace entre chapitre et verset).
  static final _numbersLoose = RegExp(
    r'^\s*(\d{1,3})(?:\s*([:.,]|\s)\s*(\d{1,3}))?(?:\s*[-–—]\s*(\d{1,3})(?:\s*[:.]\s*(\d{1,3}))?)?',
  );
  static final _gap = RegExp(r"^[ \t'’]*$");
  static const _roman = {'i': '1', 'ii': '2', 'iii': '3'};

  /// Toutes les références du texte, dans l'ordre, sans chevauchement.
  List<FoundRef> findAll(String text) {
    final tokens = _word.allMatches(text).toList();
    final out = <FoundRef>[];
    var i = 0;
    while (i < tokens.length) {
      final hit = _at(text, tokens, i, free: true);
      if (hit == null) {
        i++;
        continue;
      }
      out.add(hit);
      while (i < tokens.length && tokens[i].start < hit.end) {
        i++;
      }
    }
    return out;
  }

  /// Le texte entier est-il une seule référence ? (champ « Ajouter un passage »)
  VerseRef? parse(String input) {
    final text = input.trim();
    final tokens = _word.allMatches(text).toList();
    if (tokens.isEmpty) return null;
    final hit = _at(text, tokens, 0, free: false);
    if (hit == null || hit.start != 0) return null;
    final rest = text.substring(hit.end).trim();
    return rest.isEmpty ? hit.ref : null;
  }

  /// Référence commençant au jeton [i] : nom de livre le plus long possible
  /// (jusqu'à 4 mots : « Cantique des cantiques », « Song of Solomon »), puis
  /// les nombres.
  FoundRef? _at(String text, List<RegExpMatch> tokens, int i, {required bool free}) {
    final first = tokens[i][0]!;
    // Un livre commence par une lettre, ou par 1-3 / I-III suivi d'un mot.
    final isNumber = RegExp(r'^\d+$').hasMatch(first);
    if (isNumber && !RegExp(r'^[1-3]$').hasMatch(first)) return null;
    // Le mot doit commencer là (pas au milieu de « 2Jean » collé à autre chose).
    if (tokens[i].start > 0 && RegExp(r'[A-Za-zÀ-ÿ0-9]').hasMatch(text[tokens[i].start - 1])) return null;
    for (var n = 4; n >= 1; n--) {
      if (i + n > tokens.length) continue;
      final words = [for (var k = i; k < i + n; k++) tokens[k][0]!];
      // Les mots du nom ne contiennent pas de chiffres, sauf le préfixe 1-3.
      if (words.skip(1).any((w) => RegExp(r'\d').hasMatch(w))) continue;
      if (isNumber && n == 1) continue;
      var name = words.join(' ');
      final lowerFirst = words.first.toLowerCase();
      if (_roman.containsKey(lowerFirst) && n > 1) {
        name = '${_roman[lowerFirst]} ${words.skip(1).join(' ')}';
      }
      final book = bookIdFromName(name);
      if (book == null) continue;
      // Entre deux mots du nom : seulement des espaces ou une apostrophe (pas de ponctuation).
      var joined = true;
      for (var k = i; k < i + n - 1; k++) {
        if (!_gap.hasMatch(text.substring(tokens[k].end, tokens[k + 1].start))) joined = false;
      }
      if (!joined) continue;
      final nameEnd = tokens[i + n - 1].end;
      var after = nameEnd;
      if (after < text.length && text[after] == '.') after++; // « Jn. 3:16 »
      final m = (free ? _numbers : _numbersLoose).firstMatch(text.substring(after));
      if (m == null) continue;
      final ref = _build(book, m);
      if (ref == null) continue;
      final hasVerse = m[3] != null || m[5] != null;
      if (free && !hasVerse && n == 1 && _ambiguous.contains(name.toLowerCase())) continue;
      // Pas de chiffre collé juste après (« Jean 3:16a » accepté, « Jean 316 » non concerné).
      return FoundRef(ref, tokens[i].start, after + m.end);
    }
    return null;
  }

  VerseRef? _build(int book, RegExpMatch m) {
    var c1 = int.parse(m[1]!);
    var v1 = m[3] == null ? null : int.parse(m[3]!);
    final x = m[4] == null ? null : int.parse(m[4]!);
    final y = m[5] == null ? null : int.parse(m[5]!);
    // Livres d'un seul chapitre (Abdias, Philémon, 2 et 3 Jean, Jude) : « Jude 3 » = verset 3.
    if (bible.chapterCount(book) == 1 && v1 == null && y == null && c1 > 1) {
      v1 = c1;
      c1 = 1;
    }
    if (c1 < 1 || c1 > bible.chapterCount(book)) return null;
    int last(int c) => bible.chapter(book, c).length;
    if (v1 == null) {
      // « Romains 8 » ou « Romains 8-9 » : chapitres entiers.
      final c2 = x ?? c1;
      if (y != null || c2 < c1 || c2 > bible.chapterCount(book)) return null;
      return VerseRef(book, c1, 1, c2, last(c2));
    }
    if (v1 < 1 || v1 > last(c1)) return null;
    if (x == null) return VerseRef.single(book, c1, v1);
    if (y == null) {
      // « 3:16-18 »
      if (x < v1 || x > last(c1)) return null;
      return VerseRef(book, c1, v1, c1, x);
    }
    // « 3:16-4:2 »
    if (x < c1 || x > bible.chapterCount(book) || y < 1 || y > last(x) || (x == c1 && y < v1)) return null;
    return VerseRef(book, c1, v1, x, y);
  }
}
