import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/books.dart';
import '../../core/file_save.dart';
import '../../data/notes_repository.dart';
import '../../domain/search.dart' show normalize;
import '../common.dart';
import '../../providers.dart';
import 'note_screen.dart';

/// Onglet « Notes » : les notes de prédication, la plus récente d'abord.
class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Une note correspond si chaque mot cherché se trouve dans son titre, son
  /// prédicateur, son lieu, ses notes ou ses passages (accents et casse ignorés).
  static bool matches(SermonNote n, String query) {
    final words = normalize(query).split(' ').where((w) => w.isNotEmpty);
    if (words.isEmpty) return true;
    final hay = normalize(
      [n.title, n.preacher, n.place, n.body, for (final r in n.refs) ...[refLabel(r, 'fr'), refLabel(r, 'en')]].join(' '),
    );
    return words.every(hay.contains);
  }

  Future<void> _backup() async {
    final l = context.l10n;
    final repo = ref.read(notesRepoProvider);
    if ((await repo.all()).isEmpty) {
      if (mounted) context.toast(l.notesBackupEmpty);
      return;
    }
    final json = await repo.exportJson();
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    await saveTextFile('notes-quiz-biblique-${now.year}-${two(now.month)}-${two(now.day)}.json', json, subject: l.notesTitle);
  }

  Future<void> _restore() async {
    final l = context.l10n;
    // Tout type de fichier : selon les applications d'origine (Drive, WhatsApp…),
    // un .json n'est pas toujours annoncé comme tel. Le contenu est vérifié.
    final PlatformFile? file;
    try {
      file = await FilePicker.pickFile(type: FileType.any);
    } catch (_) {
      if (mounted) context.toast(l.notesRestoreError);
      return;
    }
    if (file == null) return;
    String content;
    try {
      content = await file.xFile.readAsString();
    } catch (_) {
      if (mounted) context.toast(l.notesRestoreError);
      return;
    }
    try {
      final res = await ref.read(notesRepoProvider).importJson(content);
      if (!mounted) return;
      final summary = [l.notesRestoreAdded(res.added), l.notesRestoreUpdated(res.updated)].join(', ');
      context.toast(l.notesRestoreDone(summary));
    } on FormatException catch (e) {
      if (mounted) context.toast(e.message == 'newer-version' ? l.notesRestoreNewer : l.notesRestoreInvalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final notes = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.notesTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) => v == 'backup' ? _backup() : _restore(),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'backup',
                child: ListTile(leading: const Icon(Icons.save_alt), title: Text(l.notesBackup), contentPadding: EdgeInsets.zero),
              ),
              PopupMenuItem(
                value: 'restore',
                child: ListTile(leading: const Icon(Icons.restore), title: Text(l.notesRestore), contentPadding: EdgeInsets.zero),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new-note',
        icon: const Icon(Icons.edit_note),
        label: Text(l.notesNew),
        onPressed: () => NoteScreen.openNew(context, ref),
      ),
      body: SafeArea(
        top: false,
        child: AsyncBody(
          value: notes,
          onRetry: () => ref.invalidate(notesProvider),
          builder: (all) {
            // Une note quittée sans rien écrire est supprimée en sortant ; si
            // l'application a été fermée entre-temps, on ne la montre pas.
            final visible = [for (final n in all) if (!n.isBlank) n];
            if (visible.isEmpty) return const _Empty();
            final shown = [for (final n in visible) if (matches(n, _search.text)) n];
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
              children: [
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: l.notesSearch,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l.close,
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(_search.clear),
                          ),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                if (shown.isEmpty)
                  Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(l.notesNoMatch))),
                for (final n in shown) _NoteCard(note: n),
                const SizedBox(height: 8),
                Text(l.notesBackupHint, style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final SermonNote note;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final meta = [
      MaterialLocalizations.of(context).formatMediumDate(note.date),
      note.preacher.trim(),
      note.place.trim(),
    ].where((s) => s.isNotEmpty).join(' · ');
    final body = note.body.trim().replaceAll(RegExp(r'\s+'), ' ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => NoteScreen.open(context, note.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.trim().isEmpty ? l.noteUntitled : note.title.trim(),
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(meta, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                if (note.refs.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    note.refs.map((r) => refLabel(r, lang, abbreviated: true)).join(' · '),
                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 96),
      children: [
        Icon(Icons.edit_note, size: 64, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 16),
        Text(l.notesEmptyTitle, textAlign: TextAlign.center, style: text.titleLarge),
        const SizedBox(height: 8),
        Text(l.notesEmptyBody, textAlign: TextAlign.center, style: text.bodyLarge),
      ],
    );
  }
}
