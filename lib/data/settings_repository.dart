import 'dart:convert';

import 'database.dart';

class AppSettings {
  const AppSettings({
    this.localeCode,
    this.textScale = 1.0,
    this.parallel = false,
    this.lastPathId,
    this.readerBook = 43,
    this.readerChapter = 1,
    this.onboarded = false,
    this.themeMode = 'system',
    this.recentSearches = const [],
  });

  /// null : langue du téléphone.
  final String? localeCode;

  /// Taille du texte biblique (0.85 à 1.6).
  final double textScale;

  /// Afficher aussi l'autre traduction sous chaque verset.
  final bool parallel;
  final String? lastPathId;
  final int readerBook;
  final int readerChapter;
  final bool onboarded;

  /// « system » (celui du téléphone), « light » ou « dark ».
  final String themeMode;

  /// Recherches récentes, la plus récente d'abord (au plus [maxRecentSearches]).
  final List<String> recentSearches;

  static const maxRecentSearches = 10;

  static const minScale = 0.85, maxScale = 1.6;

  /// Une valeur illisible (version future, fichier abîmé) donne une liste vide plutôt qu'une erreur.
  static List<String> _decodeList(String? raw) {
    if (raw == null) return const [];
    try {
      final v = jsonDecode(raw);
      return v is List ? v.whereType<String>().take(maxRecentSearches).toList() : const [];
    } on FormatException {
      return const [];
    }
  }

  static AppSettings fromMap(Map<String, String> m) {
    final scale = double.tryParse(m['textScale'] ?? '') ?? 1.0;
    final book = int.tryParse(m['readerBook'] ?? '') ?? 43;
    final chapter = int.tryParse(m['readerChapter'] ?? '') ?? 1;
    return AppSettings(
      localeCode: switch (m['locale']) {
        'fr' => 'fr',
        'en' => 'en',
        _ => null,
      },
      textScale: scale.clamp(minScale, maxScale),
      parallel: m['parallel'] == '1',
      lastPathId: m['lastPathId'],
      readerBook: book >= 1 && book <= 66 ? book : 43,
      readerChapter: chapter >= 1 ? chapter : 1,
      onboarded: m['onboarded'] == '1',
      recentSearches: _decodeList(m['recentSearches']),
      themeMode: switch (m['theme']) {
        'light' => 'light',
        'dark' => 'dark',
        _ => 'system',
      },
    );
  }
}

class SettingsRepository {
  SettingsRepository(this.db);

  final AppDatabase db;

  Stream<AppSettings> watch() =>
      db.select(db.settingsEntries).watch().map((rows) => AppSettings.fromMap({for (final r in rows) r.key: r.value}));

  Future<void> _set(String key, String? value) async {
    if (value == null) {
      await (db.delete(db.settingsEntries)..where((t) => t.key.equals(key))).go();
    } else {
      await db.into(db.settingsEntries).insertOnConflictUpdate(SettingsEntriesCompanion.insert(key: key, value: value));
    }
  }

  Future<void> setLocale(String? code) => _set('locale', code);
  Future<void> setTextScale(double v) =>
      _set('textScale', v.clamp(AppSettings.minScale, AppSettings.maxScale).toStringAsFixed(2));
  Future<void> setParallel(bool v) => _set('parallel', v ? '1' : '0');
  Future<void> setLastPath(String id) => _set('lastPathId', id);
  Future<void> setOnboarded() => _set('onboarded', '1');
  Future<void> setThemeMode(String mode) => _set('theme', mode == 'system' ? null : mode);

  /// Place [query] en tête des recherches récentes (sans doublon, casse ignorée).
  Future<void> addRecentSearch(String query) => db.transaction(() async {
    final q = query.trim();
    if (q.isEmpty) return;
    final current = AppSettings.fromMap(await raw()).recentSearches;
    final next = [
      q,
      ...current.where((x) => x.toLowerCase() != q.toLowerCase()),
    ].take(AppSettings.maxRecentSearches).toList();
    await _set('recentSearches', jsonEncode(next));
  });

  Future<void> removeRecentSearch(String query) async {
    final current = AppSettings.fromMap(await raw()).recentSearches;
    await _set('recentSearches', jsonEncode([...current.where((x) => x != query)]));
  }

  Future<void> clearRecentSearches() => _set('recentSearches', null);

  Future<void> setReaderPosition(int book, int chapter) => db.transaction(() async {
    await _set('readerBook', '$book');
    await _set('readerChapter', '$chapter');
  });

  /// Pour les tests.
  Future<Map<String, String>> raw() async => {
    for (final r in await db.select(db.settingsEntries).get()) r.key: r.value,
  };
}
