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
                leading: const Icon(Icons.feedback_outlined),
                title: Text(
                  _settingsLocalizedText(
                    en: 'Send feedback',
                    lv: 'Sūtīt atsauksmi',
                  ),
                ),
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
      _showSnack(
        _settingsLocalizedText(
          en: 'Only trip creator can delete this trip.',
          lv: 'Šo ceļojumu drīkst dzēst tikai izveidotājs.',
        ),
        isError: true,
      );
      return;
    }
    if (!trip.isActive) {
      _showSnack(
        _settingsLocalizedText(
          en: 'Only active trips can be deleted.',
          lv: 'Dzēst var tikai aktīvus ceļojumus.',
        ),
        isError: true,
      );
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
            _settingsLocalizedText(
              en: 'Delete "$tripLabel"? This is allowed only before any expenses are added.',
              lv: 'Dzēst "$tripLabel"? Tas ir atļauts tikai pirms ceļojumam pievienoti izdevumi.',
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
      _showSnack(
        _settingsLocalizedText(en: 'Trip deleted.', lv: 'Ceļojums izdzēsts.'),
        isError: false,
      );
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
      _showSnack(
        _settingsLocalizedText(
          en: 'Failed to delete trip.',
          lv: 'Neizdevās izdzēst ceļojumu.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        _updateState(() {
          _isSendingFeedback = false;
        });
      }
    }
  }

  String _settingsLocalizedText({required String en, required String lv}) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode.toLowerCase() == 'lv' ? lv : en;
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
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
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
                  validationError = _settingsLocalizedText(
                    en: 'Screenshot size must be up to 8 MB',
                    lv: 'Ekrānattēla izmēram jābūt līdz 8 MB',
                  );
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
              title: Text(
                _settingsLocalizedText(
                  en: 'Send feedback',
                  lv: 'Sūtīt atsauksmi',
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: feedbackType,
                      decoration: InputDecoration(
                        labelText: _settingsLocalizedText(
                          en: 'Type',
                          lv: 'Tips',
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'bug',
                          child: Text(
                            _settingsLocalizedText(en: 'Bug', lv: 'Kļūda'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'suggestion',
                          child: Text(
                            _settingsLocalizedText(
                              en: 'Suggestion',
                              lv: 'Ieteikums',
                            ),
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
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      minLines: 3,
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        hintText: _settingsLocalizedText(
                          en: 'Describe issue or suggestion',
                          lv: 'Apraksti problēmu vai ieteikumu',
                        ),
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
                                ? _settingsLocalizedText(
                                    en: 'Picking image...',
                                    lv: 'Tiek izvēlēts attēls...',
                                  )
                                : (screenshotBytes == null
                                      ? _settingsLocalizedText(
                                          en: 'Attach screenshot',
                                          lv: 'Pievienot ekrānattēlu',
                                        )
                                      : _settingsLocalizedText(
                                          en: 'Change screenshot',
                                          lv: 'Mainīt ekrānattēlu',
                                        )),
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
                            label: Text(
                              _settingsLocalizedText(
                                en: 'Remove image',
                                lv: 'Noņemt attēlu',
                              ),
                            ),
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
                      _settingsLocalizedText(
                        en: 'Tip: attach screenshot for faster bug triage',
                        lv: 'Ieteikums: pievieno ekrānattēlu ātrākai kļūdas analīzei',
                      ),
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
                        validationError = _settingsLocalizedText(
                          en: 'Add details or attach screenshot before sending',
                          lv: 'Pirms sūtīšanas pievieno aprakstu vai ekrānattēlu',
                        );
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
                  child: Text(_settingsLocalizedText(en: 'Send', lv: 'Sūtīt')),
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
      _showSnack(
        _settingsLocalizedText(
          en: 'Thanks! Feedback sent',
          lv: 'Paldies! Atsauksme nosūtīta',
        ),
        isError: false,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(
        _settingsLocalizedText(
          en: 'Failed to send feedback',
          lv: 'Neizdevās nosūtīt atsauksmi',
        ),
        isError: true,
      );
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
