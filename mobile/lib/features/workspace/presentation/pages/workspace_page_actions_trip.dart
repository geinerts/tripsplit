part of 'workspace_page.dart';

extension _WorkspacePageTripActions on _WorkspacePageState {
  Future<void> _onGeneratePressed() async {
    if (_snapshot == null || _isMutating) {
      return;
    }
    if (!_snapshot!.isActive) {
      _showSnack(context.l10n.tripClosedRandomDisabled, isError: true);
      return;
    }

    final members = _randomSelection.toList(growable: false)..sort();
    if (members.length < 2) {
      _showSnack(context.l10n.selectAtLeastTwoMembers, isError: true);
      return;
    }

    await _runMutation(
      action: () async {
        final result = await widget.workspaceController.generateOrder(
          tripId: widget.trip.id,
          members: members,
        );
        if (!mounted) {
          return;
        }
        _updateState(() {
          _lastDraw = result;
          final next = result.remainingIds.isNotEmpty
              ? result.remainingIds.toSet()
              : result.membersIds.toSet();
          _randomSelection = next;
        });

        await _loadData(showLoader: false);
        if (mounted) {
          final label = result.pickedUserNickname.isNotEmpty
              ? result.pickedUserNickname
              : context.l10n.userWithId(result.pickedUserId);
          if (result.cycleCompleted) {
            _showSnack(context.l10n.pickedCycleCompleted(label));
          } else {
            _showSnack(context.l10n.pickedUser(label));
          }
        }
      },
    );
  }

  Future<void> _onEndTripPressed() async {
    final snapshot = _snapshot;
    if (snapshot == null || _isMutating) {
      return;
    }
    if (!snapshot.isActive) {
      _showSnack(context.l10n.tripAlreadyClosed);
      return;
    }
    if (!_canEditMembers) {
      _showSnack(context.l10n.onlyCreatorCanFinishTrip, isError: true);
      return;
    }
    if (!snapshot.allMembersReadyToSettle) {
      _showSnack(
        context.l10n.workspaceAllMembersMustMarkReadyBeforeStartingSettlements,
        isError: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = context.l10n;
        return AlertDialog(
          title: Text(t.finishTripTitle),
          content: Text(t.finishTripConfirmationText),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancelAction),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: AppDesign.actionGradient(context),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppDesign.darkForeground,
                ),
                child: Text(t.finishTripStartSettlementsAction),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _runMutation(
      action: () async {
        await widget.workspaceController.endTrip(tripId: widget.trip.id);
        await _loadData(showLoader: false);
        if (!mounted) {
          return;
        }
        final next = _snapshot;
        if (next == null) {
          _showSnack(context.l10n.tripFinished);
          return;
        }
        if (next.isArchived) {
          _showSnack(context.l10n.tripFullySettledArchived);
        } else {
          _showSnack(context.l10n.tripFinishedSettlementStarted);
        }
      },
    );
  }

  Future<void> _onReadyToSettleChanged(bool isReady) async {
    final snapshot = _snapshot;
    if (snapshot == null || _isMutating || !snapshot.isActive) {
      return;
    }
    if (_currentUserId <= 0) {
      return;
    }

    await _runMutation(
      action: () async {
        await widget.workspaceController.setReadyToSettle(
          tripId: widget.trip.id,
          isReady: isReady,
        );
        await _loadData(showLoader: false);
        if (!mounted) {
          return;
        }
        _showSnack(
          isReady
              ? context.l10n.workspaceYouMarkedYourselfReadyToSettle
              : context.l10n.workspaceReadyToSettleMarkRemoved,
        );
      },
    );
  }

  Future<void> _onSettlementMarkSent(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.markSettlementSent(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        await _loadData(showLoader: false);
        if (mounted) {
          _showSnack(context.l10n.markedAsSent);
        }
      },
    );
  }

