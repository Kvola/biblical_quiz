import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../content/models.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../providers.dart';
import '../bible/reader_screen.dart';
import '../common.dart';
import '../quiz/quiz_screen.dart';
import '../widgets/verse_sheet.dart';

/// Les 66 livres, par Testament.
class BooksScreen extends ConsumerWidget {
  const BooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final completed = ref.watch(completedProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.booksPathTitle)),
      body: SafeArea(
        top: false,
        child: AsyncBody(
          value: ref.watch(contentProvider),
          builder: (content) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              for (final testament in Testament.values) ...[
                SectionTitle(testament == Testament.old ? l.oldTestament : l.newTestament),
                for (final b in content.books.where((b) => bookById(b.id).testament == testament))
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: completed.contains(b.lessonId)
                          ? context.palette.successContainer
                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                      child: completed.contains(b.lessonId)
                          ? Icon(Icons.check, color: context.palette.onSuccessContainer, size: 18)
                          : Text(
                              bookById(b.id).abbr(lang),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                    ),
                    title: Text(bookById(b.id).name(lang)),
                    subtitle: Text(b.of(lang).themes.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => BookScreen(bookId: b.id))),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fiche d'un livre : de quoi il parle, qui l'a écrit, verset clé, quiz.
class BookScreen extends ConsumerWidget {
  const BookScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final info = ref.watch(contentProvider).value?.book(bookId);
    final bible = ref.watch(bibleProvider(Translation.forLang(lang))).value;
    final name = bookById(bookId).name(lang);
    if (info == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final t = info.of(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            if (bible != null) Text(l.bookChapters(bible.chapterCount(bookId)), style: text.bodySmall),
            const SizedBox(height: 8),
            Text(t.summary, style: text.bodyLarge?.copyWith(height: 1.5)),
            const SizedBox(height: 16),
            _Fact(label: l.bookAuthor, value: t.author),
            _Fact(label: l.bookPeriod, value: t.period),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final th in t.themes) Chip(label: Text(th))]),
            SectionTitle(l.keyVerseTitle),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => showVerseSheet(context, info.keyVerse),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bible != null)
                        Text(
                          bible.text(info.keyVerse),
                          style: scriptureStyle(context, 1.0).copyWith(fontStyle: FontStyle.italic),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        refLabel(info.keyVerse, lang),
                        style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.quiz_outlined),
              label: Text(l.bookQuiz(info.questions.length)),
              onPressed: () => _openQuiz(context, info, name),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(l.readBook),
              onPressed: () => openReaderAt(context, ref, bookId, 1),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuiz(BuildContext context, BookInfo info, String name) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => QuizScreen(title: name, questions: info.questions, lessonId: info.lessonId),
    ),
  );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
    ),
  );
}
