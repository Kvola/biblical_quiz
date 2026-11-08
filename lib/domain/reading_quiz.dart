import 'dart:math';

import '../bible/bible.dart';
import '../content/content.dart';
import '../content/models.dart';
import '../core/books.dart';
import '../core/verse_ref.dart';
import 'book_challenge.dart';
import 'search.dart' show normalize;

/// Ce sur quoi porte un quiz de lecture : des livres, entiers ou réduits à
/// certains chapitres (ceux que le lecteur a lus).
class ReadingScope {
  const ReadingScope(this.books);

  /// Livre → chapitres retenus ; `null` = le livre entier.
  final Map<int, Set<int>?> books;

  bool get isEmpty => books.isEmpty || books.values.every((c) => c != null && c.isEmpty);

  bool includesChapter(int book, int chapter) {
    if (!books.containsKey(book)) return false;
    final chapters = books[book];
    return chapters == null || chapters.contains(chapter);
  }

  bool contains(VerseRef r) => includesChapter(r.book, r.startChapter);

  /// Chapitres effectivement couverts, dans l'ordre de la Bible.
  List<(int, int)> chaptersIn(Bible bible) => [
    for (final b in books.keys.toList()..sort())
      for (var c = 1; c <= bible.chapterCount(b); c++)
        if (includesChapter(b, c)) (b, c),
  ];
}

/// Quiz sur des livres choisis par le lecteur.
///
/// D'abord les questions RELUES du contenu dont le passage est dans la portée ;
/// puis, pour compléter, des questions tirées du texte biblique lui-même
/// (justes par construction, signalées par leur identifiant `gen-read-`) :
/// - compléter un verset (nom propre ou nom commun retiré) ;
/// - « Dans quel livre se trouve ce verset ? » (si plusieurs livres) ;
/// - « Lequel de ces passages vient en premier ? » (ordre du récit).
///
/// Aucun verset n'est jamais modifié : on ne présente pas un texte biblique
/// altéré comme une affirmation « fausse ». Les propositions incorrectes sont
/// des mots, des livres ou des passages réels, simplement mal placés.
class ReadingQuiz {
  static const idPrefix = 'gen-read-';

  /// Noms divins et mots trop attendus : jamais la réponse à compléter.
  static const _neverAnswer = {
    // Formes normalisées (sans accents ; le trait d'union devient une espace).
    'dieu', 'eternel', 'seigneur', 'christ', 'esprit', 'saint', 'jesus', 'jesus christ', 'saint esprit', 'messie',
    'lord', 'god', 'spirit', 'holy', 'ghost', 'almighty', 'amen', 'alleluia', 'selah', 'sela',
  };

  static const _detFr = {
    'le': 'm', 'un': 'm', 'ce': 'm', 'cet': 'm', 'du': 'm', 'au': 'm', 'mon': null, 'ton': null, 'son': null,
    'la': 'f', 'une': 'f', 'cette': 'f', 'ma': 'f', 'ta': 'f', 'sa': 'f',
    'les': null, 'des': null, 'aux': null, 'ces': null, 'mes': null, 'tes': null, 'ses': null, 'nos': null,
    'vos': null, 'leurs': null, 'notre': null, 'votre': null, 'leur': null, 'l': null,
  };
  static const _detEn = {'the', 'a', 'an', 'his', 'her', 'their', 'my', 'thy', 'our', 'your', 'this', 'these', 'those', 'its'};

  static const _stopFr = {
    'avec', 'dans', 'pour', 'mais', 'comme', 'sans', 'sous', 'vers', 'chez', 'entre', 'tout', 'tous', 'toute',
    'toutes', 'cette', 'leur', 'leurs', 'elle', 'elles', 'nous', 'vous', 'ils', 'lui', 'sont', 'était', 'être',
    'avait', 'fait', 'dont', 'quand', 'alors', 'ainsi', 'aussi', 'point', 'même', 'autre', 'autres', 'chose',
  };
  static const _stopEn = {
    'unto', 'thee', 'thou', 'thine', 'thy', 'hath', 'shall', 'shalt', 'that', 'with', 'which', 'them', 'they',
    'their', 'from', 'have', 'there', 'were', 'when', 'this', 'into', 'upon', 'also', 'said', 'came', 'went',
    'things', 'thing', 'every', 'neither', 'whom', 'what', 'saith', 'doth', 'didst', 'hast', 'wilt',
  };

