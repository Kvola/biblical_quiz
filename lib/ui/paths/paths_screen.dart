import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../content/models.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../providers.dart';
import '../common.dart';
import '../quiz/lesson_screen.dart';
import 'books_screen.dart';

class PathsScreen extends ConsumerWidget {
  const PathsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final completed = ref.watch(completedProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pathsTitle)),
      body: AsyncBody(
        value: ref.watch(contentProvider),
        onRetry: () => ref.invalidate(contentProvider),
        builder: (content) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            for (final p in content.paths) ...[
              _PathCard(
                icon: pathIcon(p.icon),
                title: p.title.of(lang),
                description: p.description.of(lang),
                done: p.lessons.where((x) => completed.contains(x.id)).length,
                total: p.lessons.length,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PathScreen(pathId: p.id))),
              ),
              const SizedBox(height: 12),
            ],
            _PathCard(
              icon: Icons.library_books_outlined,
              title: l.booksPathTitle,
              description: l.booksPathSubtitle,
              done: content.books.where((b) => completed.contains(b.lessonId)).length,
              total: content.books.length,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BooksScreen())),
            ),
          ],
        ),
      ),
    );
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.done,
    required this.total,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final int done;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primary.withValues(alpha: 0.1),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(description, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : done / total,
                        minHeight: 6,
                        color: done == total ? QuizColors.olive : scheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(context.l10n.lessonsProgress(done, total), style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PathScreen extends ConsumerWidget {
  const PathScreen({super.key, required this.pathId});

  final String pathId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.lang;
    final content = ref.watch(contentProvider).value;
    final path = content?.path(pathId);
    final progress = ref.watch(lessonProgressProvider).value ?? const {};
    if (path == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final next = content!.nextInPath(pathId, progress.keys.toSet());
    return Scaffold(
      appBar: AppBar(title: Text(path.title.of(lang))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
            child: Text(path.description.of(lang), style: Theme.of(context).textTheme.bodyLarge),
          ),
          for (final (i, lesson) in path.lessons.indexed)
            _LessonTile(
              number: i + 1,
              lesson: lesson,
              bestScore: progress[lesson.id]?.bestScore,
              total: progress[lesson.id]?.total,
              isNext: lesson.id == next?.id,
            ),
        ],
      ),
    );
  }
}

class _LessonTile extends ConsumerWidget {
  const _LessonTile({required this.number, required this.lesson, this.bestScore, this.total, required this.isNext});

  final int number;
  final Lesson lesson;
  final int? bestScore;
  final int? total;
  final bool isNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.lang;
    final done = bestScore != null;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        shape: isNext
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: QuizColors.gold, width: 2),
              )
            : null,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: done ? QuizColors.olive : scheme.primary.withValues(alpha: 0.1),
            foregroundColor: done ? Colors.white : scheme.primary,
            child: done ? const Icon(Icons.check) : Text('$number'),
          ),
          title: Text(lesson.title.of(lang), style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            [
              lesson.passages.map((r) => refLabel(r, lang, abbreviated: true)).join(' · '),
              if (done) context.l10n.bestScore(bestScore!, total!),
            ].join('\n'),
          ),
          isThreeLine: done,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => LessonScreen.open(context, ref, lesson),
        ),
      ),
    );
  }
}
