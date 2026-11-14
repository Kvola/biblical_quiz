import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Navigateur : téléchargement direct du fichier.
Future<bool> saveBytesFile(String name, Uint8List bytes, {required String mimeType, String? subject, String? text}) async {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  try {
    final a = web.HTMLAnchorElement()
      ..href = url
      ..download = name;
    web.document.body?.append(a);
    a.click();
    a.remove();
  } finally {
    // Laisser au navigateur le temps de lancer le téléchargement.
    Future<void>.delayed(const Duration(seconds: 5), () => web.URL.revokeObjectURL(url));
  }
  return true;
}

Future<bool> saveTextFile(String name, String content, {String mimeType = 'application/json', String? subject}) =>
    saveBytesFile(name, utf8.encode(content), mimeType: mimeType, subject: subject);