  /// Mots qui suivent naturellement un nom (« cet homme FUT guéri », « le peuple DE Dieu ») :
  /// un mot après article suivi d'un autre mot plein est souvent un adjectif (« une agréable odeur »).
  static const _afterNounFr = {
    'de', 'du', 'des', 'd', 'et', 'ou', 'qui', 'que', 'qu', 'à', 'au', 'aux', 'dans', 'sur', 'pour', 'par', 'avec',
    'en', 'ne', 'n', 'se', 's', 'lui', 'leur', 'il', 'ils', 'elle', 'elles', 'est', 'fut', 'sont', 'était', 'étaient',
    'a', 'avait', 'sera', 'seront', 'devant', 'contre', 'selon', 'comme', 'car', 'mais', 'vers', 'sous',
  };
  static const _afterNounEn = {
    'of', 'and', 'that', 'which', 'who', 'in', 'to', 'unto', 'upon', 'from', 'with', 'for', 'was', 'were', 'is',
    'are', 'shall', 'will', 'be', 'had', 'hath', 'have', 'by', 'before', 'against', 'into', 'as', 'but', 'or', 'not',
  };

  static List<Question> build({
    required Content content,
    required Bible bible,
    required String lang,
    required ReadingScope scope,
    int count = 10,
    Random? random,
  }) {
    final rnd = random ?? Random();
    if (scope.isEmpty) return const [];
    // 1) Questions relues, d'abord.
    final curated = [for (final q in content.allQuestions) if (scope.contains(q.ref)) q]..shuffle(rnd);
    final out = <Question>[...curated.take(count)];
    if (out.length >= count) return out;
    // 2) Questions tirées du texte, pour compléter.
    final gen = _Generator(content, bible, lang, scope, rnd);
    out.addAll(gen.generate(count - out.length));
    return out;
  }
}

class _Generator {
  _Generator(this.content, this.bible, this.lang, this.scope, this.rnd) {
    _analyse();
  }

  final Content content;
  final Bible bible;
  final String lang;
  final ReadingScope scope;
  final Random rnd;

  bool get _fr => lang != 'en';

  /// Versets utilisables (phrase complète, ni liste ni généalogie), par chapitre.
  final _byChapter = <(int, int), List<Verse>>{};

  /// Mots du texte de la portée : forme normalisée → (forme écrite, nature, nombre, genre).
  final _proper = <String, _Word>{};
  final _nouns = <String, _Word>{};
  final _usedVerses = <String>{};

  /// Mots rencontrés en minuscule : « Que », « Car » en début de proposition ne sont pas des noms propres.
  final _lowerSeen = <String>{};

  static final _wordRe = RegExp(r"[\p{L}][\p{L}\-]*", unicode: true);
  static final _upper = RegExp(r'^\p{Lu}', unicode: true);

  void _analyse() {
    for (final (b, c) in scope.chaptersIn(bible)) {
      for (final v in bible.chapter(b, c)) {
        final words = _wordRe.allMatches(v.text).map((m) => m[0]!).toList();
        for (final w in words) {
          if (!_upper.hasMatch(w)) _lowerSeen.add(normalize(w));
        }
        var properCount = 0;
        for (var i = 0; i < words.length; i++) {
          final w = words[i];
          final key = normalize(w);
          if (key.length < 3) continue;
          final sentenceStart = i == 0 || RegExp(r'[.!?:;]\s*$').hasMatch(_before(v.text, w, i, words));
          if (_upper.hasMatch(w) && !sentenceStart && w.toUpperCase() != w) {
            properCount++;
            final p = _proper[key] ??= _Word(w);
            p.count++;
            // « l'Agneau », « le Père », « the Nazarite » : un titre précédé d'un article, pas un nom de personne.
            final prev = i > 0 ? words[i - 1].toLowerCase() : '';
            if (_fr ? ReadingQuiz._detFr.containsKey(prev) : ReadingQuiz._detEn.contains(prev)) p.withArticle++;
          } else if (i > 0 && w.length >= 4 && !_upper.hasMatch(w)) {
            final det = words[i - 1].toLowerCase();
            final isDet = _fr ? ReadingQuiz._detFr.containsKey(det) : ReadingQuiz._detEn.contains(det);
            final stop = _fr ? ReadingQuiz._stopFr : ReadingQuiz._stopEn;
            if (isDet && !stop.contains(w.toLowerCase()) && _endsNounPhrase(v.text, words, i)) {
              final n = _nouns[key] ??= _Word(w);
              n.count++;
              final g = _fr ? ReadingQuiz._detFr[det] : null;
              if (g != null) n.genders.add(g);
            }
          }
        }
        if (_usable(v.text, properCount)) (_byChapter[(b, c)] ??= []).add(v);
      }
    }
  }

