import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_update.dart';
import 'core/web_env.dart';
import 'data/database.dart';
import 'online/online_providers.dart';
import 'online/push.dart';
import 'providers.dart';
import 'ui/online/online_links.dart';

/// Serveur des mises à jour et du jeu en ligne ; `--dart-define=QUIZ_SERVER=http://10.0.2.2:8096` en développement.
const quizServer = String.fromEnvironment('QUIZ_SERVER', defaultValue: 'https://iyf.ebng.world');

const _appSlug = 'quiz-biblique';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Version web : la page est servie par le serveur lui-même (même origine).
  final server = kIsWeb ? webBaseUri().origin : quizServer;
  // Progrès et lectures vivent dans le navigateur : lui demander de ne pas
  // les effacer quand la place manque.
  if (kIsWeb) unawaited(requestPersistentStorage());
  // Notifications du jeu en ligne : Android seulement (pas de configuration
  // Firebase pour le web). En arrière-plan : le premier écran n'attend pas Firebase.
  final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  final push = android ? PushService() : NoPushService();
  unawaited(push.init());
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase()),
        serverUrlProvider.overrideWithValue(server),
        pushProvider.overrideWithValue(push),
        // Liens d'invitation (quizbiblique://join/CODE) ouverts depuis la page du serveur.
        if (android)
          gameLinksProvider.overrideWithValue(AppLinks().uriLinkStream),
        if (appUpdateSupported)
          appUpdateCheckerProvider.overrideWithValue(
            AppUpdateChecker(server: server, slug: _appSlug, store: PrefsAppUpdateStore()),
          ),
        // Navigateur d'un téléphone Android : proposer l'application installable.
        if (kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          webInstallUrlProvider.overrideWithValue(Uri.parse('$server/apps/$_appSlug')),
      ],
      child: const BibleQuizApp(),
    ),
  );
}
