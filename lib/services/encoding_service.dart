import 'dart:typed_data';
import 'dart:convert';

class EncodingService {
  /// Encodes [data] into a standard Base64 string.
  /// Base64 is highly stable for transmission via WhatsApp/Telegram.
  String encodeBase64(Uint8List data) {
    if (data.isEmpty) return '';
    return base64.encode(data);
  }

  /// Decodes a standard Base64 string back into bytes.
  /// Automatically handles whitespace and padding.
  Uint8List decodeBase64(String text) {
    // 1. Remove all characters that are NOT valid Base64 (A-Z, a-z, 0-9, +, /, =)
    // This removes whitespace, WhatsApp trailers, and external noise.
    String input = text.replaceAll(RegExp(r'[^a-zA-Z0-9+/=]'), '');
    
    if (input.isEmpty) return Uint8List(0);

    try {
      return base64.decode(input);
    } catch (_) {
      // Fallback for slightly malformed padding
      try {
        String padded = input;
        while (padded.length % 4 != 0) {
          padded += '=';
        }
        return base64.decode(padded);
      } catch (e) {
        return Uint8List(0);
      }
    }
  }

  // Legacy support for Base85 method names to avoid breaking providers immediately
  // while we update them.
  String encodeBase85(Uint8List data) => encodeBase64(data);
  Uint8List decodeBase85(String text) => decodeBase64(text);
}
