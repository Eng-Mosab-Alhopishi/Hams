import 'dart:developer' as dev;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:math' as math;
import '../core/constants/app_constants.dart';

/// Top-level isolate function for heavy dart image operations.
Future<Uint8List?> _isolatePrepareImage(Map<String, dynamic> args) async {
  final Uint8List data = args['data'];
  final int dim = args['dim'];
  final int colors = args['colors'];

  img.Image? image = img.decodeImage(data);
  if (image == null) return null;

  if (image.width > dim || image.height > dim) {
    image = image.width > image.height 
        ? img.copyResize(image, width: dim) 
        : img.copyResize(image, height: dim);
  }
  
  image = img.quantize(image, numberOfColors: colors);
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

class ImageProcessorService {
  final ImagePicker _picker = ImagePicker();

  /// Opens the gallery to pick an image.
  Future<Uint8List?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (image == null) return null;
    return await image.readAsBytes();
  }

  /// Completely prepares the image on a background worker thread.
  /// Prevents ANY UI freezing during decode, resize, and quantization.
  Future<Uint8List?> prepareImageBackground(Uint8List originalBytes, {int dim = 800}) async {
    return await compute(_isolatePrepareImage, {
      'data': originalBytes,
      'dim': dim,
      'colors': AppConstants.quantizeColors,
    });
  }

  /// Smart Compressor Binary Search (Main Thread safe, calls Native WebP)
  Future<Uint8List> compressWithBinarySearch(
    Uint8List stableBytes, 
    int targetBytes, {
    int userMaxQuality = 55,
  }) async {
    // Safety check: if user wants lower than 25, we lower the floor to match
    int low = math.min(25, userMaxQuality); 
    int high = userMaxQuality;
    int bestQuality = low;
    Uint8List? bestTry;

    dev.log('GhostDrop Binary Search: Starting (Target: $targetBytes bytes, Max Q: $userMaxQuality, Floor: $low)');

    while (low <= high) {
      int mid = low + ((high - low) ~/ 2);
      final webpBytes = await convertStableToWebP(stableBytes, mid);

      if (webpBytes.length <= targetBytes) {
        bestTry = webpBytes;
        bestQuality = mid;
        low = mid + 1; // Try to get higher quality that still fits
        dev.log('GhostDrop Binary Search: Mid $mid fits (${webpBytes.length} bytes), trying higher.');
      } else {
        high = mid - 1; // It's too big, need lower quality
        dev.log('GhostDrop Binary Search: Mid $mid exceeds (${webpBytes.length} bytes), trying lower.');
        bestTry ??= webpBytes; // Just in case nothing fits
      }
    }

    dev.log('GhostDrop Binary Search: Finished. Chosen Quality: $bestQuality, Size: ${bestTry!.length} bytes');
    return bestTry;
  }

  /// Converts the image data to WebP format with [quality].
  /// Uses native compression on iOS/Android, and pure Dart fallback on Windows.
  Future<Uint8List> convertToWebP(img.Image image, int quality) async {
    final stableData = Uint8List.fromList(img.encodeJpg(image, quality: 90));
    return await convertStableToWebP(stableData, quality);
  }

  Future<Uint8List> convertStableToWebP(Uint8List stableData, int quality) async {
    try {
      // Platform check for native support
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
        // Use native plugin for mobile/macos for better speed
        final result = await FlutterImageCompress.compressWithList(
          stableData,
          format: CompressFormat.webp,
          quality: quality,
        );
        _logSize('After Native WebP', result.length);
        return result;
      } else {
        return stableData; // In fallback mode, stableData is JPG which serves as fallback
      }
    } catch (e) {
      dev.log('GhostDrop Fallback Failure: $e');
      return stableData;
    }
  }

  void _logSize(String label, int bytes) {
    final kb = bytes / 1024;
    dev.log('GhostDrop: $label -> ${kb.toStringAsFixed(2)} KB');
  }
}
