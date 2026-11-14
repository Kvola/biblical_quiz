import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre WhatsApp avec [text] prêt à envoyer (la personne choisit le contact
/// ou le groupe). Application WhatsApp d'abord, sinon wa.me (WhatsApp Web
/// dans le navigateur). Faux si rien n'a pu s'ouvrir : l'appelant propose
/// alors le partage habituel.
Future<bool> openWhatsApp(String text) async {
  final encoded = Uri.encodeComponent(text);
  final candidates = [
    if (!kIsWeb) Uri.parse('whatsapp://send?text=$encoded'),
    Uri.parse('https://wa.me/?text=$encoded'),
  ];
  for (final uri in candidates) {
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
    } catch (_) {
      // Pas d'application pour ce lien : essayer le suivant.
    }
  }
  return false;
}
