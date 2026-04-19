import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/audio_processor_service.dart';
import '../../services/compression_service.dart';
import '../../services/encoding_service.dart';
import '../../services/payload_manager.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/hams_error.dart';
import '../../core/providers/common_providers.dart';

enum AudioEncodeStatus { idle, recording, processing, done, error }

class AudioEncodeState {
  final AudioEncodeStatus status;
  final int elapsedSeconds;
  final int estimatedChunks;
  final Uint8List? audioBytes;
  final List<String> chunks;
  final HamsError? error;
  final bool isAutoStopped;
  final double currentAmplitude; // New
  final int processingDurationMs; // New
  final int totalCharacters; // New

  AudioEncodeState({
    required this.status,
    this.elapsedSeconds = 0,
    this.estimatedChunks = 1,
    this.audioBytes,
    this.chunks = const [],
    this.error,
    this.isAutoStopped = false,
    this.currentAmplitude = -160.0,
    this.processingDurationMs = 0,
    this.totalCharacters = 0,
  });

  AudioEncodeState copyWith({
    AudioEncodeStatus? status,
    int? elapsedSeconds,
    int? estimatedChunks,
    Uint8List? audioBytes,
    List<String>? chunks,
    HamsError? error,
    bool? isAutoStopped,
    double? currentAmplitude,
    int? processingDurationMs,
    int? totalCharacters,
  }) {
    return AudioEncodeState(
      status: status ?? this.status,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      estimatedChunks: estimatedChunks ?? this.estimatedChunks,
      audioBytes: audioBytes ?? this.audioBytes,
      chunks: chunks ?? this.chunks,
      error: error ?? this.error,
      isAutoStopped: isAutoStopped ?? this.isAutoStopped,
      currentAmplitude: currentAmplitude ?? this.currentAmplitude,
      processingDurationMs: processingDurationMs ?? this.processingDurationMs,
      totalCharacters: totalCharacters ?? this.totalCharacters,
    );
  }
}

final audioProcessorProvider = Provider((ref) {
  final service = AudioProcessorService();
  ref.onDispose(() => service.dispose());
  return service;
});

final audioEncodeProvider = StateNotifierProvider<AudioEncodeNotifier, AudioEncodeState>((ref) {
  return AudioEncodeNotifier(
    ref.watch(audioProcessorProvider),
    ref.watch(compressionServiceProvider),
    ref.watch(encodingServiceProvider),
  );
});

class AudioEncodeNotifier extends StateNotifier<AudioEncodeState> {
  final AudioProcessorService _audioProcessor;
  final CompressionService _compressionService;
  final EncodingService _encodingService;

  Timer? _timer;
  StreamSubscription? _amplitudeSub; // New

  AudioEncodeNotifier(
    this._audioProcessor,
    this._compressionService,
    this._encodingService,
  ) : super(AudioEncodeState(status: AudioEncodeStatus.idle));

  bool _isInitInProgress = false;

  Future<void> startRecording() async {
    if (state.status == AudioEncodeStatus.recording || state.status == AudioEncodeStatus.processing || _isInitInProgress) return;
    
    _isInitInProgress = true;
    try {
      state = AudioEncodeState(status: AudioEncodeStatus.recording);
      await _audioProcessor.startRecording();
      
      // Listen to amplitude for visuals
      _amplitudeSub = _audioProcessor.onAmplitudeChanged.listen((amp) {
        state = state.copyWith(currentAmplitude: amp.current);
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final newElapsed = state.elapsedSeconds + 1;
        
        // Estimation formula: ceil((elapsedSeconds * 6000/8 * 1.25) / 4000)
        final int est = ((newElapsed * (AppConstants.audioBitRate / 8) * 1.25) / AppConstants.maxChunkSize).ceil();
        
        state = state.copyWith(
          elapsedSeconds: newElapsed,
          estimatedChunks: est > 0 ? est : 1,
        );

        if (newElapsed >= AppConstants.maxRecordingSeconds) {
          stopRecording(autoStop: true);
        }
      });
    } catch (e) {
      state = state.copyWith(status: AudioEncodeStatus.error, error: HamsError.encodingFailed);
    } finally {
      _isInitInProgress = false;
    }
  }

  Future<void> stopRecording({bool autoStop = false}) async {
    if (state.status != AudioEncodeStatus.recording) return;
    
    _timer?.cancel();
    _timer = null;
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    
    state = state.copyWith(status: AudioEncodeStatus.processing, isAutoStopped: autoStop);

    final sw = Stopwatch()..start();
    try {
      final bytes = await _audioProcessor.stopAndGetBytes();
      if (bytes == null) {
        state = state.copyWith(status: AudioEncodeStatus.error, error: HamsError.encodingFailed);
        return;
      }

      // Encode pipeline
      final compressed = _compressionService.zlibCompress(bytes);
      final encodedText = _encodingService.encodeBase64(compressed);
      final chunks = PayloadManager.splitPayload(encodedText, PayloadType.audio);

      sw.stop();
      state = state.copyWith(
        status: AudioEncodeStatus.done,
        audioBytes: bytes,
        chunks: chunks,
        processingDurationMs: sw.elapsedMilliseconds,
        totalCharacters: encodedText.length,
      );
    } catch (e) {
      state = state.copyWith(status: AudioEncodeStatus.error, error: HamsError.encodingFailed);
    }
  }

  Future<void> cancelRecording() async {
    _timer?.cancel();
    _timer = null;
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    await _audioProcessor.cancelRecording();
    state = AudioEncodeState(status: AudioEncodeStatus.idle);
  }

  void reset() {
    _timer?.cancel();
    _timer = null;
    _amplitudeSub?.cancel();
    _amplitudeSub = null;
    state = AudioEncodeState(status: AudioEncodeStatus.idle);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSub?.cancel();
    super.dispose();
  }
}
