import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Prepares an upload copy; never overwrites the photo selected by the user.
class ReceiptImagePreparer {
  const ReceiptImagePreparer._();

  // Leave room below PHP's 2 MiB upload limit, including multipart overhead.
  // The API's own 8 MiB allowance is checked only after PHP accepts the file.
  static const maxUploadBytes = 1536 * 1024;

  static Future<({Uint8List bytes, String fileName})> prepare({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (bytes.isEmpty) throw const FormatException('Empty receipt image.');
    final extension = fileName.split('.').last.toLowerCase();
    if (const {'jpg', 'jpeg', 'png', 'webp'}.contains(extension) &&
        bytes.lengthInBytes <= maxUploadBytes) {
      return (bytes: bytes, fileName: fileName);
    }

    var dimensions = await _dimensions(bytes);
    for (final edge in [4096, 3200, 2560, 2048, 1600, 1280]) {
      final size = dimensions;
      final ratio = size == null
          ? 1.0
          : math.min(1.0, edge / math.max(size.width, size.height));
      // Native minWidth/minHeight scaling differs between implementations.
      // Supply matching aspect ratios so both dimensions stay within the cap.
      final width = size == null
          ? edge
          : math.max(1, (size.width * ratio).round());
      final height = size == null
          ? edge
          : math.max(1, (size.height * ratio).round());
      for (final quality in [90, 82]) {
        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: width,
          minHeight: height,
          quality: quality,
          format: CompressFormat.jpeg,
          autoCorrectionAngle: true,
          keepExif: false,
        );
        if (compressed.isEmpty) {
          throw const FormatException('Receipt conversion returned no image.');
        }
        if (compressed.lengthInBytes <= maxUploadBytes) {
          final dot = fileName.lastIndexOf('.');
          final base = (dot > 0 ? fileName.substring(0, dot) : fileName).trim();
          return (
            bytes: compressed,
            fileName: '${base.isEmpty ? 'receipt' : base}.jpg',
          );
        }
        // HEIC can be readable by the native encoder even when Flutter cannot
        // inspect its header. Its JPEG output supplies dimensions for retries.
        dimensions ??= await _dimensions(compressed);
      }
    }
    throw const FormatException(
      'Could not reduce receipt to the upload limit.',
    );
  }

  static Future<({int width, int height})?> _dimensions(Uint8List bytes) async {
    try {
      final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
      try {
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        try {
          return (width: descriptor.width, height: descriptor.height);
        } finally {
          descriptor.dispose();
        }
      } finally {
        buffer.dispose();
      }
    } catch (_) {
      return null;
    }
  }
}
