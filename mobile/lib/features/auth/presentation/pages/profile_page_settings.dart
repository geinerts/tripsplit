part of 'profile_page.dart';

const int _maxFeedbackScreenshotBytes = 8 * 1024 * 1024;

class _ProfileFeedbackDialogResult {
  const _ProfileFeedbackDialogResult({
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

extension _ProfilePageSettings on _ProfilePageState {
  Future<void> _onLogoutPressed() async {
    if (_isSubmitting || _isLoading) {
      return;
    }

    final t = context.l10n;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    bool? confirmed;
    if (isIOS) {
      confirmed = await showCupertinoModalPopup<bool>(
        context: context,
        builder: (sheetContext) => CupertinoActionSheet(
          title: Text(t.logOutButton),
          message: Text(t.logoutFromDeviceQuestion),
          actions: [
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(sheetContext).pop(true),
              child: Text(t.logOutButton),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(sheetContext).pop(false),
            child: Text(t.cancelAction),
          ),
        ),
      );
    } else {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(t.logOutButton),
            content: Text(t.logoutFromDeviceQuestion),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(t.cancelAction),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(t.logOutButton),
              ),
            ],
          );
        },
      );
    }

    if (!mounted || confirmed != true) {
      return;
    }

    _updateState(() {
      _isSubmitting = true;
    });
    try {
      await widget.controller.logout();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _openChangePasswordDialog() async {
    _openChangePasswordPage();
  }

  Future<void> _openFeedbackDialog() async {
    if (_isSendingFeedback || _isSubmitting || _isLoading) {
      return;
    }

    final result = await showModalBottomSheet<_ProfileFeedbackDialogResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        String feedbackType = 'bug';
        String feedbackNote = '';
        Uint8List? screenshotBytes;
        String? screenshotName;
        bool isPickingScreenshot = false;
        String? validationError;

        return StatefulBuilder(
          builder: (stateContext, setSheetState) {
            Future<void> onPickScreenshot() async {
              if (isPickingScreenshot) {
                return;
              }
              setSheetState(() {
                validationError = null;
                isPickingScreenshot = true;
              });

              final picked = await _pickFeedbackScreenshot();
              if (!stateContext.mounted) {
                return;
              }
              if (picked == null) {
                setSheetState(() {
                  isPickingScreenshot = false;
                });
                return;
              }
              if (picked.bytes.length > _maxFeedbackScreenshotBytes) {
                setSheetState(() {
                  isPickingScreenshot = false;
                  validationError = _profileText(
                    en: 'Screenshot size must be up to 8 MB',
                    lv: 'Ekrānattēla izmēram jābūt līdz 8 MB',
                  );
                });
                return;
              }

              setSheetState(() {
                isPickingScreenshot = false;
                screenshotBytes = picked.bytes;
                screenshotName = picked.fileName;
              });
            }

            final bottomInset = MediaQuery.of(stateContext).viewInsets.bottom;
            return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profileText(en: 'Send feedback', lv: 'Sūtīt atsauksmi'),
                      style: Theme.of(stateContext).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: feedbackType,
                      decoration: InputDecoration(
                        labelText: _profileText(en: 'Type', lv: 'Tips'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'bug',
                          child: Text(
                            _profileText(en: 'Bug', lv: 'Kļūda'),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'suggestion',
                          child: Text(
                            _profileText(en: 'Suggestion', lv: 'Ieteikums'),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setSheetState(() {
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
                        hintText: _profileText(
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
                                ? _profileText(
                                    en: 'Picking image...',
                                    lv: 'Tiek izvēlēts attēls...',
                                  )
                                : (screenshotBytes == null
                                      ? _profileText(
                                          en: 'Attach screenshot',
                                          lv: 'Pievienot ekrānattēlu',
                                        )
                                      : _profileText(
                                          en: 'Change screenshot',
                                          lv: 'Mainīt ekrānattēlu',
                                        )),
                          ),
                        ),
                        if (screenshotBytes != null)
                          OutlinedButton.icon(
                            onPressed: () {
                              setSheetState(() {
                                screenshotBytes = null;
                                screenshotName = null;
                              });
                            },
                            icon: const Icon(Icons.close),
                            label: Text(
                              _profileText(en: 'Remove image', lv: 'Noņemt attēlu'),
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
                        style: Theme.of(stateContext).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      _profileText(
                        en: 'Tip: attach screenshot for faster bug triage',
                        lv: 'Ieteikums: pievieno ekrānattēlu ātrākai kļūdas analīzei',
                      ),
                      style: Theme.of(stateContext).textTheme.bodySmall,
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
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(stateContext).pop(),
                            child: Text(stateContext.l10n.cancelAction),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              final note = feedbackNote.trim();
                              if (note.isEmpty && screenshotBytes == null) {
                                setSheetState(() {
                                  validationError = _profileText(
                                    en:
                                        'Add details or attach screenshot before sending',
                                    lv:
                                        'Pirms sūtīšanas pievieno aprakstu vai ekrānattēlu',
                                  );
                                });
                                return;
                              }
                              Navigator.of(stateContext).pop(
                                _ProfileFeedbackDialogResult(
                                  type: feedbackType,
                                  note: note,
                                  screenshotBytes: screenshotBytes,
                                  screenshotFileName: screenshotName,
                                ),
                              );
                            },
                            child: Text(_profileText(en: 'Send', lv: 'Sūtīt')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
      await widget.controller.submitFeedback(
        type: result.type,
        note: result.note,
        localeCode: localeCode,
        contextData: <String, Object?>{
          'screen': 'profile',
          'profile_edit_mode': _isEditMode,
        },
        screenshotFileName: result.screenshotFileName,
        screenshotBytes: result.screenshotBytes,
      );
      if (!mounted) {
        return;
      }
      _showSnack(
        _profileText(
          en: 'Thanks! Feedback sent',
          lv: 'Paldies! Atsauksme nosūtīta',
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(
        _profileText(
          en: 'Failed to send feedback',
          lv: 'Neizdevās nosūtīt atsauksmi',
        ),
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

    final pngBytes = await _tryTranscodeToPng(rawBytes);
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
}
