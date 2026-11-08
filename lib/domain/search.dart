import '../bible/bible.dart';
import '../core/books.dart';
import '../core/verse_ref.dart';

// ---------------------------------------------------------------------------
// Normalisation
// ---------------------------------------------------------------------------

/// Lettres accentuées et ligatures -> forme de base (minuscule).
const _fold = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ç': 'c', 'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', 'ñ': 'n', 'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', 'ý': 'y', 'ÿ': 'y', 'œ': 'oe', 'æ': 'ae', 'ß': 'ss',
};

bool _isWordChar(int c) => (c >= 0x61 && c <= 0x7a) || (c >= 0x30 && c <= 0x39); // a-z, 0-9 (après repli)

/// Forme de recherche d'un texte, avec la position d'origine de chaque caractère.
///
/// Minuscules, accents et ligatures repliés (« Éternel », « cœur » -> « eternel »,
/// « coeur »), et toute suite de caractères qui n'est ni lettre ni chiffre
/// (espaces, ponctuation, apostrophes) réduite à une seule espace. Ainsi
/// « Que la lumière soit! » et « que la lumiere soit » ont la même forme, et
/// « l'Eternel » se lit « l eternel ».
class Normalized {
  Normalized._(this.text, this.origin);

  /// Texte normalisé, sans espace au début ni à la fin.
  final String text;

  /// origin[i] = indice, dans le texte d'origine, du caractère qui a produit text[i].
  final List<int> origin;

  factory Normalized.of(String input, {bool withMap = true}) {
    final out = StringBuffer();
    final origin = <int>[];
    var pendingSpace = false;
    for (var i = 0; i < input.length; i++) {
      final ch = input[i].toLowerCase();
      final folded = _fold[ch] ?? ch;
      final code = folded.codeUnitAt(0);
      if (folded.length == 1 && !_isWordChar(code)) {
        pendingSpace = out.isNotEmpty;
        continue;
      }
      if (pendingSpace) {
        out.write(' ');
        if (withMap) origin.add(i);
        pendingSpace = false;
      }
      out.write(folded);
      if (withMap) {
        for (var k = 0; k < folded.length; k++) {
          origin.add(i);
        }
      }
    }
    return Normalized._(out.toString(), origin);
  }
}

String normalize(String input) => Normalized.of(input, withMap: false).text;

// ---------------------------------------------------------------------------
// Requête
// ---------------------------------------------------------------------------

/// Une requête analysée.
///
/// - mots séparés par des espaces : tous doivent figurer, dans n'importe quel ordre ;
/// - `"expression exacte"` entre guillemets (droits ou typographiques) ;
/// - `-mot` ou `-"expression"` : exclu ;
/// - un mot trouve aussi les mots qui commencent par lui (« pardon » ->
///   « pardonne »), sauf en mode [wholeWords].
class SearchQuery {
  SearchQuery._(this.required, this.excluded);

  /// Termes normalisés à trouver (mots ou expressions).
  final List<String> required;

  /// Termes normalisés qui excluent le verset.
  final List<String> excluded;

  bool get isEmpty => required.isEmpty;

  static final _token = RegExp(r'''(-?)(?:["“”«»]([^"“”«»]*)["“”«»]?|(\S+))''');

  factory SearchQuery.parse(String input) {
    final req = <String>[], exc = <String>[];
    for (final m in _token.allMatches(input)) {
      final negative = m[1] == '-';
      final term = normalize(m[2] ?? m[3] ?? '');
      if (term.isEmpty) continue;
      (negative ? exc : req).add(term);
    }
    // Les termes les plus longs d'abord : ils éliminent plus vite les versets.
    req.sort((a, b) => b.length.compareTo(a.length));
    return SearchQuery._(req, exc);
  }
}

/// Position du premier [term] dans [text] commençant à une frontière de mot
/// (et finissant à une frontière si [wholeWord]), à partir de [from] ; -1 sinon.
int findTerm(String text, String term, {bool wholeWord = false, int from = 0}) {
  var i = text.indexOf(term, from);
  while (i >= 0) {
    final startOk = i == 0 || text.codeUnitAt(i - 1) == 0x20;
    final end = i + term.length;
    final endOk = !wholeWord || end == text.length || text.codeUnitAt(end) == 0x20;
    if (startOk && endOk) return i;
    i = text.indexOf(term, i + 1);
  }
  return -1;
}

bool matches(String normalizedText, SearchQuery q, {bool wholeWords = false}) {
  if (q.isEmpty) return false;
  for (final t in q.required) {
    if (findTerm(normalizedText, t, wholeWord: wholeWords) < 0) return false;
  }
  for (final t in q.excluded) {
    if (findTerm(normalizedText, t, wholeWord: wholeWords) >= 0) return false;
  }
  return true;
}

