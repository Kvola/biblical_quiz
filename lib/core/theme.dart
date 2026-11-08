import 'package:flutter/material.dart';

/// Palette : bleu nuit (profondeur, confiance), or (lumière), parchemin (lecture).
abstract final class QuizColors {
  static const night = Color(0xFF1E3A5F);
  static const gold = Color(0xFFC9A227);
  static const parchment = Color(0xFFFBF7EF);
  static const ink = Color(0xFF1F2430);
  static const olive = Color(0xFF3F7D3A); // bonne réponse
  static const crimson = Color(0xFFB23A3A); // mauvaise réponse
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: QuizColors.night,
    brightness: brightness,
    primary: dark ? const Color(0xFF9DC1EA) : QuizColors.night,
    secondary: QuizColors.gold,
    surface: dark ? const Color(0xFF14181F) : QuizColors.parchment,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface, centerTitle: false),
    cardTheme: CardThemeData(
      elevation: 0,
      color: dark ? const Color(0xFF1E232C) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

/// Style du texte biblique (serif, interligne généreux) à la taille choisie.
TextStyle scriptureStyle(BuildContext context, double scale) {
  final base = Theme.of(context).textTheme.bodyLarge!;
  return base.copyWith(fontFamily: 'serif', fontSize: 18 * scale, height: 1.55);
}

/// Icônes des parcours (nom snake_case du contenu -> IconData). Les icônes
/// Material ne se résolvent pas par leur nom à l'exécution sans casser
/// l'élagage des polices : on garde une table explicite.
IconData pathIcon(String name) => switch (name) {
  'auto_stories' => Icons.auto_stories,
  'wb_sunny' => Icons.wb_sunny_outlined,
  'favorite' => Icons.favorite_outline,
  'lightbulb' => Icons.lightbulb_outline,
  'groups' => Icons.groups_outlined,
  'spa' => Icons.spa_outlined,
  _ => Icons.menu_book_outlined,
};
