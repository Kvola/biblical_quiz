import 'dart:convert';

import 'package:share_plus/share_plus.dart';

/// Propose le fichier à la feuille de partage du téléphone. Vrai si la
/// personne a choisi une destination (faux si elle a fermé la feuille).
Future<bool> saveTextFile(String name, String content, {String mimeType = 'application/json', String? subject}) async {
  final result = await SharePlus.instance.share(
    ShareParams(
      files: [XFile.fromData(utf8.encode(content), mimeType: mimeType, name: name)],
      fileNameOverrides: [name],
      subject: subject,
    ),
  );
  return result.status != ShareResultStatus.dismissed;
}
