import 'verse_ref.dart';

enum Testament { old, newT }

enum BookGenre { law, history, poetry, prophets, gospels, acts, epistles, apocalyptic }

/// Les 66 livres. Même table que scripts/books.py (vérifiée par un test).
class BookName {
  const BookName(this.id, this.fr, this.frAbbr, this.en, this.enAbbr, this.genre);

  final int id;
  final String fr;
  final String frAbbr;
  final String en;
  final String enAbbr;
  final BookGenre genre;

  Testament get testament => id <= 39 ? Testament.old : Testament.newT;

  String name(String lang) => lang == 'en' ? en : fr;
  String abbr(String lang) => lang == 'en' ? enAbbr : frAbbr;
}

const books = <BookName>[
  BookName(1, 'Genèse', 'Gn', 'Genesis', 'Gen', BookGenre.law),
  BookName(2, 'Exode', 'Ex', 'Exodus', 'Exod', BookGenre.law),
  BookName(3, 'Lévitique', 'Lv', 'Leviticus', 'Lev', BookGenre.law),
  BookName(4, 'Nombres', 'Nb', 'Numbers', 'Num', BookGenre.law),
  BookName(5, 'Deutéronome', 'Dt', 'Deuteronomy', 'Deut', BookGenre.law),
  BookName(6, 'Josué', 'Jos', 'Joshua', 'Josh', BookGenre.history),
  BookName(7, 'Juges', 'Jg', 'Judges', 'Judg', BookGenre.history),
  BookName(8, 'Ruth', 'Rt', 'Ruth', 'Ruth', BookGenre.history),
  BookName(9, '1 Samuel', '1 S', '1 Samuel', '1 Sam', BookGenre.history),
  BookName(10, '2 Samuel', '2 S', '2 Samuel', '2 Sam', BookGenre.history),
  BookName(11, '1 Rois', '1 R', '1 Kings', '1 Kgs', BookGenre.history),
  BookName(12, '2 Rois', '2 R', '2 Kings', '2 Kgs', BookGenre.history),
  BookName(13, '1 Chroniques', '1 Ch', '1 Chronicles', '1 Chr', BookGenre.history),
  BookName(14, '2 Chroniques', '2 Ch', '2 Chronicles', '2 Chr', BookGenre.history),
  BookName(15, 'Esdras', 'Esd', 'Ezra', 'Ezra', BookGenre.history),
  BookName(16, 'Néhémie', 'Né', 'Nehemiah', 'Neh', BookGenre.history),
  BookName(17, 'Esther', 'Est', 'Esther', 'Esth', BookGenre.history),
  BookName(18, 'Job', 'Jb', 'Job', 'Job', BookGenre.poetry),
  BookName(19, 'Psaumes', 'Ps', 'Psalms', 'Ps', BookGenre.poetry),
  BookName(20, 'Proverbes', 'Pr', 'Proverbs', 'Prov', BookGenre.poetry),
  BookName(21, 'Ecclésiaste', 'Ec', 'Ecclesiastes', 'Eccl', BookGenre.poetry),
  BookName(22, 'Cantique des cantiques', 'Ct', 'Song of Solomon', 'Song', BookGenre.poetry),
  BookName(23, 'Ésaïe', 'És', 'Isaiah', 'Isa', BookGenre.prophets),
  BookName(24, 'Jérémie', 'Jr', 'Jeremiah', 'Jer', BookGenre.prophets),
  BookName(25, 'Lamentations', 'Lm', 'Lamentations', 'Lam', BookGenre.prophets),
  BookName(26, 'Ézéchiel', 'Éz', 'Ezekiel', 'Ezek', BookGenre.prophets),
  BookName(27, 'Daniel', 'Dn', 'Daniel', 'Dan', BookGenre.prophets),
  BookName(28, 'Osée', 'Os', 'Hosea', 'Hos', BookGenre.prophets),
  BookName(29, 'Joël', 'Jl', 'Joel', 'Joel', BookGenre.prophets),
  BookName(30, 'Amos', 'Am', 'Amos', 'Amos', BookGenre.prophets),
  BookName(31, 'Abdias', 'Ab', 'Obadiah', 'Obad', BookGenre.prophets),
  BookName(32, 'Jonas', 'Jon', 'Jonah', 'Jonah', BookGenre.prophets),
  BookName(33, 'Michée', 'Mi', 'Micah', 'Mic', BookGenre.prophets),
  BookName(34, 'Nahum', 'Na', 'Nahum', 'Nah', BookGenre.prophets),
  BookName(35, 'Habakuk', 'Ha', 'Habakkuk', 'Hab', BookGenre.prophets),
  BookName(36, 'Sophonie', 'So', 'Zephaniah', 'Zeph', BookGenre.prophets),
  BookName(37, 'Aggée', 'Ag', 'Haggai', 'Hag', BookGenre.prophets),
  BookName(38, 'Zacharie', 'Za', 'Zechariah', 'Zech', BookGenre.prophets),
  BookName(39, 'Malachie', 'Ml', 'Malachi', 'Mal', BookGenre.prophets),
  BookName(40, 'Matthieu', 'Mt', 'Matthew', 'Matt', BookGenre.gospels),
  BookName(41, 'Marc', 'Mc', 'Mark', 'Mark', BookGenre.gospels),
  BookName(42, 'Luc', 'Lc', 'Luke', 'Luke', BookGenre.gospels),
  BookName(43, 'Jean', 'Jn', 'John', 'John', BookGenre.gospels),
  BookName(44, 'Actes', 'Ac', 'Acts', 'Acts', BookGenre.acts),
  BookName(45, 'Romains', 'Rm', 'Romans', 'Rom', BookGenre.epistles),
  BookName(46, '1 Corinthiens', '1 Co', '1 Corinthians', '1 Cor', BookGenre.epistles),
  BookName(47, '2 Corinthiens', '2 Co', '2 Corinthians', '2 Cor', BookGenre.epistles),
  BookName(48, 'Galates', 'Ga', 'Galatians', 'Gal', BookGenre.epistles),
  BookName(49, 'Éphésiens', 'Ép', 'Ephesians', 'Eph', BookGenre.epistles),
  BookName(50, 'Philippiens', 'Ph', 'Philippians', 'Phil', BookGenre.epistles),
  BookName(51, 'Colossiens', 'Col', 'Colossians', 'Col', BookGenre.epistles),
  BookName(52, '1 Thessaloniciens', '1 Th', '1 Thessalonians', '1 Thess', BookGenre.epistles),
  BookName(53, '2 Thessaloniciens', '2 Th', '2 Thessalonians', '2 Thess', BookGenre.epistles),
  BookName(54, '1 Timothée', '1 Tm', '1 Timothy', '1 Tim', BookGenre.epistles),
  BookName(55, '2 Timothée', '2 Tm', '2 Timothy', '2 Tim', BookGenre.epistles),
  BookName(56, 'Tite', 'Tt', 'Titus', 'Titus', BookGenre.epistles),
  BookName(57, 'Philémon', 'Phm', 'Philemon', 'Phlm', BookGenre.epistles),
  BookName(58, 'Hébreux', 'Hé', 'Hebrews', 'Heb', BookGenre.epistles),
  BookName(59, 'Jacques', 'Jc', 'James', 'Jas', BookGenre.epistles),
  BookName(60, '1 Pierre', '1 P', '1 Peter', '1 Pet', BookGenre.epistles),
  BookName(61, '2 Pierre', '2 P', '2 Peter', '2 Pet', BookGenre.epistles),
  BookName(62, '1 Jean', '1 Jn', '1 John', '1 John', BookGenre.epistles),
  BookName(63, '2 Jean', '2 Jn', '2 John', '2 John', BookGenre.epistles),
  BookName(64, '3 Jean', '3 Jn', '3 John', '3 John', BookGenre.epistles),
  BookName(65, 'Jude', 'Jude', 'Jude', 'Jude', BookGenre.epistles),
  BookName(66, 'Apocalypse', 'Ap', 'Revelation', 'Rev', BookGenre.apocalyptic),
];

BookName bookById(int id) => books[id - 1];

/// « Jean 3:16 » / « John 3:16 ».
String refLabel(VerseRef ref, String lang, {bool abbreviated = false}) {
  final b = bookById(ref.book);
  return '${abbreviated ? b.abbr(lang) : b.name(lang)} ${ref.chapterVerseLabel}';
}
