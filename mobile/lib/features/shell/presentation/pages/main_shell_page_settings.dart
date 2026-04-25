part of 'main_shell_page.dart';

const int _maxFeedbackScreenshotBytes = 8 * 1024 * 1024;

class _FeedbackDialogResult {
  const _FeedbackDialogResult({
    required this.type,
    required this.note,
    this.screenshotBytes,
    this.screenshotFileName,
  });

  final String type;
  final String note;
  final Uint8List? screenshotBytes;
  final String? screenshotFileName;
}

extension _MainShellPageSettings on _MainShellPageState {
  Future<void> _openSettingsSheet() async {
    if (_isLoggingOut || _isSendingFeedback) {
      return;
    }

    final openedTrip = _openedTrip;
    final currentUserId = widget.authController.currentUser?.id ?? 0;
    final canDeleteOpenedTrip =
        openedTrip != null &&
        openedTrip.isActive &&
        currentUserId > 0 &&
        (openedTrip.createdBy ?? 0) == currentUserId;

    final choice = await showAppBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        final t = sheetContext.l10n;
        return Column(
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
              leading: const Icon(Icons.feedback_outlined),
              title: Text(context.l10n.profileFeedbackSendTitle),
              onTap: () => Navigator.of(sheetContext).pop('send_feedback'),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(t.logOutButton),
              onTap: () => Navigator.of(sheetContext).pop('logout'),
            ),
            if (canDeleteOpenedTrip)
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
                onTap: () => Navigator.of(sheetContext).pop('delete_trip'),
              ),
          ],
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
      case 'send_feedback':
        await _openFeedbackDialog();
        return;
      case 'logout':
        await _onLogoutPressed();
        return;
      case 'delete_trip':
        await _onDeleteOpenedTripPressed();
        return;
      default:
        return;
    }
  }

  Future<void> _onDeleteOpenedTripPressed() async {
    if (_isLoggingOut || _isSendingFeedback) {
      return;
    }
    final trip = _openedTrip;
    if (trip == null) {
      return;
    }

    final currentUserId = widget.authController.currentUser?.id ?? 0;
    final isOwner = currentUserId > 0 && (trip.createdBy ?? 0) == currentUserId;
    if (!isOwner) {
      _showSnack(context.l10n.shellOnlyTripCreatorCanDelete, isError: true);
      return;
    }
    if (!trip.isActive) {
      _showSnack(context.l10n.shellOnlyActiveTripsCanDelete, isError: true);
      return;
    }

    final t = context.l10n;
    final tripLabel = _tripDisplayName(context, trip);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('${t.deleteAction} ${t.tripTitleShort}'),
          content: Text(
            context.l10n.shellDeleteTriplabelAllowedOnlyBeforeAnyExpensesAdded(
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
      _isSendingFeedback = true;
    });
    try {
      await widget.tripsController.deleteTrip(tripId: trip.id);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.shellTripDeleted, isError: false);
      _closeWorkspaceInShell();
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
          _isSendingFeedback = false;
        });
      }
    }
  }

  Future<void> _onLogoutPressed() async {
    if (_isLoggingOut) {
      return;
    }
    final t = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
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
      _isLoggingOut = true;
    });
    try {
      await widget.authController.logout();
      widget.tripsController.clearTripsCache(clearDisk: true);
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.authIntro, (route) => false);
    } finally {
      if (mounted) {
        _updateState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _openFeedbackDialog() async {
    final t = context.l10n;
    final result = await showDialog<_FeedbackDialogResult>(
      context: context,
      builder: (dialogContext) {
        String feedbackType = 'bug';
        String feedbackNote = '';
        Uint8List? screenshotBytes;
        String? screenshotName;
        bool isPickingScreenshot = false;
        String? validationError;

        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            Future<void> onPickScreenshot() async {
              if (isPickingScreenshot) {
                return;
              }
              setDialogState(() {
                validationError = null;
                isPickingScreenshot = true;
              });

              final picked = await _pickFeedbackScreenshot();
              if (!stateContext.mounted) {
                return;
              }
              if (picked == null) {
                setDialogState(() {
                  isPickingScreenshot = false;
                });
                return;
              }
              if (picked.bytes.length > _maxFeedbackScreenshotBytes) {
                setDialogState(() {
                  isPickingScreenshot = false;
                  validationError = context.l10n.profileScreenshotSizeMust8Mb;
                });
                return;
              }

              setDialogState(() {
                isPickingScreenshot = false;
                screenshotBytes = picked.bytes;
                screenshotName = picked.fileName;
              });
            }

            return AlertDialog(
              title: Text(context.l10n.profileFeedbackSendTitle),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (dropdownContext) {
                        final colorScheme = Theme.of(
                          dropdownContext,
                        ).colorScheme;
                        return DropdownButtonFormField<String>(
                          initialValue: feedbackType,
                          isExpanded: true,
                          menuMaxHeight: 240,
                          borderRadius: BorderRadius.circular(16),
                          dropdownColor: colorScheme.surface,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: colorScheme.primary,
                          ),
                          decoration: InputDecoration(
                            labelText: context.l10n.profileFeedbackTypeLabel,
                            prefixIcon: const Icon(Icons.category_outlined),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerLowest
                                .withValues(alpha: 0.92),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: colorScheme.primary,
                                width: 1.4,
                              ),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'bug',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bug_report_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(context.l10n.profileFeedbackTypeBug),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'suggestion',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.tips_and_updates_rounded,
                                    size: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.l10n.profileFeedbackTypeSuggestion,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setDialogState(() {
                              feedbackType = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      minLines: 3,
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: context.l10n.profileDescribeIssueSuggestion,
                      ),
                      onChanged: (value) {
                        feedbackNote = value;
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: isPickingScreenshot
                              ? null
                              : () {
                                  unawaited(onPickScreenshot());
                                },
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(
                            isPickingScreenshot
                                ? context.l10n.profilePickingImage
                                : (screenshotBytes == null
                                      ? context.l10n.profileAttachScreenshot
                                      : context.l10n.profileChangeScreenshot),
                          ),
                        ),
                        if (screenshotBytes != null)
                          OutlinedButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                screenshotBytes = null;
                                screenshotName = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: Text(context.l10n.profileRemoveImage),
                          ),
                      ],
                    ),
                    if (screenshotName != null &&
                        screenshotName!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        screenshotName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.profileTipAttachScreenshotFasterBugTriage,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (validationError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        validationError!,
                        style: Theme.of(stateContext).textTheme.bodyMedium
                            ?.copyWith(
                              color: Theme.of(stateContext).colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(stateContext).pop(),
                  child: Text(t.cancelAction),
                ),
                ElevatedButton(
                  onPressed: () {
                    final note = feedbackNote.trim();
                    if (note.isEmpty && screenshotBytes == null) {
                      setDialogState(() {
                        validationError = context
                            .l10n
                            .profileAddDetailsAttachScreenshotBeforeSending;
                      });
                      return;
                    }
                    Navigator.of(stateContext).pop(
                      _FeedbackDialogResult(
                        type: feedbackType,
                        note: note,
                        screenshotBytes: screenshotBytes,
                        screenshotFileName: screenshotName,
                      ),
                    );
                  },
                  child: Text(context.l10n.profileSendAction),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    _updateState(() {
      _isSendingFeedback = true;
    });
    try {
      final localeCode = Localizations.localeOf(context).toLanguageTag();
      await widget.authController.submitFeedback(
        type: result.type,
        note: result.note,
        tripId: _openedTrip?.id,
        localeCode: localeCode,
        contextData: <String, Object?>{
          'selected_tab_index': _selectedTabIndex,
          'opened_trip_id': _openedTrip?.id,
          'workspace_open': _isWorkspaceOpen,
        },
        screenshotFileName: result.screenshotFileName,
        screenshotBytes: result.screenshotBytes,
      );
      if (result.type == 'bug') {
        unawaited(
          AppMonitoring.captureHandledException(
            StateError('User submitted bug feedback'),
            origin: 'user_feedback',
            extras: <String, Object?>{
              'trip_id': _openedTrip?.id,
              'selected_tab_index': _selectedTabIndex,
              'has_screenshot': result.screenshotBytes != null,
            },
          ),
        );
      }
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.profileThanksFeedbackSent, isError: false);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.profileFailedSendFeedback, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isSendingFeedback = false;
        });
      }
    }
  }

  Future<({Uint8List bytes, String fileName})?>
  _pickFeedbackScreenshot() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (!mounted || picked == null || picked.files.isEmpty) {
      return null;
    }
    return _prepareFeedbackScreenshotForUpload(picked.files.first);
  }

  Future<({Uint8List bytes, String fileName})?>
  _prepareFeedbackScreenshotForUpload(PlatformFile file) async {
    final rawBytes = file.bytes;
    if (rawBytes == null || rawBytes.isEmpty) {
      return null;
    }

    final originalName = file.name.trim().isEmpty
        ? 'feedback_screenshot'
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

    final pngBytes = await _tryTranscodeFeedbackToPng(rawBytes);
    if (pngBytes == null || pngBytes.isEmpty) {
      return null;
    }

    final dot = originalName.lastIndexOf('.');
    final baseName = dot > 0 ? originalName.substring(0, dot) : originalName;
    final safeBase = baseName.trim().isEmpty
        ? 'feedback_screenshot'
        : baseName.trim();
    return (bytes: pngBytes, fileName: '$safeBase.png');
  }

  Future<Uint8List?> _tryTranscodeFeedbackToPng(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }
}
