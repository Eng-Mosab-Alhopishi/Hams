import 'dart:async';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';

enum AppClipboardStatus { empty, invalid, valid }

class ClipboardService {
  Timer? _timer;
  final _chunkDetectedController = StreamController<String>.broadcast();
  final Set<String> _processedStrings = {};

  Stream<String> get onChunkDetected => _chunkDetectedController.stream;

  /// Starts polling the clipboard for GhostDrop chunks.
  void startWatching() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConstants.clipboardPollInterval, (_) => _checkClipboard());
  }

  /// Stops polling the clipboard.
  void stopWatching() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkClipboard() async {
    await checkManual();
  }

  /// Manually checks the clipboard and returns the status.
  Future<AppClipboardStatus> checkManual() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data == null || data.text == null || data.text!.trim().isEmpty) {
      return AppClipboardStatus.empty;
    }

    final String text = data.text!.trim();
    
    // Check if this specific string was already processed
    if (_processedStrings.contains(text)) {
      return AppClipboardStatus.invalid; // Already processed
    }

    // Checking if there is ANY part of a ghostdrop string in the current lines
    final lines = text.split(RegExp(r'\r?\n'));
    bool foundValid = false;

    for (var line in lines) {
      if (AppConstants.chunkRegExp.hasMatch(line)) {
        foundValid = true;
        break;
      }
    }
    
    if (foundValid) {
      _processedStrings.add(text);
      HapticFeedback.mediumImpact();
      _chunkDetectedController.add(text);
      return AppClipboardStatus.valid;
    }

    return AppClipboardStatus.invalid;
  }

  void dispose() {
    stopWatching();
    _chunkDetectedController.close();
  }

  /// Clears the memory of processed strings so they can be processed again
  void clearProcessed() {
    _processedStrings.clear();
  }
}
