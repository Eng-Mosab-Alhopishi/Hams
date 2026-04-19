import 'dart:io';
import 'dart:typed_data';

class CompressionService {
  /// Compresses [data] using Zlib level 9 (maximum compression).
  Uint8List zlibCompress(Uint8List data) {
    return Uint8List.fromList(ZLibCodec(level: 9).encode(data));
  }

  /// Decompresses [data] using Zlib.
  Uint8List zlibDecompress(Uint8List data) {
    return Uint8List.fromList(zlib.decode(data));
  }
}
