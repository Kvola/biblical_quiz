import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/settings_repository.dart';
import '../../providers.dart';
import '../common.dart';

/// Version affichée dans « À propos » (tenue à jour avec pubspec.yaml ; vérifiée par un test).
const appVersion = '1.4.0';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double? _dragScale; // valeur du curseur pendant le glissement

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider).value ?? const AppSettings();
    final repo = ref.read(settingsRepoProvider);
    final scale = _dragScale ?? s.textScale;

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            SectionTitle(l.language),
            RadioGroup<String?>(
              groupValue: s.localeCode,
              onChanged: repo.setLocale,
              child: Column(
                children: [
                  RadioListTile<String?>(value: null, title: Text(l.languageSystem)),
                  const RadioListTile<String?>(value: 'fr', title: Text('Français · Louis Segond 1910')),
                  const RadioListTile<String?>(value: 'en', title: Text('English · King James Version')),
                ],
              ),
            ),
            SectionTitle(l.themeTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'system', icon: const Icon(Icons.brightness_auto), label: Text(l.themeSystem)),
                  ButtonSegment(value: 'light', icon: const Icon(Icons.light_mode_outlined), label: Text(l.themeLight)),
                  ButtonSegment(value: 'dark', icon: const Icon(Icons.dark_mode_outlined), label: Text(l.themeDark)),
                ],
                selected: {s.themeMode},
                showSelectedIcon: false,
                onSelectionChanged: (v) => repo.setThemeMode(v.first),
              ),
            ),
            SectionTitle(l.textSize),
            Slider(
              value: scale,
              min: AppSettings.minScale,
              max: AppSettings.maxScale,
              divisions: 15,
              label: '${(scale * 100).round()} %',
              onChanged: (v) => setState(() => _dragScale = v),
              onChangeEnd: (v) async {
                await repo.setTextScale(v);
                if (mounted) setState(() => _dragScale = null);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(l.textSizePreview, style: scriptureStyle(context, scale)),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(l.parallelSetting),
              subtitle: Text(l.parallelSettingHint),
              value: s.parallel,
              onChanged: repo.setParallel,
            ),
            SectionTitle(l.aboutTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.aboutContent),
                  const SizedBox(height: 8),
                  Text(l.aboutTexts),
                  const SizedBox(height: 8),
                  Text(l.aboutVersion(appVersion), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: context.palette.error),
              icon: const Icon(Icons.delete_outline),
              label: Text(l.resetProgress),
              onPressed: _confirmReset,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset() async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(l.resetProgress),
        content: Text(l.resetProgressBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(l.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: c.palette.error),
            onPressed: () => Navigator.pop(c, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(progressRepoProvider).resetProgress();
    if (mounted) context.toast(l.resetDone);
  }
}