  Future<void> _onSettlementConfirmReceived(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.confirmSettlementReceived(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        await _loadData(showLoader: false);
        if (!mounted) {
          return;
        }
        final next = _snapshot;
        if (next?.isArchived == true) {
          _showSnack(context.l10n.confirmedAllSettlementsArchived);
        } else {
          _showSnack(context.l10n.confirmedAsReceived);
        }
      },
    );
  }

  Future<void> _onSettlementRemind(SettlementItem settlement) async {
    final settlementId = settlement.id;
    if (settlementId == null || settlementId <= 0) {
      return;
    }
    await _runMutation(
      action: () async {
        await widget.workspaceController.remindSettlement(
          tripId: widget.trip.id,
          settlementId: settlementId,
        );
        if (mounted) {
          _showSnack(context.l10n.workspaceReminderSent);
        }
      },
    );
  }

  Future<void> _openReceiptUrl(String url) async {
    final parsed = Uri.tryParse(url.trim());
    if (parsed == null) {
      _showSnack(context.l10n.receiptLinkInvalid, isError: true);
      return;
    }

    final opened = await launchUrl(
      parsed,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showSnack(context.l10n.couldNotOpenReceiptLink, isError: true);
    }
  }

  bool _isCurrentTripOwner() {
    final userId = widget.authController.currentUser?.id ?? _currentUserId;
    if (userId <= 0) {
      return false;
    }
    return (widget.trip.createdBy ?? 0) == userId;
  }

  Future<void> _openTripActionsSheet() async {
    final t = context.l10n;
    final canEdit = _isCurrentTripOwner();
    final canManageMembers = _canEditMembers;
    final canDelete = _canEditMembers;
    if (!canEdit && !canDelete && !canManageMembers) {
      return;
    }

    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canEdit)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: Text('${t.editAction} ${t.tripTitleShort}'),
                  onTap: () => Navigator.of(sheetContext).pop('edit'),
                ),
              if (canManageMembers)
                ListTile(
                  leading: const Icon(Icons.group_add_outlined),
                  title: Text(t.addMembersAction),
                  subtitle: Text(
                    context.l10n.workspaceInviteLinkOrAddFromFriends,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('members'),
                ),
              if (canDelete)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                  title: Text(
                    '${t.deleteAction} ${t.tripTitleShort}',
                    style: Theme.of(sheetContext).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(sheetContext).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('delete'),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }

    if (choice == 'edit') {
      await _onEditCurrentTripPressed();
      return;
    }
    if (choice == 'members') {
      await _openAddMembersDialog();
      return;
    }
    if (choice == 'delete') {
      await _onDeleteCurrentTripPressed();
      return;
    }
  }

  Future<void> _onEditCurrentTripPressed() async {
    if (_isMutating) {
      return;
    }
    if (!_isCurrentTripOwner()) {
      _showSnack(
        context.l10n.workspaceOnlyTripCreatorCanEditThisTrip,
        isError: true,
      );
      return;
    }

    final result = await _showEditTripDialog(widget.trip);
    if (result == null || !mounted) {
      return;
    }

    final nextName = result.name.trim();
    final hasNameChange = nextName != widget.trip.name.trim();
    final imageBytes = result.imageBytes;
    final imageFileName = result.imageFileName?.trim() ?? '';
    final hasNewImage =
        imageBytes != null && imageBytes.isNotEmpty && imageFileName.isNotEmpty;
    final removeImage = result.removeImage && !hasNewImage;

    if (!hasNameChange && !hasNewImage && !removeImage) {
      _showSnack(context.l10n.noChangesToSave);
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      String? imagePath;
      if (hasNewImage) {
        final uploaded = await widget.tripsController.uploadTripImage(
          tripId: widget.trip.id,
          fileName: imageFileName,
          bytes: imageBytes,
        );
        imagePath = uploaded.path;
      }

      await widget.tripsController.updateTrip(
        tripId: widget.trip.id,
        name: nextName,
        imagePath: imagePath,
        removeImage: removeImage,
      );

      await _loadData(showLoader: false);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.workspaceTripUpdated);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.workspaceFailedToUpdateTrip, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

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
        final selectedSource =
            await showCupertinoModalPopup<_TripImageSourceOption>(
              context: dialogContext,
              builder: (cupertinoContext) => CupertinoActionSheet(
                actions: [
                  if (hasImage)
                    CupertinoActionSheetAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.of(
                        cupertinoContext,
                      ).pop(_TripImageSourceOption.remove),
                      child: Text(context.l10n.profileRemoveImage),
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
                    title: Text(context.l10n.profileRemoveImage),
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
                                        gradient:
                                            selectedImageBytes == null &&
                                                !hasExistingTripImage
                                            ? AppDesign.brandGradient
                                            : null,
                                        color:
                                            selectedImageBytes == null &&
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
                                                      color: AppDesign
                                                          .darkForeground,
                                                      size: 22,
                                                    ),
                                              ),
                                            )
                                          : const Icon(
                                              Icons.image_outlined,
                                              color: AppDesign.darkForeground,
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
                                            color: AppDesign.cardStroke(
                                              context,
                                            ),
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
                            context.l10n.tripsSelectedImage(selectedImageName!),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ] else if (existingTripImageUrl.isNotEmpty &&
                            !removeImageRequested) ...[
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.tripsTripImageAlreadySet,
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

  Future<void> _openSettingsSheet() async {
    if (_isMutating) {
      return;
    }

    final canDeleteTrip = _canEditMembers && _isTripActive;
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final t = sheetContext.l10n;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: Text(t.appearance),
                onTap: () => Navigator.of(sheetContext).pop('appearance'),
              ),
              ListTile(
                leading: const Icon(Icons.translate_outlined),
                title: Text(t.languageAction),
                onTap: () => Navigator.of(sheetContext).pop('language'),
              ),
              ListTile(
                leading: const Icon(Icons.casino_outlined),
                title: Text(context.l10n.workspaceRandomPicker),
                onTap: () => Navigator.of(sheetContext).pop('random_picker'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t.logOutButton),
                onTap: () => Navigator.of(sheetContext).pop('logout'),
              ),
              if (canDeleteTrip)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(sheetContext).colorScheme.error,
                  ),
                  title: Text(
                    '${t.deleteAction} ${t.tripTitleShort}',
                    style: TextStyle(
                      color: Theme.of(sheetContext).colorScheme.error,
                    ),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop('delete_trip'),
                ),
            ],
          ),
        );
      },
    );

    if (!mounted || choice == null) {
      return;
    }

    switch (choice) {
      case 'appearance':
        showThemeModePicker(context);
        return;
      case 'language':
        showAppLocalePicker(context);
        return;
      case 'random_picker':
        await _openRandomPickerSheet();
        return;
      case 'logout':
        await _onLogoutPressed();
        return;
      case 'delete_trip':
        await _onDeleteCurrentTripPressed();
        return;
      default:
        return;
    }
  }

  Future<void> _openRandomPickerSheet() async {
    final snapshot = _snapshot;
    if (snapshot == null || !mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.88;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.l10n.workspaceRandomPicker,
                    style: Theme.of(sheetContext).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(child: _buildRandomTab(snapshot)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onDeleteCurrentTripPressed() async {
    if (_isMutating || _isLoading) {
      return;
    }
    if (!_canEditMembers) {
      _showSnack(context.l10n.shellOnlyTripCreatorCanDelete, isError: true);
      return;
    }
    if (!_isTripActive) {
      _showSnack(context.l10n.shellOnlyActiveTripsCanDelete, isError: true);
      return;
    }

    final t = context.l10n;
    final tripName = widget.trip.name.trim();
    final tripLabel = tripName.isNotEmpty
        ? tripName
        : t.tripWithId(widget.trip.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${t.deleteAction} ${t.tripTitleShort}'),
          content: Text(
            context.l10n.tripsDeleteThisIsAllowedOnlyBeforeAnyExpensesAreAdded(
              tripLabel,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(t.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              child: Text(t.deleteAction),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      await widget.tripsController.deleteTrip(tripId: widget.trip.id);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.shellTripDeleted);

      final onExitRequested = widget.onExitRequested;
      if (onExitRequested != null) {
        onExitRequested();
      } else {
        Navigator.of(context).maybePop();
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.shellFailedToDeleteTrip, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }

  Future<void> _onLogoutPressed() async {
    if (_isMutating || _isLoading) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = context.l10n;
        return AlertDialog(
          title: Text(t.logOutButton),
          content: Text(t.logoutFromDeviceQuestion),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancelAction),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.logOutButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    _updateState(() {
      _isMutating = true;
    });
    try {
      await widget.authController.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.authIntro, (route) => false);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
        });
      }
    }
  }
}
