import 'dart:io' show gzip;
import 'dart:typed_data';

List<int> gunzip(Uint8List bytes) => gzip.decode(bytes);
