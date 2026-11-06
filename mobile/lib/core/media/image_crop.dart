import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset, Size;

/// A crop as fractions of the source image, so it survives resizing.
class ImageCropRect {
  const ImageCropRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory ImageCropRect.fromJson(Map<String, dynamic> json) => ImageCropRect(
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    width: (json['width'] as num).toDouble(),
    height: (json['height'] as num).toDouble(),
  );

  final double x, y, width, height;

  Map<String, double> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };
}

/// The uncropped image and crop sent with an upload, so the crop can be edited later.
class ImageCropSourceUpload {
  const ImageCropSourceUpload({required this.bytes, required this.crop});

  final Uint8List bytes;
  final ImageCropRect crop;
}

/// What the crop editor works on.
class ImageCropSourceData {
  const ImageCropSourceData({
    required this.bytes,
    required this.width,
    required this.height,
    this.crop,
    this.hasOriginal = true,
    this.revision = '',
  });

  final Uint8List bytes;
  final int width, height;
  final ImageCropRect? crop;

  /// False when parts cut off earlier are gone, so the image can only be zoomed.
  final bool hasOriginal;
  final String revision;
}

/// The crop window over an image, in image pixels. Keeps it inside the image.
class ImageCropWindow {
  ImageCropWindow({
    required this.imageSize,
    required this.aspectRatio,
    ImageCropRect? initial,
  }) {
    if (initial == null) {
      _cropWidth = maxCropWidth;
      _center = imageSize.center(Offset.zero);
    } else {
      _cropWidth = (initial.width * imageSize.width).clamp(
        minCropWidth,
        maxCropWidth,
      );
      _center = Offset(
        (initial.x + initial.width / 2) * imageSize.width,
        (initial.y + initial.height / 2) * imageSize.height,
      );
    }
    _clampCenter();
  }

  /// The server refuses a crop narrower than this, unless the image is smaller.
  static const minimumWidth = 320.0;

  final Size imageSize;
  final double aspectRatio;
  late double _cropWidth;
  late Offset _center;

  double get cropWidth => _cropWidth;
  double get cropHeight => _cropWidth / aspectRatio;
  Offset get center => _center;
  double get maxCropWidth =>
      math.min(imageSize.width, imageSize.height * aspectRatio);
  double get minCropWidth => math.min(minimumWidth, maxCropWidth);
  bool get canZoomIn => _cropWidth > minCropWidth;
  bool get canZoomOut => _cropWidth < maxCropWidth;

  void pan(Offset imageDelta) {
    _center += imageDelta;
    _clampCenter();
  }

  /// A factor above 1 zooms in, showing a smaller part of the image.
  void zoom(double factor) {
    _cropWidth = (_cropWidth / factor).clamp(minCropWidth, maxCropWidth);
    _clampCenter();
  }

  void _clampCenter() {
    final halfWidth = cropWidth / 2, halfHeight = cropHeight / 2;
    _center = Offset(
      _center.dx.clamp(halfWidth, imageSize.width - halfWidth),
      _center.dy.clamp(halfHeight, imageSize.height - halfHeight),
    );
  }

  ImageCropRect get rect => ImageCropRect(
    x: (_center.dx - cropWidth / 2) / imageSize.width,
    y: (_center.dy - cropHeight / 2) / imageSize.height,
    width: cropWidth / imageSize.width,
    height: cropHeight / imageSize.height,
  );
}
