import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class AppImageCropper {
  AppImageCropper._();

  static final ImageCropper _cropper = ImageCropper();

  static Future<XFile?> cropAvatar({
    required BuildContext context,
    required XFile source,
  }) {
    return _crop(
      context: context,
      source: source,
      ratioX: 1,
      ratioY: 1,
      title: 'Adjust avatar',
    );
  }

  static Future<XFile?> cropTripImage({
    required BuildContext context,
    required XFile source,
  }) {
    return _crop(
      context: context,
      source: source,
      ratioX: 16,
      ratioY: 9,
      title: 'Adjust trip image',
    );
  }

  static Future<XFile?> _crop({
    required BuildContext context,
    required XFile source,
    required double ratioX,
    required double ratioY,
    required String title,
  }) async {
    final scheme = Theme.of(context).colorScheme;

    final cropped = await _cropper.cropImage(
      sourcePath: source.path,
      aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          toolbarColor: scheme.surface,
          toolbarWidgetColor: scheme.onSurface,
          activeControlsWidgetColor: scheme.primary,
          cropFrameColor: scheme.primary,
          cropGridColor: scheme.primary.withValues(alpha: 0.35),
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          // Keep iOS crop UI clean: one title area (no duplicate heading),
          // while preserving pinch-to-zoom and pan behavior.
          title: '',
          doneButtonTitle: 'Save',
          cancelButtonTitle: 'Cancel',
          embedInNavigationController: false,
          hidesNavigationBar: true,
          rotateButtonsHidden: true,
          resetButtonHidden: true,
          aspectRatioPickerButtonHidden: true,
          aspectRatioLockEnabled: true,
          aspectRatioLockDimensionSwapEnabled: false,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    if (cropped == null) {
      return null;
    }
    return XFile(cropped.path);
  }
}
