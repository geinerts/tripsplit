part of 'profile_page.dart';

extension _ProfilePageEditFlow on _ProfilePageState {
  void _openDeactivateAccountPage() {
    if (_isLoading || _isSubmitting) {
      return;
    }
    _updateState(() {
      _isEditMode = true;
      _editSession += 1;
      _isDeactivateAccountPage = true;
      _isChangePasswordPage = false;
      _deactivateDraftPassword = '';
      _activeEditField = null;
      _editErrorText = null;
      _errorText = null;
    });
    widget.onEditModeChanged?.call(true);
  }

  void _openChangePasswordPage() {
    if (_isLoading || _isSubmitting) {
      return;
    }
    final email = (_initialEmail ?? '').trim().toLowerCase();
    if (email.isEmpty || !_isValidEmail(email)) {
      _showSnack(
        context.l10n.profileEditSetValidEmailEditProfileChangingPassword,
      );
      return;
    }
    _updateState(() {
      _isEditMode = true;
      _editSession += 1;
      _isDeactivateAccountPage = false;
      _isChangePasswordPage = true;
      _draftPassword = '';
      _draftRepeatPassword = '';
      _activeEditField = null;
      _editErrorText = null;
      _errorText = null;
    });
    widget.onEditModeChanged?.call(true);
  }

  void _openEditProfilePage() {
    if (_isLoading || _isSubmitting) {
      return;
    }

    _updateState(() {
      _isEditMode = true;
      _editSession += 1;
      _isDeactivateAccountPage = false;
      _isChangePasswordPage = false;
      _deactivateDraftPassword = '';
      _activeEditField = null;
      _draftFullName = _fullNameController.text.trim();
      _draftEmail = _emailController.text.trim();
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
      _editErrorText = null;
      _errorText = null;
    });
    widget.onEditModeChanged?.call(true);
  }

  void _closeEditMode() {
    _updateState(() {
      _isEditMode = false;
      _isDeactivateAccountPage = false;
      _isChangePasswordPage = false;
      _deactivateDraftPassword = '';
      _activeEditField = null;
      _draftFullName = _fullNameController.text.trim();
      _draftEmail = _emailController.text.trim();
      _draftBankCountryCode = _initialBankCountryCode;
      _draftBankAccountNumber = _initialBankAccountNumber;
      _draftBankIban = _initialBankIban;
      _draftBankBic = _initialBankBic;
      _draftBankSortCode = _initialBankSortCode;
      _draftRevolutHandle = _initialRevolutHandle;
      _draftRevolutMeLink = _initialRevolutMeLink;
      _draftPaypalMeLink = _initialPaypalMeLink;
      _draftPreferredCurrencyCode = _initialPreferredCurrencyCode;
      _editErrorText = null;
      _draftPassword = '';
      _draftRepeatPassword = '';
    });
    widget.onEditModeChanged?.call(false);
  }

  void _handleEditBackNavigation() {
    _closeEditMode();
  }

  void _onDeactivatePasswordChanged(String value) {
    _deactivateDraftPassword = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  Future<void> _onDeactivateAccountPressed() async {
    if (_isSubmitting || _isLoading) {
      return;
    }
    final password = _deactivateDraftPassword;

    _updateState(() {
      _isSubmitting = true;
      _editErrorText = null;
    });
    try {
      await widget.controller.deactivateAccount(password: password);
      if (!mounted) {
        return;
      }
      await widget.controller.logout();
      if (!mounted) {
        return;
      }
      _showSnack(
        context.l10n.profileEditDeactivatedReactivationLinkEmailRestoreAccess,
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.authIntro, (route) => false);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText = context.l10n.profileEditCouldNotDeactivateTryAgain;
      });
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _onSendDeletionLinkPressed() async {
    if (_isSubmitting || _isLoading) {
      return;
    }
    final password = _deactivateDraftPassword;

    _updateState(() {
      _isSubmitting = true;
      _editErrorText = null;
    });
    try {
      await widget.controller.requestAccountDeletionLink(password: password);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.profileEditDeletionLinkSentEmail);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText =
            context.l10n.profileEditCouldNotSendDeletionLinkTryAgain;
      });
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _startInlineFieldEdit(_ProfileEditField field) {
    if (_isSubmitting) {
      return;
    }
    _updateState(() {
      _activeEditField = field;
      _editErrorText = null;
      switch (field) {
        case _ProfileEditField.fullName:
          _draftFullName = _fullNameController.text.trim();
          break;
        case _ProfileEditField.email:
          _draftEmail = _emailController.text.trim();
          _draftPassword = '';
          _draftRepeatPassword = '';
          break;
        case _ProfileEditField.preferredCurrency:
          _draftPreferredCurrencyCode =
              AppCurrencyCatalog.normalizeProfilePreferred(
                _draftPreferredCurrencyCode,
              );
          break;
      }
    });
  }

