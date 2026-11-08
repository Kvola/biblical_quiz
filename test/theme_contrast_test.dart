import 'dart:math' as math;

import 'package:biblical_quiz/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rapport de contraste WCAG 2.x entre deux couleurs opaques.
double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// Une couleur translucide telle qu'elle apparaît posée sur [background].
Color over(Color color, Color background) => Color.alphaBlend(color, background);

void main() {
  for (final brightness in Brightness.values) {
    group('Contraste — mode ${brightness == Brightness.dark ? 'sombre' : 'clair'}', () {
      final theme = buildTheme(brightness);
      final s = theme.colorScheme;
      final p = theme.extension<QuizPalette>()!;
      final card = theme.cardTheme.color!;
      final surface = s.surface;

      // (nom, avant-plan, fond) : un texte doit atteindre 4,5:1 (WCAG AA).
      final text = <(String, Color, Color)>[
        ('texte / fond', s.onSurface, surface),
        ('texte / carte', s.onSurface, card),
        ('texte secondaire / fond', s.onSurfaceVariant, surface),
        ('texte secondaire / carte', s.onSurfaceVariant, card),
        ('liens et titres de section / fond', s.primary, surface),
        ('liens et titres de section / carte', s.primary, card),
        ('bouton principal', s.onPrimary, s.primary),
        ('étiquette dorée / carte', p.accentText, card),
        ('étiquette dorée / fond', p.accentText, surface),
        ('« Bonne réponse » / carte', p.success, card),
        ('« Pas tout à fait » / carte', p.error, card),
        ('action destructrice / fond', p.error, surface),
        ('proposition juste', s.onSurface, p.successContainer),
        ('proposition fausse', s.onSurface, p.errorContainer),
        ('pastille « terminé »', p.onSuccessContainer, p.successContainer),
        ('carte d’accueil : titre', p.heroForeground, p.heroBackground),
        ('carte d’accueil : sous-titres', p.heroMuted, p.heroBackground),
        ('carte d’accueil : étiquette', p.heroAccent, p.heroBackground),
        ('carte d’accueil : bouton', p.onHeroButton, p.heroButton),
        ('verset surligné', s.onSurface, over(p.highlight, surface)),
      ];
      for (final (name, fg, bg) in text) {
        test('$name ≥ 4,5:1', () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(4.5), reason: '$name : ${contrast(fg, bg).toStringAsFixed(2)}');
        });
      }

      // Icônes, bordures et éléments graphiques : 3:1 (WCAG 1.4.11).
      final graphics = <(String, Color, Color)>[
        ('icône dorée / carte', p.accentIcon, card),
        ('icône dorée / fond', p.accentIcon, surface),
        ('icône de marque / carte', p.brandIcon, card),
        ('coche verte / carte', p.success, card),
        ('bordure de proposition juste', p.success, p.successContainer),
        ('bordure de proposition fausse', p.error, p.errorContainer),
        ('bordure de proposition / fond', s.outline, surface),
        ('bouton doré / carte d’accueil', p.heroButton, p.heroBackground),
      ];
      for (final (name, fg, bg) in graphics) {
        test('$name ≥ 3:1', () {
          expect(contrast(fg, bg), greaterThanOrEqualTo(3), reason: '$name : ${contrast(fg, bg).toStringAsFixed(2)}');
        });
      }
    });
  }
}
