import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

/// Propose le fichier à la feuille de partage du téléphone (Drive, WhatsApp,
/// e-mail…). Vrai si la personne a choisi une destination (faux si elle a fermé la feuille).
Future<bool> saveBytesFile(String name, Uint8List bytes, {required String mimeType, String? subject, String? text}) async {
  final result = await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(bytes, mimeType: mimeType, name: name)],
      fileNameOverrides: [name],
      subject: subject,
      text: text,
    ),
  );
  return result.status != ShareResultStatus.dismissed;
}

Future<bool> saveTextFile(String name, String content, {String mimeType = 'application/json', String? subject}) =>
    saveBytesFile(name, utf8.encode(content), mimeType: mimeType, subject: subject);
