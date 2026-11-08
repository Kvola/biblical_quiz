import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../content/models.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../domain/quiz_session.dart';
import '../../providers.dart';
import '../common.dart';
import '../widgets/passage_view.dart';
import '../widgets/verse_sheet.dart';
import 'quiz_view.dart';
import 'result_view.dart';

enum _Stage { read, quiz, result }

/// Une leçon : lire le passage, répondre, puis voir ce qu'il faut retenir.
class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  static Future<void> open(BuildContext context, WidgetRef ref, Lesson lesson) {
    ref.read(settingsRepoProvider).setLastPath(lesson.pathId);
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonScreen(lesson: lesson)));
  }

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  _Stage _stage = _Stage.read;
  QuizSession? _session;

  Lesson get lesson => widget.lesson;

  void _startQuiz() => setState(() {
    _session = QuizSession(lesson.questions);
    _stage = _Stage.quiz;
  });

  Future<void> _finish(QuizSession s) async {
    setState(() => _stage = _Stage.result);
    await ref.read(progressRepoProvider).recordQuiz(lessonId: lesson.id, records: s.records, total: s.length);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final s = _session;
    final inQuiz = _stage == _Stage.quiz && s != null && (s.index > 0 || s.isAnswered);
    return PopScope(
      canPop: !inQuiz,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await confirmQuit(context) && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(lesson.title.of(lang)),
          actions: [if (_stage == _Stage.read) const _ParallelToggle()],
        ),
        body: switch (_stage) {
          _Stage.read => _ReadStage(lesson: lesson, onDone: _startQuiz),
          _Stage.quiz => QuizView(key: ObjectKey(s), session: s!, onFinished: _finish, onProgress: () => setState(() {})),
          _Stage.result => _ResultStage(
            lesson: lesson,
            session: s!,
            onReread: () => setState(() => _stage = _Stage.read),
          ),
        },
      ),
    );
  }
}

class _ParallelToggle extends ConsumerWidget {
  const _ParallelToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parallel = ref.watch(settingsProvider).value?.parallel ?? false;
    return IconButton(
      tooltip: context.l10n.showParallel,
      isSelected: parallel,
      icon: const Icon(Icons.translate),
      onPressed: () => ref.read(settingsRepoProvider).setParallel(!parallel),
    );
  }
}

class _ReadStage extends ConsumerWidget {
  const _ReadStage({required this.lesson, required this.onDone});

  final Lesson lesson;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final t = Translation.forLang(lang);
    final count = ref
        .watch(bibleProvider(t))
        .whenOrNull(data: (b) => lesson.passages.fold<int>(0, (n, r) => n + b.passage(r).length));
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.introTitle,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: QuizColors.gold),
                          ),
                          const SizedBox(height: 6),
                          Text(lesson.intro.of(lang), style: const TextStyle(height: 1.4)),
                          const SizedBox(height: 8),
                          Text(
                            [
                              lesson.passages.map((r) => refLabel(r, lang)).join(' · '),
                              if (count != null) l.versesCount(count),
                            ].join(' — '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              PassageSliver(refs: lesson.passages),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onDone, child: Text(l.goToQuestions(lesson.questions.length))),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultStage extends ConsumerWidget {
  const _ResultStage({required this.lesson, required this.session, required this.onReread});

  final Lesson lesson;
  final QuizSession session;
  final VoidCallback onReread;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final content = ref.watch(contentProvider).value;
    final next = content?.after(lesson);
    final bible = ref.watch(bibleProvider(Translation.forLang(lang))).value;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        ResultHeader(session: session),
        SectionTitle(l.takeawayTitle),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(lesson.takeaway.of(lang), style: const TextStyle(fontSize: 16, height: 1.45)),
          ),
        ),
        SectionTitle(l.keyVerseTitle),
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => showVerseSheet(context, lesson.keyVerse),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bible != null)
                    Text(
                      bible.text(lesson.keyVerse),
                      style: scriptureStyle(context, 1.0).copyWith(fontStyle: FontStyle.italic),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    refLabel(lesson.keyVerse, lang),
                    style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (next != null) ...[
          FilledButton(
            onPressed: () => Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => LessonScreen(lesson: next))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  Text(l.nextLesson),
                  Text(
                    next.title.of(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        OutlinedButton(onPressed: onReread, child: Text(l.rereadPassage)),
        const SizedBox(height: 10),
        if (next == null)
          FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.finish))
        else
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.finish)),
      ],
    );
  }
}
