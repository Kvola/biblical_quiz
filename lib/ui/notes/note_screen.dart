import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/whatsapp.dart';
import '../../core/verse_ref.dart';
import '../../data/notes_repository.dart';
import '../../domain/days.dart';
import '../../domain/reading_quiz.dart';
import '../../domain/note_text.dart';
import '../../domain/ref_finder.dart';
import '../../providers.dart';
import '../common.dart';
import '../reading/reading_quiz_screen.dart';
import '../widgets/passage_view.dart';
import '../widgets/verse_sheet.dart';
import 'add_passage_dialog.dart';

/// Une note de prédication : titre, jour, prédicateur, lieu, passages, notes.
///
/// Tout s'enregistre au fil de la frappe (pas de bouton « Enregistrer » à
/// oublier pendant une prédication). Une note ouverte puis quittée sans rien
/// écrire est supprimée.
class NoteScreen extends ConsumerStatefulWidget {
  const NoteScreen({super.key, required this.noteId});

  final int noteId;

  /// Ouvre une nouvelle note (avec un premier passage éventuel).
  static Future<void> openNew(BuildContext context, WidgetRef ref, {VerseRef? passage}) async {
    final id = await ref.read(notesRepoProvider).create(refs: [?passage]);
    if (context.mounted) await open(context, id);
  }

