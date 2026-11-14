import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../bible/printed_numbering.dart';
import '../../core/books.dart';
import '../../core/theme.dart';
import '../../core/verse_ref.dart';
import '../../domain/ref_finder.dart';
import '../../providers.dart';
import '../common.dart';

/// Demande un passage (« Jean 3:16-18 », « Ps 23 »…) et le renvoie dans la
/// numérotation de l'application, ou null si la personne annule.
///
/// En français, quand une Segond imprimée numérote ces versets autrement
/// (titres des Psaumes, Jonas 2…), la personne choisit d'où viennent ses
/// numéros : de sa Bible imprimée (choix par défaut : c'est ce qu'on lit à
/// l'église) ou de l'application. Le texte de chaque possibilité est montré.
Future<VerseRef?> showAddPassageDialog(BuildContext context, {String initial = ''}) =>
    showDialog<VerseRef>(context: context, builder: (_) => _AddPassageDialog(initial: initial));

class _AddPassageDialog extends ConsumerStatefulWidget {
  const _AddPassageDialog({required this.initial});

  final String initial;

  @override
  ConsumerState<_AddPassageDialog> createState() => _AddPassageDialogState();
}

class _AddPassageDialogState extends ConsumerState<_AddPassageDialog> {
  late final _controller = TextEditingController(text: widget.initial);
  bool _printed = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// (référence telle que tapée, même référence lue comme numéros imprimés si différente)
  (VerseRef?, VerseRef?) _parse(Bible bible, PrintedNumbering numbering, String lang) {
    final typed = RefFinder(bible).parse(_controller.text);
    if (typed == null || lang != 'fr') return (typed, null);
    return (typed, numbering.fromPrinted(typed));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final bible = ref.watch(bibleProvider(Translation.forLang(lang))).value;
    final numbering = ref.watch(printedNumberingProvider).value ?? PrintedNumbering.empty;
    final (typed, fromPrinted) = bible == null ? (null, null) : _parse(bible, numbering, lang);
    final result = fromPrinted != null && _printed ? fromPrinted : typed;
    final text = _controller.text.trim();

    Widget preview(VerseRef r) {
      final verses = bible!.passage(r);
      final first = verses.isEmpty ? '' : verses.first.text;
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${refLabel(r, lang)}\n', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: verses.length > 1 ? '$first …' : first, style: scriptureStyle(context, 0.85)),
          ],
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      );
    }

    return AlertDialog(
      title: Text(l.noteAddPassage),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l.addPassageHint,
              errorText: text.isNotEmpty && typed == null && bible != null ? l.addPassageInvalid : null,
              errorMaxLines: 3,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {
              if (result != null) Navigator.of(context).pop(result);
            },
          ),
          const SizedBox(height: 12),
          if (typed != null && fromPrinted != null) ...[
            Text(l.addPassageNumbering, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            RadioGroup<bool>(
              groupValue: _printed,
              onChanged: (v) => setState(() => _printed = v ?? true),
              child: Column(
                children: [
                  for (final (value, label, r) in [(true, l.addPassagePrinted, fromPrinted), (false, l.addPassageApp, typed)])
                    RadioListTile<bool>(
                      value: value,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: preview(r),
                    ),
                ],
              ),
            ),
          ] else if (typed != null)
            preview(typed),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.cancel)),
        FilledButton(
          onPressed: result == null ? null : () => Navigator.of(context).pop(result),
          child: Text(l.addPassageAdd),
        ),
      ],
    );
  }
}
