part of 'trips_page.dart';

extension _TripsPageDialogHelpers on _TripsPageState {
  Future<({Uint8List bytes, String fileName})?> _pickTripImageForUpload() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (picked == null || picked.files.isEmpty) {
      return null;
    }
    final prepared = await _prepareTripImageForUpload(picked.files.first);
    if (prepared == null) {
      return null;
    }
    final bytes = prepared.bytes;
    if (bytes.length > _TripsPageState._maxTripImageBytes) {
      _showSnack('Trip image is too large (max 8 MB).', isError: true);
      return null;
    }
    return prepared;
  }

  Future<({Uint8List bytes, String fileName})?> _prepareTripImageForUpload(
    PlatformFile file,
  ) async {
    final rawBytes = file.bytes;
    if (rawBytes == null || rawBytes.isEmpty) {
      return null;
    }

    final originalName = file.name.trim().isEmpty
        ? 'trip-image'
        : file.name.trim();
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
