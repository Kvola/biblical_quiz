import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../providers.dart';
import '../bible/reader_screen.dart';
import '../common.dart';
import '../reading/reading_quiz_screen.dart';

/// « Ma lecture de la Bible » : avancement global, par Testament, et les 66
/// livres en tuiles remplies selon les chapitres lus. Toucher un livre montre
/// ses chapitres (ouvrir l'un d'eux, ou lancer un quiz sur le livre).
class BibleReadingSection extends ConsumerWidget {
  const BibleReadingSection({super.key, required this.bible});

  final Bible bible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final read = ref.watch(readChaptersProvider).value ?? const <int, Set<int>>{};
    int total(int from, int to) => [for (var b = from; b <= to; b++) bible.chapterCount(b)].fold(0, (a, b) => a + b);
    int done(int from, int to) => [for (var b = from; b <= to; b++) (read[b] ?? const {}).length].fold(0, (a, b) => a + b);
    final all = total(1, 66), allDone = done(1, 66);
    final started = [for (var b = 1; b <= 66; b++) if ((read[b] ?? const {}).isNotEmpty) b];
    final finished = [for (final b in started) if (read[b]!.length >= bible.chapterCount(b)) b];
    final text = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: Text(l.bibleReadingTotal(allDone, all), style: text.titleMedium)),
                Text('${(allDone * 100 / all).toStringAsFixed(allDone * 100 / all < 10 && allDone > 0 ? 1 : 0)} %',
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 8),
            _Bar(value: allDone / all, height: 10),
            const SizedBox(height: 6),
            Text('${l.booksStarted(started.length)} · ${l.booksFinished(finished.length)}', style: text.bodySmall),
            const SizedBox(height: 14),
            for (final (label, from, to) in [(l.oldTestament, 1, 39), (l.newTestament, 40, 66)]) ...[
              Row(
                children: [
                  Expanded(child: Text(label, style: text.titleSmall)),
                  Text('${done(from, to)} / ${total(from, to)}', style: text.bodySmall),
                ],
              ),
              const SizedBox(height: 6),
              _Bar(value: done(from, to) / total(from, to)),
              const SizedBox(height: 10),
              _BookGrid(from: from, to: to, bible: bible, read: read),
              const SizedBox(height: 14),
            ],
            Text(l.bibleReadingHint, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.value, this.height = 6});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) => LinearProgressIndicator(
    value: value.clamp(0, 1),
    minHeight: height,
    borderRadius: BorderRadius.circular(height / 2),
    color: context.palette.success,
  );
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({required this.from, required this.to, required this.bible, required this.read});

  final int from, to;
  final Bible bible;
  final Map<int, Set<int>> read;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Tuiles d'environ 56 px : 5 à 6 par ligne sur un téléphone, plus sur une tablette.
        final perRow = (c.maxWidth / 60).floor().clamp(4, 12);
        const gap = 6.0;
        final size = (c.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var b = from; b <= to; b++)
              _BookTile(book: bookById(b), size: size, done: (read[b] ?? const {}).length, total: bible.chapterCount(b)),
          ],
        );
      },
    );
  }
}

class _BookTile extends ConsumerWidget {
  const _BookTile({required this.book, required this.size, required this.done, required this.total});

  final BookName book;
  final double size;
  final int done, total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final scheme = Theme.of(context).colorScheme;
    final p = context.palette;
    final ratio = done / total;
    final complete = done >= total;
    final fg = complete ? p.onSuccessContainer : scheme.onSurface;
    return Semantics(
      button: true,
      label: l.bookReadSemantics(book.name(lang), done, total),
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: done > 0 ? p.success : scheme.outlineVariant, width: done > 0 ? 1.5 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showBook(context, ref),
          child: SizedBox(
            width: size,
            height: size * 0.8,
            child: Stack(
              children: [
                // Remplissage de bas en haut, proportionnel aux chapitres lus.
                Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(heightFactor: ratio, widthFactor: 1, child: ColoredBox(color: p.successContainer)),
                ),
                Center(
                  child: Text(
                    book.abbr(lang),
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: fg),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBook(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BookSheet(book: book, total: total, parentContext: context),
    );
  }
}

class _BookSheet extends ConsumerWidget {
  const _BookSheet({required this.book, required this.total, required this.parentContext});

  final BookName book;
  final int total;
  final BuildContext parentContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final p = context.palette;
    final scheme = Theme.of(context).colorScheme;
    final read = ref.watch(readChaptersProvider).value?[book.id] ?? const <int>{};
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.name(lang), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(l.chaptersReadOf(read.length, total)),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var c = 1; c <= total; c++)
                      SizedBox(
                        width: 48,
                        height: 44,
                        child: Material(
                          color: read.contains(c) ? p.successContainer : scheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: read.contains(c) ? p.success : scheme.outlineVariant),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              Navigator.pop(context);
                              openReaderAt(parentContext, ref, book.id, c);
                            },
                            child: Center(
                              child: Text(
                                '$c',
                                style: TextStyle(
                                  fontWeight: read.contains(c) ? FontWeight.w700 : FontWeight.w400,
                                  color: read.contains(c) ? p.onSuccessContainer : scheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ReadingQuizScreen.open(parentContext, books: {book.id});
                },
                icon: const Icon(Icons.quiz_outlined),
                label: Text(l.quizOnThisBook),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
