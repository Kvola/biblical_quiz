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

  static const minScale = 0.85, maxScale = 1.6;

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

  Future<void> setReaderPosition(int book, int chapter) => db.transaction(() async {
    await _set('readerBook', '$book');
    await _set('readerChapter', '$chapter');
  });

  /// Pour les tests.
  Future<Map<String, String>> raw() async => {
    for (final r in await db.select(db.settingsEntries).get()) r.key: r.value,
  };
}