  /// Le mot n° [i] est-il suivi d'une ponctuation, de la fin, ou d'un mot outil ? (sinon : adjectif probable)
  bool _endsNounPhrase(String text, List<String> words, int i) {
    if (i + 1 >= words.length) return true;
    final next = words[i + 1].toLowerCase();
    final set = _fr ? ReadingQuiz._afterNounFr : ReadingQuiz._afterNounEn;
    if (set.contains(next)) return true;
    // Ponctuation entre les deux mots ?
    final at = text.indexOf(words[i]);
    final nextAt = at < 0 ? -1 : text.indexOf(words[i + 1], at + words[i].length);
    return nextAt > 0 && RegExp(r'[,.;:!?»”)]').hasMatch(text.substring(at + words[i].length, nextAt));
  }

  /// Texte qui précède l'occurrence n° [i] (approximation suffisante pour repérer un début de phrase).
  String _before(String text, String w, int i, List<String> words) {
    final prev = words[i - 1];
    final at = text.indexOf(w, text.indexOf(prev) + prev.length);
    return at < 0 ? '' : text.substring(0, at);
  }

  bool _usable(String text, int properCount) {
    final t = text.trim();
    if (t.length < 50 || t.length > 260 || !BookChallenge.isCompleteSentence(t)) return false;
    // Le verset doit aussi COMMENCER une phrase : « et le cours des torrents… » prolonge le précédent.
    if (!RegExp(r'^[«"“(]?\s*\p{Lu}', unicode: true).hasMatch(t)) return false;
    if (properCount > 4) return false; // liste de noms, généalogie
    if (RegExp(r'\d').allMatches(t).length >= 3) return false; // dénombrements
    if (RegExp(r'\b(engendra|begat)\b').allMatches(t).length >= 2) return false;
    return true;
  }

  /// Noms propres les plus fréquents de la portée : réponses trop évidentes (« Jésus » dans les Évangiles).
  bool _isProper(String key) {
    final p = _proper[key];
    return p != null && !_lowerSeen.contains(key) && p.withArticle * 2 < p.count;
  }

  late final Set<String> _tooFrequent = () {
    final sorted = _proper.entries.toList()..sort((a, b) => b.value.count.compareTo(a.value.count));
    return {for (final e in sorted.take(3)) e.key};
  }();

  List<Question> generate(int need) {
    final out = <Question>[];
    final multiBook = scope.books.length >= 2;
    final orderBook = _orderBook();
    final plan = [
      _cloze, _cloze,
      if (multiBook) _whichBook,
      _cloze,
      if (orderBook != null) () => _order(orderBook),
    ];
    var misses = 0;
    for (var i = 0; out.length < need && misses < plan.length * 6; i++) {
      final q = plan[i % plan.length]();
      if (q == null || out.any((x) => x.id == q.id)) {
        misses++;
        continue;
      }
      out.add(q);
    }
    return out;
  }

  /// Un verset utilisable pas encore employé, en variant les chapitres.
  Verse? _pickVerse({bool Function(Verse)? where}) {
    final chapters = _byChapter.keys.toList()..shuffle(rnd);
    for (final c in chapters) {
      final verses = [..._byChapter[c]!]..shuffle(rnd);
      for (final v in verses) {
        final code = '${v.book}:${v.chapter}:${v.number}';
        if (_usedVerses.contains(code)) continue;
        if (where != null && !where(v)) continue;
        return v;
      }
    }
    return null;
  }

  VerseRef _ref(Verse v) => VerseRef.single(v.book, v.chapter, v.number);

  String _label(VerseRef r) => refLabel(r, lang);

  LText _same(String s) => LText(s, s);

