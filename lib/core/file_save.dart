/// Enregistrer un fichier produit par l'application (sauvegarde des notes) :
/// feuille de partage sur téléphone (Drive, e-mail, WhatsApp, Fichiers…),
/// téléchargement dans le navigateur.
library;

export 'file_save_io.dart' if (dart.library.js_interop) 'file_save_web.dart';
