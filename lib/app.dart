import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_update.dart';
import 'core/theme.dart';
import 'l10n/gen/app_localizations.dart';
import 'providers.dart';
import 'ui/onboarding_screen.dart';
import 'ui/shell.dart';

class BibleQuizApp extends ConsumerWidget {
  const BibleQuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(settingsProvider.select((s) => s.value?.localeCode));
    final onboarded = ref.watch(settingsProvider.select((s) => s.value?.onboarded));
    final themeMode = ref.watch(settingsProvider.select((s) => s.value?.themeMode));
    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: switch (themeMode) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: code == null ? null : Locale(code),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Anglais si le téléphone est en anglais, sinon français.
      localeResolutionCallback: (device, supported) =>
          device?.languageCode == 'en' ? const Locale('en') : const Locale('fr'),
      // Bandeau « nouvelle version » au-dessus de tous les écrans.
      builder: (context, child) => AppUpdateHost(
        checker: ref.watch(appUpdateCheckerProvider),
        strings: appUpdateStrings,
        webInstallUrl: ref.watch(webInstallUrlProvider),
        child: child ?? const SizedBox.shrink(),
      ),
      home: switch (onboarded) {
        // Le temps d'ouvrir la base (quelques millisecondes) : fond de la marque.
        null => const Scaffold(backgroundColor: QuizColors.night),
        false => const OnboardingScreen(),
        true => const Shell(),
      },
    );
  }
}

AppUpdateStrings appUpdateStrings(BuildContext context) {
  final l = AppLocalizations.of(context);
  return AppUpdateStrings(
    available: l.updateAvailable,
    required: l.updateRequired,
    requiredHint: l.updateRequiredHint,
    download: l.updateDownload,
    later: l.updateLater,
    webInstallTitle: l.webInstallTitle,
    webInstallBody: l.webInstallBody,
    webInstallAction: l.webInstallAction,
    webInstallDismiss: l.updateLater,
    homeScreenTitle: l.homeScreenTitle,
    homeScreenBody: l.homeScreenBody,
    homeScreenDismiss: l.homeScreenDismiss,
  );
}
