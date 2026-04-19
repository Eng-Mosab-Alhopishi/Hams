import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../core/constants/app_constants.dart';

class AudioProcessorService {
  final _recorder = AudioRecorder();

  /// Start recording voice message to a temporary .ogg file.
  Future<void> startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission not granted');
    }

    final dir = await getTemporaryDirectory();
    final String path = '${dir.path}/hams_audio.ogg';
    
    // Cleanup old recording if exists
    final oldFile = File(path);
    if (await oldFile.exists()) {
      try {
        await oldFile.delete();
      } catch (_) {}
    }

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.opus,
        bitRate: AppConstants.audioBitRate,
        sampleRate: AppConstants.audioSampleRate,
        numChannels: AppConstants.audioChannels,
      ),
      path: path,
    );
  }

  /// Get real-time amplitude for visual feedback.
  Stream<Amplitude> get onAmplitudeChanged => _recorder.onAmplitudeChanged(const Duration(milliseconds: 100));

  Future<bool> isRecording() => _recorder.isRecording();

  /// Stop recording and return the bytes of the .ogg file.
  Future<Uint8List?> stopAndGetBytes() async {
    final path = await _recorder.stop();
    if (path == null) return null;

    // Small delay to ensure file is flushed and closed
    await Future.delayed(const Duration(milliseconds: 200));

    final file = File(path);
    if (!await file.exists()) return null;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return null;
    
    return bytes;
  }

  /// Cancel and cleanup.
  Future<void> cancelRecording() async {
    await _recorder.stop();
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
