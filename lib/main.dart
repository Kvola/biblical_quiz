import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_update.dart';
import 'data/database.dart';
import 'providers.dart';

/// Serveur des mises à jour ; `--dart-define=QUIZ_SERVER=http://10.0.2.2:8096` en développement.
const quizServer = String.fromEnvironment('QUIZ_SERVER', defaultValue: 'https://iyf.ebng.world');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase()),
        if (appUpdateSupported)
          appUpdateCheckerProvider.overrideWithValue(
            AppUpdateChecker(server: quizServer, slug: 'quiz-biblique', store: PrefsAppUpdateStore()),
          ),
      ],
      child: const BibleQuizApp(),
    ),
  );
}
