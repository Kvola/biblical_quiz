import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/books.dart';
import '../../core/verse_ref.dart';
import '../../providers.dart';
import '../common.dart';
import 'note_screen.dart';

/// « Ajouter à une note » (depuis un verset) : une nouvelle note, ou l'une des
/// notes récentes. Confirme par un message avec « Ouvrir ».
Future<void> addVerseToNote(BuildContext context, WidgetRef ref, VerseRef verse) async {
  final l = context.l10n;
  final lang = context.lang;
  final notes = [for (final n in await ref.read(notesRepoProvider).all()) if (!n.isBlank) n]
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  if (!context.mounted) return;
  final choice = await showModalBottomSheet<int>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.7),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(l.addToNoteTitle(refLabel(verse, lang)), style: Theme.of(ctx).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: Text(l.notesNew),
              onTap: () => Navigator.of(ctx).pop(-1),
            ),
            for (final n in notes.take(8))
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: Text(n.title.trim().isEmpty ? l.noteUntitled : n.title.trim(), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(MaterialLocalizations.of(ctx).formatMediumDate(n.date)),
                onTap: () => Navigator.of(ctx).pop(n.id),
              ),
          ],
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  if (choice == -1) {
    await NoteScreen.openNew(context, ref, passage: verse);
    return;
  }
  final note = notes.firstWhere((n) => n.id == choice);
  final title = note.title.trim().isEmpty ? l.noteUntitled : note.title.trim();
  final added = await ref.read(notesRepoProvider).addRef(choice, verse);
  if (!context.mounted) return;
  context.toast(
    added ? l.addedToNote(title) : l.alreadyInNote(title),
    action: SnackBarAction(label: l.open, onPressed: () => NoteScreen.open(context, choice)),
  );
}
