import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/media/app_image_cropper.dart';
import '../../../core/media/image_crop_flow.dart';

const _maxVisitPhotoBytes = 512 * 1024;

/// Chooses and frames a visit photo, sized to fit the visit's JSON upload limit.
Future<CroppedImagePick?> pickTravelPhoto(BuildContext context) async {
  final pick = await pickAndCropImage(
    context: context,
    source: ImageSource.gallery,
    title: context.l10n.imageCropEditAction,
    aspectRatio: AppImageCropper.tripAspectRatio,
    maxEdge: 1024,
  );
  if (pick == null) return null;
  return CroppedImagePick(
    bytes: await _fitVisitLimit(pick),
    source: pick.source,
  );
}

Future<Uint8List> _fitVisitLimit(CroppedImagePick pick) async {
  if (pick.bytes.length <= _maxVisitPhotoBytes) return pick.bytes;
  for (final edge in [1024, 768, 512]) {
    final bytes = await FlutterImageCompress.compressWithList(
      pick.bytes,
      minWidth: edge,
      minHeight: edge,
      quality: 80,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (bytes.isNotEmpty && bytes.length <= _maxVisitPhotoBytes) return bytes;
  }
  throw const FormatException('Photo could not be prepared.');
}
