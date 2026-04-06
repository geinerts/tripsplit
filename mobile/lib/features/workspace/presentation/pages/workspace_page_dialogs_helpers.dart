part of 'workspace_page.dart';

extension _WorkspacePageDialogsHelpers on _WorkspacePageState {
  String _plainLocalizedText({required String en, required String lv}) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode.toLowerCase() == 'lv' ? lv : en;
  }

  String _splitModeHint(String splitMode) {
    final t = context.l10n;
    switch (splitMode) {
      case 'exact':
        return t.splitHintExact;
      case 'percent':
        return t.splitHintPercent;
      case 'shares':
        return t.splitHintShares;
      default:
        return t.splitHintEqual;
    }
  }

  String _splitModeValueLabel(String splitMode) {
    final t = context.l10n;
    switch (splitMode) {
      case 'exact':
        return t.amountLabel;
      case 'percent':
        return t.percentLabel;
      case 'shares':
        return t.sharesLabel;
      default:
        return t.valueLabel;
    }
  }

  String _splitModeValueSuffix(String splitMode) {
    switch (splitMode) {
      case 'percent':
        return '%';
      case 'shares':
        return context.l10n.shareUnit;
      default:
        return '';
    }
  }

  String _formatNumericInput(double value) {
    final rounded = value.abs() < 0.0000001 ? 0.0 : value;
    if ((rounded - rounded.roundToDouble()).abs() < 0.0000001) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(2);
  }

  List<Widget> _buildSplitInputFields({
    required List<WorkspaceUser> users,
    required Set<int> selected,
    required String splitMode,
    required Map<int, TextEditingController> splitControllers,
  }) {
    final activeIds = selected.isNotEmpty
        ? selected.toList(growable: false)
        : users
              .map((user) => user.id)
              .where((id) => id > 0)
              .toList(growable: false);
    activeIds.sort();

    final fields = <Widget>[];
    final t = context.l10n;
    for (final userId in activeIds) {
      String label = t.userWithId(userId);
      for (final user in users) {
        if (user.id == userId) {
          label = user.nickname;
          break;
        }
      }
      final controller = splitControllers.putIfAbsent(
        userId,
        () => TextEditingController(),
      );
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '$label - ${_splitModeValueLabel(splitMode)}',
              suffixText: _splitModeValueSuffix(splitMode),
            ),
          ),
        ),
      );
    }
    if (fields.isEmpty) {
      fields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(t.noParticipantsSelected),
        ),
      );
    }
    return fields;
  }

  Future<_PickedFile?> _pickReceiptFile() async {
    final receiptFallbackName = context.l10n.receiptFallbackName;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>[
        'jpg',
        'jpeg',
        'png',
        'webp',
        'heic',
        'heif',
        'hif',
      ],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final fileName = file.name.trim().isEmpty
        ? receiptFallbackName
        : file.name.trim();
    final bytesFromPicker = file.bytes;
    if (bytesFromPicker != null && bytesFromPicker.isNotEmpty) {
      return _prepareReceiptForUpload(
        fileName: fileName,
        bytes: bytesFromPicker,
      );
    }

    final path = file.path;
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final bytesFromDisk = await File(path).readAsBytes();
    if (bytesFromDisk.isEmpty) {
      return null;
    }

    return _prepareReceiptForUpload(fileName: fileName, bytes: bytesFromDisk);
  }

  Future<_PickedFile?> _prepareReceiptForUpload({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final lowered = fileName.toLowerCase();
    final isDirectSupported =
        lowered.endsWith('.jpg') ||
        lowered.endsWith('.jpeg') ||
        lowered.endsWith('.png') ||
        lowered.endsWith('.webp');
    if (isDirectSupported) {
      return _PickedFile(fileName: fileName, bytes: bytes);
    }

    final pngBytes = await _tryTranscodeReceiptToPng(bytes);
    if (pngBytes == null || pngBytes.isEmpty) {
      _showSnack(
        'This image format is not supported on this device. Please choose JPG or PNG.',
        isError: true,
      );
      return null;
    }

    final dot = fileName.lastIndexOf('.');
    final baseName = dot > 0 ? fileName.substring(0, dot) : fileName;
    final safeBase = baseName.trim().isEmpty ? 'receipt' : baseName.trim();
    return _PickedFile(fileName: '$safeBase.png', bytes: pngBytes);
  }

  Future<Uint8List?> _tryTranscodeReceiptToPng(Uint8List bytes) async {
    try {
      final codec = await instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

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

    final pngBytes = await _tryTranscodeTripToPng(rawBytes);
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

  Future<Uint8List?> _tryTranscodeTripToPng(Uint8List bytes) async {
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
