part of 'profile_page.dart';

extension _ProfilePageActions on _ProfilePageState {
  static final Uri _portfolioUri = Uri.parse('https://portfolio.egm.lv');

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) {
        return;
      }
      final version = info.version.trim();
      final build = info.buildNumber.trim();
      final label = build.isEmpty ? version : '$version+$build';
      _updateState(() {
        _appVersionLabel = label.isEmpty ? '—' : label;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _appVersionLabel = '—';
      });
    }
  }

  Future<void> _openPortfolioUrl() async {
    final opened = await launchUrl(
      _portfolioUri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _profileText(
              en: 'Could not open website.',
              lv: 'Neizdevās atvērt mājaslapu.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _onFooterVersionTap() async {
    await _openPortfolioUrl();
  }

  Future<void> _onFooterLogoTap() async {
    if (!mounted) {
      return;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await showCupertinoModalPopup<void>(
        context: context,
        builder: (sheetContext) {
          return CupertinoActionSheet(
            title: Text(
              _profileText(en: 'Open website?', lv: 'Atvērt mājaslapu?'),
            ),
            message: Text('portfolio.egm.lv'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_openPortfolioUrl());
                },
                child: Text(
                  _profileText(
                    en: 'Open portfolio.egm.lv',
                    lv: 'Atvērt portfolio.egm.lv',
                  ),
                ),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(sheetContext).pop(),
              child: Text(_profileText(en: 'Cancel', lv: 'Atcelt')),
            ),
          );
        },
      );
      return;
    }

    final shouldOpen = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _profileText(en: 'Open website?', lv: 'Atvērt mājaslapu?'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'https://portfolio.egm.lv',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: Text(
                    _profileText(
                      en: 'Open portfolio.egm.lv',
                      lv: 'Atvērt portfolio.egm.lv',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: Text(_profileText(en: 'Cancel', lv: 'Atcelt')),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (shouldOpen == true) {
      await _openPortfolioUrl();
    }
  }

  void _bindCommandController(ProfilePageCommandController? controller) {
    if (controller == null) {
      return;
    }
    _handledRefreshRequestCount = controller.refreshRequestCount;
    _handledCloseEditModeRequestCount = controller.closeEditModeRequestCount;
    controller.addListener(_onCommandControllerChanged);
  }

  void _unbindCommandController(ProfilePageCommandController? controller) {
    controller?.removeListener(_onCommandControllerChanged);
  }

  void _onCommandControllerChanged() {
    final controller = widget.commandController;
    if (controller == null) {
      return;
    }

    final refreshRequestCount = controller.refreshRequestCount;
    if (refreshRequestCount != _handledRefreshRequestCount) {
      _handledRefreshRequestCount = refreshRequestCount;
      unawaited(_loadProfile());
    }

    final closeEditModeRequestCount = controller.closeEditModeRequestCount;
    if (closeEditModeRequestCount != _handledCloseEditModeRequestCount) {
      _handledCloseEditModeRequestCount = closeEditModeRequestCount;
      if (_isEditMode) {
        _handleEditBackNavigation();
      }
    }
  }

  Future<void> _loadProfile() async {
    _updateState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final user = await widget.controller.loadCurrentUser();
      NotificationPreferences prefs = widget.controller.notificationPreferences;
      try {
        prefs = await widget.controller.loadNotificationPreferences();
      } catch (_) {
        // Keep cached defaults/preferences if endpoint is unavailable.
      }
      if (!mounted) {
        return;
      }
      _applyUser(user);
      _applyNotificationPreferences(prefs);
    } on ApiException catch (error) {
      final fallback = widget.controller.currentUser;
      if (!mounted) {
        return;
      }
      if (fallback != null) {
        _applyUser(fallback);
        _applyNotificationPreferences(
          widget.controller.notificationPreferences,
        );
        _errorText = context.l10n.profileRefreshCachedData;
      } else {
        _errorText = error.message;
      }
    } catch (_) {
      final fallback = widget.controller.currentUser;
      if (!mounted) {
        return;
      }
      if (fallback != null) {
        _applyUser(fallback);
        _applyNotificationPreferences(
          widget.controller.notificationPreferences,
        );
        _errorText = context.l10n.profileRefreshCachedData;
      } else {
        _errorText = context.l10n.unexpectedErrorLoadingProfile;
      }
    } finally {
      if (mounted) {
        _updateState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyUser(AuthUser user) {
    _user = user;
    _avatarBytes = widget.controller.avatarBytesFor(user);
    _initialFullName = _joinFullName(user.firstName, user.lastName);
    _initialEmail = user.email;
    _initialBankCountryCode = (user.bankCountryCode ?? '').trim().toUpperCase();
    _initialBankAccountNumber = (user.bankAccountNumber ?? '').trim();
    _initialBankIban = (user.bankIban ?? '').trim().toUpperCase();
    _initialBankBic = (user.bankBic ?? '').trim().toUpperCase();
    _initialBankSortCode = (user.bankSortCode ?? '').trim();
    _initialRevolutHandle = (user.revolutHandle ?? '').trim();
    _initialRevolutMeLink = (user.revolutMeLink ?? '').trim();
    _initialPaypalMeLink = (user.paypalMeLink ?? '').trim();
    _initialPreferredCurrencyCode =
        AppCurrencyCatalog.normalizeProfilePreferred(
          user.preferredCurrencyCode,
        );
    _fullNameController.text = _initialFullName;
    _emailController.text = user.email ?? '';
    _draftFullName = _initialFullName;
    _draftEmail = user.email ?? '';
    _draftBankCountryCode = _initialBankCountryCode;
    _draftBankAccountNumber = _initialBankAccountNumber;
    _draftBankIban = _initialBankIban;
    _draftBankBic = _initialBankBic;
    _draftBankSortCode = _initialBankSortCode;
    _draftRevolutHandle = _initialRevolutHandle;
    _draftRevolutMeLink = _initialRevolutMeLink;
    _draftPaypalMeLink = _initialPaypalMeLink;
    _draftPreferredCurrencyCode = _initialPreferredCurrencyCode;
    _draftPassword = '';
    _draftRepeatPassword = '';
    _deactivateDraftPassword = '';
    _isDeactivateAccountPage = false;
    _isChangePasswordPage = false;
    _editErrorText = null;
  }

  void _applyNotificationPreferences(NotificationPreferences prefs) {
    _inAppNotificationsEnabled = prefs.inAppBannerEnabled;
    _pushExpenseUpdatesEnabled = prefs.pushExpenseAddedEnabled;
    _pushFriendInvitesEnabled = prefs.pushFriendInvitesEnabled;
    _pushTripUpdatesEnabled = prefs.pushTripUpdatesEnabled;
    _pushSettlementUpdatesEnabled = prefs.pushSettlementUpdatesEnabled;
  }

  String _joinFullName(String? firstName, String? lastName) {
    final first = (firstName ?? '').trim();
    final last = (lastName ?? '').trim();
    return '$first $last'.trim();
  }

  ({String firstName, String lastName})? _parseFullName(String raw) {
    final normalized = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.isEmpty) {
      return null;
    }
    final parts = normalized.split(' ');
    if (parts.length < 2) {
      return null;
    }
    final firstName = parts.first.trim();
    final lastName = parts.sublist(1).join(' ').trim();
    if (firstName.length < 2 || lastName.length < 2) {
      return null;
    }
    return (firstName: firstName, lastName: lastName);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
  }

  String _normalizeDraftText(String value) => value.trim();

  String _normalizeDraftIban(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();

  String _normalizeDraftBic(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();

  String _normalizeDraftCountryCode(String value) => value.trim().toUpperCase();

  String _normalizeDraftSortCode(String value) =>
      value.trim().replaceAll(RegExp(r'[^0-9]'), '');

  String _normalizeDraftAccountNumber(String value) =>
      value.trim().replaceAll(RegExp(r'[^0-9A-Za-z]'), '');

  Map<String, String?> _buildPaymentDetailsPatch() {
    final patch = <String, String?>{};

    void putIfChanged({
      required String key,
      required String initial,
      required String draft,
      required String Function(String value) normalize,
    }) {
      if (normalize(initial) == normalize(draft)) {
        return;
      }
      patch[key] = draft.trim();
    }

    putIfChanged(
      key: 'bank_country_code',
      initial: _initialBankCountryCode,
      draft: _draftBankCountryCode,
      normalize: _normalizeDraftCountryCode,
    );
    putIfChanged(
      key: 'bank_account_number',
      initial: _initialBankAccountNumber,
      draft: _draftBankAccountNumber,
      normalize: _normalizeDraftAccountNumber,
    );
    putIfChanged(
      key: 'bank_iban',
      initial: _initialBankIban,
      draft: _draftBankIban,
      normalize: _normalizeDraftIban,
    );
    putIfChanged(
      key: 'bank_bic',
      initial: _initialBankBic,
      draft: _draftBankBic,
      normalize: _normalizeDraftBic,
    );
    putIfChanged(
      key: 'bank_sort_code',
      initial: _initialBankSortCode,
      draft: _draftBankSortCode,
      normalize: _normalizeDraftSortCode,
    );
    putIfChanged(
      key: 'revolut_handle',
      initial: _initialRevolutHandle,
      draft: _draftRevolutHandle,
      normalize: _normalizeDraftText,
    );
    putIfChanged(
      key: 'revolut_me_link',
      initial: _initialRevolutMeLink,
      draft: _draftRevolutMeLink,
      normalize: _normalizeDraftText,
    );
    putIfChanged(
      key: 'paypal_me_link',
      initial: _initialPaypalMeLink,
      draft: _draftPaypalMeLink,
      normalize: _normalizeDraftText,
    );

    return patch;
  }

  Future<bool> _onSavePressed() async {
    final t = context.l10n;
    if (_isSubmitting || _isLoading) {
      return false;
    }

    final fullNameInput = _fullNameController.text.trim();
    final parsedName = fullNameInput.isEmpty
        ? null
        : _parseFullName(fullNameInput);
    if (fullNameInput.isNotEmpty && parsedName == null) {
      _updateState(() {
        _errorText = t.fullNameValidation;
      });
      return false;
    }
    if (fullNameInput.isEmpty && _initialFullName.isNotEmpty) {
      _updateState(() {
        _errorText = t.fullNameValidation;
      });
      return false;
    }
    final normalizedFullName = parsedName == null
        ? _initialFullName
        : _joinFullName(parsedName.firstName, parsedName.lastName);
    final email = _emailController.text.trim().toLowerCase();
    final baseEmail = (_initialEmail ?? '').trim().toLowerCase();
    final password = _passwordController.text;
    final repeat = _repeatController.text;

    final emailChanged = email != baseEmail;
    final passwordTouched = password.isNotEmpty || repeat.isNotEmpty;
    final wantsCredentialsUpdate = emailChanged || passwordTouched;
    final paymentPatch = _buildPaymentDetailsPatch();
    final paymentDetailsChanged = paymentPatch.isNotEmpty;
    final preferredCurrencyCode = AppCurrencyCatalog.normalizeProfilePreferred(
      _draftPreferredCurrencyCode,
    );
    final preferredCurrencyChanged =
        preferredCurrencyCode != _initialPreferredCurrencyCode;

    if (wantsCredentialsUpdate) {
      if (!_isValidEmail(email)) {
        _updateState(() {
          _errorText = t.invalidEmailFormat;
        });
        return false;
      }
      if (password.length < 8) {
        _updateState(() {
          _errorText = t.passwordMinLengthShort;
        });
        return false;
      }
      if (password != repeat) {
        _updateState(() {
          _errorText = t.passwordsDoNotMatch;
        });
        return false;
      }
    }

    final fullNameChanged = normalizedFullName != _initialFullName;
    if (!fullNameChanged &&
        !wantsCredentialsUpdate &&
        !paymentDetailsChanged &&
        !preferredCurrencyChanged) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.noChangesToSave)));
      return false;
    }

    _updateState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final updated = await widget.controller.updateProfile(
        firstName: fullNameChanged ? parsedName?.firstName : null,
        lastName: fullNameChanged ? parsedName?.lastName : null,
        email: wantsCredentialsUpdate ? email : null,
        password: wantsCredentialsUpdate ? password : null,
        preferredCurrencyCode: preferredCurrencyChanged
            ? preferredCurrencyCode
            : null,
        paymentDetails: paymentPatch.isEmpty ? null : paymentPatch,
      );
      if (!mounted) {
        return false;
      }
      _applyUser(updated);
      widget.onProfileChanged?.call();
      _passwordController.clear();
      _repeatController.clear();
      _updateState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.profileUpdated)));
      return true;
    } on ApiException catch (error) {
      if (!mounted) {
        return false;
      }
      _updateState(() {
        _errorText = error.message;
      });
      return false;
    } catch (_) {
      if (!mounted) {
        return false;
      }
      _updateState(() {
        _errorText = context.l10n.unexpectedErrorUpdatingProfile;
      });
      return false;
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  bool _hasAvatarImage() {
    final hasBytes = _avatarBytes != null && _avatarBytes!.isNotEmpty;
    final hasRemote = widget.controller.avatarUrlFor(_user) != null;
    return hasBytes || hasRemote;
  }

  Future<void> _onAvatarTapped() async {
    if (_isSubmitting || _isLoading) {
      return;
    }

    final selected = await _showAvatarActionSheet();
    if (!mounted || selected == null) {
      return;
    }
    if (selected == _AvatarSourceOption.remove) {
      await _onRemoveAvatarPressed();
      return;
    }

    final source = selected == _AvatarSourceOption.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    await _pickAvatarFromSource(source);
  }

  Future<_AvatarSourceOption?> _showAvatarActionSheet() async {
    final t = context.l10n;
    final hasAvatar = _hasAvatarImage();
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return showCupertinoModalPopup<_AvatarSourceOption>(
        context: context,
        builder: (cupertinoContext) => CupertinoActionSheet(
          actions: [
            if (hasAvatar)
              CupertinoActionSheetAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(
                  cupertinoContext,
                ).pop(_AvatarSourceOption.remove),
                child: Text(t.removeAvatarAction),
              ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(
                cupertinoContext,
              ).pop(_AvatarSourceOption.camera),
              child: Text(t.takePhotoAction),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.of(
                cupertinoContext,
              ).pop(_AvatarSourceOption.library),
              child: Text(t.chooseFromLibraryAction),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(cupertinoContext).pop(),
            child: Text(t.cancelAction),
          ),
        ),
      );
    }

    return showModalBottomSheet<_AvatarSourceOption>(
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
                ).pop(_AvatarSourceOption.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(t.chooseFromLibraryAction),
                onTap: () => Navigator.of(
                  bottomSheetContext,
                ).pop(_AvatarSourceOption.library),
              ),
              if (hasAvatar)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(t.removeAvatarAction),
                  onTap: () => Navigator.of(
                    bottomSheetContext,
                  ).pop(_AvatarSourceOption.remove),
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
  }

  Future<void> _pickAvatarFromSource(ImageSource source) async {
    if (_isSubmitting || _isLoading) {
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 94,
        maxWidth: 2048,
        maxHeight: 2048,
      );
      if (!mounted || picked == null) {
        return;
      }

      final cropped = await AppImageCropper.cropAvatar(
        context: context,
        source: picked,
      );
      if (!mounted || cropped == null) {
        return;
      }

      final rawBytes = await cropped.readAsBytes();
      final fallbackName = picked.name.trim().isEmpty
          ? (source == ImageSource.camera
                ? 'avatar_camera.jpg'
                : 'avatar_gallery.jpg')
          : picked.name.trim();
      final incomingName = _fileNameFromPath(
        cropped.path,
        fallbackName: fallbackName,
      );
      final prepared = await _prepareAvatarForUpload(
        rawBytes: rawBytes,
        fileName: incomingName,
      );
      if (!mounted) {
        return;
      }
      if (prepared == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.avatarPickFailed)));
        return;
      }

      final bytes = prepared.bytes;
      final fileName = prepared.fileName;
      if (bytes.length > _ProfilePageState._maxAvatarBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.avatarFileTooLarge)),
        );
        return;
      }

      final updated = await widget.controller.uploadAvatar(
        fileName: fileName,
        bytes: bytes,
      );
      if (!mounted || updated == null) {
        return;
      }
      _applyUser(updated);
      _updateState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.avatarUpdatedMessage)),
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.avatarPickFailed)));
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

  Future<({Uint8List bytes, String fileName})?> _prepareAvatarForUpload({
    required Uint8List rawBytes,
    required String fileName,
  }) async {
    if (rawBytes.isEmpty) {
      return null;
    }

    final originalName = fileName.trim().isEmpty ? 'avatar' : fileName.trim();
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
      _showSnack(
        _profileText(
          en: 'This image format is not supported on this device. Please choose JPG or PNG.',
          lv: 'Šis attēla formāts šajā ierīcē netiek atbalstīts. Lūdzu, izvēlies JPG vai PNG.',
        ),
      );
      return null;
    }

    final dot = originalName.lastIndexOf('.');
    final baseName = dot > 0 ? originalName.substring(0, dot) : originalName;
    final safeBase = baseName.trim().isEmpty ? 'avatar' : baseName.trim();
    return (bytes: pngBytes, fileName: '$safeBase.png');
  }

  Future<Uint8List?> _tryTranscodeToPng(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _onRemoveAvatarPressed() async {
    if (_isSubmitting || _isLoading) {
      return;
    }
    AuthUser? updated;
    try {
      updated = await widget.controller.removeAvatar();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }
    if (!mounted || updated == null) {
      return;
    }
    _applyUser(updated);
    _updateState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.avatarRemovedMessage)));
  }

  Future<void> _setNotificationPreferences({
    bool? inAppBannerEnabled,
    bool? pushExpenseAddedEnabled,
    bool? pushFriendInvitesEnabled,
    bool? pushTripUpdatesEnabled,
    bool? pushSettlementUpdatesEnabled,
    required VoidCallback applyOptimistic,
    required VoidCallback rollback,
  }) async {
    if (_isLoading || _isSubmitting) {
      return;
    }

    _updateState(applyOptimistic);
    try {
      final prefs = await widget.controller.updateNotificationPreferences(
        inAppBannerEnabled: inAppBannerEnabled,
        pushExpenseAddedEnabled: pushExpenseAddedEnabled,
        pushFriendInvitesEnabled: pushFriendInvitesEnabled,
        pushTripUpdatesEnabled: pushTripUpdatesEnabled,
        pushSettlementUpdatesEnabled: pushSettlementUpdatesEnabled,
      );
      if (!mounted) {
        return;
      }
      _updateState(() {
        _applyNotificationPreferences(prefs);
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(rollback);
      _showSnack(
        error.message.trim().isNotEmpty
            ? error.message
            : 'Failed to save notification settings.',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(rollback);
      _showSnack(
        _profileText(
          en: 'Failed to save notification settings.',
          lv: 'Neizdevās saglabāt paziņojumu iestatījumus.',
        ),
      );
    }
  }

  Future<void> _setInAppNotificationsEnabled(bool value) async {
    final previous = _inAppNotificationsEnabled;
    await _setNotificationPreferences(
      inAppBannerEnabled: value,
      applyOptimistic: () {
        _inAppNotificationsEnabled = value;
      },
      rollback: () {
        _inAppNotificationsEnabled = previous;
      },
    );
  }

  Future<void> _setPushExpenseUpdatesEnabled(bool value) async {
    final previous = _pushExpenseUpdatesEnabled;
    await _setNotificationPreferences(
      pushExpenseAddedEnabled: value,
      applyOptimistic: () {
        _pushExpenseUpdatesEnabled = value;
      },
      rollback: () {
        _pushExpenseUpdatesEnabled = previous;
      },
    );
  }

  Future<void> _setPushFriendInvitesEnabled(bool value) async {
    final previous = _pushFriendInvitesEnabled;
    await _setNotificationPreferences(
      pushFriendInvitesEnabled: value,
      applyOptimistic: () {
        _pushFriendInvitesEnabled = value;
      },
      rollback: () {
        _pushFriendInvitesEnabled = previous;
      },
    );
  }

  Future<void> _setPushTripUpdatesEnabled(bool value) async {
    final previous = _pushTripUpdatesEnabled;
    await _setNotificationPreferences(
      pushTripUpdatesEnabled: value,
      applyOptimistic: () {
        _pushTripUpdatesEnabled = value;
      },
      rollback: () {
        _pushTripUpdatesEnabled = previous;
      },
    );
  }

  Future<void> _setPushSettlementUpdatesEnabled(bool value) async {
    final previous = _pushSettlementUpdatesEnabled;
    await _setNotificationPreferences(
      pushSettlementUpdatesEnabled: value,
      applyOptimistic: () {
        _pushSettlementUpdatesEnabled = value;
      },
      rollback: () {
        _pushSettlementUpdatesEnabled = previous;
      },
    );
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _AvatarSourceOption { camera, library, remove }
