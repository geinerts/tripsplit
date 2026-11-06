import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

import 'image_crop.dart';
import 'image_crop_editor_page.dart';

/// A cropped photo ready to show and upload, with the original it came from.
class CroppedImagePick {
  const CroppedImagePick({required this.bytes, required this.source});

  final Uint8List bytes;
  final ImageCropSourceUpload source;
}

const _sourceMaxEdge = 2048;

/// Chooses a photo, lets the person frame it, and prepares both images.
/// Returns null when they cancel at either step.
Future<CroppedImagePick?> pickAndCropImage({
  required BuildContext context,
  required ImageSource source,
  required String title,
  required double aspectRatio,
  required int maxEdge,
  bool circular = false,
}) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    imageQuality: 94,
    maxWidth: _sourceMaxEdge.toDouble(),
    maxHeight: _sourceMaxEdge.toDouble(),
    requestFullMetadata: false,
  );
  if (picked == null || !context.mounted) return null;
  final upright = await _uprightJpeg(await picked.readAsBytes());
  if (!context.mounted) return null;
  final sourceData = await describeImage(upright);
  if (!context.mounted) return null;
  final crop = await Navigator.of(context).push<ImageCropRect>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ImageCropEditorPage<ImageCropRect>(
        title: title,
        aspectRatio: aspectRatio,
        circular: circular,
        load: () async => sourceData,
        complete: (rect, _) async => rect,
      ),
    ),
  );
  if (crop == null) return null;
  return CroppedImagePick(
    bytes: await renderImageCrop(upright, crop, maxEdge: maxEdge),
    source: ImageCropSourceUpload(bytes: upright, crop: crop),
  );
}

/// Applies the EXIF rotation and drops metadata, so the crop means the same on the
/// server as it does on screen, and location data never leaves the phone.
Future<Uint8List> _uprightJpeg(Uint8List bytes) =>
    FlutterImageCompress.compressWithList(
      bytes,
      minWidth: _sourceMaxEdge,
      minHeight: _sourceMaxEdge,
      quality: 92,
      format: CompressFormat.jpeg,
      autoCorrectionAngle: true,
      keepExif: false,
    );

Future<ImageCropSourceData> describeImage(Uint8List bytes) async {
  final image = await _decode(bytes);
  final data = ImageCropSourceData(
    bytes: bytes,
    width: image.width,
    height: image.height,
  );
  image.dispose();
  return data;
}

Future<ui.Image> _decode(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  return frame.image;
}

/// Draws the cropped part, for previews and for the upload shown to others.
Future<Uint8List> renderImageCrop(
  Uint8List bytes,
  ImageCropRect crop, {
  required int maxEdge,
}) async {
  final image = await _decode(bytes);
  final source = Rect.fromLTWH(
    crop.x * image.width,
    crop.y * image.height,
    crop.width * image.width,
    crop.height * image.height,
  );
  final longest = source.longestSide;
  final scale = longest > maxEdge ? maxEdge / longest : 1.0;
  final width = (source.width * scale).round().clamp(1, maxEdge);
  final height = (source.height * scale).round().clamp(1, maxEdge);
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawImageRect(
    image,
    source,
    Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    Paint()..filterQuality = FilterQuality.high,
  );
  final picture = recorder.endRecording();
  final rendered = await picture.toImage(width, height);
  final png = await rendered.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  rendered.dispose();
  image.dispose();
  if (png == null) throw StateError('Could not draw the cropped photo.');
  final pngBytes = png.buffer.asUint8List();
  try {
    return await FlutterImageCompress.compressWithList(
      pngBytes,
      minWidth: width,
      minHeight: height,
      quality: 90,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
  } catch (_) {
    return pngBytes;
  }
}
