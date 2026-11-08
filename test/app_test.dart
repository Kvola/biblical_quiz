import 'package:biblical_quiz/app.dart';
import 'package:biblical_quiz/data/database.dart';
import 'package:biblical_quiz/providers.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parcours de bout en bout avec les vrais fichiers de contenu et une base en mémoire.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// Base préparée (réglages) AVANT de monter l'application : écrire pendant
  /// que l'application ouvre la base bloquerait l'horloge simulée.
  Future<AppDatabase> pumpApp(WidgetTester tester, {Map<String, String> settings = const {}, String device = 'fr'}) async {
    tester.platformDispatcher.localeTestValue = Locale(device);
    tester.platformDispatcher.localesTestValue = [Locale(device)];
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    // closeStreamsSynchronously : pas de minuteur Drift en suspens à la fin du test.
    final db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    await tester.runAsync(() async {
      for (final e in settings.entries) {
        await db.into(db.settingsEntries).insert(SettingsEntriesCompanion.insert(key: e.key, value: e.value));
      }
    });
    await tester.pumpWidget(
      ProviderScope(overrides: [databaseProvider.overrideWithValue(db)], child: const BibleQuizApp()),
    );
    return db;
  }

  /// Démonte l'application (fin des flux), puis ferme la base hors de l'horloge simulée.
  Future<void> teardown(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  }

  /// Le chargement des Bibles passe par un isolat : on laisse le temps réel s'écouler.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('premier lancement, leçon complète, résultat enregistré', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final db = await pumpApp(tester);
    await settle(tester);

    // Accueil de premier lancement, en français par défaut.
    expect(find.text('Quiz Biblique'), findsWidgets);
    await tester.tap(find.text('Commencer'));
    await settle(tester);

    // Accueil : la première leçon est proposée.
    expect(find.text('Lire et répondre'), findsOneWidget);
    await tester.tap(find.text('Lire et répondre'));
    await settle(tester);

    // Lecture : le passage s'affiche, puis on passe aux questions.
    expect(find.text('Avant de lire'), findsOneWidget);
    await tester.tap(find.textContaining('J’ai lu'));
    await settle(tester);

    // Répondre à toutes les questions en choisissant toujours la première proposition.
    for (var i = 0; i < 10; i++) {
      expect(find.textContaining('Question'), findsWidgets);
      await tester.tap(find.byKey(const ValueKey('option-0')));
      await tester.pump();
      if (i == 0) {
        // Retour système après une réponse : confirmation demandée, on reste.
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        expect(find.text('Quitter ?'), findsOneWidget);
        await tester.tap(find.text('Continuer'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Question 1 sur'), findsOneWidget);
      }
      final next = find.text('Suivant');
      if (next.evaluate().isNotEmpty) {
        await tester.tap(next);
        await tester.pump();
      } else {
        await tester.tap(find.text('Voir le résultat'));
        await settle(tester);
        break;
      }
    }

    // La liste du résultat est paresseuse : sa longueur dépend des réponses ratées.
    await tester.scrollUntilVisible(find.text('À retenir'), 300);
    expect(find.text('À retenir'), findsOneWidget);
    final saved = await tester.runAsync(() => db.select(db.lessonProgress).get());
    expect(saved, hasLength(1));
    expect(saved!.single.lessonId, 'story-creation');
    await teardown(tester, db);
  });

  testWidgets('l’anglais affiche la King James', (tester) async {
    // Téléphone en français, mais anglais choisi dans les réglages : le réglage l'emporte.
    final db = await pumpApp(tester, settings: {'locale': 'en', 'onboarded': '1'});
    await settle(tester);
    await tester.tap(find.text('Bible'));
    await settle(tester);
    // Position par défaut : Jean 1.
    expect(find.text('John 1'), findsOneWidget);
    expect(find.textContaining('In the beginning was the Word'), findsOneWidget);
    await teardown(tester, db);
  });
}
