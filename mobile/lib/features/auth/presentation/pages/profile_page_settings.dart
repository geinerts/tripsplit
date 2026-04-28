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
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: t.logOutButton,
      message: t.logoutFromDeviceQuestion,
      confirmLabel: t.logOutButton,
      cancelLabel: t.cancelAction,
      icon: Icons.logout_rounded,
      destructive: true,
    );

    if (!mounted || !confirmed) {
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
      ).pushNamedAndRemoveUntil(AppRouter.authIntro, (route) => false);
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

    final result = await showAppBottomSheet<_ProfileFeedbackDialogResult>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String feedbackType = 'bug';
        String feedbackNote = '';
        Uint8List? screenshotBytes;
        String? screenshotName;
        bool isPickingScreenshot = false;
        String? validationError;

        return StatefulBuilder(
          builder: (stateContext, setSheetState) {
            final colorScheme = Theme.of(stateContext).colorScheme;

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
                  validationError = context.l10n.profileScreenshotSizeMust8Mb;
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
                      context.l10n.profileFeedbackSendTitle,
                      style: Theme.of(stateContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
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
                              Text(context.l10n.profileFeedbackTypeSuggestion),
                            ],
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
                              setSheetState(() {
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
                        style: Theme.of(stateContext).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.profileTipAttachScreenshotFasterBugTriage,
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
                                  validationError = context
                                      .l10n
                                      .profileAddDetailsAttachScreenshotBeforeSending;
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
                            child: Text(context.l10n.profileSendAction),
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
      _showSnack(context.l10n.profileThanksFeedbackSent);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.profileFailedSendFeedback);
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
