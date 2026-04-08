part of 'trips_page.dart';

extension _TripsPageEditDialog on _TripsPageState {
  Future<_EditTripResult?> _showEditTripDialog(Trip trip) async {
    final t = context.l10n;
    final nameController = TextEditingController(text: trip.name.trim());
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool removeImageRequested = false;
    String? errorText;

    Future<void> onPickTripImage(
      StateSetter setDialogState,
      BuildContext dialogContext,
    ) async {
      final existingTripImageUrl = (trip.imageUrl ?? trip.imageThumbUrl ?? '')
          .trim();
      final hasExistingTripImage =
          !removeImageRequested && existingTripImageUrl.isNotEmpty;
      final hasImage = selectedImageBytes != null || hasExistingTripImage;
      final platform = Theme.of(dialogContext).platform;
      final isIOS = platform == TargetPlatform.iOS;

      if (isIOS) {
        final selectedSource = await showCupertinoModalPopup<_TripImageSourceOption>(
          context: dialogContext,
          builder: (cupertinoContext) => CupertinoActionSheet(
            actions: [
              if (hasImage)
                CupertinoActionSheetAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.of(
                    cupertinoContext,
                  ).pop(_TripImageSourceOption.remove),
                  child: Text(
                    _pageText(
                      en: 'Remove image',
                      lv: 'Noņemt attēlu',
                    ),
                  ),
                ),
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(
                  cupertinoContext,
                ).pop(_TripImageSourceOption.camera),
                child: Text(t.takePhotoAction),
              ),
              CupertinoActionSheetAction(
                onPressed: () => Navigator.of(
                  cupertinoContext,
                ).pop(_TripImageSourceOption.library),
                child: Text(t.chooseFromLibraryAction),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.of(cupertinoContext).pop(),
              child: Text(t.cancelAction),
            ),
          ),
        );

        if (!mounted || !dialogContext.mounted || selectedSource == null) {
          return;
        }

        if (selectedSource == _TripImageSourceOption.remove) {
          setDialogState(() {
            selectedImageBytes = null;
            selectedImageName = null;
            removeImageRequested = true;
          });
          return;
        }

        final source = selectedSource == _TripImageSourceOption.camera
            ? ImageSource.camera
            : ImageSource.gallery;
        final picked = await _pickTripImageForUploadFromSource(source);
        if (!mounted || !dialogContext.mounted || picked == null) {
          return;
        }
        setDialogState(() {
          selectedImageBytes = picked.bytes;
          selectedImageName = picked.fileName;
          removeImageRequested = false;
        });
        return;
      }

      final selectedSource = await showModalBottomSheet<_TripImageSourceOption>(
        context: dialogContext,
        showDragHandle: true,
        builder: (bottomSheetContext) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(t.takePhotoAction),
                  onTap: () => Navigator.of(
                    bottomSheetContext,
                  ).pop(_TripImageSourceOption.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(t.chooseFromLibraryAction),
                  onTap: () => Navigator.of(
                    bottomSheetContext,
                  ).pop(_TripImageSourceOption.library),
                ),
                if (hasImage)
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: Text(
                      _pageText(
                        en: 'Remove image',
                        lv: 'Noņemt attēlu',
                      ),
                    ),
                    onTap: () => Navigator.of(
                      bottomSheetContext,
                    ).pop(_TripImageSourceOption.remove),
                  ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(t.cancelAction),
                  onTap: () => Navigator.of(bottomSheetContext).pop(),
                ),
              ],
            ),
          );
        },
      );
      if (!mounted || !dialogContext.mounted || selectedSource == null) {
        return;
      }
      if (selectedSource == _TripImageSourceOption.remove) {
        setDialogState(() {
          selectedImageBytes = null;
          selectedImageName = null;
          removeImageRequested = true;
        });
        return;
      }
      final source = selectedSource == _TripImageSourceOption.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      final picked = await _pickTripImageForUploadFromSource(source);
      if (!mounted || !dialogContext.mounted || picked == null) {
        return;
      }
      setDialogState(() {
        selectedImageBytes = picked.bytes;
        selectedImageName = picked.fileName;
        removeImageRequested = false;
      });
    }

    try {
      return await showDialog<_EditTripResult>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              final existingTripImageUrl =
                  (trip.imageUrl ?? trip.imageThumbUrl ?? '').trim();
              final hasExistingTripImage =
                  !removeImageRequested && existingTripImageUrl.isNotEmpty;
              return AlertDialog(
                title: Text('${t.editAction} ${t.tripTitleShort}'),
                content: SizedBox(
                  width: 430,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => unawaited(
                                onPickTripImage(setDialogState, dialogContext),
                              ),
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                width: 62,
                                height: 62,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppDesign.cardStroke(context),
                                        ),
                                        gradient: selectedImageBytes == null &&
                                                !hasExistingTripImage
                                            ? AppDesign.brandGradient
                                            : null,
                                        color: selectedImageBytes == null &&
                                                hasExistingTripImage
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: selectedImageBytes != null
                                          ? ClipOval(
                                              child: Image.memory(
                                                selectedImageBytes!,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                gaplessPlayback: true,
                                              ),
                                            )
                                          : hasExistingTripImage
                                          ? ClipOval(
                                              child: Image.network(
                                                existingTripImageUrl,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, _, _) =>
                                                    const Icon(
                                                      Icons.image_outlined,
                                                      color: Colors.white,
                                                      size: 22,
                                                    ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image_outlined,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppDesign.cardStroke(context),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.photo_camera_rounded,
                                          size: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: t.tripNameLabel,
                                  hintText: t.tripNameHint,
                                ),
                                onChanged: (_) {
                                  setDialogState(() {
                                    errorText = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        if (selectedImageName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _pageText(
                              en: 'Selected image: $selectedImageName',
                              lv: 'Izvēlētais attēls: $selectedImageName',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ] else if (existingTripImageUrl.isNotEmpty &&
                            !removeImageRequested) ...[
                          const SizedBox(height: 4),
                          Text(
                            _pageText(
                              en: 'Trip image already set.',
                              lv: 'Tripa attēls jau ir iestatīts.',
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (errorText != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            errorText!,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.cancelAction),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final nextName = nameController.text.trim();
                      if (nextName.length < 2 || nextName.length > 120) {
                        setDialogState(() {
                          errorText = t.tripNameLengthValidation;
                        });
                        return;
                      }
                      Navigator.of(context).pop(
                        _EditTripResult(
                          name: nextName,
                          imageFileName: selectedImageName,
                          imageBytes: selectedImageBytes,
                          removeImage: removeImageRequested,
                        ),
                      );
                    },
                    child: Text(t.saveAction),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      nameController.dispose();
    }
  }
}
