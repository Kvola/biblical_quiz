import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../common.dart';
import 'online_links.dart';

/// Ce qu'un QR code de partie contient : un code à rejoindre ou à regarder (projection).
typedef GameScan = ({String? join, String? watch});

/// Lit le contenu d'un QR code : lien d'invitation du serveur, lien de
/// l'application (`quizbiblique://join/…`), lien web (`?join=` / `?watch=`) ou
/// code seul (6 caractères). Null si ce n'est pas un QR code de partie.
GameScan? parseScannedGame(String raw) {
  final text = raw.trim();
  if (RegExp(r'^[A-Za-z0-9]{6}$').hasMatch(text)) return (join: text.toUpperCase(), watch: null);
  final uri = Uri.tryParse(text);
  if (uri == null || !const {'http', 'https', 'quizbiblique'}.contains(uri.scheme)) return null;
  final link = parseGameLink(uri);
  if (link.join == null && link.watch == null) return null;
  return link;
}

/// Ouvre la caméra et rend la partie lue (null si l'utilisateur ferme).
typedef GameScanner = Future<GameScan?> Function(BuildContext context);

/// Remplacé dans les tests (pas de caméra).
final gameScannerProvider = Provider<GameScanner>((ref) => scanGameQr);

Future<GameScan?> scanGameQr(BuildContext context) =>
    Navigator.of(context).push<GameScan>(MaterialPageRoute(fullscreenDialog: true, builder: (_) => const ScanScreen()));

/// Lecture du QR code affiché par la salle d'attente d'un match ou d'un tournoi.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  bool _done = false;
  bool _wrongCode = false;
  Timer? _wrongTimer;

  @override
  void dispose() {
    _wrongTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _finish(GameScan scan) {
    if (_done || !mounted) return;
    _done = true;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(scan);
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final scan = parseScannedGame(b.rawValue ?? '');
      if (scan != null) return _finish(scan);
    }
    // Un autre QR code (site, Wi-Fi…) : on le dit, et on continue de chercher.
    if (capture.barcodes.isNotEmpty) {
      _wrongTimer?.cancel();
      setState(() => _wrongCode = true);
      _wrongTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _wrongCode = false);
      });
    }
  }

  /// Un QR code reçu en image (capture d'écran envoyée sur WhatsApp, photo) :
  /// lu dans le fichier, sans caméra.
  Future<void> _fromImage() async {
    final l = context.l10n;
    await _controller.stop();
    String? path;
    try {
      path = (await FilePicker.pickFile(type: FileType.image))?.path;
    } catch (_) {
      path = null;
    }
    if (!mounted) return;
    if (path != null) {
      BarcodeCapture? capture;
      try {
        capture = await _controller.analyzeImage(path, formats: const [BarcodeFormat.qrCode]);
      } catch (_) {
        capture = null;
      }
      if (!mounted) return;
      for (final b in capture?.barcodes ?? const <Barcode>[]) {
        final scan = parseScannedGame(b.rawValue ?? '');
        if (scan != null) return _finish(scan);
      }
      context.toast(l.scanNoQrInImage);
    }
    try {
      await _controller.start();
    } catch (_) {}
  }

  /// Après un premier refus, Android redemande l'autorisation : on relance la caméra.
  Future<void> _retry() async {
    try {
      await _controller.stop();
      await _controller.start();
    } catch (_) {
      // L'écran d'erreur reste affiché ; la saisie du code reste possible.
    }
  }

  Future<void> _type() async {
    await _controller.stop();
    if (!mounted) return;
    final code = await askGameCode(context, context.l10n.onlineJoinTitle, allowScan: false);
    if (code != null && code.length == 6) return _finish((join: code, watch: null));
    if (mounted) await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(l.scanQr),
        actions: [
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, state, _) => state.torchState == TorchState.unavailable
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: l.scanTorch,
                    icon: Icon(state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off),
                    onPressed: _controller.toggleTorch,
                  ),
          ),
          // Pas de lecture d'image dans le navigateur (non prise en charge par le lecteur).
          if (!kIsWeb)
            IconButton(tooltip: l.scanFromImage, icon: const Icon(Icons.image_outlined), onPressed: _fromImage),
          IconButton(tooltip: l.scanTypeCode, icon: const Icon(Icons.keyboard), onPressed: _type),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) =>
                _CameraError(error: error, onType: _type, onRetry: _retry, onImage: kIsWeb ? null : _fromImage),
          ),
          // Cadre et consignes : seulement quand la caméra fonctionne (sinon l'écran d'erreur les remplace).
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, state, _) => state.error != null
                ? const SizedBox.shrink()
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              border: Border.all(color: _wrongCode ? Colors.orangeAccent : Colors.white, width: 3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 32,
                        child: SafeArea(
                          top: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_wrongCode)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    l.scanNotAGame,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              Text(
                                l.scanHint,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white),
                                ),
                                onPressed: _type,
                                icon: const Icon(Icons.keyboard),
                                label: Text(l.scanTypeCode),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error, required this.onType, required this.onRetry, this.onImage});

  final MobileScannerException error;
  final VoidCallback onType;
  final VoidCallback onRetry;
  final VoidCallback? onImage;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                denied ? l.scanCameraDenied : l.scanCameraUnavailable,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onType, icon: const Icon(Icons.keyboard), label: Text(l.scanTypeCode)),
              if (onImage != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  onPressed: onImage,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(l.scanFromImage),
                ),
              ],
              const SizedBox(height: 8),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Demande un code de partie (6 caractères), avec, si [allowScan], un bouton
/// pour le scanner. Rend le code en majuscules, ou null si annulé.
///
/// Le champ appartient à la boîte de dialogue : il n'est libéré qu'après sa
/// disparition complète.
Future<String?> askGameCode(BuildContext context, String title, {bool allowScan = true, String? action}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _CodeDialog(title: title, allowScan: allowScan, action: action),
    );

class _CodeDialog extends ConsumerStatefulWidget {
  const _CodeDialog({required this.title, required this.allowScan, this.action});

  final String title;
  final bool allowScan;
  final String? action;

  @override
  ConsumerState<_CodeDialog> createState() => _CodeDialogState();
}

class _CodeDialogState extends ConsumerState<_CodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim().toUpperCase();
    if (code.length == 6) Navigator.pop(context, code);
  }

  Future<void> _scan() async {
    final scan = await ref.read(gameScannerProvider)(context);
    final code = scan?.join ?? scan?.watch;
    if (code != null && mounted) Navigator.pop(context, code);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: !widget.allowScan,
            maxLength: 6,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
            style: const TextStyle(fontSize: 24, letterSpacing: 4, fontWeight: FontWeight.w700),
            decoration: InputDecoration(hintText: l.onlineJoinHint),
            onSubmitted: (_) => _submit(),
          ),
          if (widget.allowScan) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l.scanQr),
                onPressed: _scan,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        FilledButton(onPressed: _submit, child: Text(widget.action ?? l.onlineJoin)),
      ],
    );
  }
}
