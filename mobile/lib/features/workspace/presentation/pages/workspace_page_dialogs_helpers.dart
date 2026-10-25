part of 'workspace_page.dart';

enum _ReceiptSource { camera, gallery, files }

extension _WorkspacePageDialogsHelpers on _WorkspacePageState {
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
          label = user.preferredName;
          break;
        }
      }
      final controller = splitControllers.putIfAbsent(
        userId,
        () => TextEditingController(),
      );
      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(16) > 24;
              final inputWidth = stacked ? constraints.maxWidth : 128.0;
              return Column(
                children: [
                  Flex(
                    direction: stacked ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: stacked
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: stacked
                            ? constraints.maxWidth
                            : constraints.maxWidth - inputWidth - 16,
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(
                        width: stacked ? 0 : 16,
                        height: stacked ? 8 : 0,
                      ),
                      SizedBox(
                        width: inputWidth,
                        child: Semantics(
                          label: label,
                          child: TextField(
                            key: ValueKey('split-input-$userId'),
                            controller: controller,
                            textAlign: TextAlign.end,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              filled: false,
                              labelText: _splitModeValueLabel(splitMode),
                              suffixText: _splitModeValueSuffix(splitMode),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                ],
              );
            },
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

  Future<_PickedFile?> _pickReceiptAttachment(
    BuildContext pickerContext,
  ) async {
    final t = pickerContext.l10n;
    final account = widget.authController.currentUser?.id;
    try {
      final source = await showAppPlatformActionSheet<_ReceiptSource>(
        context: pickerContext,
        title: t.addReceiptAction,
        cancelLabel: t.cancelAction,
        actions: [
          AppPlatformAction(
            value: _ReceiptSource.camera,
            icon: Icons.photo_camera_outlined,
            title: t.takePhotoAction,
          ),
          AppPlatformAction(
            value: _ReceiptSource.gallery,
            icon: Icons.photo_library_outlined,
            title: t.chooseFromLibraryAction,
          ),
          AppPlatformAction(
            value: _ReceiptSource.files,
            icon: Icons.folder_open_outlined,
            title: t.chooseReceiptFile,
          ),
        ],
      );
      if (!mounted ||
          !pickerContext.mounted ||
          source == null ||
          account != widget.authController.currentUser?.id) {
        return null;
      }
      if (source == _ReceiptSource.files) {
        final file = await _pickReceiptFile();
        return mounted &&
                pickerContext.mounted &&
                account == widget.authController.currentUser?.id
            ? file
            : null;
      }
      final photo = await ImagePicker().pickImage(
        source: source == _ReceiptSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        imageQuality: 94,
        maxWidth: 4096,
        maxHeight: 4096,
        requestFullMetadata: false,
      );
      if (!mounted ||
          !pickerContext.mounted ||
          photo == null ||
          account != widget.authController.currentUser?.id) {
        return null;
      }
      final bytes = await photo.readAsBytes();
      if (!mounted ||
          !pickerContext.mounted ||
          bytes.isEmpty ||
          account != widget.authController.currentUser?.id) {
        return null;
      }
      final prepared = await _prepareReceiptForUpload(
        fileName: photo.name.trim().isEmpty ? 'receipt.jpg' : photo.name,
        bytes: bytes,
      );
      return mounted &&
              pickerContext.mounted &&
              account == widget.authController.currentUser?.id
          ? prepared
          : null;
    } on PlatformException catch (error) {
      if (mounted && pickerContext.mounted) {
        final denied =
            error.code.toLowerCase().contains('access_denied') ||
            error.code.toLowerCase().contains('access_restricted');
        _showSnack(
          denied ? t.receiptPhotoAccessDenied : t.receiptPickFailed,
          isError: true,
        );
      }
    } catch (_) {
      if (mounted && pickerContext.mounted) {
        _showSnack(t.receiptPickFailed, isError: true);
      }
    }
    return null;
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
    try {
      final prepared = await ReceiptImagePreparer.prepare(
        fileName: fileName,
        bytes: bytes,
      );
      if (!mounted) return null;
      return _PickedFile(fileName: prepared.fileName, bytes: prepared.bytes);
    } catch (_) {
      if (mounted) {
        _showSnack(context.l10n.receiptPickFailed, isError: true);
      }
      return null;
    }
  }

  Future<({Uint8List bytes, String fileName})?>
  _pickTripImageForUploadFromSource(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 94,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (!mounted || picked == null) {
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

  Future<({Uint8List bytes, String fileName})?>
  _prepareTripImageBytesForUpload({
    required Uint8List rawBytes,
    required String fileName,
  }) async {
    final originalName = fileName.trim().isEmpty
        ? 'trip-image'
        : fileName.trim();
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
    if (!mounted) return null;
    if (pngBytes == null || pngBytes.isEmpty) {
      _showSnack(
        context.l10n.profileImageFormatNotSupportedDevicePleaseChooseJpg,
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
