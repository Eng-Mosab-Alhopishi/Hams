import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/compression_service.dart';
import '../../services/encoding_service.dart';
import '../../services/clipboard_service.dart';

// Shared Service Instances
final compressionService = Provider((ref) => CompressionService());
final encodingService = Provider((ref) => EncodingService());

// Shared Application Providers
final clipboardServiceProvider = Provider((ref) {
  final service = ClipboardService();
  ref.onDispose(() => service.dispose());
  return service;
});

// For backward compatibility and standard naming across app
final compressionServiceProvider = Provider((ref) => CompressionService());
final encodingServiceProvider = Provider((ref) => EncodingService());
