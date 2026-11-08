import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../core/verse_ref.dart';
import '../../domain/search.dart';
import '../../providers.dart';
import '../bible/reader_screen.dart';
import '../common.dart';
import '../widgets/verse_sheet.dart';

enum _Scope { all, old, newT, book }

/// Recherche de versets par mots, expression exacte ou référence, hors ligne.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery});

  final String? initialQuery;

  static Future<void> open(BuildContext context, {String? query}) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: query)));

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  /// Au-delà, on invite à affiner : une liste de 20 000 versets ne se lit pas.
  static const maxShown = 500;
  static const _debounce = Duration(milliseconds: 250);

  late final TextEditingController _controller = TextEditingController(text: widget.initialQuery ?? '');
  final _focus = FocusNode();
  Timer? _timer;

  String _query = '';
  _Scope _scope = _Scope.all;
  int? _book;
  bool _wholeWords = false;
  Translation? _translation; // null : celle de la langue de l'interface

  @override
  void initState() {
    super.initState();
    _query = _controller.text;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  Translation get _t => _translation ?? Translation.forLang(context.lang);

  Set<int>? get _books => switch (_scope) {
    _Scope.all => null,
    _Scope.old => {for (var b = 1; b <= 39; b++) b},
    _Scope.newT => {for (var b = 40; b <= 66; b++) b},
    _Scope.book => _book == null ? null : {_book!},
  };

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      if (mounted) setState(() => _query = value);
    });
  }

  void _setQuery(String value) {
    _timer?.cancel();
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    setState(() => _query = value);
  }

  void _remember() => ref.read(settingsRepoProvider).addRecentSearch(_controller.text);

  Future<void> _openVerse(Verse v) async {
    _remember();
    await openReaderAt(context, ref, v.book, v.chapter, verse: v.number);
  }

  Future<void> _pickBook() async {
    final lang = context.lang;
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (c) => SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (c, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            children: [
              for (final testament in Testament.values) ...[
                SectionTitle(testament == Testament.old ? c.l10n.oldTestament : c.l10n.newTestament),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final b in books.where((b) => b.testament == testament))
                      ActionChip(label: Text(b.name(lang)), onPressed: () => Navigator.pop(c, b.id)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      setState(() {
        _scope = _Scope.book;
        _book = picked;
      });
    }
  }

  void _showTips() {
    final l = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (c) => SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(l.searchTipsTitle, style: Theme.of(c).textTheme.titleLarge),
            const SizedBox(height: 12),
            _Tip(text: l.searchTipWords, example: l.searchExampleWords, onTap: _useExample),
            _Tip(text: l.searchTipPhrase, example: l.searchExamplePhrase, onTap: _useExample),
            _Tip(text: l.searchTipExclude, example: l.searchExampleExclude, onTap: _useExample),
            _Tip(text: l.searchTipAccents),
            _Tip(text: l.searchTipRef, example: l.searchExampleRef, onTap: _useExample),
          ],
        ),
      ),
    );
  }

  void _useExample(String example) {
    Navigator.of(context).popUntil((r) => r is! ModalBottomSheetRoute);
    _setQuery(example);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final t = _t;
    final indexAsync = ref.watch(searchIndexProvider(t));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focus,
          autofocus: widget.initialQuery == null,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (v) {
            _setQuery(v);
            _remember();
          },
          decoration: InputDecoration(
            hintText: l.searchHint,
            border: InputBorder.none,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(tooltip: l.searchClear, icon: const Icon(Icons.close), onPressed: () => _setQuery('')),
          ),
        ),
        actions: [IconButton(tooltip: l.searchTipsTitle, icon: const Icon(Icons.help_outline), onPressed: _showTips)],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _Filters(
              scope: _scope,
              bookLabel: _book == null ? null : bookById(_book!).name(lang),
              wholeWords: _wholeWords,
              translation: t,
              onScope: (s) => s == _Scope.book ? _pickBook() : setState(() => _scope = s),
              onWholeWords: (v) => setState(() => _wholeWords = v),
              onTranslation: () => setState(() => _translation = t.other),
            ),
            const Divider(height: 1),
            Expanded(
              child: switch (indexAsync) {
                AsyncData(:final value) => _body(value),
                AsyncError(:final error) => AsyncBody(
                  value: AsyncError<void>(error, StackTrace.empty),
                  builder: (_) => const SizedBox(),
                  onRetry: () => ref.invalidate(searchIndexProvider(t)),
                ),
                _ => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [const CircularProgressIndicator(), const SizedBox(height: 12), Text(l.searchPreparing)],
                  ),
                ),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(SearchIndex index) {
    final l = context.l10n;
    final lang = context.lang;
    final text = _query.trim();
    if (text.isEmpty) return _EmptyState(onPick: _setQuery, onTips: _showTips);

    final refHit = parseHumanRef(text, index.bible);
    final q = SearchQuery.parse(text);
    // Une référence reconnue ne lance pas de recherche de mots (« Jean 3 16 »
    // trouverait sinon tous les versets contenant « jean »).
    final result = refHit != null ? SearchResult.empty : index.search(q, books: _books, wholeWords: _wholeWords);
    final shown = result.hits.length > maxShown ? result.hits.sublist(0, maxShown) : result.hits;
    final scheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (refHit != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.menu_book, color: context.palette.brandIcon),
                  title: Text(
                    l.searchGoTo(refLabel(refHit.ref, lang)),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: refHit.chapterOnly
                      ? null
                      : Text(index.bible.text(refHit.ref), maxLines: 3, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _remember();
                    final r = refHit.ref;
                    openReaderAt(context, ref, r.book, r.startChapter, verse: refHit.chapterOnly ? null : r.startVerse);
                  },
                ),
              ),
            ),
          ),
        if (refHit == null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                _books == null || result.hits.length == result.total
                    ? l.searchResults(result.total)
                    : l.searchResultsFiltered(result.hits.length, result.total),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          if (result.perBook.length > 1)
            SliverToBoxAdapter(
              child: _BookDistribution(
                perBook: result.perBook,
                selected: _scope == _Scope.book ? _book : null,
                onTap: (b) => setState(() {
                  if (_scope == _Scope.book && _book == b) {
                    _scope = _Scope.all;
                    _book = null;
                  } else {
                    _scope = _Scope.book;
                    _book = b;
                  }
                }),
              ),
            ),
          if (result.total == 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.searchNoResult,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
          SliverList.separated(
            itemCount: shown.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, i) {
              final v = index.verses[shown[i]];
              return _ResultTile(
                verse: v,
                query: q,
                wholeWords: _wholeWords,
                onTap: () => _openVerse(v),
                onLongPress: () => showVerseSheet(context, VerseRef.single(v.book, v.chapter, v.number)),
              );
            },
          ),
          if (result.hits.length > maxShown)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l.searchMoreResults(result.hits.length - maxShown),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.scope,
    required this.bookLabel,
    required this.wholeWords,
    required this.translation,
    required this.onScope,
    required this.onWholeWords,
    required this.onTranslation,
  });

  final _Scope scope;
  final String? bookLabel;
  final bool wholeWords;
  final Translation translation;
  final void Function(_Scope) onScope;
  final void Function(bool) onWholeWords;
  final VoidCallback onTranslation;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget choice(_Scope s, String label) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(label: Text(label), selected: scope == s, onSelected: (_) => onScope(s)),
    );
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          choice(_Scope.all, l.searchAll),
          choice(_Scope.old, l.searchOld),
          choice(_Scope.newT, l.searchNew),
          choice(_Scope.book, scope == _Scope.book && bookLabel != null ? bookLabel! : l.searchBook),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(label: Text(l.searchWholeWords), selected: wholeWords, onSelected: onWholeWords),
          ),
          ActionChip(
            avatar: const Icon(Icons.translate, size: 18),
            label: Text(translation.shortName),
            tooltip: l.searchIn(translation.fullName),
            onPressed: onTranslation,
          ),
        ],
      ),
    );
  }
}

