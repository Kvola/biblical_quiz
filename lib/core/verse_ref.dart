/// Référence biblique « livre:chapitre:verset[-[chapitre:]verset] ».
///
/// Même grammaire que scripts/refs.py : le contenu est validé par le script
/// et relu ici, les deux doivent rester d'accord.
class VerseRef implements Comparable<VerseRef> {
  const VerseRef(this.book, this.startChapter, this.startVerse, this.endChapter, this.endVerse);

  const VerseRef.single(this.book, this.startChapter, this.startVerse)
    : endChapter = startChapter,
      endVerse = startVerse;

  final int book;
  final int startChapter;
  final int startVerse;
  final int endChapter;
  final int endVerse;

  static final _re = RegExp(r'^(\d{1,2}):(\d{1,3}):(\d{1,3})(?:-(?:(\d{1,3}):)?(\d{1,3}))?$');

  static VerseRef parse(String text) {
    final m = _re.firstMatch(text.trim());
    if (m == null) throw FormatException('Référence mal formée', text);
    final book = int.parse(m[1]!);
    final c1 = int.parse(m[2]!);
    final v1 = int.parse(m[3]!);
    final c2 = m[5] == null ? c1 : int.parse(m[4] ?? m[2]!);
    final v2 = m[5] == null ? v1 : int.parse(m[5]!);
    if (book < 1 || book > 66) throw FormatException('Livre inconnu', text);
    if (c2 < c1 || (c2 == c1 && v2 < v1)) throw FormatException('Fin avant le début', text);
    return VerseRef(book, c1, v1, c2, v2);
  }

  bool get isSingle => startChapter == endChapter && startVerse == endVerse;

  /// Vrai si le verset (chapitre, verset) est couvert.
  bool covers(int chapter, int verse) {
    final k = chapter * 1000 + verse;
    return k >= startChapter * 1000 + startVerse && k <= endChapter * 1000 + endVerse;
  }

  /// « 3:16 », « 1:1-31 », « 1:1–2:3 » (sans le livre).
  String get chapterVerseLabel {
    if (isSingle) return '$startChapter:$startVerse';
    if (startChapter == endChapter) return '$startChapter:$startVerse-$endVerse';
    return '$startChapter:$startVerse–$endChapter:$endVerse';
  }

  String get code => isSingle
      ? '$book:$startChapter:$startVerse'
      : startChapter == endChapter
      ? '$book:$startChapter:$startVerse-$endVerse'
      : '$book:$startChapter:$startVerse-$endChapter:$endVerse';

  @override
  String toString() => code;

  @override
  bool operator ==(Object other) =>
      other is VerseRef &&
      other.book == book &&
      other.startChapter == startChapter &&
      other.startVerse == startVerse &&
      other.endChapter == endChapter &&
      other.endVerse == endVerse;

  @override
  int get hashCode => Object.hash(book, startChapter, startVerse, endChapter, endVerse);

  @override
  int compareTo(VerseRef o) {
    if (book != o.book) return book - o.book;
    if (startChapter != o.startChapter) return startChapter - o.startChapter;
    return startVerse - o.startVerse;
  }
}
