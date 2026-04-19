import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/payload_manager.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/hams_error.dart';

class DecodeState {
  final List<PayloadManager> payloads;

  DecodeState({required this.payloads});

  DecodeState copyWith({List<PayloadManager>? payloads}) {
    return DecodeState(payloads: payloads ?? this.payloads);
  }
}

final decodeProvider = StateNotifierProvider<DecodeNotifier, DecodeState>((ref) {
  return DecodeNotifier();
});

class DecodeNotifier extends StateNotifier<DecodeState> {
  DecodeNotifier() : super(DecodeState(payloads: []));

  void addChunk(String text) {
    if (text.trim().isEmpty) return;

    final lines = text.split(RegExp(r'\r?\n'));
    bool changed = false;

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final match = AppConstants.chunkRegExp.firstMatch(line);
      if (match != null) {
        final String typeStr = match.group(1)!;
        final String? idStr = match.group(2); // Optional Mini-ID
        final int current = int.parse(match.group(3)!);
        final int total = int.parse(match.group(4)!);
        
        final PayloadType incomingType = typeStr == AppConstants.audioHeader 
            ? PayloadType.audio 
            : PayloadType.image;

        final rawSub = line.substring(match.end);
        final cleanBase64 = rawSub.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '');

        final chunkData = ChunkData(incomingType, idStr, current, total, cleanBase64);

        // 1. Try to find an existing PayloadManager that accepts this chunk
        PayloadManager? targetManager;
        for (var pm in state.payloads) {
          if (pm.canAccept(chunkData)) {
            targetManager = pm;
            break;
          }
        }

        // 2. If no manager accepts it and we don't already have it, create a new one
        if (targetManager == null) {
          targetManager = PayloadManager(totalChunks: total, type: incomingType, payloadId: idStr);
          state.payloads.insert(0, targetManager); // Insert at top (newest first)
        }

        // 3. Add chunk to the manager
        final result = targetManager.addChunk(current, cleanBase64);
        if (result != PayloadState.duplicate && result != PayloadState.invalid) {
          changed = true;
        }
      }
    }

    if (changed) {
      // Force UI update by assigning a new list instance
      state = state.copyWith(payloads: List.from(state.payloads));
    }
  }

  void reset() {
    state = DecodeState(payloads: []);
  }

  void removePayload(PayloadManager pm) {
    final newList = List<PayloadManager>.from(state.payloads)..remove(pm);
    state = state.copyWith(payloads: newList);
  }

  Future<ReassembledPayload?> decodePayload(PayloadManager pm) async {
    try {
      final payload = pm.reassemble();
      return payload; // Returns null if incomplete
    } catch (e) {
      throw HamsError.decompressionFailed;
    }
  }
}

