import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bible/bible.dart';
import 'content/content.dart';
import 'core/app_update.dart';
import 'data/database.dart';
import 'data/progress_repository.dart';
import 'data/settings_repository.dart';
import 'domain/search.dart';

/// Fournis dans `main()` via `overrideWithValue`.
final databaseProvider = Provider<AppDatabase>((ref) => throw UnimplementedError());
final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

/// Vérification des nouvelles versions : null = aucune (tests, iOS, ordinateur).
/// Activée dans `main()` sur Android ; sans réseau, l'application n'en voit rien.
final appUpdateCheckerProvider = Provider<AppUpdateChecker?>((ref) => null);

final settingsRepoProvider = Provider((ref) => SettingsRepository(ref.watch(databaseProvider)));
final progressRepoProvider = Provider((ref) => ProgressRepository(ref.watch(databaseProvider)));

final settingsProvider = StreamProvider<AppSettings>((ref) => ref.watch(settingsRepoProvider).watch());

/// Langue effective du contenu (« fr » ou « en »), posée par l'application
/// d'après la locale résolue : réglage explicite, sinon langue du téléphone.
final langProvider = Provider<String>((ref) => 'fr');

final contentProvider = FutureProvider<Content>((ref) => Content.load(ref.watch(assetBundleProvider)));

/// Chaque Bible est chargée à la première demande puis gardée en mémoire.
final bibleProvider = FutureProvider.family<Bible, Translation>(
  (ref, t) => Bible.load(ref.watch(assetBundleProvider), t),
);

final lessonProgressProvider = StreamProvider<Map<String, LessonProgressData>>(
  (ref) => ref.watch(progressRepoProvider).watchLessons(),
);

final completedProvider = Provider<Set<String>>(
  (ref) => ref.watch(lessonProgressProvider).value?.keys.toSet() ?? const {},
);

final dueProvider = StreamProvider<List<String>>((ref) => ref.watch(progressRepoProvider).watchDue());

final summaryProvider = StreamProvider<ProgressSummary>((ref) => ref.watch(progressRepoProvider).watchSummary());

final favoritesProvider = StreamProvider<List<String>>((ref) => ref.watch(progressRepoProvider).watchFavorites());

/// Chapitres lus, par livre (lecteur ou marque manuelle).
final readChaptersProvider = StreamProvider<Map<int, Set<int>>>((ref) => ref.watch(progressRepoProvider).watchReadChapters());

/// Index de recherche d'une traduction : construit une fois, hors du fil de
/// l'interface (normalisation des 31 102 versets), puis gardé en mémoire.
final searchIndexProvider = FutureProvider.family<SearchIndex, Translation>((ref, t) async {
  final bible = await ref.watch(bibleProvider(t).future);
  final texts = [for (final v in bible.allVerses) v.text];
  final normalized = await Isolate.run(() => SearchIndex.normalizeAll(texts));
  return SearchIndex(bible, normalized);
});
