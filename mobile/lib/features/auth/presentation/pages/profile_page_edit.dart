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
        _profileText(
          en: 'Set a valid email in Edit profile before changing password.',
          lv: 'Pirms paroles maiņas ievadi derīgu e-pastu sadaļā "Edit profile".',
        ),
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
      _draftBankAccountHolder = _initialBankAccountHolder;
      _draftBankAccountNumber = _initialBankAccountNumber;
      _draftBankIban = _initialBankIban;
      _draftBankBic = _initialBankBic;
      _draftBankSortCode = _initialBankSortCode;
      _draftBankRoutingNumber = _initialBankRoutingNumber;
      _draftRevolutHandle = _initialRevolutHandle;
      _draftPaypalMeLink = _initialPaypalMeLink;
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
      _draftBankAccountHolder = _initialBankAccountHolder;
      _draftBankAccountNumber = _initialBankAccountNumber;
      _draftBankIban = _initialBankIban;
      _draftBankBic = _initialBankBic;
      _draftBankSortCode = _initialBankSortCode;
      _draftBankRoutingNumber = _initialBankRoutingNumber;
      _draftRevolutHandle = _initialRevolutHandle;
      _draftPaypalMeLink = _initialPaypalMeLink;
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
        _profileText(
          en: 'Account deactivated. Use reactivation link from email to restore access.',
          lv: 'Konts deaktivēts. Lai atjaunotu piekļuvi, izmanto reaktivācijas saiti e-pastā.',
        ),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRouter.login, (route) => false);
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
        _editErrorText = _profileText(
          en: 'Could not deactivate account. Please try again.',
          lv: 'Neizdevās deaktivēt kontu. Mēģini vēlreiz.',
        );
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
      _showSnack(
        _profileText(
          en: 'Deletion link sent to your email.',
          lv: 'Dzēšanas saite nosūtīta uz tavu e-pastu.',
        ),
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
        _editErrorText = _profileText(
          en: 'Could not send deletion link. Please try again.',
          lv: 'Neizdevās nosūtīt dzēšanas saiti. Mēģini vēlreiz.',
        );
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
      if (field == _ProfileEditField.fullName) {
        _draftFullName = _fullNameController.text.trim();
      } else {
        _draftEmail = _emailController.text.trim();
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

  void _onDraftBankCountryCodeChanged(String? value) {
    _updateState(() {
      _draftBankCountryCode = (value ?? '').trim().toUpperCase();
      if (_editErrorText != null) {
        _editErrorText = null;
      }
    });
  }

  void _onDraftBankAccountHolderChanged(String value) {
    _draftBankAccountHolder = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftBankAccountNumberChanged(String value) {
    _draftBankAccountNumber = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftBankIbanChanged(String value) {
    _draftBankIban = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftBankBicChanged(String value) {
    _draftBankBic = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftBankSortCodeChanged(String value) {
    _draftBankSortCode = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftBankRoutingNumberChanged(String value) {
    _draftBankRoutingNumber = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftRevolutHandleChanged(String value) {
    _draftRevolutHandle = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftPaypalMeLinkChanged(String value) {
    _draftPaypalMeLink = value;
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
      if (_draftPassword.isEmpty || _draftRepeatPassword.isEmpty) {
        _updateState(() {
          _editErrorText = t.changeEmailWithPasswordHelper;
        });
        return;
      }
      if (_draftPassword.length < 8) {
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
      _fullNameController.text = _fullNameController.text.trim();
      _emailController.text = _draftEmail.trim();
      _passwordController.text = _draftPassword;
      _repeatController.text = _draftRepeatPassword;
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
            editor: _buildEmailInlineEditor,
          ),
          const Divider(height: 1),
          _buildPaymentDetailsSection(context),
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
            _profileText(en: 'Deactivate account', lv: 'Deaktivēt kontu'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _profileText(
              en: 'You can deactivate account access or request an email link to permanently delete the account. Password is optional for Google/Apple accounts.',
              lv: 'Vari deaktivēt konta piekļuvi vai pieprasīt e-pasta saiti neatgriezeniskai konta dzēšanai. Google/Apple kontiem parole nav obligāta.',
            ),
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
              labelText: _profileText(en: 'Password', lv: 'Parole'),
              hintText: _profileText(
                en: 'Enter your password (optional for Google/Apple)',
                lv: 'Ievadi paroli (Google/Apple nav obligāti)',
              ),
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
              label: Text(
                _profileText(en: 'Deactivate account', lv: 'Deaktivēt kontu'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _onSendDeletionLinkPressed,
              icon: const Icon(Icons.mark_email_read_outlined),
              label: Text(
                _profileText(
                  en: 'Send deletion link to email',
                  lv: 'Nosūtīt dzēšanas saiti uz e-pastu',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _closeEditMode,
              child: Text(
                _profileText(en: 'Back to profile', lv: 'Atpakaļ uz profilu'),
              ),
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
        _editErrorText = _profileText(
          en: 'Set a valid email in profile before changing password.',
          lv: 'Pirms paroles maiņas iestati derīgu e-pastu profilā.',
        );
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
      _showSnack(
        _profileText(en: 'Password updated.', lv: 'Parole atjaunināta.'),
      );
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
        _editErrorText = _profileText(
          en: 'Failed to update password.',
          lv: 'Neizdevās atjaunināt paroli.',
        );
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
            _profileText(en: 'Change password', lv: 'Mainīt paroli'),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            _profileText(en: 'Account: $email', lv: 'Konts: $email'),
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

  bool _isIbanPreferredCountry(String countryCode) {
    const ibanCountries = <String>{
      'AT',
      'BE',
      'BG',
      'CH',
      'CY',
      'CZ',
      'DE',
      'DK',
      'EE',
      'ES',
      'FI',
      'FR',
      'GR',
      'HR',
      'HU',
      'IE',
      'IS',
      'IT',
      'LI',
      'LT',
      'LU',
      'LV',
      'MT',
      'NL',
      'NO',
      'PL',
      'PT',
      'RO',
      'SE',
      'SI',
      'SK',
    };
    return ibanCountries.contains(countryCode);
  }

  bool _countryUsesSortCode(String countryCode) {
    return countryCode == 'GB' || countryCode == 'AU' || countryCode == 'NZ';
  }

  bool _countryUsesRoutingNumber(String countryCode) {
    return countryCode == 'US' || countryCode == 'CA';
  }

  String _sortCodeLabelForCountry(String countryCode) {
    switch (countryCode) {
      case 'AU':
        return _profileText(en: 'BSB code', lv: 'BSB kods');
      case 'NZ':
        return _profileText(en: 'Branch code', lv: 'Filiāles kods');
      default:
        return _profileText(en: 'Sort code', lv: 'Sort code');
    }
  }

  Widget _buildPaymentDetailsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final countryCode = _draftBankCountryCode.trim().toUpperCase();
    const supportedCountryCodes = <String>{
      'LV',
      'LT',
      'EE',
      'DE',
      'FR',
      'ES',
      'IT',
      'NL',
      'BE',
      'PT',
      'IE',
      'FI',
      'SE',
      'NO',
      'DK',
      'PL',
      'CZ',
      'SK',
      'RO',
      'HU',
      'GB',
      'US',
      'CA',
      'AU',
      'CH',
      'ZZ',
    };
    final selectedCountryCode = supportedCountryCodes.contains(countryCode)
        ? countryCode
        : '';
    final usesIban = _isIbanPreferredCountry(selectedCountryCode);
    final usesSortCode = _countryUsesSortCode(selectedCountryCode);
    final usesRouting = _countryUsesRoutingNumber(selectedCountryCode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _profileText(en: 'Payment details', lv: 'Maksājumu dati'),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              _profileText(
                en: 'Add preferred payout details for settlements.',
                lv: 'Pievieno vēlamos izmaksas datus norēķiniem.',
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppDesign.mutedColor(context),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: selectedCountryCode,
              isExpanded: true,
              menuMaxHeight: 280,
              borderRadius: BorderRadius.circular(14),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.primary,
              ),
              decoration: InputDecoration(
                isDense: true,
                labelText: _profileText(
                  en: 'Bank country',
                  lv: 'Bankas valsts',
                ),
                prefixIcon: const Icon(Icons.public_outlined),
              ),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(_profileText(en: 'Not set', lv: 'Nav iestatīts')),
                ),
                const DropdownMenuItem(value: 'LV', child: Text('Latvia')),
                const DropdownMenuItem(value: 'LT', child: Text('Lithuania')),
                const DropdownMenuItem(value: 'EE', child: Text('Estonia')),
                const DropdownMenuItem(value: 'DE', child: Text('Germany')),
                const DropdownMenuItem(value: 'FR', child: Text('France')),
                const DropdownMenuItem(value: 'ES', child: Text('Spain')),
                const DropdownMenuItem(value: 'IT', child: Text('Italy')),
                const DropdownMenuItem(value: 'NL', child: Text('Netherlands')),
                const DropdownMenuItem(value: 'BE', child: Text('Belgium')),
                const DropdownMenuItem(value: 'PT', child: Text('Portugal')),
                const DropdownMenuItem(value: 'IE', child: Text('Ireland')),
                const DropdownMenuItem(value: 'FI', child: Text('Finland')),
                const DropdownMenuItem(value: 'SE', child: Text('Sweden')),
                const DropdownMenuItem(value: 'NO', child: Text('Norway')),
                const DropdownMenuItem(value: 'DK', child: Text('Denmark')),
                const DropdownMenuItem(value: 'PL', child: Text('Poland')),
                const DropdownMenuItem(value: 'CZ', child: Text('Czechia')),
                const DropdownMenuItem(value: 'SK', child: Text('Slovakia')),
                const DropdownMenuItem(value: 'RO', child: Text('Romania')),
                const DropdownMenuItem(value: 'HU', child: Text('Hungary')),
                const DropdownMenuItem(
                  value: 'GB',
                  child: Text('United Kingdom'),
                ),
                const DropdownMenuItem(
                  value: 'US',
                  child: Text('United States'),
                ),
                const DropdownMenuItem(value: 'CA', child: Text('Canada')),
                const DropdownMenuItem(value: 'AU', child: Text('Australia')),
                const DropdownMenuItem(value: 'CH', child: Text('Switzerland')),
                const DropdownMenuItem(
                  value: 'ZZ',
                  child: Text('Other country'),
                ),
              ],
              onChanged: _isSubmitting ? null : _onDraftBankCountryCodeChanged,
            ),
            const SizedBox(height: 10),
            _buildPaymentTextField(
              key: ValueKey('edit-bank-holder-$_editSession'),
              label: _profileText(
                en: 'Account holder name',
                lv: 'Konta turētāja vārds',
              ),
              hint: _profileText(en: 'Optional', lv: 'Pēc izvēles'),
              initialValue: _draftBankAccountHolder,
              onChanged: _onDraftBankAccountHolderChanged,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            if (usesIban) ...[
              _buildPaymentTextField(
                key: ValueKey('edit-bank-iban-$_editSession'),
                label: 'IBAN',
                hint: _profileText(
                  en: 'Example: LV80BANK0000435195001',
                  lv: 'Piemērs: LV80BANK0000435195001',
                ),
                initialValue: _draftBankIban,
                onChanged: _onDraftBankIbanChanged,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              _buildPaymentTextField(
                key: ValueKey('edit-bank-bic-$_editSession'),
                label: 'BIC / SWIFT',
                hint: _profileText(en: '8 or 11 chars', lv: '8 vai 11 simboli'),
                initialValue: _draftBankBic,
                onChanged: _onDraftBankBicChanged,
                textInputAction: TextInputAction.next,
              ),
            ] else ...[
              _buildPaymentTextField(
                key: ValueKey('edit-bank-account-number-$_editSession'),
                label: _profileText(en: 'Account number', lv: 'Konta numurs'),
                hint: _profileText(en: 'Optional', lv: 'Pēc izvēles'),
                initialValue: _draftBankAccountNumber,
                onChanged: _onDraftBankAccountNumberChanged,
                textInputAction: TextInputAction.next,
              ),
              if (usesSortCode) ...[
                const SizedBox(height: 8),
                _buildPaymentTextField(
                  key: ValueKey('edit-bank-sort-$_editSession'),
                  label: _sortCodeLabelForCountry(selectedCountryCode),
                  hint: _profileText(en: 'Optional', lv: 'Pēc izvēles'),
                  initialValue: _draftBankSortCode,
                  onChanged: _onDraftBankSortCodeChanged,
                  textInputAction: TextInputAction.next,
                ),
              ],
              if (usesRouting) ...[
                const SizedBox(height: 8),
                _buildPaymentTextField(
                  key: ValueKey('edit-bank-routing-$_editSession'),
                  label: _profileText(
                    en: 'Routing number',
                    lv: 'Routing numurs',
                  ),
                  hint: _profileText(en: 'Optional', lv: 'Pēc izvēles'),
                  initialValue: _draftBankRoutingNumber,
                  onChanged: _onDraftBankRoutingNumberChanged,
                  textInputAction: TextInputAction.next,
                ),
              ],
              if (!usesSortCode && !usesRouting) ...[
                const SizedBox(height: 8),
                _buildPaymentTextField(
                  key: ValueKey('edit-bank-bic-generic-$_editSession'),
                  label: 'BIC / SWIFT',
                  hint: _profileText(en: 'Optional', lv: 'Pēc izvēles'),
                  initialValue: _draftBankBic,
                  onChanged: _onDraftBankBicChanged,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ],
            const SizedBox(height: 8),
            _buildPaymentTextField(
              key: ValueKey('edit-revolut-handle-$_editSession'),
              label: _profileText(
                en: 'Revolut handle',
                lv: 'Revolut lietotājs',
              ),
              hint: _profileText(en: '@username', lv: '@lietotajs'),
              initialValue: _draftRevolutHandle,
              onChanged: _onDraftRevolutHandleChanged,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 8),
            _buildPaymentTextField(
              key: ValueKey('edit-paypal-me-$_editSession'),
              label: 'PayPal.me',
              hint: _profileText(
                en: 'paypal.me/username or username',
                lv: 'paypal.me/lietotajs vai lietotajs',
              ),
              initialValue: _draftPaypalMeLink,
              onChanged: _onDraftPaypalMeLinkChanged,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => unawaited(_onSavePressed()),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        unawaited(_onSavePressed());
                      },
                icon: const Icon(Icons.save_outlined),
                label: Text(_profileText(en: 'Save details', lv: 'Saglabāt')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTextField({
    required Key key,
    required String label,
    required String hint,
    required String initialValue,
    required ValueChanged<String> onChanged,
    required TextInputAction textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      key: key,
      initialValue: initialValue,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        hintText: hint,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
    );
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
          textInputAction: TextInputAction.next,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            isDense: true,
            labelText: t.newPasswordLabel,
            helperText: t.changeEmailWithPasswordHelper,
          ),
          onChanged: _onDraftPasswordChanged,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('edit-email-repeat-$_editSession'),
          initialValue: _draftRepeatPassword,
          textInputAction: TextInputAction.done,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            isDense: true,
            labelText: t.repeatNewPasswordLabel,
          ),
          onChanged: _onDraftRepeatPasswordChanged,
          onFieldSubmitted: (_) => _saveInlineField(_ProfileEditField.email),
        ),
      ],
    );
  }
}
