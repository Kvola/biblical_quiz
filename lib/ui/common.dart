import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';

extension ContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Langue effective : « en » ou « fr ». Elle choisit aussi la traduction biblique.
  String get lang => Localizations.localeOf(this).languageCode == 'en' ? 'en' : 'fr';

  void toast(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action, behavior: SnackBarBehavior.floating));
  }
}

/// Affiche une valeur asynchrone : indicateur, erreur avec « Réessayer », ou contenu.
class AsyncBody<T> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder, this.onRetry});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncData(:final value) => builder(value),
    AsyncError(:final error) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            Text(context.l10n.loadError, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('$error', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
            ],
          ],
        ),
      ),
    ),
    _ => const Center(child: CircularProgressIndicator()),
  };
}

/// Titre de section dans une liste.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
    ),
  );
}