/// Plages (début, fin) à surligner dans le texte d'ORIGINE d'un verset.
List<(int, int)> highlightRanges(String original, SearchQuery q, {bool wholeWords = false}) {
  final n = Normalized.of(original);
  final ranges = <(int, int)>[];
  for (final t in q.required) {
    var from = 0;
    while (true) {
      final i = findTerm(n.text, t, wholeWord: wholeWords, from: from);
      if (i < 0) break;
      var end = i + t.length;
      // Un mot trouvé par son début est surligné en entier (« pardon|ne »).
      if (!wholeWords) {
        while (end < n.text.length && n.text.codeUnitAt(end) != 0x20) {
          end++;
        }
      }
      final last = n.origin[end - 1];
      ranges.add((n.origin[i], last + 1));
      from = i + 1;
    }
  }
  ranges.sort((a, b) => a.$1.compareTo(b.$1));
  // Fusion des plages qui se chevauchent.
  final merged = <(int, int)>[];
  for (final r in ranges) {
    if (merged.isNotEmpty && r.$1 <= merged.last.$2) {
      final l = merged.removeLast();
      merged.add((l.$1, r.$2 > l.$2 ? r.$2 : l.$2));
    } else {
      merged.add(r);
    }
  }
  return merged;
}

// ---------------------------------------------------------------------------
// Index et recherche
// ---------------------------------------------------------------------------

class SearchResult {
  const SearchResult({required this.hits, required this.perBook, required this.total});

  /// Indices (dans [SearchIndex.verses]) des versets trouvés, dans l'ordre biblique.
  final List<int> hits;

  /// Nombre de versets trouvés par livre (avant le filtre de livres).
  final Map<int, int> perBook;

  /// Nombre total de versets trouvés (avant le filtre de livres).
  final int total;

  static const empty = SearchResult(hits: [], perBook: {}, total: 0);
}

/// Index de recherche d'une traduction : le texte normalisé de chaque verset.
///
/// Une simple liste parcourue à chaque recherche : 31 102 versets se
/// parcourent en quelques dizaines de millisecondes, sans base à construire
/// ni à migrer, et le résultat est exact.
class SearchIndex {
  SearchIndex(this.bible, this.normalized) : assert(normalized.length == bible.verseCount);

  final Bible bible;
  final List<String> normalized;

  List<Verse> get verses => bible.allVerses;

  /// Construit l'index (à appeler hors du fil de l'interface : ~0,5 s).
  static List<String> normalizeAll(List<String> texts) => [for (final t in texts) normalize(t)];

  /// [books] : livres retenus (null = tous). Le décompte par livre ignore ce
  /// filtre, pour que la personne voie où se trouvent les autres résultats.
  SearchResult search(SearchQuery q, {Set<int>? books, bool wholeWords = false}) {
    if (q.isEmpty) return SearchResult.empty;
    final all = verses;
    final hits = <int>[];
    final perBook = <int, int>{};
    var total = 0;
    for (var i = 0; i < normalized.length; i++) {
      if (!matches(normalized[i], q, wholeWords: wholeWords)) continue;
      final b = all[i].book;
      perBook[b] = (perBook[b] ?? 0) + 1;
      total++;
      if (books == null || books.contains(b)) hits.add(i);
    }
    return SearchResult(hits: hits, perBook: perBook, total: total);
  }
}

// ---------------------------------------------------------------------------
// Références tapées par une personne (« Jean 3:16 », « 1 Co 13 », « jn 3 16 »)
// ---------------------------------------------------------------------------

final Map<String, int> _bookKeys = () {
  final m = <String, int>{};
  for (final b in books) {
    for (final name in [b.fr, b.frAbbr, b.en, b.enAbbr]) {
      final k = normalize(name);
      m[k] = b.id;
      m[k.replaceAll(' ', '')] = b.id; // « 1co », « 1jn »
    }
  }
  // Variantes courantes.
  for (final e in {
    'psaume': 19,
    'psalm': 19,
    'cantique': 22,
    'song': 22,
    'apoc': 66,
    'revelations': 66,
    'actes des apotres': 44,
    'esaie': 23,
    'isaie': 23,
    'qohelet': 21,
    'jacques': 59,
    'ecclesiaste': 21,
  }.entries) {
    m[e.key] = e.value;
  }
  return m;
}();

/// Reconnaît une référence. Renvoie null si le texte n'en est pas une ou si
/// elle n'existe pas dans [bible]. Un chapitre seul renvoie son premier verset
/// (et [chapterOnly] vrai).
({VerseRef ref, bool chapterOnly})? parseHumanRef(String input, Bible bible) {
  final n = normalize(input);
  final m = RegExp(r'^((?:[1-3] ?)?[a-z][a-z ]*?) ?(\d{1,3})(?: (\d{1,3})(?: (\d{1,3}))?)?$').firstMatch(n);
  if (m == null) return null;
  final book = _bookKeys[m[1]!.trim()] ?? _bookKeys[m[1]!.replaceAll(' ', '')];
  if (book == null) return null;
  final chapter = int.parse(m[2]!);
  if (chapter < 1 || chapter > bible.chapterCount(book)) return null;
  if (m[3] == null) {
    return (ref: VerseRef.single(book, chapter, 1), chapterOnly: true);
  }
  final v1 = int.parse(m[3]!);
  final v2 = m[4] == null ? v1 : int.parse(m[4]!);
  if (bible.verse(book, chapter, v1) == null || bible.verse(book, chapter, v2) == null || v2 < v1) return null;
  return (ref: VerseRef(book, chapter, v1, chapter, v2), chapterOnly: false);
}