/// Où se trouvent les résultats : un bouton par livre, avec le nombre de versets.
class _BookDistribution extends StatelessWidget {
  const _BookDistribution({required this.perBook, required this.selected, required this.onTap});

  final Map<int, int> perBook;
  final int? selected;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final lang = context.lang;
    final entries = perBook.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final e in entries)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: FilterChip(
                visualDensity: VisualDensity.compact,
                label: Text('${bookById(e.key).abbr(lang)} ${e.value}'),
                selected: selected == e.key,
                onSelected: (_) => onTap(e.key),
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultTile extends ConsumerWidget {
  const _ResultTile({
    required this.verse,
    required this.query,
    required this.wholeWords,
    required this.onTap,
    required this.onLongPress,
  });

  final Verse verse;
  final SearchQuery query;
  final bool wholeWords;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = context.lang;
    final scheme = Theme.of(context).colorScheme;
    final p = context.palette;
    final scale = ref.watch(settingsProvider.select((s) => s.value?.textScale ?? 1.0));
    final base = scriptureStyle(context, scale).copyWith(fontSize: 16 * scale, height: 1.45);
    final mark = base.copyWith(backgroundColor: p.highlight, fontWeight: FontWeight.w700, color: scheme.onSurface);
    final text = verse.text;
    final spans = <TextSpan>[];
    var pos = 0;
    for (final (a, b) in highlightRanges(text, query, wholeWords: wholeWords)) {
      if (a > pos) spans.add(TextSpan(text: text.substring(pos, a)));
      spans.add(TextSpan(text: text.substring(a, b), style: mark));
      pos = b;
    }
    if (pos < text.length) spans.add(TextSpan(text: text.substring(pos)));
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              refLabel(VerseRef.single(verse.book, verse.chapter, verse.number), lang),
              style: TextStyle(fontWeight: FontWeight.w700, color: scheme.primary),
            ),
            const SizedBox(height: 4),
            Text.rich(TextSpan(children: spans), style: base),
          ],
        ),
      ),
    );
  }
}

/// Avant de taper : recherches récentes et exemples.
class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.onPick, required this.onTips});

  final void Function(String) onPick;
  final VoidCallback onTips;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final recent = ref.watch(settingsProvider.select((s) => s.value?.recentSearches ?? const <String>[]));
    final repo = ref.read(settingsRepoProvider);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        if (recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(child: SectionTitle(l.searchRecent)),
              TextButton(onPressed: repo.clearRecentSearches, child: Text(l.searchClearRecent)),
            ],
          ),
          for (final r in recent)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.history),
              title: Text(r),
              trailing: IconButton(
                tooltip: l.searchClear,
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => repo.removeRecentSearch(r),
              ),
              onTap: () => onPick(r),
            ),
        ],
        SectionTitle(l.searchTipsTitle),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final e in [l.searchExampleWords, l.searchExamplePhrase, l.searchExampleExclude, l.searchExampleRef])
              ActionChip(label: Text(e), onPressed: () => onPick(e)),
          ],
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onTips,
            icon: const Icon(Icons.help_outline),
            label: Text(l.searchTipsTitle),
          ),
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip({required this.text, this.example, this.onTap});

  final String text;
  final String? example;
  final void Function(String)? onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text),
        if (example != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ActionChip(label: Text(example!), onPressed: () => onTap?.call(example!)),
          ),
      ],
    ),
  );
}
