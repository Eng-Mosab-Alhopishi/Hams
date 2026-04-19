import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:ghostdrop/services/encoding_service.dart';

void main() {
  final service = EncodingService();

  group('Base85 (Ascii85) Encoding/Decoding Tests', () {
    test('Round-trip check with random bytes', () {
      final random = Random();
      final data = Uint8List.fromList(List.generate(100, (_) => random.nextInt(256)));
      
      final encoded = service.encodeBase85(data);
      final decoded = service.decodeBase85(encoded);
      
      expect(decoded, equals(data));
      expect(encoded.startsWith('<~'), isTrue);
      expect(encoded.endsWith('~>'), isTrue);
    });

    test('Empty input handles correctly', () {
      final encoded = service.encodeBase85(Uint8List(0));
      expect(encoded, equals('<~~>'));
      
      final decoded = service.decodeBase85(encoded);
      expect(decoded.isEmpty, isTrue);
    });

    test('Exactly 4 bytes produces 5 chars (+ framing)', () {
      final data = Uint8List.fromList([1, 2, 3, 4]);
      final encoded = service.encodeBase85(data);
      
      // Header (2) + 5 chars + Footer (2) = 9
      expect(encoded.length, equals(9));
      expect(service.decodeBase85(encoded), equals(data));
    });

    test('All-zero bytes uses "z" compression', () {
      final data = Uint8List.fromList([0, 0, 0, 0]);
      final encoded = service.encodeBase85(data);
      
      expect(encoded, contains('z'));
      expect(encoded.length, equals(5)); // <~z~>
      expect(service.decodeBase85(encoded), equals(data));
    });

    test('Whitespace stability', () {
      final data = Uint8List.fromList([100, 101, 102, 103, 104]);
      final encoded = service.encodeBase85(data);
      
      // Inject some spaces and newlines
      final modified = '${encoded.substring(0, 4)}\n ${encoded.substring(4, 6)}   ${encoded.substring(6)}';
      
      expect(service.decodeBase85(modified), equals(data));
    });

    test('Padding edge cases (1, 2, 3 bytes)', () {
      for (int i = 1; i <= 3; i++) {
        final data = Uint8List.fromList(List.generate(i, (index) => index + 1));
        final encoded = service.encodeBase85(data);
        final decoded = service.decodeBase85(encoded);
        expect(decoded, equals(data), reason: 'Failed at length $i');
      }
    });

    test('Printable ASCII verification', () {
      final data = Uint8List.fromList(List.generate(100, (i) => i));
      final encoded = service.encodeBase85(data);
      
      // Remove frames
      final content = encoded.substring(2, encoded.length - 2);
      for (var code in content.codeUnits) {
        // Range 33 (!) to 117 (u) plus 'z' (122)
        expect(code == 122 || (code >= 33 && code <= 117), isTrue, 
          reason: 'Non-printable or invalid char detected: ${String.fromCharCode(code)} ($code)');
      }
    });
  });
}
