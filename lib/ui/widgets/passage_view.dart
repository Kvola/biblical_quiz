import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../core/verse_ref.dart';
import '../../providers.dart';
import '../common.dart';

/// Versets d'une liste de références, dans la traduction de la langue de
/// l'interface, avec en option l'autre traduction sous chaque verset.
///
/// Rendu en widgets « slivers » pour s'insérer dans un CustomScrollView.
class PassageSliver extends ConsumerWidget {
  const PassageSliver({super.key, required this.refs, this.onVerseTap, this.showHeadings = true});

  final List<VerseRef> refs;
  final void Function(Verse verse)? onVerseTap;
  final bool showHeadings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translation.forLang(context.lang);
    final settings = ref.watch(settingsProvider).value;
    final scale = settings?.textScale ?? 1.0;
    final parallel = settings?.parallel ?? false;
    final bible = ref.watch(bibleProvider(t));
    final other = parallel ? ref.watch(bibleProvider(t.other)) : null;

    final b = bible.value;
    if (b == null) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 160,
          child: AsyncBody(value: bible, builder: (_) => const SizedBox(), onRetry: () => ref.invalidate(bibleProvider(t))),
        ),
      );
    }
    final o = other?.value;
    final children = <Widget>[];
    for (final r in refs) {
      if (showHeadings) children.add(_Heading(text: refLabel(r, context.lang)));
      int? lastChapter;
      for (final v in b.passage(r)) {
        if (r.startChapter != r.endChapter && v.chapter != lastChapter) {
          children.add(_ChapterMark(chapter: v.chapter));
        }
        lastChapter = v.chapter;
        children.add(
          VerseTile(
            verse: v,
            scale: scale,
            secondary: o?.verse(v.book, v.chapter, v.number)?.text,
            onTap: onVerseTap == null ? null : () => onVerseTap!(v),
          ),
        );
      }
    }
    return SliverList.list(children: children);
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class _ChapterMark extends StatelessWidget {
  const _ChapterMark({required this.chapter});

  final int chapter;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
    child: Text('— $chapter —', style: Theme.of(context).textTheme.labelLarge),
  );
}

/// Un verset : numéro en exposant, texte serif, et l'autre traduction en dessous si demandée.
class VerseTile extends StatelessWidget {
  const VerseTile({super.key, required this.verse, required this.scale, this.secondary, this.onTap, this.highlighted = false});

  final Verse verse;
  final double scale;
  final String? secondary;
  final VoidCallback? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final style = scriptureStyle(context, scale);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: highlighted ? QuizColors.gold.withValues(alpha: 0.18) : null,
        padding: EdgeInsets.fromLTRB(20, verse.paragraph ? 10 : 2, 20, 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${verse.number} ',
                    style: style.copyWith(
                      fontSize: style.fontSize! * 0.62,
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.superscripts()],
                    ),
                  ),
                  TextSpan(text: verse.text, style: style),
                ],
              ),
            ),
            if (secondary != null)
              Padding(
                padding: const EdgeInsets.only(top: 2, bottom: 6),
                child: Text(
                  secondary!,
                  style: style.copyWith(
                    fontSize: style.fontSize! * 0.82,
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