  // -- Compléter le verset -------------------------------------------------
  Question? _cloze() {
    for (var attempt = 0; attempt < 12; attempt++) {
      final v = _pickVerse();
      if (v == null) return null;
      final matches = _wordRe.allMatches(v.text).toList();
      final words = [for (final m in matches) m[0]!];
      // Candidats : noms propres d'abord, puis noms communs introduits par un article.
      final candidates = <(RegExpMatch, _Word, bool)>[];
      for (var i = 1; i < words.length; i++) {
        final key = normalize(words[i]);
        if (ReadingQuiz._neverAnswer.contains(key) || _tooFrequent.contains(key)) continue;
        final sentenceStart = RegExp(r'[.!?:;«“"]\s*$').hasMatch(v.text.substring(0, matches[i].start));
        if (_isProper(key) && _upper.hasMatch(words[i]) && !sentenceStart) {
          candidates.add((matches[i], _proper[key]!, true));
          continue;
        }
        final n = _nouns[key];
        if (n != null && !_upper.hasMatch(words[i])) {
          final det = words[i - 1].toLowerCase();
          final isDet = _fr ? ReadingQuiz._detFr.containsKey(det) : ReadingQuiz._detEn.contains(det);
          if (isDet && _endsNounPhrase(v.text, words, i)) candidates.add((matches[i], n, false));
        }
      }
      if (candidates.isEmpty) {
        _usedVerses.add('${v.book}:${v.chapter}:${v.number}');
        continue;
      }
      candidates.sort((a, b) => (b.$3 ? 1 : 0).compareTo(a.$3 ? 1 : 0));
      final (match, word, proper) = candidates.first;
      final surface = match[0]!;
      final distractors = _distractors(surface, word, proper, v.text);
      if (distractors.length < 3) {
        _usedVerses.add('${v.book}:${v.chapter}:${v.number}');
        continue;
      }
      // On retire CETTE occurrence (le mot peut figurer deux fois dans le verset).
      final blanked = v.text.replaceRange(match.start, match.end, '_____');
      _usedVerses.add('${v.book}:${v.chapter}:${v.number}');
      final ref = _ref(v);
      final label = _label(ref);
      final options = [surface, ...distractors]..shuffle(rnd);
      return ChoiceQuestion(
        id: '${ReadingQuiz.idPrefix}cloze-${ref.code}-${normalize(surface)}',
        prompt: _same(_fr ? 'Complétez le verset ($label) :\n« $blanked »' : 'Complete the verse ($label):\n“$blanked”'),
        explain: _same(_fr ? '$label : « ${v.text} »' : '$label: “${v.text}”'),
        ref: ref,
        fr: options,
        en: options,
        answer: options.indexOf(surface),
      );
    }
    return null;
  }

  /// Mots de même nature, présents dans les livres choisis mais pas dans le verset.
  List<String> _distractors(String surface, _Word word, bool proper, String verse) {
    // Comparaison sur l'expression entière : « Jésus-Christ » se normalise en « jesus christ ».
    final inVerse = ' ${normalize(verse)} ';
    final pool = proper ? _proper : _nouns;
    final plural = _plural(surface);
    final gender = word.genders.length == 1 ? word.genders.first : null;
    final candidates = <_Word>[];
    for (final e in pool.entries) {
      if (e.key == normalize(surface) || inVerse.contains(' ${e.key} ')) continue;
      if (ReadingQuiz._neverAnswer.contains(e.key)) continue;
      if (proper && !_isProper(e.key)) continue;
      final w = e.value;
      if (!proper) {
        if (_plural(w.surface) != plural) continue;
        final g = w.genders.length == 1 ? w.genders.first : null;
        if (gender != null && g != null && g != gender) continue;
      }
      if ((w.surface.length - surface.length).abs() > 6) continue;
      candidates.add(w);
    }
    // Les plus présents d'abord (plausibles pour qui a lu), puis tirage.
    candidates.sort((a, b) => b.count.compareTo(a.count));
    final top = candidates.take(10).toList()..shuffle(rnd);
    final seen = <String>{normalize(surface)};
    return [for (final w in top) if (seen.add(normalize(w.surface))) w.surface].take(3).toList();
  }

  bool _plural(String w) {
    final l = w.toLowerCase();
    return _fr ? (l.endsWith('s') || l.endsWith('x')) : (l.endsWith('s') && !l.endsWith('ss'));
  }

