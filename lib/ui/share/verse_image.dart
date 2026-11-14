import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../bible/bible.dart';
import '../../core/books.dart';
import '../../core/file_save.dart';
import '../../core/verse_ref.dart';
import '../../providers.dart';
import '../common.dart';

/// Texte d'un passage pour l'image : versets à la suite, coupé proprement
/// (« … ») au-delà de [maxChars]. Renvoie aussi s'il a fallu couper.
@visibleForTesting
(String, bool) verseImageText(List<Verse> verses, {int maxChars = 480}) {
  final full = verses.map((v) => v.text.trim()).join(' ');
  if (full.length <= maxChars) return (full, false);
  var cut = full.substring(0, maxChars);
  final space = cut.lastIndexOf(' ');
  if (space > maxChars * 0.6) cut = cut.substring(0, space);
  return ('${cut.replaceAll(RegExp(r'[\s,;:.!?]+$'), '')} …', true);
}

/// Taille du texte selon sa longueur : un verset court s'affiche en grand.
@visibleForTesting
double verseImageFontSize(int length) => switch (length) {
  <= 110 => 27,
  <= 200 => 23,
  <= 300 => 20,
  <= 400 => 17.5,
  _ => 15.5,
};

/// Image PNG (1080 × 1350) de la carte affichée sous [boundary].
Future<Uint8List> captureVerseCard(GlobalKey boundary) async {
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await render.toImage(pixelRatio: 1080 / VerseCard.width);
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('png');
    return data.buffer.asUint8List();
  } finally {
    image.dispose();
  }
}

/// Carte à partager (4:5, 360 × 450 points logiques ; rendue en 1080 × 1350).
class VerseCard extends StatelessWidget {
  const VerseCard({
    super.key,
    required this.text,
    required this.reference,
    this.title,
    this.light = false,
  });

  static const width = 360.0, height = 450.0;
  static const _navy = Color(0xFF1E3A5F), _navyDark = Color(0xFF142A47);
  static const _gold = Color(0xFFD4A72C),
      _cream = Color(0xFFFBF6EC),
      _creamDark = Color(0xFFF1E6CF);

  /// Or plus soutenu sur fond clair (contraste suffisant pour un texte).
  static const _goldOnLight = Color(0xFF755A0C);

  /// Fond crème et texte bleu nuit au lieu du fond bleu nuit.
  final bool light;

  final String text;

  /// « Psaumes 51:10 · LSG »
  final String reference;

  /// Titre de la note (facultatif), en haut de la carte.
  final String? title;

  @override
  Widget build(BuildContext context) {
    final size = verseImageFontSize(text.length);
    final background = light
        ? const [_cream, _creamDark]
        : const [_navy, _navyDark];
    final ink = light ? _navy : _cream;
    final accent = light ? _goldOnLight : _gold;
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: background,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null && title!.trim().isNotEmpty) ...[
                Text(
                  title!.trim().toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Container(width: 44, height: 3, color: _gold),
              const SizedBox(height: 18),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.lang == 'fr' ? '« $text »' : '“$text”',
                    maxLines: 14,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ink,
                      fontFamily: 'serif',
                      fontSize: size,
                      height: 1.42,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                reference,
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/branding/logo.png',
                      width: 22,
                      height: 22,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.appTitle,
                    style: TextStyle(
                      color: ink.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aperçu de l'image, choix du passage (s'il y en a plusieurs), partage.
class VerseImageScreen extends ConsumerStatefulWidget {
  const VerseImageScreen({super.key, required this.refs, this.title});

  final List<VerseRef> refs;
  final String? title;

  static Future<void> open(
    BuildContext context,
    List<VerseRef> refs, {
    String? title,
  }) => Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => VerseImageScreen(refs: refs, title: title),
    ),
  );

  @override
  ConsumerState<VerseImageScreen> createState() => _VerseImageScreenState();
}

class _VerseImageScreenState extends ConsumerState<VerseImageScreen> {
  final _boundary = GlobalKey();
  int _selected = 0;
  bool _busy = false;

  Future<void> _share(String filename) async {
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      await saveBytesFile(
        filename,
        await captureVerseCard(_boundary),
        mimeType: 'image/png',
      );
    } catch (_) {
      if (mounted) context.toast(l.shareImageFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final lang = context.lang;
    final t = Translation.forLang(lang);
    final bible = ref.watch(bibleProvider(t)).value;
    final verseRef = widget.refs[_selected.clamp(0, widget.refs.length - 1)];
    final (text, cut) = bible == null
        ? ('', false)
        : verseImageText(bible.passage(verseRef));
    final label = refLabel(verseRef, lang);
    final filename =
        'verset-${label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}.png';
    // Style retenu d'une fois sur l'autre.
    final light = ref.watch(
      settingsProvider.select((s) => s.value?.verseImageLight ?? false),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.shareImageTitle)),
      body: SafeArea(
        top: false,
        child: bible == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  if (widget.refs.length > 1) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final (i, r) in widget.refs.indexed)
                          ChoiceChip(
                            label: Text(refLabel(r, lang, abbreviated: true)),
                            selected: i == _selected,
                            onSelected: (_) => setState(() => _selected = i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Center(
                    child: SegmentedButton<bool>(
                      key: const ValueKey('image-style'),
                      segments: [
                        ButtonSegment(
                          value: false,
                          icon: const Icon(Icons.dark_mode_outlined),
                          label: Text(l.imageDark),
                        ),
                        ButtonSegment(
                          value: true,
                          icon: const Icon(Icons.light_mode_outlined),
                          label: Text(l.imageLight),
                        ),
                      ],
                      selected: {light},
                      onSelectionChanged: (v) => ref
                          .read(settingsRepoProvider)
                          .setVerseImageLight(v.first),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: AspectRatio(
                        aspectRatio: VerseCard.width / VerseCard.height,
                        // Ombre autour de l'aperçu seulement (hors de l'image) : la carte
                        // claire se détache ainsi du fond crème de l'écran.
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: FittedBox(
                            child: RepaintBoundary(
                              key: _boundary,
                              child: VerseCard(
                                text: text,
                                reference: '$label · ${t.shortName}',
                                title: widget.title,
                                light: light,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (cut) ...[
                    const SizedBox(height: 8),
                    Text(
                      l.shareImageLong,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const ValueKey('share-image'),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.image_outlined),
                    label: Text(l.shareImageAction),
                    onPressed: _busy ? null : () => _share(filename),
                  ),
                ],
              ),
      ),
    );
  }
}