  void _onDraftFullNameChanged(String value) {
    _draftFullName = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftEmailChanged(String value) {
    _draftEmail = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftPasswordChanged(String value) {
    _draftPassword = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftRepeatPasswordChanged(String value) {
    _draftRepeatPassword = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  Future<void> _saveInlineField(_ProfileEditField field) async {
    final t = context.l10n;
    if (_isSubmitting || _isLoading) {
      return;
    }

    if (field == _ProfileEditField.fullName) {
      final proposed = _draftFullName.trim();
      final current = _fullNameController.text.trim();
      if (proposed == current) {
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
        });
        return;
      }
      _fullNameController.text = proposed;
      _emailController.text = _emailController.text.trim();
      _passwordController.clear();
      _repeatController.clear();
    } else if (field == _ProfileEditField.email) {
      final proposed = _draftEmail.trim().toLowerCase();
      final current = _emailController.text.trim().toLowerCase();
      if (proposed == current) {
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
        });
        return;
      }
      if (!_isValidEmail(proposed)) {
        _updateState(() {
          _editErrorText = t.invalidEmailFormat;
        });
        return;
      }

      final currentPassword = _draftPassword.trim();
      if (currentPassword.isEmpty) {
        _updateState(() {
          _editErrorText =
              context.l10n.profileEditEnterCurrentPasswordChangeEmail;
        });
        return;
      }

      _updateState(() {
        _isSubmitting = true;
        _editErrorText = null;
      });
      try {
        await widget.controller.requestEmailChange(
          newEmail: proposed,
          currentPassword: currentPassword,
        );
        if (!mounted) {
          return;
        }
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
          _draftEmail = _emailController.text.trim();
          _draftPassword = '';
          _draftRepeatPassword = '';
        });
        _showSnack(
          context.l10n.profileEditVerificationWasSentNewEmailSecurityNoticeWas,
        );
      } on ApiException catch (error) {
        if (!mounted) {
          return;
        }
        _updateState(() {
          _editErrorText = error.message;
        });
      } catch (_) {
        if (!mounted) {
          return;
        }
        _updateState(() {
          _editErrorText =
              context.l10n.profileEditCouldNotStartEmailChangeRightNowTry;
        });
      } finally {
        if (mounted) {
          _updateState(() {
            _isSubmitting = false;
          });
        }
      }
      return;
    } else if (field == _ProfileEditField.preferredCurrency) {
      final proposed = AppCurrencyCatalog.normalize(
        _draftPreferredCurrencyCode,
      );
      final current = AppCurrencyCatalog.normalize(
        _initialPreferredCurrencyCode,
      );
      if (proposed == current) {
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
        });
        return;
      }
      _draftPreferredCurrencyCode = proposed;
    }

    final success = await _onSavePressed();
    if (!mounted) {
      return;
    }
    if (!success) {
      _updateState(() {
        final inlineMessage = (_errorText ?? '').trim();
        if (inlineMessage.isNotEmpty) {
          _editErrorText = inlineMessage;
          _errorText = null;
        }
      });
      return;
    }

    _updateState(() {
      _activeEditField = null;
      _editErrorText = null;
      _draftPassword = '';
      _draftRepeatPassword = '';
    });
  }

  Widget _buildInlineEditProfilePage(BuildContext context) {
    if (_isDeactivateAccountPage) {
      return _buildDeactivateAccountPage(context);
    }
    if (_isChangePasswordPage) {
      return _buildChangePasswordPage(context);
    }

    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
      child: Column(
        key: ValueKey('profile-edit-page-$_editSession'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEditableProfileRow(
            context: context,
            field: _ProfileEditField.fullName,
            label: t.fullNameLabel,
            displayValue: _draftFullName.trim().isEmpty
                ? t.notSetValue
                : _draftFullName.trim(),
            editor: _buildFullNameInlineEditor,
          ),
          const Divider(height: 1),
          _buildEditableProfileRow(
            context: context,
            field: _ProfileEditField.email,
            label: t.emailAddressLabel,
            displayValue: _draftEmail.trim().isEmpty
                ? t.notSetValue
                : _draftEmail.trim(),
            labelTrailing: _buildPrimaryEmailBadge(context),
            editor: _buildEmailInlineEditor,
          ),
          const Divider(height: 1),
          _buildEditableProfileRow(
            context: context,
            field: _ProfileEditField.preferredCurrency,
            label: context.l10n.profileEditOverviewCurrency,
            displayValue: _preferredCurrencyDisplayValue(),
            editor: _buildPreferredCurrencyInlineEditor,
          ),
          const Divider(height: 1),
          _buildProfileSectionTile(
            context: context,
            title: context.l10n.profileEditPaymentMethod,
            icon: Icons.account_balance_wallet_outlined,
            subtitle: context.l10n.profileEditBankTransferRevolutPaypalMe,
            onTap: _isSubmitting || _isLoading
                ? null
                : () => unawaited(_openPaymentInfoPage()),
          ),
          if (_editErrorText != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _editErrorText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeactivateAccountPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        key: ValueKey('deactivate-page-$_editSession'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.profileDeactivateAccount,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            context
                .l10n
                .profileEditDeactivateAccessRequestEmailLinkPermanentlyDeletePassword,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: ValueKey('deactivate-password-$_editSession'),
            initialValue: _deactivateDraftPassword,
            textInputAction: TextInputAction.done,
            obscureText: true,
            decoration: InputDecoration(
              labelText: context.l10n.passwordLabel,
              hintText:
                  context.l10n.profileEditEnterPasswordOptionalGoogleApple,
            ),
            onChanged: _onDeactivatePasswordChanged,
            onFieldSubmitted: (_) => unawaited(_onDeactivateAccountPressed()),
          ),
          if (_editErrorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _editErrorText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : _onDeactivateAccountPressed,
              icon: const Icon(Icons.person_off),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              label: Text(context.l10n.profileDeactivateAccount),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _onSendDeletionLinkPressed,
              icon: const Icon(Icons.mark_email_read_outlined),
              label: Text(context.l10n.profileEditSendDeletionLinkEmail),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _closeEditMode,
              child: Text(context.l10n.profileEditBackProfile),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSubmitPasswordChange() async {
    final t = context.l10n;
    if (_isSubmitting || _isLoading) {
      return;
    }
    final email = (_initialEmail ?? '').trim().toLowerCase();
    if (email.isEmpty || !_isValidEmail(email)) {
      _updateState(() {
        _editErrorText =
            context.l10n.profileEditSetValidEmailProfileChangingPassword;
      });
      return;
    }
    if (_draftPassword.trim().length < 8) {
      _updateState(() {
        _editErrorText = t.passwordMinLengthShort;
      });
      return;
    }
    if (_draftPassword != _draftRepeatPassword) {
      _updateState(() {
        _editErrorText = t.passwordsDoNotMatch;
      });
      return;
    }

    _updateState(() {
      _isSubmitting = true;
      _editErrorText = null;
    });
    try {
      final updated = await widget.controller.updateProfile(
        email: email,
        password: _draftPassword,
      );
      if (!mounted) {
        return;
      }
      _applyUser(updated);
      _showSnack(context.l10n.profileEditPasswordUpdated);
      _closeEditMode();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText = context.l10n.profileEditFailedUpdatePassword;
      });
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildChangePasswordPage(BuildContext context) {
    final t = context.l10n;
    final email = (_initialEmail ?? '').trim().toLowerCase();
    return AppSurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        key: ValueKey('change-password-page-$_editSession'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.profileChangePassword,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.profileEditEmail(email),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppDesign.mutedColor(context),
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: ValueKey('change-password-$_editSession'),
            initialValue: _draftPassword,
            textInputAction: TextInputAction.next,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: t.newPasswordLabel,
              helperText: t.passwordMinLengthShort,
            ),
            onChanged: _onDraftPasswordChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            key: ValueKey('change-password-repeat-$_editSession'),
            initialValue: _draftRepeatPassword,
            textInputAction: TextInputAction.done,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(labelText: t.repeatNewPasswordLabel),
            onChanged: _onDraftRepeatPasswordChanged,
            onFieldSubmitted: (_) {
              unawaited(_onSubmitPasswordChange());
            },
          ),
          if (_editErrorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _editErrorText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : _closeEditMode,
                  child: Text(t.cancelAction),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () {
                          unawaited(_onSubmitPasswordChange());
                        },
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(t.saveAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableProfileRow({
    required BuildContext context,
    required _ProfileEditField field,
    required String label,
    required String displayValue,
    required Widget Function(BuildContext) editor,
    Widget? labelTrailing,
  }) {
    final isActive = _activeEditField == field;
    final t = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (labelTrailing != null && isActive) ...[
                  const SizedBox(height: 6),
                  labelTrailing,
                ],
                const SizedBox(height: 6),
                if (isActive)
                  editor(context)
                else
                  Text(
                    displayValue,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isSubmitting
                ? null
                : () {
                    if (isActive) {
                      _saveInlineField(field);
                    } else {
                      _startInlineFieldEdit(field);
                    }
                  },
            icon: _isSubmitting && isActive
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(isActive ? Icons.check_rounded : Icons.edit_outlined),
            tooltip: isActive ? t.saveAction : t.editAction,
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryEmailBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dotColor = colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: dotColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            context.l10n.profileEditPrimary,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: dotColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  AppCurrencyOption _preferredCurrencyOptionFor(String? code) {
    final normalized = AppCurrencyCatalog.normalizeProfilePreferred(code);
    for (final item in AppCurrencyCatalog.profilePreferredSupported) {
      if (item.code == normalized) {
        return item;
      }
    }
    return AppCurrencyCatalog.profilePreferredSupported.first;
  }

  String _preferredCurrencyDisplayValue() {
    final option = _preferredCurrencyOptionFor(_draftPreferredCurrencyCode);
    return '${option.symbol} ${option.code} - ${option.label}';
  }

  Future<void> _pickPreferredCurrencyCode() async {
    if (_isSubmitting || _isLoading) {
      return;
    }

    var query = '';
    final currentCode = AppCurrencyCatalog.normalizeProfilePreferred(
      _draftPreferredCurrencyCode,
    );
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (pickerContext) {
        final maxHeight = MediaQuery.sizeOf(pickerContext).height * 0.62;
        return SizedBox(
          height: maxHeight,
          child: StatefulBuilder(
            builder: (pickerContext, setPickerState) {
              final normalizedQuery = query.trim().toUpperCase();
              final filtered = AppCurrencyCatalog.profilePreferredSupported
                  .where((item) {
                    if (normalizedQuery.isEmpty) {
                      return true;
                    }
                    final haystack = '${item.code} ${item.label} ${item.symbol}'
                        .toUpperCase();
                    return haystack.contains(normalizedQuery);
                  })
                  .toList(growable: false);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                    child: TextField(
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setPickerState(() {
                          query = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: context.l10n.profileEditSearchCurrency,
                        prefixIcon: const Icon(Icons.search_rounded),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              context.l10n.profileEditNoCurrenciesFound,
                              style: Theme.of(
                                pickerContext,
                              ).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              final selected = item.code == currentCode;
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () => Navigator.of(
                                    pickerContext,
                                  ).pop(item.code),
                                  child: Ink(
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      10,
                                      12,
                                      10,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: selected
                                          ? Theme.of(pickerContext)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.10)
                                          : Theme.of(pickerContext)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withValues(alpha: 0.45),
                                      border: Border.all(
                                        color: selected
                                            ? Theme.of(
                                                pickerContext,
                                              ).colorScheme.primary
                                            : AppDesign.cardStroke(
                                                pickerContext,
                                              ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Theme.of(
                                              pickerContext,
                                            ).colorScheme.surface,
                                            border: Border.all(
                                              color: AppDesign.cardStroke(
                                                pickerContext,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            item.symbol,
                                            style: Theme.of(pickerContext)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            '${item.code} - ${item.label}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(pickerContext)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        if (selected)
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: Theme.of(
                                              pickerContext,
                                            ).colorScheme.primary,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (!mounted || picked == null) {
      return;
    }
    _updateState(() {
      _draftPreferredCurrencyCode =
          AppCurrencyCatalog.normalizeProfilePreferred(picked);
      if (_editErrorText != null) {
        _editErrorText = null;
      }
    });
  }

  Widget _buildPreferredCurrencyInlineEditor(BuildContext context) {
    final option = _preferredCurrencyOptionFor(_draftPreferredCurrencyCode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isSubmitting
                ? null
                : () => unawaited(_pickPreferredCurrencyCode()),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppDesign.cardStroke(context)),
              ),
              child: Row(
                children: [
                  Text(
                    option.symbol,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${option.code} - ${option.label}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.profileEditOverviewTotalsConvertedCurrency,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppDesign.mutedColor(context)),
        ),
      ],
    );
  }

  Future<void> _openPaymentInfoPage() async {
    if (_isSubmitting || _isLoading) {
      return;
    }
    final result = await Navigator.of(context).push<_PaymentInfoEditorResult>(
      MaterialPageRoute<_PaymentInfoEditorResult>(
        fullscreenDialog: true,
        builder: (pageContext) => _PaymentInfoEditorPage(
          initialBankCountryCode: _draftBankCountryCode,
          initialBankAccountNumber: _draftBankAccountNumber,
          initialBankIban: _draftBankIban,
          initialBankBic: _draftBankBic,
          initialBankSortCode: _draftBankSortCode,
          initialRevolutHandle: _draftRevolutHandle,
          initialRevolutMeLink: _draftRevolutMeLink,
          initialPaypalMeLink: _draftPaypalMeLink,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    _updateState(() {
      _draftBankCountryCode = result.bankCountryCode.trim().toUpperCase();
      _draftBankAccountNumber = result.bankAccountNumber.trim();
      _draftBankIban = result.bankIban.trim().toUpperCase();
      _draftBankBic = result.bankBic.trim().toUpperCase();
      _draftBankSortCode = result.bankSortCode.trim();
      _draftRevolutHandle = result.revolutHandle.trim();
      _draftRevolutMeLink = result.revolutMeLink.trim();
      _draftPaypalMeLink = result.paypalMeLink.trim();
      _activeEditField = null;
      _editErrorText = null;
      _errorText = null;
    });

    await _savePaymentDetailsOnly();
  }

  Future<void> _savePaymentDetailsOnly() async {
    if (_isSubmitting || _isLoading) {
      return;
    }
    final paymentPatch = _buildPaymentDetailsPatch();
    if (paymentPatch.isEmpty) {
      _showSnack(context.l10n.noChangesToSave);
      return;
    }

    _updateState(() {
      _isSubmitting = true;
      _editErrorText = null;
      _errorText = null;
    });

    try {
      final updated = await widget.controller.updateProfile(
        paymentDetails: paymentPatch,
      );
      if (!mounted) {
        return;
      }
      _applyUser(updated);
      _showSnack(context.l10n.profileEditPaymentInfoUpdated);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _editErrorText =
            context.l10n.profileEditCouldNotSavePaymentInfoTryAgain;
      });
    } finally {
      if (mounted) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildFullNameInlineEditor(BuildContext context) {
    final t = context.l10n;
    return TextFormField(
      key: ValueKey('edit-full-name-$_editSession'),
      initialValue: _draftFullName,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.name,
      autofillHints: const [AutofillHints.name],
      decoration: InputDecoration(
        isDense: true,
        hintText: t.fullNameHint,
        helperText: t.fullNameHelper,
      ),
      onChanged: _onDraftFullNameChanged,
      onFieldSubmitted: (_) => _saveInlineField(_ProfileEditField.fullName),
    );
  }

  Widget _buildEmailInlineEditor(BuildContext context) {
    final t = context.l10n;
    return Column(
      children: [
        TextFormField(
          key: ValueKey('edit-email-$_editSession'),
          initialValue: _draftEmail,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(isDense: true, hintText: t.emailHint),
          onChanged: _onDraftEmailChanged,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('edit-email-password-$_editSession'),
          initialValue: _draftPassword,
          textInputAction: TextInputAction.done,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            isDense: true,
            labelText: context.l10n.profileEditCurrentPassword,
            helperText: t.changeEmailWithPasswordHelper,
          ),
          onChanged: _onDraftPasswordChanged,
          onFieldSubmitted: (_) => _saveInlineField(_ProfileEditField.email),
        ),
      ],
    );
  }
}

enum _PaymentInfoMethod { bankTransfer, revolut, paypal }

enum _BankTransferRegion { europe, uk }

class _PaymentInfoEditorResult {
  const _PaymentInfoEditorResult({
    required this.bankCountryCode,
    required this.bankAccountNumber,
    required this.bankIban,
    required this.bankBic,
    required this.bankSortCode,
    required this.revolutHandle,
    required this.revolutMeLink,
    required this.paypalMeLink,
  });

  final String bankCountryCode;
  final String bankAccountNumber;
  final String bankIban;
  final String bankBic;
  final String bankSortCode;
  final String revolutHandle;
  final String revolutMeLink;
  final String paypalMeLink;
}

class _PaymentInfoEditorPage extends StatefulWidget {
  const _PaymentInfoEditorPage({
    required this.initialBankCountryCode,
    required this.initialBankAccountNumber,
    required this.initialBankIban,
    required this.initialBankBic,
    required this.initialBankSortCode,
    required this.initialRevolutHandle,
    required this.initialRevolutMeLink,
    required this.initialPaypalMeLink,
  });

  final String initialBankCountryCode;
  final String initialBankAccountNumber;
  final String initialBankIban;
  final String initialBankBic;
  final String initialBankSortCode;
  final String initialRevolutHandle;
  final String initialRevolutMeLink;
  final String initialPaypalMeLink;

  @override
  State<_PaymentInfoEditorPage> createState() => _PaymentInfoEditorPageState();
}

class _PaymentInfoEditorPageState extends State<_PaymentInfoEditorPage> {
  late final TextEditingController _bankAccountNumberController;
  late final TextEditingController _bankIbanController;
  late final TextEditingController _bankBicController;
  late final TextEditingController _bankSortCodeController;
  late final TextEditingController _revolutHandleController;
  late final TextEditingController _revolutMeController;
  late final TextEditingController _paypalMeController;
  late _PaymentInfoMethod _selectedMethod;
  late _BankTransferRegion _bankRegion;
  String? _formErrorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bankAccountNumberController = TextEditingController(
      text: widget.initialBankAccountNumber,
    );
    _bankIbanController = TextEditingController(text: widget.initialBankIban);
    _bankBicController = TextEditingController(text: widget.initialBankBic);
    _bankSortCodeController = TextEditingController(
      text: widget.initialBankSortCode,
    );
    _revolutHandleController = TextEditingController(
      text: widget.initialRevolutHandle,
    );
    _revolutMeController = TextEditingController(
      text: widget.initialRevolutMeLink,
    );
    _paypalMeController = TextEditingController(
      text: widget.initialPaypalMeLink,
    );
    _selectedMethod = _resolveInitialMethod();
    _bankRegion = _resolveInitialBankRegion();
  }

  @override
  void dispose() {
    _bankAccountNumberController.dispose();
    _bankIbanController.dispose();
    _bankBicController.dispose();
    _bankSortCodeController.dispose();
    _revolutHandleController.dispose();
    _revolutMeController.dispose();
    _paypalMeController.dispose();
    super.dispose();
  }

  _PaymentInfoMethod _resolveInitialMethod() {
    final hasBank =
        widget.initialBankIban.trim().isNotEmpty ||
        widget.initialBankBic.trim().isNotEmpty ||
        widget.initialBankSortCode.trim().isNotEmpty ||
        widget.initialBankAccountNumber.trim().isNotEmpty;
    if (hasBank) {
      return _PaymentInfoMethod.bankTransfer;
    }
    final hasRevolut =
        widget.initialRevolutHandle.trim().isNotEmpty ||
        widget.initialRevolutMeLink.trim().isNotEmpty;
    if (hasRevolut) {
      return _PaymentInfoMethod.revolut;
    }
    if (widget.initialPaypalMeLink.trim().isNotEmpty) {
      return _PaymentInfoMethod.paypal;
    }
    return _PaymentInfoMethod.bankTransfer;
  }

  _BankTransferRegion _resolveInitialBankRegion() {
    final country = widget.initialBankCountryCode.trim().toUpperCase();
    if (country == 'GB') {
      return _BankTransferRegion.uk;
    }
    final hasUkSpecific =
        widget.initialBankSortCode.trim().isNotEmpty ||
        widget.initialBankAccountNumber.trim().isNotEmpty;
    if (hasUkSpecific) {
      return _BankTransferRegion.uk;
    }
    return _BankTransferRegion.europe;
  }

  String _methodLabel(_PaymentInfoMethod method) {
    switch (method) {
      case _PaymentInfoMethod.bankTransfer:
        return context.l10n.profileEditBankTransferIbanSwift;
      case _PaymentInfoMethod.revolut:
        return 'Revolut';
      case _PaymentInfoMethod.paypal:
        return 'PayPal.me';
    }
  }

  String _methodHint(_PaymentInfoMethod method) {
    switch (method) {
      case _PaymentInfoMethod.bankTransfer:
        return context.l10n.profileEditIbanSwift;
      case _PaymentInfoMethod.revolut:
        return context.l10n.profileEditRevtagRevolutMe;
      case _PaymentInfoMethod.paypal:
        return context.l10n.profileEditPaypalMeLink;
    }
  }

  IconData _methodIcon(_PaymentInfoMethod method) {
    switch (method) {
      case _PaymentInfoMethod.bankTransfer:
        return Icons.account_balance_rounded;
      case _PaymentInfoMethod.revolut:
        return Icons.bolt_rounded;
      case _PaymentInfoMethod.paypal:
        return Icons.paypal_rounded;
    }
  }

  Future<void> _openPaymentMethodPicker() async {
    if (_isSaving) {
      return;
    }

    final picked = await showModalBottomSheet<_PaymentInfoMethod>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(
                  context.l10n.profileEditChoosePaymentMethod,
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              for (final method in _PaymentInfoMethod.values) ...[
                _buildPaymentMethodOptionTile(sheetContext, method),
                if (method != _PaymentInfoMethod.values.last)
                  const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );

    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _selectedMethod = picked;
      _formErrorText = null;
    });
  }

  Widget _buildPaymentMethodOptionTile(
    BuildContext context,
    _PaymentInfoMethod method,
  ) {
    final selected = method == _selectedMethod;
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).pop(method),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: selected
                ? primary.withValues(alpha: 0.08)
                : Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: Border.all(
              color: selected ? primary : AppDesign.cardStroke(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: AppDesign.cardStroke(context)),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _methodIcon(method),
                  size: 18,
                  color: selected ? primary : AppDesign.mutedColor(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _methodLabel(method),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _methodHint(method),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? primary : AppDesign.mutedColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodField(BuildContext context) {
    final method = _selectedMethod;
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _isSaving ? null : () => unawaited(_openPaymentMethodPicker()),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppDesign.cardStroke(context)),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: 0.10),
                  border: Border.all(color: primary.withValues(alpha: 0.28)),
                ),
                alignment: Alignment.center,
                child: Icon(_methodIcon(method), size: 18, color: primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _methodLabel(method),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.profileEditTapChange,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.unfold_more_rounded,
                color: AppDesign.mutedColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAndClose() {
    if (_isSaving) {
      return;
    }
    var bankCountryCode = widget.initialBankCountryCode.trim().toUpperCase();
    var bankAccountNumber = _bankAccountNumberController.text.trim();
    var bankIban = _bankIbanController.text.trim().toUpperCase();
    var bankBic = _bankBicController.text.trim().toUpperCase();
    var bankSortCode = _bankSortCodeController.text.trim();

    if (_selectedMethod == _PaymentInfoMethod.bankTransfer) {
      if (_bankRegion == _BankTransferRegion.uk) {
        final normalizedSortCode = bankSortCode.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        final normalizedAccountNumber = bankAccountNumber.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        if (normalizedSortCode.length != 6 ||
            normalizedAccountNumber.length != 8) {
          setState(() {
            _formErrorText =
                context.l10n.profileEditUkTransfersSortCode6DigitsNumber8;
          });
          return;
        }
        bankCountryCode = 'GB';
        bankSortCode = normalizedSortCode;
        bankAccountNumber = normalizedAccountNumber;
        bankIban = '';
        bankBic = '';
      } else {
        bankSortCode = '';
        bankAccountNumber = '';
        final ibanCountryMatch = RegExp(r'^[A-Z]{2}').firstMatch(bankIban);
        bankCountryCode = ibanCountryMatch?.group(0) ?? '';
      }
    }

    setState(() {
      _isSaving = true;
      _formErrorText = null;
    });
    Navigator.of(context).pop(
      _PaymentInfoEditorResult(
        bankCountryCode: bankCountryCode,
        bankAccountNumber: bankAccountNumber,
        bankIban: bankIban,
        bankBic: bankBic,
        bankSortCode: bankSortCode,
        revolutHandle: _revolutHandleController.text.trim(),
        revolutMeLink: _revolutMeController.text.trim(),
        paypalMeLink: _paypalMeController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.profileEditPaymentInfo)),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              14,
              16,
              16 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            children: [
              AppSurfaceCard(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.profileEditPaymentMethod,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentMethodField(context),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 170),
                      child: _buildMethodForm(context),
                    ),
                    if (_formErrorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _formErrorText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _isSaving ? null : _saveAndClose,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(context.l10n.profileEditSaveDetails),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodForm(BuildContext context) {
    switch (_selectedMethod) {
      case _PaymentInfoMethod.bankTransfer:
        return Column(
          key: const ValueKey('payment-method-bank'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.profileEditBankRegion,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<_BankTransferRegion>(
              segments: [
                ButtonSegment<_BankTransferRegion>(
                  value: _BankTransferRegion.europe,
                  label: Text(context.l10n.profileEditEurope),
                  icon: const Icon(Icons.public_rounded),
                ),
                ButtonSegment<_BankTransferRegion>(
                  value: _BankTransferRegion.uk,
                  label: const Text('UK'),
                  icon: const Icon(Icons.flag_rounded),
                ),
              ],
              selected: <_BankTransferRegion>{_bankRegion},
              onSelectionChanged: _isSaving
                  ? null
                  : (selection) {
                      final next = selection.first;
                      setState(() {
                        _bankRegion = next;
                        _formErrorText = null;
                      });
                    },
            ),
            const SizedBox(height: 12),
            if (_bankRegion == _BankTransferRegion.uk) ...[
              _buildTextField(
                controller: _bankSortCodeController,
                label: context.l10n.profileEditSortCode,
                hint: context.l10n.profileEditExample112233,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _bankAccountNumberController,
                label: context.l10n.profileEditNumber,
                hint: context.l10n.profileEdit8Digits,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.profileEditUkDomesticTransfersSortCodeNumber,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppDesign.mutedColor(context),
                ),
              ),
            ] else ...[
              _buildTextField(
                controller: _bankIbanController,
                label: 'IBAN',
                hint: context.l10n.profileEditExampleLv80bank0000435195001,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _bankBicController,
                label: 'BIC / SWIFT',
                hint: context.l10n.profileEdit811Chars,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.l10n.profileEditHolderNameTakenProfileFullName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppDesign.mutedColor(context),
                  ),
                ),
              ),
            ],
          ],
        );
      case _PaymentInfoMethod.revolut:
        return Column(
          key: const ValueKey('payment-method-revolut'),
          children: [
            _buildTextField(
              controller: _revolutMeController,
              label: 'Revolut.me',
              hint: context.l10n.profileEditRevolutMeUsername,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _revolutHandleController,
              label: context.l10n.profileEditRevtag,
              hint: context.l10n.profileEditUsername,
              textInputAction: TextInputAction.done,
            ),
          ],
        );
      case _PaymentInfoMethod.paypal:
        return Column(
          key: const ValueKey('payment-method-paypal'),
          children: [
            _buildTextField(
              controller: _paypalMeController,
              label: 'PayPal.me',
              hint: context.l10n.profileEditPaypalMeUsernameUsername,
              textInputAction: TextInputAction.done,
            ),
          ],
        );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required TextInputAction textInputAction,
  }) {
    return TextField(
      controller: controller,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
