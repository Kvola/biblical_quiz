import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../content/models.dart';
import '../../core/background.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../domain/reading_quiz.dart';
import '../../providers.dart';
import '../common.dart';
import '../quiz/quiz_screen.dart';

/// « Quiz sur mes lectures » : choix d'un ou plusieurs livres, des chapitres lus
/// ou des livres entiers, puis quiz (questions relues d'abord, puis tirées du texte).
class ReadingQuizScreen extends ConsumerStatefulWidget {
  const ReadingQuizScreen({super.key, this.initialBooks});

  /// Livres cochés à l'ouverture (depuis le lecteur : le livre en cours).
  final Set<int>? initialBooks;

  static Future<void> open(BuildContext context, {Set<int>? books}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingQuizScreen(initialBooks: books)));

  @override
  ConsumerState<ReadingQuizScreen> createState() => _ReadingQuizScreenState();
}

class _ReadingQuizScreenState extends ConsumerState<ReadingQuizScreen> {
  Set<int>? _selected; // null : pas encore initialisé (on attend les chapitres lus)
  bool? _onlyRead; // null : automatique (chapitres lus s'il y en a dans la sélection)
  int _count = 10;
  bool _busy = false;

  static const _genres = [
    BookGenre.law, BookGenre.history, BookGenre.poetry, BookGenre.prophets, //
    BookGenre.gospels, BookGenre.acts, BookGenre.epistles, BookGenre.apocalyptic,
  ];

  String _genreLabel(BookGenre g) {
    final l = context.l10n;
    return switch (g) {
      BookGenre.law => l.genreLaw,
      BookGenre.history => l.genreHistory,
      BookGenre.poetry => l.genrePoetry,
      BookGenre.prophets => l.genreProphets,
      BookGenre.gospels => l.genreGospels,
      BookGenre.acts => l.genreActs,
      BookGenre.epistles => l.genreEpistles,
      BookGenre.apocalyptic => l.genreApocalyptic,
    };
  }

  Future<void> _start(Bible bible, Map<int, Set<int>> read, bool onlyRead) async {
    final l = context.l10n;
    final lang = context.lang;
    final selected = _selected ?? {};
    if (selected.isEmpty) {
      context.toast(l.readingQuizPickOne);
      return;
    }
    final scope = ReadingScope({for (final b in selected) b: onlyRead ? (read[b] ?? <int>{}) : null});
    final name = selected.length == 1 ? bookById(selected.single).name(lang) : l.readingQuizBooksCount(selected.length);
    setState(() => _busy = true);
    await openReadingQuiz(context, ref, scope: scope, count: _count, title: l.readingQuizNamed(name), bible: bible,
        tooFew: l.readingQuizTooFew, onBuilt: () {
      if (mounted) setState(() => _busy = false);
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final t = Translation.forLang(lang);
    final readAsync = ref.watch(readChaptersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.readingQuizTitle)),
      body: AsyncBody(
        value: ref.watch(bibleProvider(t)),
        onRetry: () => ref.invalidate(bibleProvider(t)),
        builder: (bible) {
          final read = readAsync.value ?? const <int, Set<int>>{};
          if (_selected == null && readAsync.hasValue) {
            // Ouverture : le livre demandé, sinon tout ce qui a été lu.
            _selected = {...?widget.initialBooks};
            if (_selected!.isEmpty) _selected = {for (final e in read.entries) if (e.value.isNotEmpty) e.key};
          }
          final selected = _selected ?? <int>{};
          final hasRead = selected.any((b) => (read[b] ?? const {}).isNotEmpty);
          // Choix automatique : « chapitres lus » seulement si CHAQUE livre choisi en a ;
          // sinon un livre ajouté sans lecture (ex. les Poétiques) ne compterait pas.
          final allRead = selected.isNotEmpty && selected.every((b) => (read[b] ?? const {}).isNotEmpty);
          final onlyRead = (_onlyRead ?? allRead) && hasRead;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.paddingOf(context).bottom),
                  children: [
                    Text(l.readingQuizIntro, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 12),
                    // La sélection, toujours visible (la liste des 66 livres est longue).
                    if (selected.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          for (final b in selected.toList()..sort())
                            InputChip(
                              label: Text(bookById(b).name(lang)),
                              selected: true,
                              showCheckmark: false,
                              onDeleted: () => setState(() => _selected = {...selected}..remove(b)),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                    ],
                    _QuickPicks(
                      hasRead: read.values.any((c) => c.isNotEmpty),
                      genres: _genres,
                      genreLabel: _genreLabel,
                      isGenreSelected: (g) {
                        final ids = [for (final b in books) if (b.genre == g) b.id];
                        return ids.every(selected.contains);
                      },
                      onMyReading: () => setState(() => _selected = {for (final e in read.entries) if (e.value.isNotEmpty) e.key}),
                      onGenre: (g) => setState(() {
                        final ids = [for (final b in books) if (b.genre == g) b.id];
                        final all = ids.every(selected.contains);
                        _selected = {...selected}..removeAll(all ? ids : const <int>[]);
                        if (!all) _selected!.addAll(ids);
                      }),
                      onNone: () => setState(() => _selected = {}),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: true, label: Text(l.scopeRead), enabled: hasRead),
                        ButtonSegment(value: false, label: Text(l.scopeWhole)),
                      ],
                      selected: {onlyRead},
                      onSelectionChanged: (v) => setState(() => _onlyRead = v.first),
                    ),
                    const SizedBox(height: 6),
                    Text(onlyRead ? l.scopeReadHint : l.scopeWholeHint, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    Text(l.questionCountLabel, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 10, label: Text('10')),
                        ButtonSegment(value: 15, label: Text('15')),
                        ButtonSegment(value: 20, label: Text('20')),
                      ],
                      selected: {_count},
                      onSelectionChanged: (v) => setState(() => _count = v.first),
                    ),
                    const SizedBox(height: 20),
                    Text(l.readingQuizBooks, style: Theme.of(context).textTheme.titleMedium),
                    for (final (title, range) in [(l.oldTestament, (1, 39)), (l.newTestament, (40, 66))]) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
                      ),
                      for (var b = range.$1; b <= range.$2; b++)
                        _BookTile(
                          book: bookById(b),
                          total: bible.chapterCount(b),
                          read: (read[b] ?? const {}).length,
                          selected: selected.contains(b),
                          onChanged: (v) => setState(() {
                            _selected = {...selected};
                            v ? _selected!.add(b) : _selected!.remove(b);
                          }),
                          onMarkAll: () => ref
                              .read(progressRepoProvider)
                              .markChaptersRead(b, [for (var c = 1; c <= bible.chapterCount(b); c++) c], manual: true),
                          onClear: () => ref.read(progressRepoProvider).unmarkRead(b),
                        ),
                    ],
                  ],
                ),
              ),
              Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: SafeArea(
                  top: false,
                  minimum: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _busy || selected.isEmpty ? null : () => _start(bible, read, onlyRead),
                      icon: _busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.play_arrow),
                      label: Text(l.startReadingQuiz(selected.length)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickPicks extends StatelessWidget {
  const _QuickPicks({
    required this.hasRead,
    required this.genres,
    required this.genreLabel,
    required this.isGenreSelected,
    required this.onMyReading,
    required this.onGenre,
    required this.onNone,
  });

  final bool hasRead;
  final List<BookGenre> genres;
  final String Function(BookGenre) genreLabel;
  final bool Function(BookGenre) isGenreSelected;
  final VoidCallback onMyReading;
  final void Function(BookGenre) onGenre;
  final VoidCallback onNone;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (hasRead)
          ActionChip(avatar: const Icon(Icons.history_edu, size: 18), label: Text(l.selectMyReading), onPressed: onMyReading),
        for (final g in genres)
          FilterChip(label: Text(genreLabel(g)), selected: isGenreSelected(g), onSelected: (_) => onGenre(g)),
        ActionChip(label: Text(l.selectNone), onPressed: onNone),
      ],
    );
  }
}

