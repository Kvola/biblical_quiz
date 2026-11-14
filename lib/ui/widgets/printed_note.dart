import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/books.dart';
import '../../core/verse_ref.dart';
import '../../providers.dart';
import '../common.dart';

/// « Segond imprimée : Psaume 19:8-15 », quand une Segond imprimée numérote
/// la référence autrement que l'application. Rien en anglais (la King James
/// est la numérotation de l'application) ni quand les numéros sont les mêmes.
/// Toucher la mention explique pourquoi.
class PrintedRefNote extends ConsumerWidget {
  const PrintedRefNote(this.verseRef, {super.key, this.padding = EdgeInsets.zero, this.abbreviated = false});

  final VerseRef verseRef;
  final EdgeInsetsGeometry padding;
  final bool abbreviated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = printedLabel(context, ref, verseRef, abbreviated: abbreviated);
    if (label == null) return const SizedBox.shrink();
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant);
    return Padding(
      padding: padding,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => showPrintedNumberingHelp(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 14, color: style?.color),
              const SizedBox(width: 4),
              Flexible(child: Text(context.l10n.printedRef(label), style: style)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Libellé de la référence dans une Segond imprimée, ou null (anglais, numéros identiques,
/// table pas encore chargée).
String? printedLabel(BuildContext context, WidgetRef ref, VerseRef verseRef, {bool abbreviated = false}) {
  if (context.lang != 'fr') return null;
  final printed = ref.watch(printedNumberingProvider).value?.printed(verseRef);
  return printed == null ? null : refLabel(printed, 'fr', abbreviated: abbreviated);
}

Future<void> showPrintedNumberingHelp(BuildContext context) {
  final l = context.l10n;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.printedNoteTitle),
      content: SingleChildScrollView(child: Text(l.printedNoteBody)),
      actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l.close))],
    ),
  );
}
