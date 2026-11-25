import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'image_crop_flow.dart';
import 'image_crop.dart';
import 'receipt_crop.dart';
import 'receipt_crop_editor_page.dart';
import 'receipt_image_preparer.dart';

typedef ReceiptPhoto = ({Uint8List bytes, String fileName});

/// The same local preparation and crop output for camera, gallery and files.
class PreparedReceiptCrop {
  const PreparedReceiptCrop(this.photo, this.source);

  final ReceiptPhoto photo;
  final ImageCropSourceData source;

  static Future<PreparedReceiptCrop> prepare(
    Uint8List bytes,
    String fileName,
  ) async {
    final photo = await ReceiptImagePreparer.prepare(
      bytes: bytes,
      fileName: fileName,
    );
    return PreparedReceiptCrop(photo, await describeImage(photo.bytes));
  }

  Future<ReceiptPhoto> complete(ImageCropRect crop, int turns) async {
    if (turns == 0 &&
        crop.x == 0 &&
        crop.y == 0 &&
        crop.width == 1 &&
        crop.height == 1) {
      return photo;
    }
    final cropped = await renderReceiptCrop(photo.bytes, crop, turns);
    return ReceiptImagePreparer.prepare(
      bytes: cropped,
      fileName: 'receipt.png',
    );
  }
}

/// Crops a local upload copy. Cancellation never attaches the original instead.
Future<({Uint8List bytes, String fileName})?> cropReceiptImage({
  required BuildContext context,
  required Uint8List bytes,
  required String fileName,
  required bool Function() isCurrentAccount,
}) async {
  if (!isCurrentAccount()) return null;
  final prepared = await PreparedReceiptCrop.prepare(bytes, fileName);
  if (!context.mounted || !isCurrentAccount()) return null;
  final result = await Navigator.of(context)
      .push<({Uint8List bytes, String fileName})>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) =>
              ReceiptCropEditorPage<({Uint8List bytes, String fileName})>(
                source: prepared.source,
                isCurrentAccount: isCurrentAccount,
                complete: prepared.complete,
              ),
        ),
      );
  return context.mounted && isCurrentAccount() ? result : null;
}