  // -- Dans quel livre ? ---------------------------------------------------
  Question? _whichBook() {
    final v = _pickVerse(where: (v) => v.text.length <= 220);
    if (v == null) return null;
    _usedVerses.add('${v.book}:${v.chapter}:${v.number}');
    final correct = bookById(v.book);
    final others = [for (final b in scope.books.keys) if (b != v.book) bookById(b)]..shuffle(rnd);
    final picks = others.take(3).toList();
    if (picks.length < 3) {
      // Moins de quatre livres choisis : on complète avec des livres du même genre.
      final sameGenre = [for (final b in books) if (b.genre == correct.genre && b.id != correct.id && !picks.contains(b)) b]
        ..shuffle(rnd);
      final rest = [for (final b in books) if (b.id != correct.id && !picks.contains(b) && !sameGenre.contains(b)) b]
        ..shuffle(rnd);
      for (final b in [...sameGenre, ...rest]) {
        if (picks.length >= 3) break;
        picks.add(b);
      }
    }
    final options = [correct, ...picks]..shuffle(rnd);
    final ref = _ref(v);
    final label = _label(ref);
    return ChoiceQuestion(
      id: '${ReadingQuiz.idPrefix}book-${ref.code}',
      prompt: _same(_fr ? 'Dans quel livre se trouve ce verset ?\n« ${v.text} »' : 'Which book is this verse from?\n“${v.text}”'),
      explain: _same(_fr ? 'Ce verset se trouve en $label.' : 'This verse is found in $label.'),
      ref: ref,
      fr: [for (final b in options) b.fr],
      en: [for (final b in options) b.en],
      answer: options.indexOf(correct),
    );
  }

  // -- Ordre du récit ------------------------------------------------------
  /// Un livre dont au moins quatre chapitres sont dans la portée (sinon pas de question d'ordre).
  int? _orderBook() {
    final perBook = <int, int>{};
    for (final (b, _) in _byChapter.keys) {
      perBook[b] = (perBook[b] ?? 0) + 1;
    }
    final eligible = [for (final e in perBook.entries) if (e.value >= 4) e.key]..shuffle(rnd);
    return eligible.firstOrNull;
  }

  Question? _order(int book) {
    final chapters = [for (final k in _byChapter.keys) if (k.$1 == book) k.$2]..sort();
    if (chapters.length < 4) return null;
    // Quatre chapitres répartis sur la portée, un verset court de chacun.
    final step = chapters.length / 4;
    final picks = <Verse>[];
    for (var k = 0; k < 4; k++) {
      final lo = (k * step).floor(), hi = max(lo + 1, ((k + 1) * step).floor());
      final c = chapters[lo + rnd.nextInt(hi - lo)];
      final verses = [for (final v in _byChapter[(book, c)]!) if (v.text.length <= 200) v]..shuffle(rnd);
      final v = verses.where((v) => !_usedVerses.contains('${v.book}:${v.chapter}:${v.number}')).firstOrNull;
      if (v == null) return null;
      picks.add(v);
    }
    for (final v in picks) {
      _usedVerses.add('${v.book}:${v.chapter}:${v.number}');
    }
    String excerpt(Verse v) {
      final words = v.text.split(RegExp(r'\s+'));
      return words.length <= 12 ? v.text : '${words.take(12).join(' ')}…';
    }

    final first = picks.reduce((a, b) => a.chapter < b.chapter || (a.chapter == b.chapter && a.number < b.number) ? a : b);
    final options = [for (final v in picks) excerpt(v)];
    if (options.toSet().length < 4) return null;
    final correct = excerpt(first);
    options.shuffle(rnd);
    final name = bookById(book).name(lang);
    final sorted = [...picks]..sort((a, b) => a.chapter != b.chapter ? a.chapter.compareTo(b.chapter) : a.number.compareTo(b.number));
    final refs = sorted.map((v) => _label(_ref(v))).join(_fr ? ', puis ' : ', then ');
    return ChoiceQuestion(
      id: '${ReadingQuiz.idPrefix}order-${picks.map((v) => _ref(v).code).join('_')}',
      prompt: _same(_fr ? 'Dans $name, lequel de ces passages vient en premier ?' : 'In $name, which of these passages comes first?'),
      explain: _same(_fr ? 'Dans l’ordre du livre : $refs.' : 'In the order of the book: $refs.'),
      ref: _ref(first),
      fr: options,
      en: options,
      answer: options.indexOf(correct),
    );
  }
}

class _Word {
  _Word(this.surface);

  final String surface;
  final genders = <String>{};
  int count = 0;
  int withArticle = 0;
}
