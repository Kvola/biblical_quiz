import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return MaterialApp(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      locale: code == null ? null : Locale(code),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      // Anglais si le téléphone est en anglais, sinon français.
      localeResolutionCallback: (device, supported) =>
          device?.languageCode == 'en' ? const Locale('en') : const Locale('fr'),
      home: switch (onboarded) {
        null => const Scaffold(backgroundColor: QuizColors.night),
        false => const OnboardingScreen(),
        true => const Shell(),
      },
    );
  }
}
