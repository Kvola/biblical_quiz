import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../core/verse_ref.dart';
import '../../providers.dart';
import '../bible/reader_screen.dart';
import '../common.dart';
import '../launchers.dart';
import 'bible_reading_section.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final summary = ref.watch(summaryProvider).value;
    final due = ref.watch(dueProvider).value ?? const [];
    final favorites = ref.watch(favoritesProvider).value ?? const [];
    final content = ref.watch(contentProvider).value;
    final completed = ref.watch(completedProvider);
    final bible = ref.watch(bibleProvider(Translation.forLang(lang))).value;
    final pct = summary == null ? '–' : '${(summary.accuracy * 100).round()} %';

    return Scaffold(
      appBar: AppBar(title: Text(l.progressTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.9,
              children: [
                _Stat(
                  label: l.statStreak,
                  value: l.daysShort(summary?.currentStreak ?? 0),
                  icon: Icons.local_fire_department,
                ),
                _Stat(
                  label: l.statBestStreak,
                  value: l.daysShort(summary?.bestStreak ?? 0),
                  icon: Icons.emoji_events_outlined,
                ),
                _Stat(label: l.statLessons, value: '${summary?.lessonsCompleted ?? 0}', icon: Icons.menu_book_outlined),
                _Stat(label: l.statAnswered, value: '${summary?.answered ?? 0}', icon: Icons.edit_note),
                _Stat(label: l.statAccuracy, value: pct, icon: Icons.check_circle_outline),
                _Stat(label: l.statMastered, value: '${summary?.mastered ?? 0}', icon: Icons.verified_outlined),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: Icon(Icons.replay, color: context.palette.success),
                title: Text(l.reviewTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(due.isEmpty ? l.reviewEmpty : l.reviewDue(due.length)),
                trailing: due.isEmpty
                    ? null
                    : FilledButton.tonal(onPressed: () => openReview(context, ref), child: Text(l.reviewStart)),
              ),
            ),
            if (content != null) ...[
              SectionTitle(l.pathsProgressTitle),
              for (final p in content.paths)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(pathIcon(p.icon), size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p.title.of(lang))),
                      SizedBox(
                        width: 90,
                        child: LinearProgressIndicator(
                          value: p.lessons.where((x) => completed.contains(x.id)).length / p.lessons.length,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${p.lessons.where((x) => completed.contains(x.id)).length}/${p.lessons.length}',
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (bible != null) ...[SectionTitle(l.bibleReadingTitle), BibleReadingSection(bible: bible)],
            SectionTitle(l.favoritesTitle),
            if (favorites.isEmpty)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text(l.favoritesEmpty))
            else
              for (final code in favorites)
                if (_tryParse(code) case final r?)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(refLabel(r, lang), style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: bible == null
                          ? null
                          : Text(bible.text(r), maxLines: 3, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        tooltip: l.removeFavorite,
                        icon: const Icon(Icons.bookmark_remove_outlined),
                        onPressed: () async {
                          final repo = ref.read(progressRepoProvider);
                          await repo.toggleFavorite(code);
                          if (context.mounted) {
                            context.toast(
                              l.favoriteRemoved,
                              action: SnackBarAction(label: l.undo, onPressed: () => repo.toggleFavorite(code)),
                            );
                          }
                        },
                      ),
                      onTap: () => openReaderAt(context, ref, r.book, r.startChapter, verse: r.startVerse),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  static VerseRef? _tryParse(String code) {
    try {
      return VerseRef.parse(code);
    } on FormatException {
      return null;
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: context.palette.accentIcon),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(value, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  Text(label, style: text.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
