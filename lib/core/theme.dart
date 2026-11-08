import 'package:flutter/material.dart';

/// Couleurs de marque : bleu nuit (profondeur, confiance), or (lumière),
/// parchemin (lecture). Ce sont des couleurs de **marque**, pas de texte :
/// un écran n'emploie jamais ces constantes pour colorer un texte ou une
/// icône, mais la [QuizPalette] du thème, qui a une valeur lisible en clair
/// ET en sombre.
abstract final class QuizColors {
  static const night = Color(0xFF1E3A5F);
  static const gold = Color(0xFFC9A227);
  static const parchment = Color(0xFFFBF7EF);
  static const ink = Color(0xFF1F2430);

  // Fonds du mode sombre.
  static const darkSurface = Color(0xFF14181F);
  static const darkCard = Color(0xFF1E232C);
}

/// Couleurs sémantiques de l'application, déclinées pour chaque luminosité.
///
/// Chaque couple texte/fond est vérifié par test/theme_contrast_test.dart
/// (WCAG : 4,5:1 pour un texte, 3:1 pour une icône ou un grand texte).
@immutable
class QuizPalette extends ThemeExtension<QuizPalette> {
  const QuizPalette({
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.error,
    required this.errorContainer,
    required this.accentText,
    required this.accentIcon,
    required this.brandIcon,
    required this.heroBackground,
    required this.heroForeground,
    required this.heroMuted,
    required this.heroAccent,
    required this.heroButton,
    required this.onHeroButton,
    required this.highlight,
    required this.card,
  });

  /// Bonne réponse, élément terminé (texte, icône, bordure).
  final Color success;

  /// Fond d'une proposition juste / pastille « terminé ».
  final Color successContainer;
  final Color onSuccessContainer;

  /// Mauvaise réponse, action destructrice.
  final Color error;
  final Color errorContainer;

  /// L'or quand il porte un texte (étiquettes « Avant de lire »…).
  final Color accentText;

  /// L'or pour une icône (série, verset du jour, statistiques).
  final Color accentIcon;

  /// Icône de marque sur une carte (le bleu nuit en clair, un bleu clair en sombre).
  final Color brandIcon;

  /// Carte mise en avant de l'accueil (« Pour commencer / Continuer »).
  final Color heroBackground;
  final Color heroForeground;
  final Color heroMuted;
  final Color heroAccent;
  final Color heroButton;
  final Color onHeroButton;

  /// Surlignage d'un verset (venu d'un favori).
  final Color highlight;

  /// Fond des cartes (repris par le thème des Card).
  final Color card;

  static const light = QuizPalette(
    success: Color(0xFF2E6B2A),
    successContainer: Color(0xFFE3F0E1),
    onSuccessContainer: Color(0xFF1B4419),
    error: Color(0xFFA12B2B),
    errorContainer: Color(0xFFF8E3E3),
    accentText: Color(0xFF7A5F00),
    accentIcon: Color(0xFFA27F0E),
    brandIcon: QuizColors.night,
    heroBackground: QuizColors.night,
    heroForeground: Colors.white,
    heroMuted: Color(0xFFC9D6E6),
    heroAccent: Color(0xFFE8CB6A),
    heroButton: QuizColors.gold,
    onHeroButton: QuizColors.ink,
    highlight: Color(0x40C9A227),
    card: Colors.white,
  );

  static const dark = QuizPalette(
    success: Color(0xFF8BCF88),
    successContainer: Color(0xFF1F3A21),
    onSuccessContainer: Color(0xFFCDEBCB),
    error: Color(0xFFF29B9B),
    errorContainer: Color(0xFF3D2224),
    accentText: Color(0xFFE8CB6A),
    accentIcon: Color(0xFFE8CB6A),
    brandIcon: Color(0xFF9DC1EA),
    heroBackground: Color(0xFF24476F),
    heroForeground: Colors.white,
    heroMuted: Color(0xFFD0DCEA),
    heroAccent: Color(0xFFF0D683),
    heroButton: Color(0xFFE8CB6A),
    onHeroButton: QuizColors.ink,
    highlight: Color(0x55E8CB6A),
    card: QuizColors.darkCard,
  );

  @override
  QuizPalette copyWith() => this;

  @override
  QuizPalette lerp(QuizPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return QuizPalette(
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      error: l(error, other.error),
      errorContainer: l(errorContainer, other.errorContainer),
      accentText: l(accentText, other.accentText),
      accentIcon: l(accentIcon, other.accentIcon),
      brandIcon: l(brandIcon, other.brandIcon),
      heroBackground: l(heroBackground, other.heroBackground),
      heroForeground: l(heroForeground, other.heroForeground),
      heroMuted: l(heroMuted, other.heroMuted),
      heroAccent: l(heroAccent, other.heroAccent),
      heroButton: l(heroButton, other.heroButton),
      onHeroButton: l(onHeroButton, other.onHeroButton),
      highlight: l(highlight, other.highlight),
      card: l(card, other.card),
    );
  }
}

extension PaletteX on BuildContext {
  QuizPalette get palette => Theme.of(this).extension<QuizPalette>()!;
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final palette = dark ? QuizPalette.dark : QuizPalette.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: QuizColors.night,
    brightness: brightness,
    primary: dark ? const Color(0xFF9DC1EA) : QuizColors.night,
    onPrimary: dark ? const Color(0xFF0E2238) : Colors.white,
    secondary: dark ? palette.accentText : QuizColors.gold,
    error: palette.error,
    surface: dark ? QuizColors.darkSurface : QuizColors.parchment,
    onSurface: dark ? const Color(0xFFE6E8EC) : QuizColors.ink,
    onSurfaceVariant: dark ? const Color(0xFFB9BFC9) : const Color(0xFF4F5663),
    outline: dark ? const Color(0xFF8A93A0) : const Color(0xFF747B86),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    extensions: [palette],
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(backgroundColor: scheme.surface, foregroundColor: scheme.onSurface, centerTitle: false),
    cardTheme: CardThemeData(
      elevation: 0,
      color: palette.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: dark ? 0.9 : 0.6)),
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
