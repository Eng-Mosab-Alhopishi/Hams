import 'dart:typed_data';
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/image_processor_service.dart';
import '../../services/compression_service.dart';
import '../../services/encoding_service.dart';
import '../../services/payload_manager.dart';

import '../../core/errors/hams_error.dart';
import '../../core/providers/common_providers.dart';
import '../settings/settings_provider.dart';

enum EncodeStatus { idle, picking, processing, done, error }

class EncodeState {
  final EncodeStatus status;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final Uint8List? processedData;
  final List<String> chunks;
  final HamsError? error;
  final double progress; // 0.0 to 1.0
  final int encodingDurationMs; // New
  final int totalCharacters; // New

  EncodeState({
    required this.status,
    this.originalSize = 0,
    this.compressedSize = 0,
    this.compressionRatio = 0.0,
    this.processedData,
    this.chunks = const [],
    this.error,
    this.progress = 0.0,
    this.encodingDurationMs = 0,
    this.totalCharacters = 0,
  });

  EncodeState copyWith({
    EncodeStatus? status,
    int? originalSize,
    int? compressedSize,
    double? compressionRatio,
    Uint8List? processedData,
    List<String>? chunks,
    HamsError? error,
    double? progress,
    int? encodingDurationMs,
    int? totalCharacters,
  }) {
    return EncodeState(
      status: status ?? this.status,
      originalSize: originalSize ?? this.originalSize,
      compressedSize: compressedSize ?? this.compressedSize,
      compressionRatio: compressionRatio ?? this.compressionRatio,
      processedData: processedData ?? this.processedData,
      chunks: chunks ?? this.chunks,
      error: error ?? this.error,
      progress: progress ?? this.progress,
      encodingDurationMs: encodingDurationMs ?? this.encodingDurationMs,
      totalCharacters: totalCharacters ?? this.totalCharacters,
    );
  }
}

final imageProcessorProvider = Provider((ref) => ImageProcessorService());

final encodeProvider = StateNotifierProvider<EncodeNotifier, EncodeState>((ref) {
  return EncodeNotifier(
    ref,
    ref.watch(imageProcessorProvider),
    ref.watch(compressionServiceProvider),
    ref.watch(encodingServiceProvider),
  );
});

class EncodeNotifier extends StateNotifier<EncodeState> {
  final Ref _ref;
  final ImageProcessorService _imageProcessor;
  final CompressionService _compressionService;
  final EncodingService _encodingService;

  EncodeNotifier(this._ref, this._imageProcessor, this._compressionService, this._encodingService)
      : super(EncodeState(status: EncodeStatus.idle));

  Future<void> processImage() async {
    state = state.copyWith(status: EncodeStatus.picking, error: null, progress: 0.0);

    final sw = Stopwatch()..start();
    try {
      final originalBytes = await _imageProcessor.pickImage();
      if (originalBytes == null) {
        state = state.copyWith(status: EncodeStatus.idle);
        return;
      }

      // Check max size (Requirement: original > 5MB -> imageTooLarge)
      if (originalBytes.length > 5 * 1024 * 1024) {
        state = state.copyWith(status: EncodeStatus.error, error: HamsError.imageTooLarge);
        return;
      }

      state = state.copyWith(
        status: EncodeStatus.processing,
        originalSize: originalBytes.length,
        progress: 0.1,
      );

      // 1. Isolate prep (Decode, Resize, Quantize) without blocking UI!
      const targetPayloadBytes = 14900; 
      
      final settings = _ref.read(settingsProvider);
      
      final stableBytes = await _imageProcessor.prepareImageBackground(
        originalBytes, 
        dim: settings.maxDimension,
      );
      if (stableBytes == null) {
        state = state.copyWith(status: EncodeStatus.error, error: HamsError.invalidPayload);
        return;
      }
      state = state.copyWith(progress: 0.5);

      // 2. Binary Search WebP (Fast native thread)
      final webpBytes = await _imageProcessor.compressWithBinarySearch(
        stableBytes, 
        targetPayloadBytes,
        userMaxQuality: settings.webpQuality,
      );
      state = state.copyWith(progress: 0.7);

      // 6. Zlib Compress
      final compressedBytes = _compressionService.zlibCompress(webpBytes);
      state = state.copyWith(progress: 0.9);

      // 7. Base64 Encode (Changed from Base85 for WhatsApp stability)
      final encodedText = _encodingService.encodeBase64(compressedBytes);
      
      // 8. Chunking
      final chunks = PayloadManager.splitPayload(encodedText, PayloadType.image);

      final ratio = (1.0 - (encodedText.length / originalBytes.length)) * 100;

      sw.stop();
      state = state.copyWith(
        status: EncodeStatus.done,
        compressedSize: encodedText.length,
        compressionRatio: ratio,
        processedData: compressedBytes,
        chunks: chunks,
        progress: 1.0,
        encodingDurationMs: sw.elapsedMilliseconds,
        totalCharacters: encodedText.length,
      );
    } catch (e, stack) {
      dev.log('Hams Process Failure: $e');
      dev.log(stack.toString());
      state = state.copyWith(
        status: EncodeStatus.error,
        error: HamsError.encodingFailed,
      );
    }
  }

  void reset() {
    state = EncodeState(status: EncodeStatus.idle);
  }
}
