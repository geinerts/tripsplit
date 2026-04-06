part of 'trips_page.dart';

extension _TripsPageDialogHelpers on _TripsPageState {
  Future<({Uint8List bytes, String fileName})?> _pickTripImageForUploadFromSource(
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 94,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (picked == null) {
        return null;
      }
      final cropped = await AppImageCropper.cropTripImage(
        context: context,
        source: picked,
      );
      if (cropped == null) {
        return null;
      }

      final rawBytes = await cropped.readAsBytes();
      final fallbackName = picked.name.trim().isEmpty
          ? (source == ImageSource.camera
                ? 'trip_camera.jpg'
                : 'trip_gallery.jpg')
          : picked.name.trim();
      final incomingName = _fileNameFromPath(
        cropped.path,
        fallbackName: fallbackName,
      );
      return _prepareTripImageBytesForUpload(
        rawBytes: rawBytes,
        fileName: incomingName,
      );
    } catch (_) {
      return null;
    }
  }

  String _fileNameFromPath(String path, {required String fallbackName}) {
    final normalized = path.trim();
    if (normalized.isEmpty) {
      return fallbackName;
    }
    final slashIndex = normalized.lastIndexOf('/');
    final candidate = slashIndex >= 0
        ? normalized.substring(slashIndex + 1)
        : normalized;
    final trimmed = candidate.trim();
    if (trimmed.isEmpty) {
      return fallbackName;
    }
    return trimmed;
  }

  Future<({Uint8List bytes, String fileName})?> _prepareTripImageBytesForUpload({
    required Uint8List rawBytes,
    required String fileName,
  }) async {
    final originalName = fileName.trim().isEmpty ? 'trip-image' : fileName.trim();
    final lowered = originalName.toLowerCase();
    final isDirectSupported =
        lowered.endsWith('.jpg') ||
        lowered.endsWith('.jpeg') ||
        lowered.endsWith('.png') ||
        lowered.endsWith('.webp');
    if (isDirectSupported) {
      return (bytes: rawBytes, fileName: originalName);
    }

    final pngBytes = await _tryTranscodeToPng(rawBytes);
    if (pngBytes == null || pngBytes.isEmpty) {
      _showSnack(
        'This image format is not supported on this device. Please choose JPG or PNG.',
        isError: true,
      );
      return null;
    }

    final dot = originalName.lastIndexOf('.');
    final baseName = dot > 0 ? originalName.substring(0, dot) : originalName;
    final safeBase = baseName.trim().isEmpty ? 'trip-image' : baseName.trim();
    return (bytes: pngBytes, fileName: '$safeBase.png');
  }

  Future<Uint8List?> _tryTranscodeToPng(Uint8List bytes) async {
    try {
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