  static Future<void> open(BuildContext context, int id) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => NoteScreen(noteId: id)));

  @override
  ConsumerState<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends ConsumerState<NoteScreen> {
  final _title = TextEditingController();
  final _preacher = TextEditingController();
  final _place = TextEditingController();
  final _body = TextEditingController();
  late final NotesRepository _repo = ref.read(notesRepoProvider);

  SermonNote? _note;
  bool _loaded = false;
  bool _deleted = false;
  Timer? _debounce;

  /// Champs modifiés depuis le dernier enregistrement.
  final _dirty = <String>{};

  /// Pendant une prédication, le téléphone ne doit pas se verrouiller entre
  /// deux phrases : l'écran reste allumé tant que la note est ouverte.
  static Future<void> _keepAwake(bool on) async {
    try {
      await WakelockPlus.toggle(enable: on);
    } catch (_) {
      // Navigateur sans cette fonction, tests : sans conséquence.
    }
  }

  @override
  void initState() {
    super.initState();
    unawaited(_keepAwake(true));
    _load();
    for (final (key, c) in [('title', _title), ('preacher', _preacher), ('place', _place), ('body', _body)]) {
      c.addListener(() {
        if (!_loaded) return;
        _dirty.add(key);
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 600), _save);
      });
    }
  }

  Future<void> _load() async {
    final n = await _repo.get(widget.noteId);
    if (!mounted) return;
    _title.text = n?.title ?? '';
    _preacher.text = n?.preacher ?? '';
    _place.text = n?.place ?? '';
    _body.text = n?.body ?? '';
    setState(() {
      _note = n;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    _debounce?.cancel();
    if (_dirty.isEmpty || _deleted) return;
    final fields = {..._dirty};
    _dirty.clear();
    await _repo.update(
      widget.noteId,
      title: fields.contains('title') ? _title.text : null,
      preacher: fields.contains('preacher') ? _preacher.text : null,
      place: fields.contains('place') ? _place.text : null,
      body: fields.contains('body') ? _body.text : null,
    );
  }

  @override
  void dispose() {
    // Dernières frappes, puis nettoyage d'une note restée vide. Le dépôt ne
    // dépend pas du widget : ces écritures vont au bout même écran fermé.
    final repo = _repo;
    final id = widget.noteId;
    final pending = _save();
    if (!_deleted) unawaited(pending.then((_) => repo.deleteIfBlank(id)));
    _debounce?.cancel();
    unawaited(_keepAwake(false));
    for (final c in [_title, _preacher, _place, _body]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addPassage({String initial = ''}) async {
    final r = await showAddPassageDialog(context, initial: initial);
    if (r == null || !mounted) return;
    await _repo.addRef(widget.noteId, r);
  }

  Future<void> _removePassage(SermonNote note, VerseRef r) async {
    final l = context.l10n;
    final before = note.refs;
    await _repo.setRefs(widget.noteId, [for (final x in before) if (x != r) x]);
    if (!mounted) return;
    context.toast(
      l.notePassageRemoved,
      action: SnackBarAction(label: l.undo, onPressed: () => _repo.setRefs(widget.noteId, before)),
    );
  }

  Future<void> _pickDay(SermonNote note) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: note.date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 366)),
      helpText: context.l10n.noteDateTooltip,
    );
    if (picked != null) await _repo.update(widget.noteId, day: dayKey(picked));
  }

  /// Partager : WhatsApp (mise en forme WhatsApp), une autre application, ou copier.
  Future<void> _share(SermonNote note) async {
    final lang = context.lang;
    final l = context.l10n;
    final dates = MaterialLocalizations.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.chat_outlined), title: Text(l.shareWhatsApp), onTap: () => Navigator.of(ctx).pop('whatsapp')),
            ListTile(leading: const Icon(Icons.share), title: Text(l.shareOther), onTap: () => Navigator.of(ctx).pop('other')),
            ListTile(leading: const Icon(Icons.copy), title: Text(l.copyText), onTap: () => Navigator.of(ctx).pop('copy')),
          ],
        ),
      ),
    );
    if (choice == null) return;
    await _save();
    final bible = await ref.read(bibleProvider(Translation.forLang(lang)).future);
    final fresh = await _repo.get(widget.noteId) ?? note;
    String text({required bool whatsapp}) => noteShareText(
      fresh,
      bible: bible,
      lang: lang,
      dateLabel: dates.formatFullDate(fresh.date),
      untitled: l.noteUntitled,
      passagesLabel: l.notePassages,
      notesLabel: l.noteBody,
      footer: l.noteShareFooter,
      whatsapp: whatsapp,
    );
    final subject = fresh.title.trim().isEmpty ? null : fresh.title.trim();
    switch (choice) {
      case 'whatsapp':
        if (await openWhatsApp(text(whatsapp: true))) return;
        if (mounted) context.toast(l.whatsappFailed);
        await SharePlus.instance.share(ShareParams(text: text(whatsapp: false), subject: subject));
      case 'other':
        await SharePlus.instance.share(ShareParams(text: text(whatsapp: false), subject: subject));
      case 'copy':
        await Clipboard.setData(ClipboardData(text: text(whatsapp: false)));
        if (mounted) context.toast(l.copied);
    }
  }

  /// Quiz sur les chapitres des passages de la note.
  Future<void> _quiz(SermonNote note) async {
    final l = context.l10n;
    final books = <int, Set<int>>{};
    for (final r in note.refs) {
      for (var c = r.startChapter; c <= r.endChapter; c++) {
        (books[r.book] ??= {}).add(c);
      }
    }
    final title = note.title.trim().isEmpty ? l.noteUntitled : note.title.trim();
    await openReadingQuiz(
      context,
      ref,
      scope: ReadingScope(books),
      count: 10,
      title: l.readingQuizNamed(title),
      tooFew: l.noteQuizTooFew,
    );
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    _deleted = true;
    _debounce?.cancel();
    final deleted = await _repo.delete(widget.noteId);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (deleted == null) return;
    final repo = _repo;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l.noteDeleted),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: l.undo, onPressed: () => repo.restore(deleted)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final note = ref.watch(_noteProvider(widget.noteId)).value ?? _note;
    final bible = ref.watch(bibleProvider(Translation.forLang(lang))).value;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    // Références tapées dans les notes et pas encore dans les passages (ni telles
    // quelles, ni converties depuis une Segond imprimée : « Ps 51:12 » ajouté
    // comme Psaumes 51:10 ne doit plus être proposé).
    final numbering = lang == 'fr' ? ref.watch(printedNumberingProvider).value : null;
    final found = <VerseRef>[];
    if (bible != null && note != null) {
      for (final f in RefFinder(bible).findAll(_body.text)) {
        final converted = numbering?.fromPrinted(f.ref);
        if (note.refs.contains(f.ref) || (converted != null && note.refs.contains(converted))) continue;
        if (!found.contains(f.ref)) found.add(f.ref);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.notesTitle),
        actions: [
          if (note != null && note.refs.isNotEmpty)
            IconButton(
              tooltip: l.noteReadPassages,
              icon: const Icon(Icons.menu_book_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => _PassagesScreen(title: _title.text.trim().isEmpty ? l.noteUntitled : _title.text.trim(), refs: note.refs)),
              ),
            ),
          if (note != null)
            IconButton(tooltip: l.share, icon: const Icon(Icons.share), onPressed: () => _share(note)),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') _delete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(l.noteDelete), contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: note == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  TextField(
                    key: const ValueKey('note-title'),
                    controller: _title,
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(hintText: l.noteTitleHint, border: InputBorder.none),
                    maxLines: null,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.event_outlined, size: 18),
                        label: Text(MaterialLocalizations.of(context).formatFullDate(note.date)),
                        tooltip: l.noteDateTooltip,
                        onPressed: () => _pickDay(note),
                      ),
                    ],
                  ),
                  _MetaField(controller: _preacher, icon: Icons.person_outline, hint: l.notePreacherHint, fieldKey: 'note-preacher'),
                  _MetaField(controller: _place, icon: Icons.place_outlined, hint: l.notePlaceHint, fieldKey: 'note-place'),
                  SectionTitle(l.notePassages),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in note.refs)
                        InputChip(
                          label: Text(refLabel(r, lang)),
                          onPressed: () => showVerseSheet(context, r),
                          onDeleted: () => _removePassage(note, r),
                          deleteButtonTooltipMessage: l.notePassageRemoved,
                        ),
                      ActionChip(
                        key: const ValueKey('note-add-passage'),
                        avatar: const Icon(Icons.add, size: 18),
                        label: Text(l.noteAddPassage),
                        onPressed: _addPassage,
                      ),
                    ],
                  ),
                  if (note.refs.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        key: const ValueKey('note-quiz'),
                        icon: const Icon(Icons.quiz_outlined),
                        label: Text(l.noteQuiz),
                        onPressed: () => _quiz(note),
                      ),
                    ),
                  ],
                  SectionTitle(l.noteBody),
                  TextField(
                    key: const ValueKey('note-body'),
                    controller: _body,
                    minLines: 8,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}), // références repérées
                    decoration: InputDecoration(hintText: l.noteBodyHint, border: const OutlineInputBorder(), hintMaxLines: 3),
                  ),
                  if (found.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(l.noteFoundRefs, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in found)
                          ActionChip(
                            avatar: const Icon(Icons.add, size: 18),
                            label: Text(refLabel(r, lang)),
                            // En français, une référence de chapitre numéroté autrement passe
                            // par le dialogue (Bible imprimée ou application ?).
                            onPressed: () async {
                              if (numbering != null && numbering.fromPrinted(r) != null) {
                                await _addPassage(initial: refLabel(r, lang));
                              } else {
                                await _repo.addRef(widget.noteId, r);
                                if (context.mounted) context.toast(l.notePassageAdded);
                              }
                            },
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.cloud_done_outlined, size: 16, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(l.noteAutosave, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.light_mode_outlined, size: 16, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Flexible(child: Text(l.noteAwake, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant))),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

final _noteProvider = StreamProvider.autoDispose.family<SermonNote?, int>((ref, id) => ref.watch(notesRepoProvider).watch(id));

class _MetaField extends StatelessWidget {
  const _MetaField({required this.controller, required this.icon, required this.hint, required this.fieldKey});

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final String fieldKey;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, right: 12),
        child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      Expanded(
        child: TextField(
          key: ValueKey(fieldKey),
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            isDense: true,
          ),
        ),
      ),
    ],
  );
}

/// Les passages d'une note, à lire d'un trait (pendant ou après la prédication).
class _PassagesScreen extends StatelessWidget {
  const _PassagesScreen({required this.title, required this.refs});

  final String title;
  final List<VerseRef> refs;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          PassageSliver(
            refs: refs,
            onVerseTap: (v) => showVerseSheet(context, VerseRef.single(v.book, v.chapter, v.number)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    ),
  );
}
