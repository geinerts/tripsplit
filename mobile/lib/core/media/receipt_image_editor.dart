import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'app_image_cropper.dart';
import 'receipt_image_preparer.dart';

/// Edits a disposable copy, including byte-only Files selections and HEIC.
class ReceiptImageEditor {
  const ReceiptImageEditor._();

  static Future<({Uint8List bytes, String fileName})?> cropAndPrepare({
    required BuildContext context,
    required Uint8List bytes,
    required String fileName,
  }) async {
    // Normalize unsupported formats before handing them to the native cropper.
    final source = await ReceiptImagePreparer.prepare(
      bytes: bytes,
      fileName: fileName,
    );
    if (!context.mounted) return null;
    final directory = await Directory.systemTemp.createTemp('splyto-receipt-');
    XFile? cropped;
    try {
      final file = File.fromUri(directory.uri.resolve('source-image'));
      await file.writeAsBytes(source.bytes, flush: true);
      if (!context.mounted) return null;
      cropped = await AppImageCropper.cropReceipt(
        context: context,
        source: XFile(file.path),
      );
      if (cropped == null || !context.mounted) return null;
      return await ReceiptImagePreparer.prepare(
        bytes: await cropped.readAsBytes(),
        fileName: 'receipt.jpg',
      );
    } finally {
      // The cropper returns a newly generated temporary file, never the photo
      // in the user's library. Remove both temporary copies after reading.
      if (cropped != null) {
        final output = File(cropped.path);
        if (await output.exists()) await output.delete();
      }
      await directory.delete(recursive: true);
    }
  }
}
