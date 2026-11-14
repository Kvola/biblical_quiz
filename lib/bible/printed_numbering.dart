import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/verse_ref.dart';

/// Numéros des versets dans une Segond imprimée.
///
/// Les deux Bibles embarquées suivent la numérotation de la King James, pour
/// partager les mêmes références. Beaucoup de Segond imprimées numérotent
/// autrement quelques chapitres : dans les Psaumes, le titre compte souvent
/// comme verset 1 (Ps 19:7 ici = Ps 19:8 sur papier) ; Jonas 1:17 = Jonas 2:1…
///
/// Table produite par scripts/build_lsg_printed.py (assets/bible/lsg_printed.json) :
/// pour chaque chapitre numéroté autrement, des plages
/// `[premier, dernier, chapitre, verset, chapitre de fin, verset de fin]`.
/// Une plage de plusieurs versets avance d'un verset imprimé par verset ; une
/// plage d'un seul verset peut couvrir plusieurs versets imprimés (Ps 51:1 = 51:1-3).
class PrintedNumbering {
  PrintedNumbering(this._chapters);

  static const asset = 'assets/bible/lsg_printed.json';

  static const empty = PrintedNumbering._empty();
  const PrintedNumbering._empty() : _chapters = const {};

  final Map<String, List<List<int>>> _chapters;

  factory PrintedNumbering.parse(String json) {
    final raw = jsonDecode(json) as Map<String, dynamic>;
    return PrintedNumbering({
      for (final e in raw.entries)
        e.key: [for (final r in e.value as List) (r as List).cast<int>()],
    });
  }

  static Future<PrintedNumbering> load(AssetBundle bundle) async => PrintedNumbering.parse(await bundle.loadString(asset));

  /// Vrai si une Segond imprimée numérote ce chapitre autrement.
  bool chapterDiffers(int book, int chapter) => _chapters.containsKey('$book:$chapter');

  /// Début et fin, sur papier, du verset (chapitre, verset) ; null si identiques.
  ((int, int), (int, int))? _verse(int book, int chapter, int verse) {
    final runs = _chapters['$book:$chapter'];
    if (runs == null) return null;
    for (final r in runs) {
      if (verse < r[0] || verse > r[1]) continue;
      if (r[1] > r[0]) {
        final v = r[3] + verse - r[0];
        return ((r[2], v), (r[2], v));
      }
      return ((r[2], r[3]), (r[4], r[5]));
    }
    return null;
  }

  /// La même référence avec les numéros d'une Segond imprimée, ou null s'ils
  /// sont identiques à ceux de l'application.
  VerseRef? printed(VerseRef ref) {
    final s = _verse(ref.book, ref.startChapter, ref.startVerse)?.$1 ?? (ref.startChapter, ref.startVerse);
    final e = _verse(ref.book, ref.endChapter, ref.endVerse)?.$2 ?? (ref.endChapter, ref.endVerse);
    final p = VerseRef(ref.book, s.$1, s.$2, e.$1, e.$2);
    return p == ref ? null : p;
  }
}
