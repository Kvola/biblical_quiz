import 'package:biblical_quiz/app.dart';
import 'package:biblical_quiz/data/database.dart';
import 'package:biblical_quiz/providers.dart';
import 'package:biblical_quiz/ui/settings/settings_screen.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformAssetBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Parcours de bout en bout avec les vrais fichiers de contenu et une base en mémoire.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// Base préparée (réglages) AVANT de monter l'application : écrire pendant
  /// que l'application ouvre la base bloquerait l'horloge simulée.
  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    Map<String, String> settings = const {},
    String device = 'fr',
  }) async {
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
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          // Un accès aux fichiers neuf par test : le cache partagé de rootBundle
          // garde des futures nées dans l'horloge simulée du test précédent.
          assetBundleProvider.overrideWithValue(PlatformAssetBundle()),
        ],
        child: const BibleQuizApp(),
      ),
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

  /// Attend (en temps réel, 15 s au plus) qu'un élément apparaisse : sous la
  /// charge de toute la suite, le chargement des Bibles peut prendre plusieurs secondes.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 150 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsWidgets, reason: 'attendu : $finder');
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

  testWidgets('rien d’utile sous la barre de gestes (SafeArea)', (tester) async {
    // Téléphone « bord à bord » (Android 15+) : 48 dp de barre de gestes en bas,
    // 32 dp de barre d'état en haut.
    const dpr = 2.5, inset = 48.0;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = dpr;
    tester.view.padding = const FakeViewPadding(top: 32 * dpr, bottom: inset * dpr);
    tester.view.viewPadding = const FakeViewPadding(top: 32 * dpr, bottom: inset * dpr);
    addTearDown(tester.view.reset);
    final limit = 2400 / dpr - inset; // ordonnée maximale d'un élément utilisable

    void expectAboveGestureBar(Finder f, String what) {
      expect(f, findsWidgets, reason: what);
      final bottom = tester.getRect(f.last).bottom;
      expect(bottom, lessThanOrEqualTo(limit), reason: '$what descend à $bottom (limite $limit)');
    }

    final db = await pumpApp(tester, settings: {'onboarded': '1'});
    await waitFor(tester, find.byTooltip('Réglages'));

    // Écran poussé avec une longue liste : son dernier bouton reste au-dessus.
    await tester.tap(find.byTooltip('Réglages'));
    await settle(tester);
    // Faire défiler la liste des réglages jusqu'en bas — et non celle de
    // l'accueil, restée dessous dans l'arbre (Scrollable.first par défaut).
    final settingsList = find.descendant(of: find.byType(SettingsScreen), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('Effacer ma progression'), 300, scrollable: settingsList);
    await tester.drag(settingsList, const Offset(0, -2000));
    await tester.pumpAndSettle();
    expectAboveGestureBar(find.text('Effacer ma progression'), 'bouton « Effacer ma progression »');
    await tester.binding.handlePopRoute();
    await settle(tester);

    // Leçon : le bouton fixé en bas de la lecture.
    await waitFor(tester, find.text('Lire et répondre'));
    await tester.tap(find.text('Lire et répondre'));
    await waitFor(tester, find.textContaining('J’ai lu'));
    expectAboveGestureBar(find.textContaining('J’ai lu'), 'bouton « J’ai lu »');

    // Feuille du verset (ouverte depuis la lecture) : ses boutons d'action.
    await waitFor(tester, find.textContaining('Au commencement, Dieu créa'));
    await tester.tap(find.textContaining('Au commencement, Dieu créa'));
    await waitFor(tester, find.text('Partager'));
    await tester.drag(find.byType(DraggableScrollableSheet), const Offset(0, -2000));
    await tester.pumpAndSettle();
    expectAboveGestureBar(find.text('Partager'), 'bouton « Partager » de la feuille du verset');

    await teardown(tester, db);
  });

  testWidgets('seule une vraie lecture de la Bible compte pour la série', (tester) async {
    final db = await pumpApp(tester, settings: {'onboarded': '1'});
    await waitFor(tester, find.text('Lire et répondre'));
    Future<int> activeDays() async => (await tester.runAsync(() => db.select(db.activityDays).get()))!.length;

    // L'onglet Bible existe (IndexedStack) mais n'est pas affiché : rester 30 s sur l'accueil ne compte pas.
    await tester.pump(const Duration(seconds: 30));
    expect(await activeDays(), 0);

    // 20 s de lecture, onglet Bible affiché : le jour devient actif.
    await tester.tap(find.text('Bible'));
    await waitFor(tester, find.textContaining('Au commencement était la Parole'));
    await tester.pump(const Duration(seconds: 21));
    await settle(tester);
    expect(await activeDays(), 1);
    await teardown(tester, db);
  });

  testWidgets('recherche : expression, ouverture du verset, référence, historique', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final db = await pumpApp(tester, settings: {'onboarded': '1'});
    await waitFor(tester, find.byTooltip('Rechercher'));

    await tester.tap(find.byTooltip('Rechercher'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), '"que la lumière soit"');
    await waitFor(tester, find.text('Genèse 1:3'));
    expect(find.textContaining('verset'), findsWidgets);

    // Ouvrir le résultat : le lecteur s'ouvre sur Genèse 1.
    await tester.tap(find.text('Genèse 1:3'));
    await waitFor(tester, find.text('Genèse 1'));
    final recent = await tester.runAsync(
      () => (db.select(db.settingsEntries)..where((t) => t.key.equals('recentSearches'))).getSingleOrNull(),
    );
    expect(recent?.value, contains('que la lumière soit'));
    await tester.binding.handlePopRoute();
    await settle(tester);

    // Une référence propose d'y aller, sans recherche de mots.
    await tester.enterText(find.byType(TextField), 'Jn 3:16');
    await waitFor(tester, find.text('Aller à Jean 3:16'));
    await teardown(tester, db);
  });

  testWidgets('l’anglais affiche la King James', (tester) async {
    // Téléphone en français, mais anglais choisi dans les réglages : le réglage l'emporte.
    final db = await pumpApp(tester, settings: {'locale': 'en', 'onboarded': '1'});
    await settle(tester);
    await tester.tap(find.text('Bible'));
    await waitFor(tester, find.textContaining('In the beginning was the Word'));
    // Position par défaut : Jean 1.
    expect(find.text('John 1'), findsOneWidget);
    expect(find.textContaining('In the beginning was the Word'), findsOneWidget);
    await teardown(tester, db);
  });

  testWidgets('chapitre lu (lecture réelle), puis quiz sur mes lectures', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final db = await pumpApp(tester, settings: {'onboarded': '1'});
    await waitFor(tester, find.text('Lire et répondre'));
    Future<List<ReadChapter>> readRows() async => (await tester.runAsync(() => db.select(db.readChapters).get()))!;

    // Jean 1 : aller au bout du chapitre ne suffit pas, il faut aussi y passer le temps de lecture.
    await tester.tap(find.text('Bible'));
    await waitFor(tester, find.textContaining('Au commencement était la Parole'));
    await tester.scrollUntilVisible(find.text('Marquer comme lu'), 400, scrollable: find.byType(Scrollable).last);
    await settle(tester);
    expect(await readRows(), isEmpty, reason: 'un simple survol ne compte pas');
    await tester.pump(const Duration(seconds: 181));
    await settle(tester);
    final rows = await readRows();
    expect([for (final r in rows) (r.book, r.chapter, r.manual)], [(43, 1, false)]);
    expect(find.text('Chapitre lu'), findsOneWidget);

    // Juste après la lecture : un petit quiz sur CE chapitre.
    await tester.tap(find.text('Tester ce chapitre'));
    await waitFor(tester, find.text('Quiz : Jean 1'));
    await waitFor(tester, find.textContaining('Question 1 sur'));
    expect(find.textContaining('sur 5'), findsWidgets);
    await tester.binding.handlePopRoute();
    await settle(tester);

    // Progrès : la lecture de la Bible, livre par livre.
    await tester.tap(find.text('Progrès'));
    await settle(tester);
    final total = find.text('1 chapitre lu sur 1189');
    await tester.scrollUntilVisible(total, 400, scrollable: find.byType(Scrollable).first);
    expect(total, findsOneWidget);
    final jn = find.bySemanticsLabel('Jean : 1 chapitres lus sur 21');
    await tester.scrollUntilVisible(jn, 300, scrollable: find.byType(Scrollable).first);
    // Encore un peu : la tuile ne doit pas rester sous la barre de navigation.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
    await settle(tester);
    await tester.tap(jn);
    await settle(tester);
    expect(find.text('1 / 21 chapitres lus'), findsOneWidget);
    expect(find.text('Quiz sur ce livre'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await settle(tester);

    // Le quiz propose Jean (lu) et porte sur ce qui a été lu.
    await tester.tap(find.text('Accueil'));
    await settle(tester);
    final card = find.ancestor(of: find.text('Quiz sur mes lectures'), matching: find.byType(ListTile));
    await tester.scrollUntilVisible(card, 300, scrollable: find.byType(Scrollable).first);
    expect(find.descendant(of: card, matching: find.textContaining('1 chapitre lu')), findsOneWidget);
    await tester.tap(find.descendant(of: card, matching: find.byType(FilledButton)));
    await settle(tester);
    expect(find.text('Commencer · 1 livre'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('1 / 21 chapitres lus'), 500, scrollable: find.byType(Scrollable).first);
    expect(find.text('1 / 21 chapitres lus'), findsOneWidget);
    await tester.tap(find.text('Commencer · 1 livre'));
    await waitFor(tester, find.textContaining('Question 1'));
    // Chaque question indique son passage (Jean 1) ou qu'elle est tirée du texte.
    expect(find.byWidgetPredicate((w) => w is Chip), findsOneWidget);
    expect(find.textContaining('Jean 1').evaluate().isNotEmpty || find.text('Tiré du texte').evaluate().isNotEmpty, isTrue);
    await teardown(tester, db);
  });
}
