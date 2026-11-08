import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../core/verse_ref.dart';
import '../../providers.dart';
import '../common.dart';

/// Ouvre une feuille qui montre une référence et propose copier / partager / mettre de côté.
Future<void> showVerseSheet(BuildContext context, VerseRef ref) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  // Pas sous la barre d'état en haut, ni sous la barre de gestes en bas.
  useSafeArea: true,
  builder: (_) => SafeArea(top: false, child: VerseSheet(verseRef: ref)),
);

String shareText(Bible bible, VerseRef ref, String lang) {
  final quoted = lang == 'en' ? '“${bible.text(ref)}”' : '« ${bible.text(ref)} »';
  return '$quoted\n— ${refLabel(ref, lang)} (${bible.translation.shortName})';
}

class VerseSheet extends ConsumerWidget {
  const VerseSheet({super.key, required this.verseRef});

  final VerseRef verseRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translation.forLang(context.lang);
    final bible = ref.watch(bibleProvider(t));
    final favorites = ref.watch(favoritesProvider).value ?? const [];
    final isFavorite = favorites.contains(verseRef.code);
    final scale = ref.watch(settingsProvider).value?.textScale ?? 1.0;
    final l = context.l10n;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, controller) => AsyncBody(
        value: bible,
        builder: (b) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              '${refLabel(verseRef, context.lang)} · ${t.shortName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            for (final v in b.passage(verseRef))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text.rich(
                  TextSpan(
                    children: [
                      if (!verseRef.isSingle)
                        TextSpan(
                          text: '${v.number} ',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                        ),
                      TextSpan(text: v.text),
                    ],
                  ),
                  style: scriptureStyle(context, scale),
                ),
              ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(isFavorite ? l.removeFavorite : l.addFavorite),
                  onPressed: () async {
                    final added = await ref.read(progressRepoProvider).toggleFavorite(verseRef.code);
                    if (context.mounted) context.toast(added ? l.favoriteAdded : l.favoriteRemoved);
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.copy),
                  label: Text(l.copy),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: shareText(b, verseRef, context.lang)));
                    if (context.mounted) context.toast(l.copied);
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.share),
                  label: Text(l.share),
                  onPressed: () => SharePlus.instance.share(ShareParams(text: shareText(b, verseRef, context.lang))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
