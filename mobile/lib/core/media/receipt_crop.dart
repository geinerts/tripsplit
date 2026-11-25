import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'image_crop.dart';

/// A free rectangular frame in the displayed (possibly rotated) image.
class ReceiptCropWindow {
  ReceiptCropWindow(this.originalSize);

  final ui.Size originalSize;
  int quarterTurns = 0;
  ui.Rect rect = const ui.Rect.fromLTWH(0, 0, 1, 1);

  ui.Size get size => quarterTurns.isEven
      ? originalSize
      : ui.Size(originalSize.height, originalSize.width);

  ImageCropRect get crop => ImageCropRect(
    x: rect.left,
    y: rect.top,
    width: rect.width,
    height: rect.height,
  );

  void reset() {
    quarterTurns = 0;
    rect = const ui.Rect.fromLTWH(0, 0, 1, 1);
  }

  void rotate() {
    rect = ui.Rect.fromLTWH(
      1 - rect.bottom,
      rect.left,
      rect.height,
      rect.width,
    );
    quarterTurns = (quarterTurns + 1) % 4;
  }

  void move(ui.Offset delta) {
    rect = ui.Rect.fromLTWH(
      (rect.left + delta.dx).clamp(0, 1 - rect.width),
      (rect.top + delta.dy).clamp(0, 1 - rect.height),
      rect.width,
      rect.height,
    );
  }

  /// Each axis is -1 for its leading edge, 1 for trailing, or 0 to leave it.
  void resize(ui.Offset edge, ui.Offset delta) {
    final minWidth = math.min(1.0, 32 / size.width);
    final minHeight = math.min(1.0, 32 / size.height);
    rect = ui.Rect.fromLTRB(
      edge.dx < 0
          ? (rect.left + delta.dx).clamp(0, rect.right - minWidth)
          : rect.left,
      edge.dy < 0
          ? (rect.top + delta.dy).clamp(0, rect.bottom - minHeight)
          : rect.top,
      edge.dx > 0
          ? (rect.right + delta.dx).clamp(rect.left + minWidth, 1)
          : rect.right,
      edge.dy > 0
          ? (rect.bottom + delta.dy).clamp(rect.top + minHeight, 1)
          : rect.bottom,
    );
  }
}

/// Renders only the selected pixels, with the same rotation as the preview.
/// The caller applies receipt upload size limits to the resulting PNG.
Future<Uint8List> renderReceiptCrop(
  Uint8List bytes,
  ImageCropRect crop,
  int quarterTurns,
) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final ui.Image image;
  try {
    image = (await codec.getNextFrame()).image;
  } finally {
    codec.dispose();
  }
  final turns = quarterTurns % 4;
  final width = turns.isEven ? image.width : image.height;
  final height = turns.isEven ? image.height : image.width;
  final source = ui.Rect.fromLTWH(
    crop.x * width,
    crop.y * height,
    crop.width * width,
    crop.height * height,
  );
  final outWidth = source.width.round().clamp(1, width);
  final outHeight = source.height.round().clamp(1, height);
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)
    ..scale(outWidth / source.width, outHeight / source.height)
    ..translate(-source.left, -source.top);
  switch (turns) {
    case 1:
      canvas.translate(image.height.toDouble(), 0);
    case 2:
      canvas.translate(image.width.toDouble(), image.height.toDouble());
    case 3:
      canvas.translate(0, image.width.toDouble());
  }
  canvas.rotate(turns * math.pi / 2);
  canvas.drawImage(
    image,
    ui.Offset.zero,
    ui.Paint()..filterQuality = ui.FilterQuality.high,
  );
  final picture = recorder.endRecording();
  try {
    final rendered = await picture.toImage(outWidth, outHeight);
    try {
      final data = await rendered.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('Could not crop receipt.');
      return data.buffer.asUint8List();
    } finally {
      rendered.dispose();
    }
  } finally {
    picture.dispose();
    image.dispose();
  }
}
