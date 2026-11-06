import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/l10n.dart';

class AppImageCropper {
  AppImageCropper._();

  // Shared with trip photo previews: never crop the saved frame a second time.
  static const tripAspectRatio = 16 / 9;

  static final ImageCropper _cropper = ImageCropper();

  /// Receipts can be tall or wide: keep the frame free, with rotation available.
  static Future<XFile?> cropReceipt({
    required BuildContext context,
    required XFile source,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final cropped = await _cropper.cropImage(
      sourcePath: source.path,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: context.l10n.receiptPhotoLabel,
          toolbarColor: scheme.surface,
          toolbarWidgetColor: scheme.onSurface,
          activeControlsWidgetColor: scheme.primary,
          cropFrameColor: scheme.primary,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: '',
          doneButtonTitle: context.l10n.saveAction,
          cancelButtonTitle: context.l10n.cancelAction,
          hidesNavigationBar: true,
          aspectRatioPickerButtonHidden: true,
          aspectRatioLockEnabled: false,
          rotateButtonsHidden: false,
          resetButtonHidden: false,
        ),
      ],
    );
    return cropped == null ? null : XFile(cropped.path);
  }
}
