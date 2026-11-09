/// Décompression gzip : `dart:io` sur téléphone (zlib natif, rapide),
/// `package:archive` dans un navigateur, où `dart:io` n'existe pas.
library;

export 'gunzip_io.dart' if (dart.library.js_interop) 'gunzip_web.dart';
