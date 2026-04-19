import 'dart:typed_data';
import 'dart:math' as math;
import '../core/constants/app_constants.dart';
import 'encoding_service.dart';
import 'compression_service.dart';

enum PayloadState { incomplete, complete, duplicate, invalid }

enum PayloadType { image, audio }

class ReassembledPayload {
  final Uint8List bytes;
  final PayloadType type;
  const ReassembledPayload(this.bytes, this.type);
}

class ChunkData {
  final PayloadType type;
  final String? id;
  final int current;
  final int total;
  final String payload;
  
  ChunkData(this.type, this.id, this.current, this.total, this.payload);
}


class PayloadManager {
  final Map<int, String> _chunks = {};
  
  final int totalChunks;
  final PayloadType type;
  final String? payloadId; // Optional Mini-ID to prevent collisions

  PayloadManager({
    required this.totalChunks,
    required this.type,
    this.payloadId,
  });

  final EncodingService _encodingService = EncodingService();
  final CompressionService _compressionService = CompressionService();

  static String generateMiniId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rnd = math.Random();
    return String.fromCharCodes(Iterable.generate(
      3, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  /// Splits [encodedText] into WhatsApp-safe chunks.
  static List<String> splitPayload(String encodedText, PayloadType type) {
    final String header = type == PayloadType.image ? AppConstants.imageHeader : AppConstants.audioHeader;
    final String miniId = generateMiniId();
    
    if (encodedText.length <= AppConstants.maxChunkSize) {
      return ['[$header:$miniId:1/1]$encodedText'];
    }

    final List<String> chunks = [];
    final int total = (encodedText.length / AppConstants.maxChunkSize).ceil();
    
    // Determine padding based on whether total is >= 10
    final bool usePadding = total >= 10;

    for (int i = 0; i < total; i++) {
      final int start = i * AppConstants.maxChunkSize;
      final int end = (i + 1) * AppConstants.maxChunkSize;
      final String payload = encodedText.substring(
        start, 
        end > encodedText.length ? encodedText.length : end
      );
      
      final String currentStr = usePadding ? (i + 1).toString().padLeft(2, '0') : (i + 1).toString();
      final String totalStr = total.toString();
      
      chunks.add('[$header:$miniId:$currentStr/$totalStr]$payload');
    }

    return chunks;
  }

  /// Checks if this manager can accept the provided chunk.
  bool canAccept(ChunkData data) {
    if (type != data.type) return false;
    if (totalChunks != data.total) return false;
    if (payloadId != data.id) return false;
    return true;
  }

  /// Attempts to add a chunk. Use canAccept() before calling this.
  PayloadState addChunk(int current, String payload) {
    if (_chunks.containsKey(current)) {
      return PayloadState.duplicate;
    }

    _chunks[current] = payload;

    return _chunks.length == totalChunks ? PayloadState.complete : PayloadState.incomplete;
  }

  /// Reassembles the payload into original bytes and type.
  ReassembledPayload? reassemble() {
    if (_chunks.length != totalChunks || totalChunks == 0) return null;

    final buffer = StringBuffer();
    for (int i = 1; i <= totalChunks; i++) {
      buffer.write(_chunks[i]);
    }

    final String fullText = buffer.toString();
    final Uint8List compressedBytes = _encodingService.decodeBase64(fullText);
    final Uint8List decompressed = _compressionService.zlibDecompress(compressedBytes);
    
    return ReassembledPayload(decompressed, type);
  }

  void reset() {
    _chunks.clear();
  }

  int get receivedCount => _chunks.length;
}
