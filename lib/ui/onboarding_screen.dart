import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers.dart';
import 'common.dart';

/// Premier lancement : choisir la langue et comprendre le principe, en un écran.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final repo = ref.read(settingsRepoProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/branding/logo.png', width: 96, height: 96),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.appTitle,
              textAlign: TextAlign.center,
              style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              l.tagline,
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(color: context.palette.accentText),
            ),
            const SizedBox(height: 24),
            Text(l.welcomeIntro, style: text.bodyLarge),
            const SizedBox(height: 16),
            for (final (i, step) in [l.welcomeStep1, l.welcomeStep2, l.welcomeStep3].indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text('${i + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(step, style: text.bodyLarge),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Text(
              l.welcomeOffline,
              style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Text(l.chooseLanguage, style: text.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'fr', label: Text('Français')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {lang},
              onSelectionChanged: (v) => repo.setLocale(v.first),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () async {
                // La langue affichée devient un choix explicite.
                await repo.setLocale(lang);
                await repo.setOnboarded();
              },
              child: Text(l.start),
            ),
          ],
        ),
      ),
    );
  }
}
