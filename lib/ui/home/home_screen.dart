import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../content/content.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../core/verse_ref.dart';
import '../../domain/book_challenge.dart';
import '../../domain/days.dart';
import '../../providers.dart';
import '../common.dart';
import '../reading/reading_quiz_screen.dart';
import '../launchers.dart';
import '../quiz/lesson_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/verse_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final content = ref.watch(contentProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            tooltip: l.searchTitle,
            icon: const Icon(Icons.search),
            onPressed: () => SearchScreen.open(context),
          ),
          IconButton(
            tooltip: l.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AsyncBody(
          value: content,
          onRetry: () => ref.invalidate(contentProvider),
          builder: (c) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const _StreakCard(),
              const SizedBox(height: 12),
              _ContinueCard(content: c),
              const _ReviewCard(),
              const SizedBox(height: 12),
              _VerseOfDayCard(content: c),
              const SizedBox(height: 12),
              const _ReadingQuizCard(),
              const SizedBox(height: 12),
              const _ChallengeCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(summaryProvider).value;
    final streak = s?.currentStreak ?? 0;
    final subtitle = streak == 0 ? l.streakStart : (s!.activeToday ? l.streakDone : l.streakKeep);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: context.palette.accentIcon.withValues(alpha: 0.18),
          child: Icon(
            Icons.local_fire_department,
            color: streak > 0 ? context.palette.accentIcon : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Text(
          streak == 0 ? l.streakStart : l.streakDays(streak),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: streak == 0 ? null : Text(subtitle),
      ),
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  const _ContinueCard({required this.content});

  final Content content;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final completed = ref.watch(completedProvider);
    final lastPath = ref.watch(settingsProvider.select((s) => s.value?.lastPathId));
    final next = content.suggestedNext(completed, lastPath);
    final text = Theme.of(context).textTheme;
    if (next == null) {
      return Card(
        child: Padding(padding: const EdgeInsets.all(16), child: Text(l.allDone)),
      );
    }
    final path = content.path(next.pathId)!;
    final p = context.palette;
    return Card(
      color: p.heroBackground,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (completed.isEmpty ? l.startTitle : l.continueTitle).toUpperCase(),
              style: text.labelMedium?.copyWith(color: p.heroAccent, letterSpacing: 1.2),
            ),
            const SizedBox(height: 6),
            Text(path.title.of(lang), style: text.bodyMedium?.copyWith(color: p.heroMuted)),
            Text(
              next.title.of(lang),
              style: text.headlineSmall?.copyWith(color: p.heroForeground, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              next.passages.map((r) => refLabel(r, lang)).join(' · '),
              style: text.bodySmall?.copyWith(color: p.heroMuted),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: p.heroButton, foregroundColor: p.onHeroButton),
              icon: const Icon(Icons.menu_book),
              label: Text(l.lessonStart),
              onPressed: () => LessonScreen.open(context, ref, next),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(dueProvider).value ?? const [];
    if (due.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Icon(Icons.replay, color: context.palette.success),
          title: Text(l.reviewTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(l.reviewDue(due.length)),
          trailing: FilledButton.tonal(onPressed: () => openReview(context, ref), child: Text(l.reviewStart)),
        ),
      ),
    );
  }
}

class _VerseOfDayCard extends ConsumerWidget {
  const _VerseOfDayCard({required this.content});

  final Content content;

  /// Le même verset toute la journée, différent chaque jour, sans état stocké.
  static VerseRef pick(Content content, Bible bible, int day) {
    final candidates = BookChallenge.readableCandidates(content, bible);
    return candidates[day % candidates.length];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final lang = context.lang;
    final bible = ref.watch(bibleProvider(Translation.forLang(lang))).value;
    if (bible == null) return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
    final ref0 = pick(content, bible, dayKey(DateTime.now()));
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showVerseSheet(context, ref0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.wb_twilight, color: context.palette.accentIcon, size: 20),
                  const SizedBox(width: 8),
                  Text(l.verseOfDay, style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
              const SizedBox(height: 10),
              Text(bible.text(ref0), style: scriptureStyle(context, 1.0).copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text(
                refLabel(ref0, lang),
                style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadingQuizCard extends ConsumerWidget {
  const _ReadingQuizCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final read = ref.watch(readChaptersProvider).value ?? const {};
    final chapters = read.values.fold<int>(0, (n, c) => n + c.length);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(Icons.history_edu, color: context.palette.brandIcon),
        title: Text(l.readingQuizTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(chapters == 0 ? l.readingQuizSubtitle : '${l.readingQuizSubtitle} · ${l.chaptersReadTotal(chapters)}'),
        trailing: FilledButton.tonal(onPressed: () => ReadingQuizScreen.open(context), child: Text(l.play)),
      ),
    );
  }
}

class _ChallengeCard extends ConsumerWidget {
  const _ChallengeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(Icons.travel_explore, color: context.palette.brandIcon),
        title: Text(l.challengeTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(l.challengeSubtitle),
        trailing: FilledButton.tonal(onPressed: () => openBookChallenge(context, ref), child: Text(l.play)),
      ),
    );
  }
}
