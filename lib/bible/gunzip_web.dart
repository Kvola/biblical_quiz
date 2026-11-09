import 'dart:typed_data';

import 'package:archive/archive.dart' show GZipDecoder;

List<int> gunzip(Uint8List bytes) => GZipDecoder().decodeBytes(bytes);
