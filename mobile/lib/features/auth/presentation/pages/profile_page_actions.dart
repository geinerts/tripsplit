part of 'profile_page.dart';

extension _ProfilePageActions on _ProfilePageState {
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
      try {
        await widget.controller.loadNotificationPreferences();
      } catch (_) {
        // Keep cached defaults/preferences if endpoint is unavailable.
      }
      if (!mounted) {
        return;
      }
      _applyUser(user);
    } on ApiException catch (error) {
      final fallback = widget.controller.currentUser;
      if (!mounted) {
        return;
      }
      if (fallback != null) {
        _applyUser(fallback);
        // Offline is shown once, next to the bell.
        _errorText = error.isNetworkError
            ? null
            : context.l10n.profileRefreshCachedData;
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
    _initialWisePayLink = (user.wisePayLink ?? '').trim();
    _initialPreferredCurrencyCode =
        AppCurrencyCatalog.normalizeProfilePreferred(
          user.preferredCurrencyCode,
        );
    _fullNameController.text = _initialFullName;
    _emailController.text = user.email ?? '';
    _draftFullName = _initialFullName;
    _draftBankCountryCode = _initialBankCountryCode;
    _draftBankAccountNumber = _initialBankAccountNumber;
    _draftBankIban = _initialBankIban;
    _draftBankBic = _initialBankBic;
    _draftBankSortCode = _initialBankSortCode;
    _draftRevolutHandle = _initialRevolutHandle;
    _draftRevolutMeLink = _initialRevolutMeLink;
    _draftPaypalMeLink = _initialPaypalMeLink;
    _draftWisePayLink = _initialWisePayLink;
    _draftPreferredCurrencyCode = _initialPreferredCurrencyCode;
    _editErrorText = null;
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
    putIfChanged(
      key: 'wise_pay_link',
      initial: _initialWisePayLink,
      draft: _draftWisePayLink,
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
    if (selected == _AvatarSourceOption.editCrop) {
      await _editAvatarCrop();
      return;
    }

    final source = selected == _AvatarSourceOption.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    await _pickAvatarFromSource(source);
  }

  Future<void> _editAvatarCrop() async {
    final updated = await widget.controller.editAvatarCrop(
      context,
      context.l10n.imageCropperAdjustAvatar,
    );
    if (!mounted || updated == null) return;
    _applyUser(updated);
    _updateState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.avatarUpdatedMessage)));
  }

  Future<_AvatarSourceOption?> _showAvatarActionSheet() async {
    final t = context.l10n;
    final hasAvatar = _hasAvatarImage();

    return showAppPlatformActionSheet<_AvatarSourceOption>(
      context: context,
      cancelLabel: t.cancelAction,
      actions: [
        if (hasAvatar &&
            (widget.controller.currentUser?.avatarUrl ?? '').isNotEmpty)
          AppPlatformAction(
            value: _AvatarSourceOption.editCrop,
            icon: Icons.crop_outlined,
            title: t.imageCropEditAction,
          ),
        AppPlatformAction(
          value: _AvatarSourceOption.camera,
          icon: Icons.photo_camera_outlined,
          title: t.takePhotoAction,
        ),
        AppPlatformAction(
          value: _AvatarSourceOption.library,
          icon: Icons.photo_library_outlined,
          title: t.chooseFromLibraryAction,
        ),
        if (hasAvatar)
          AppPlatformAction(
            value: _AvatarSourceOption.remove,
            icon: Icons.delete_outline,
            title: t.removeAvatarAction,
            destructive: true,
          ),
      ],
    );
  }

  Future<void> _pickAvatarFromSource(ImageSource source) async {
    if (_isSubmitting || _isLoading) {
      return;
    }

    try {
      final pick = await pickAndCropImage(
        context: context,
        source: source,
        title: context.l10n.imageCropperAdjustAvatar,
        aspectRatio: 1,
        maxEdge: 1024,
        circular: true,
      );
      if (!mounted || pick == null) {
        return;
      }

      final bytes = pick.bytes;
      if (bytes.length > _ProfilePageState._maxAvatarBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.avatarFileTooLarge)),
        );
        return;
      }

      final updated = await widget.controller.uploadAvatar(
        fileName: 'avatar.jpg',
        bytes: bytes,
        cropSource: pick.source,
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

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _AvatarSourceOption { editCrop, camera, library, remove }