class _BookTile extends StatelessWidget {
  const _BookTile({
    required this.book,
    required this.total,
    required this.read,
    required this.selected,
    required this.onChanged,
    required this.onMarkAll,
    required this.onClear,
  });

  final BookName book;
  final int total;
  final int read;
  final bool selected;
  final ValueChanged<bool> onChanged;
  final VoidCallback onMarkAll;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    return CheckboxListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      controlAffinity: ListTileControlAffinity.leading,
      value: selected,
      onChanged: (v) => onChanged(v ?? false),
      title: Text(book.name(lang)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.chaptersReadOf(read, total)),
          if (read > 0) ...[
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: read / total,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              color: context.palette.success,
            ),
          ],
        ],
      ),
      secondary: PopupMenuButton<String>(
        onSelected: (v) => v == 'all' ? onMarkAll() : onClear(),
        itemBuilder: (_) => [
          PopupMenuItem(value: 'all', enabled: read < total, child: Text(l.markBookRead)),
          PopupMenuItem(value: 'clear', enabled: read > 0, child: Text(l.unmarkBookRead)),
        ],
      ),
    );
  }
}

/// Construit un quiz de lecture (hors du fil de l'interface) puis l'ouvre.
/// [tooFew] : message si la portée ne donne pas au moins trois questions.
Future<void> openReadingQuiz(
  BuildContext context,
  WidgetRef ref, {
  required ReadingScope scope,
  required int count,
  required String title,
  required String tooFew,
  Bible? bible,
  VoidCallback? onBuilt,
}) async {
  final lang = context.lang;
  final nav = Navigator.of(context);
  final content = await ref.read(contentProvider.future);
  final Bible b = bible ?? await ref.read(bibleProvider(Translation.forLang(lang)).future);
  List<Question> questions;
  try {
    // Plusieurs livres = des milliers de versets à analyser : hors du fil de l'interface.
    questions = await runInBackground(() => ReadingQuiz.build(content: content, bible: b, lang: lang, scope: scope, count: count));
  } catch (_) {
    questions = ReadingQuiz.build(content: content, bible: b, lang: lang, scope: scope, count: count);
  }
  onBuilt?.call();
  if (!context.mounted) return;
  if (questions.length < 3) {
    context.toast(tooFew);
    return;
  }
  await nav.push(
    MaterialPageRoute(
      builder: (_) => QuizScreen(title: title, questions: questions, shuffleQuestions: true, showSource: true),
    ),
  );
}
