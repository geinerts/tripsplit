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
    if (password.trim().isEmpty) {
      _updateState(() {
        _editErrorText = _profileText(
          en: 'Enter your password to deactivate account.',
          lv: 'Ievadi paroli, lai deaktivētu kontu.',
        );
      });
      return;
    }

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
    if (password.trim().isEmpty) {
      _updateState(() {
        _editErrorText = _profileText(
          en: 'Enter your password to request deletion link.',
          lv: 'Ievadi paroli, lai pieprasītu dzēšanas saiti.',
        );
      });
      return;
    }

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
              en: 'You can deactivate account access with password or request an email link to permanently delete the account.',
              lv: 'Vari deaktivēt konta piekļuvi ar paroli vai pieprasīt e-pasta saiti neatgriezeniskai konta dzēšanai.',
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
                en: 'Enter your password',
                lv: 'Ievadi savu paroli',
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
