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
      _draftBankIban = _initialBankIban;
      _draftBankBic = _initialBankBic;
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
      _draftBankIban = _initialBankIban;
      _draftBankBic = _initialBankBic;
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
        case _ProfileEditField.bankTransfer:
          _draftBankIban = _draftBankIban.trim();
          _draftBankBic = _draftBankBic.trim();
          break;
        case _ProfileEditField.revolut:
          _draftRevolutHandle = _draftRevolutHandle.trim();
          _draftRevolutMeLink = _draftRevolutMeLink.trim();
          break;
        case _ProfileEditField.paypal:
          _draftPaypalMeLink = _draftPaypalMeLink.trim();
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

  void _onDraftRevolutHandleChanged(String value) {
    _draftRevolutHandle = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _onDraftRevolutMeLinkChanged(String value) {
    _draftRevolutMeLink = value;
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
      if (!_isValidEmail(proposed)) {
        _updateState(() {
          _editErrorText = t.invalidEmailFormat;
        });
        return;
      }

      final currentPassword = _draftPassword.trim();
      if (currentPassword.isEmpty) {
        _updateState(() {
          _editErrorText = _profileText(
            en: 'Enter current password to change email.',
            lv: 'Lai mainītu e-pastu, ievadi pašreizējo paroli.',
          );
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
          _profileText(
            en: 'Verification was sent to the new email. Security notice was sent to your current email.',
            lv: 'Verifikācijas saite nosūtīta uz jauno e-pastu. Drošības paziņojums nosūtīts uz pašreizējo e-pastu.',
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
            en: 'Could not start email change right now. Please try again.',
            lv: 'Neizdevās sākt e-pasta maiņu. Mēģini vēlreiz.',
          );
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
    } else if (field == _ProfileEditField.bankTransfer) {
      final proposedIban = _draftBankIban.trim().toUpperCase();
      final proposedBic = _draftBankBic.trim().toUpperCase();
      final currentIban = _initialBankIban.trim().toUpperCase();
      final currentBic = _initialBankBic.trim().toUpperCase();
      if (proposedIban == currentIban && proposedBic == currentBic) {
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
        });
        return;
      }
      _draftBankIban = proposedIban;
      _draftBankBic = proposedBic;
    } else if (field == _ProfileEditField.revolut) {
      final proposedHandle = _draftRevolutHandle.trim();
      final currentHandle = _initialRevolutHandle.trim();
      final proposedMe = _draftRevolutMeLink.trim();
      final currentMe = _initialRevolutMeLink.trim();
      if (proposedHandle == currentHandle && proposedMe == currentMe) {
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
        });
        return;
      }
      _draftRevolutHandle = proposedHandle;
      _draftRevolutMeLink = proposedMe;
    } else if (field == _ProfileEditField.paypal) {
      final proposed = _draftPaypalMeLink.trim();
      final current = _initialPaypalMeLink.trim();
      if (proposed == current) {
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
        });
        return;
      }
      _draftPaypalMeLink = proposed;
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
            label: _profileText(en: 'Overview currency', lv: 'Pārskata valūta'),
            displayValue: _preferredCurrencyDisplayValue(),
            editor: _buildPreferredCurrencyInlineEditor,
          ),
          const Divider(height: 1),
          _buildEditableProfileRow(
            context: context,
            field: _ProfileEditField.bankTransfer,
            label: _profileText(
              en: 'Bank transfer (IBAN / SWIFT)',
              lv: 'Bankas pārskaitījums (IBAN / SWIFT)',
            ),
            displayValue: _bankTransferDisplayValue(t.notSetValue),
            editor: _buildBankTransferInlineEditor,
          ),
          const Divider(height: 1),
          _buildEditableProfileRow(
            context: context,
            field: _ProfileEditField.revolut,
            label: _profileText(en: 'Revolut', lv: 'Revolut'),
            displayValue: _revolutDisplayValue(t.notSetValue),
            editor: _buildRevolutInlineEditor,
          ),
          const Divider(height: 1),
          _buildEditableProfileRow(
            context: context,
            field: _ProfileEditField.paypal,
            label: 'PayPal.me',
            displayValue: _draftPaypalMeLink.trim().isEmpty
                ? t.notSetValue
                : _draftPaypalMeLink.trim(),
            editor: _buildPaypalInlineEditor,
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
            _profileText(en: 'Primary', lv: 'Primārais'),
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
                        hintText: _profileText(
                          en: 'Search currency',
                          lv: 'Meklēt valūtu',
                        ),
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
                              _profileText(
                                en: 'No currencies found',
                                lv: 'Valūtas netika atrastas',
                              ),
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
          _profileText(
            en: 'Overview totals are converted to this currency.',
            lv: 'Pārskata summas tiks konvertētas uz šo valūtu.',
          ),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppDesign.mutedColor(context)),
        ),
      ],
    );
  }

  String _bankTransferDisplayValue(String notSetLabel) {
    final iban = _draftBankIban.trim();
    final bic = _draftBankBic.trim();
    if (iban.isEmpty && bic.isEmpty) {
      return notSetLabel;
    }
    if (iban.isNotEmpty && bic.isNotEmpty) {
      return 'IBAN: $iban\nSWIFT: $bic';
    }
    if (iban.isNotEmpty) {
      return 'IBAN: $iban';
    }
    return 'SWIFT: $bic';
  }

  Widget _buildBankTransferInlineEditor(BuildContext context) {
    return Column(
      children: [
        _buildPaymentTextField(
          key: ValueKey('edit-bank-iban-inline-$_editSession'),
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
          key: ValueKey('edit-bank-bic-inline-$_editSession'),
          label: 'BIC / SWIFT',
          hint: _profileText(en: '8 or 11 chars', lv: '8 vai 11 simboli'),
          initialValue: _draftBankBic,
          onChanged: _onDraftBankBicChanged,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _saveInlineField(_ProfileEditField.bankTransfer),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            _profileText(
              en: 'Account holder name comes from your profile full name.',
              lv: 'Konta turētāja vārds tiek ņemts no profila pilnā vārda.',
            ),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppDesign.mutedColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevolutInlineEditor(BuildContext context) {
    return Column(
      children: [
        _buildPaymentTextField(
          key: ValueKey('edit-revolut-me-inline-$_editSession'),
          label: 'Revolut.me',
          hint: _profileText(
            en: 'revolut.me/username',
            lv: 'revolut.me/lietotajs',
          ),
          initialValue: _draftRevolutMeLink,
          onChanged: _onDraftRevolutMeLinkChanged,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 8),
        _buildPaymentTextField(
          key: ValueKey('edit-revolut-inline-$_editSession'),
          label: _profileText(en: 'Revtag', lv: 'Revtag'),
          hint: _profileText(en: '@username', lv: '@lietotajs'),
          initialValue: _draftRevolutHandle,
          onChanged: _onDraftRevolutHandleChanged,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _saveInlineField(_ProfileEditField.revolut),
        ),
      ],
    );
  }

  String _revolutDisplayValue(String notSetLabel) {
    final meLink = _draftRevolutMeLink.trim();
    if (meLink.isNotEmpty) {
      return meLink;
    }
    final revtag = _draftRevolutHandle.trim();
    if (revtag.isNotEmpty) {
      return revtag;
    }
    return notSetLabel;
  }

  Widget _buildPaypalInlineEditor(BuildContext context) {
    return _buildPaymentTextField(
      key: ValueKey('edit-paypal-inline-$_editSession'),
      label: 'PayPal.me',
      hint: _profileText(
        en: 'paypal.me/username or username',
        lv: 'paypal.me/lietotajs vai lietotajs',
      ),
      initialValue: _draftPaypalMeLink,
      onChanged: _onDraftPaypalMeLinkChanged,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _saveInlineField(_ProfileEditField.paypal),
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
          textInputAction: TextInputAction.done,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          decoration: InputDecoration(
            isDense: true,
            labelText: _profileText(
              en: 'Current password',
              lv: 'Pašreizējā parole',
            ),
            helperText: t.changeEmailWithPasswordHelper,
          ),
          onChanged: _onDraftPasswordChanged,
          onFieldSubmitted: (_) => _saveInlineField(_ProfileEditField.email),
        ),
      ],
    );
  }
}
