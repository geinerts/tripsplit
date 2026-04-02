part of 'trips_page.dart';

extension _TripsPageDialogs on _TripsPageState {
  Future<_CreateTripResult?> _showCreateTripDialog() async {
    final nameController = TextEditingController();
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    final selected = <int>{};
    final selectedUsers = <int, TripUser>{};
    BuildContext? dialogBuildContext;
    var friendQuickPicks = const <TripUser>[];
    var isLoadingFriendQuickPicks = false;
    var friendQuickPicksRequested = false;

    try {
      return await showModalBottomSheet<_CreateTripResult>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (sheetContext) {
          final t = sheetContext.l10n;
          String? errorText;

          Future<void> loadFriendQuickPicks(StateSetter setDialogState) async {
            if (isLoadingFriendQuickPicks) {
              return;
            }
            bool canUpdateDialog() {
              final c = dialogBuildContext;
              return mounted && c != null && c.mounted;
            }

            setDialogState(() {
              isLoadingFriendQuickPicks = true;
            });

            try {
              final cached = widget.friendsController.peekSnapshotCache(
                allowStale: false,
              );
              final snapshot =
                  cached ??
                  await widget.friendsController.loadSnapshot(
                    forceRefresh: false,
                  );
              if (!canUpdateDialog()) {
                return;
              }
              setDialogState(() {
                friendQuickPicks = snapshot.friends
                    .map(
                      (friend) => TripUser(
                        id: friend.id,
                        nickname: friend.nickname,
                        avatarUrl: friend.avatarUrl,
                        avatarThumbUrl: friend.avatarThumbUrl,
                      ),
                    )
                    .toList(growable: false);
              });
            } catch (_) {
              if (!canUpdateDialog()) {
                return;
              }
              setDialogState(() {
                friendQuickPicks = const <TripUser>[];
              });
            } finally {
              if (canUpdateDialog()) {
                setDialogState(() {
                  isLoadingFriendQuickPicks = false;
                });
              }
            }
          }

          Future<void> onPickTripImage(StateSetter setDialogState) async {
            final hasImage = selectedImageBytes != null;
            final platform = Theme.of(context).platform;
            final isIOS = platform == TargetPlatform.iOS;

            if (isIOS) {
              final selectedSource =
                  await showCupertinoModalPopup<_TripImageSourceOption>(
                    context: context,
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

              if (!mounted || !context.mounted || selectedSource == null) {
                return;
              }

              if (selectedSource == _TripImageSourceOption.remove) {
                setDialogState(() {
                  selectedImageBytes = null;
                  selectedImageName = null;
                });
                return;
              }

              final source = selectedSource == _TripImageSourceOption.camera
                  ? ImageSource.camera
                  : ImageSource.gallery;
              final picked = await _pickTripImageForUploadFromSource(source);
              if (!mounted || !context.mounted || picked == null) {
                return;
              }
              setDialogState(() {
                selectedImageBytes = picked.bytes;
                selectedImageName = picked.fileName;
              });
              return;
            }

            final selectedSource = await showModalBottomSheet<_TripImageSourceOption>(
              context: context,
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
            if (!mounted || !context.mounted || selectedSource == null) {
              return;
            }
            if (selectedSource == _TripImageSourceOption.remove) {
              setDialogState(() {
                selectedImageBytes = null;
                selectedImageName = null;
              });
              return;
            }
            final source = selectedSource == _TripImageSourceOption.camera
                ? ImageSource.camera
                : ImageSource.gallery;
            final picked = await _pickTripImageForUploadFromSource(source);
            if (!mounted || !context.mounted || picked == null) {
              return;
            }
            setDialogState(() {
              selectedImageBytes = picked.bytes;
              selectedImageName = picked.fileName;
            });
          }

          return StatefulBuilder(
            builder: (context, setDialogState) {
              dialogBuildContext = context;
              final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;
              final maxSheetHeight = MediaQuery.sizeOf(context).height * 0.9;
              if (!friendQuickPicksRequested) {
                friendQuickPicksRequested = true;
                unawaited(loadFriendQuickPicks(setDialogState));
              }

              return Padding(
                padding: EdgeInsets.only(bottom: viewInsetsBottom),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxSheetHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            t.createNewTripTitle,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () => unawaited(
                                      onPickTripImage(setDialogState),
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
                                              gradient: selectedImageBytes == null
                                                  ? AppDesign.brandGradient
                                                  : null,
                                            ),
                                            alignment: Alignment.center,
                                            child: selectedImageBytes == null
                                                ? const Icon(
                                                    Icons.image_outlined,
                                                    color: Colors.white,
                                                    size: 22,
                                                  )
                                                : ClipOval(
                                                    child: Image.memory(
                                                      selectedImageBytes!,
                                                      width: 56,
                                                      height: 56,
                                                      fit: BoxFit.cover,
                                                      gaplessPlayback: true,
                                                    ),
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
                                const SizedBox(height: 6),
                                Text(
                                  _pageText(
                                    en: 'Selected image: $selectedImageName',
                                    lv: 'Izvēlētais attēls: $selectedImageName',
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Text(
                                t.selectedPeopleLabel,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 6),
                              if (selectedUsers.isEmpty)
                                Text(
                                  'No members selected yet.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final user in selectedUsers.values)
                                      InputChip(
                                        label: Text(user.nickname),
                                        selected: true,
                                        onDeleted: () {
                                          setDialogState(() {
                                            selected.remove(user.id);
                                            selectedUsers.remove(user.id);
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              if (isLoadingFriendQuickPicks) ...[
                                const SizedBox(height: 10),
                                const LinearProgressIndicator(minHeight: 2),
                              ],
                              if (friendQuickPicks.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    for (final friend in friendQuickPicks)
                                      FilterChip(
                                        label: Text(friend.nickname),
                                        selected: selected.contains(friend.id),
                                        onSelected: (isSelected) {
                                          setDialogState(() {
                                            if (isSelected) {
                                              selected.add(friend.id);
                                              selectedUsers[friend.id] = friend;
                                            } else {
                                              selected.remove(friend.id);
                                              selectedUsers.remove(friend.id);
                                            }
                                          });
                                        },
                                      ),
                                  ],
                                ),
                              ],
                              if (errorText != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  errorText!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () =>
                                    Navigator.of(sheetContext).pop(),
                                child: Text(t.cancelAction),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final name = nameController.text.trim();
                                  if (name.length < 2 || name.length > 120) {
                                    setDialogState(() {
                                      errorText = t.tripNameLengthValidation;
                                    });
                                    return;
                                  }

                                  final memberIds = selected.toList(
                                    growable: false,
                                  )..sort();
                                  Navigator.of(sheetContext).pop(
                                    _CreateTripResult(
                                      name: name,
                                      memberIds: memberIds,
                                      imageFileName: selectedImageName,
                                      imageBytes: selectedImageBytes,
                                    ),
                                  );
                                },
                                child: Text(t.createAction),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        nameController.dispose();
      });
    }
  }
}

enum _TripImageSourceOption { camera, library, remove }
