part of 'workspace_page.dart';

enum _ReceiptSource { camera, gallery, files }

extension _WorkspacePageDialogsHelpers on _WorkspacePageState {
  String _formatNumericInput(double value) {
    final rounded = value.abs() < 0.0000001 ? 0.0 : value;
    if ((rounded - rounded.roundToDouble()).abs() < 0.0000001) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(2);
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
        final file = await _pickReceiptFile(pickerContext);
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
        pickerContext: pickerContext,
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

  Future<_PickedFile?> _pickReceiptFile(BuildContext pickerContext) async {
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

    if (!pickerContext.mounted || result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.first;
    final fileName = file.name.trim().isEmpty
        ? receiptFallbackName
        : file.name.trim();
    final bytesFromPicker = file.bytes;
    if (bytesFromPicker != null && bytesFromPicker.isNotEmpty) {
      return _prepareReceiptForUpload(
        pickerContext: pickerContext,
        fileName: fileName,
        bytes: bytesFromPicker,
      );
    }

    final path = file.path;
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final bytesFromDisk = await File(path).readAsBytes();
    if (!pickerContext.mounted || bytesFromDisk.isEmpty) {
      return null;
    }

    return _prepareReceiptForUpload(
      pickerContext: pickerContext,
      fileName: fileName,
      bytes: bytesFromDisk,
    );
  }

  Future<_PickedFile?> _prepareReceiptForUpload({
    required BuildContext pickerContext,
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      if (!mounted || !pickerContext.mounted) return null;
      final prepared = await ReceiptImageEditor.cropAndPrepare(
        context: pickerContext,
        fileName: fileName,
        bytes: bytes,
      );
      if (!mounted || prepared == null) return null;
      return _PickedFile(fileName: prepared.fileName, bytes: prepared.bytes);
    } catch (_) {
      if (mounted) {
        _showSnack(context.l10n.receiptPickFailed, isError: true);
      }
      return null;
    }
  }

  Future<TripImageDraft?> _pickTripImageForUploadFromSource(
    ImageSource source,
  ) async {
    try {
      final pick = await pickAndCropImage(
        context: context,
        source: source,
        title: context.l10n.imageCropperAdjustTripImage,
        aspectRatio: AppImageCropper.tripAspectRatio,
        maxEdge: 2048,
      );
      if (pick == null) return null;
      return (bytes: pick.bytes, fileName: 'trip.jpg', source: pick.source);
    } catch (_) {
      return null;
    }
  }
}
