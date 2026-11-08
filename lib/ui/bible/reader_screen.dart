import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/verse_ref.dart';
import '../../providers.dart';
import '../common.dart';
import '../widgets/passage_view.dart';
import '../widgets/verse_sheet.dart';

/// Ouvre le lecteur sur un chapitre précis (depuis une fiche de livre ou un favori).
Future<void> openReaderAt(BuildContext context, WidgetRef ref, int book, int chapter, {int? verse}) {
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ReaderScreen(initialBook: book, initialChapter: chapter, highlightVerse: verse),
    ),
  );
}

/// Lecture libre de la Bible, chapitre par chapitre.
///
/// En onglet, il reprend là où on s'était arrêté. Lire un chapitre au moins
/// [_ReaderScreenState._activeAfter], lecteur visible et application au
/// premier plan, compte comme activité du jour (la série).
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, this.initialBook, this.initialChapter, this.highlightVerse, this.active = true});

  final int? initialBook;
  final int? initialChapter;
  final int? highlightVerse;

  /// Faux quand le lecteur est un onglet non affiché : les onglets restent
  /// construits (IndexedStack), et un onglet caché ne lit pas.
  final bool active;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  static const _activeAfter = Duration(seconds: 20);

  int? _book;
  int? _chapter;
  int? _highlight;
  Timer? _activeTimer;
  late final AppLifecycleListener _lifecycle;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _book = widget.initialBook;
    _chapter = widget.initialChapter;
    _highlight = widget.highlightVerse;
    // Application en arrière-plan : on ne lit pas.
    _lifecycle = AppLifecycleListener(onShow: _armActivity, onHide: _disarm);
    WidgetsBinding.instance.addPostFrameCallback((_) => _armActivity());
  }

  @override
  void didUpdateWidget(ReaderScreen old) {
    super.didUpdateWidget(old);
    if (widget.active != old.active) widget.active ? _armActivity() : _disarm();
  }

  @override
  void dispose() {
    _disarm();
    _lifecycle.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _go(Bible bible, int book, int chapter, {int? highlight}) {
    final c = chapter.clamp(1, bible.chapterCount(book));
    setState(() {
      _book = book;
      _chapter = c;
      _highlight = highlight;
    });
    ref.read(settingsRepoProvider).setReaderPosition(book, c);
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _armActivity();
  }

  /// (Re)démarre le compte des secondes de lecture du chapitre affiché.
  void _armActivity() {
    _disarm();
    if (!mounted || !widget.active) return;
    _activeTimer = Timer(_activeAfter, () => ref.read(progressRepoProvider).markActive());
  }

  void _disarm() {
    _activeTimer?.cancel();
    _activeTimer = null;
  }

  Future<void> _pickBook(Bible bible) async {
    final picked = await showModalBottomSheet<(int, int)>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => SafeArea(top: false, child: _BookPicker(bible: bible)),
    );
    if (picked != null) _go(bible, picked.$1, picked.$2);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final t = Translation.forLang(lang);
    final settings = ref.watch(settingsProvider).value;
    final bibleAsync = ref.watch(bibleProvider(t));

    return AsyncBody(
      value: bibleAsync,
      onRetry: () => ref.invalidate(bibleProvider(t)),
      builder: (bible) {
        // Première ouverture : position enregistrée, sinon Jean 1.
        if (_book == null && settings != null) {
          _book = settings.readerBook;
          _chapter = settings.readerChapter.clamp(1, bible.chapterCount(settings.readerBook));
        }
        final book = _book ?? 43, chapter = _chapter ?? 1;
        final count = bible.chapterCount(book);
        final title = l.chapterTitle(bookById(book).name(lang), chapter);
        final hasPrev = chapter > 1 || book > 1;
        final hasNext = chapter < count || book < 66;
        final verses = bible.chapter(book, chapter);
        final ref0 = VerseRef(book, chapter, 1, chapter, verses.length);

        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: () => _pickBook(bible),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: l.showParallel,
                isSelected: settings?.parallel ?? false,
                icon: const Icon(Icons.translate),
                onPressed: () => ref.read(settingsRepoProvider).setParallel(!(settings?.parallel ?? false)),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              controller: _scroll,
              slivers: [
                _ChapterSliver(
                  verseRef: ref0,
                  highlight: _highlight,
                  onVerseTap: (v) => showVerseSheet(context, VerseRef.single(v.book, v.chapter, v.number)),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: hasPrev
                                ? () => chapter > 1
                                      ? _go(bible, book, chapter - 1)
                                      : _go(bible, book - 1, bible.chapterCount(book - 1))
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            label: Text(l.previousChapter, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: hasNext
                                ? () => chapter < count ? _go(bible, book, chapter + 1) : _go(bible, book + 1, 1)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            label: Text(l.nextChapter, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Le chapitre courant, avec un verset éventuellement surligné (venu d'un favori).
class _ChapterSliver extends ConsumerWidget {
  const _ChapterSliver({required this.verseRef, required this.onVerseTap, this.highlight});

  final VerseRef verseRef;
  final int? highlight;
  final void Function(Verse) onVerseTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (highlight == null) {
      return PassageSliver(refs: [verseRef], showHeadings: false, onVerseTap: onVerseTap);
    }
    final t = Translation.forLang(context.lang);
    final settings = ref.watch(settingsProvider).value;
    final bible = ref.watch(bibleProvider(t)).value;
    final other = (settings?.parallel ?? false) ? ref.watch(bibleProvider(t.other)).value : null;
    if (bible == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverList.list(
      children: [
        for (final v in bible.passage(verseRef))
          VerseTile(
            verse: v,
            scale: settings?.textScale ?? 1.0,
            secondary: other?.verse(v.book, v.chapter, v.number)?.text,
            highlighted: v.number == highlight,
            onTap: () => onVerseTap(v),
          ),
      ],
    );
  }
}

/// Choix d'un livre puis d'un chapitre.
class _BookPicker extends StatefulWidget {
  const _BookPicker({required this.bible});

  final Bible bible;

  @override
  State<_BookPicker> createState() => _BookPickerState();
}

class _BookPickerState extends State<_BookPicker> {
  int? _book;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, controller) {
        final book = _book;
        if (book != null) {
          final n = widget.bible.chapterCount(book);
          return Column(
            children: [
              ListTile(
                leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() => _book = null)),
                title: Text(l.chooseChapter(bookById(book).name(lang))),
              ),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 64,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: n,
                  itemBuilder: (_, i) => OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(48, 48)),
                    onPressed: () => Navigator.of(context).pop((book, i + 1)),
                    child: Text('${i + 1}'),
                  ),
                ),
              ),
            ],
          );
        }
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(l.chooseBook, style: Theme.of(context).textTheme.titleLarge),
            for (final testament in Testament.values) ...[
              SectionTitle(testament == Testament.old ? l.oldTestament : l.newTestament),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final b in books.where((b) => b.testament == testament))
                    ActionChip(
                      label: Text(b.name(lang)),
                      onPressed: () {
                        // Un livre d'un seul chapitre s'ouvre directement.
                        if (widget.bible.chapterCount(b.id) == 1) {
                          Navigator.of(context).pop((b.id, 1));
                        } else {
                          setState(() => _book = b.id);
                        }
                      },
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
