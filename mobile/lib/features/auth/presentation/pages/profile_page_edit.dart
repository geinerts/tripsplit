part of 'profile_page.dart';

extension _ProfilePageEditFlow on _ProfilePageState {
  void _openEditProfilePage() {
    if (_isLoading || _isSubmitting) {
      return;
    }

    _updateState(() {
      _isEditMode = true;
      _editSession += 1;
      _isDeactivateAccountPage = false;
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
    if (_isDeactivateAccountPage) {
      _closeDeactivateAccountPage();
      return;
    }
    _closeEditMode();
  }

  void _openDeactivateAccountPage() {
    if (!_isEditMode || _isSubmitting) {
      return;
    }
    _updateState(() {
      _isDeactivateAccountPage = true;
      _activeEditField = null;
      _editErrorText = null;
      _deactivateDraftPassword = '';
    });
  }

  void _closeDeactivateAccountPage() {
    _updateState(() {
      _isDeactivateAccountPage = false;
      _deactivateDraftPassword = '';
      _editErrorText = null;
    });
  }

  void _onDeactivatePasswordChanged(String value) {
    _deactivateDraftPassword = value;
    if (_editErrorText != null) {
      _updateState(() {
        _editErrorText = null;
      });
    }
  }

  void _showDeactivateComingSoon(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) {
      return;
    }
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onDeactivateAccountPressed() {
    _showDeactivateComingSoon(
      'Deactivate account flow will be enabled in the next step.',
    );
  }

  void _onSendDeletionLinkPressed() {
    _showDeactivateComingSoon(
      'Email deletion link flow will be enabled in the next step.',
    );
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
      } else if (field == _ProfileEditField.email) {
        _draftEmail = _emailController.text.trim();
      } else {
        _draftPassword = '';
        _draftRepeatPassword = '';
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
    } else {
      if (_draftPassword.isEmpty && _draftRepeatPassword.isEmpty) {
        _updateState(() {
          _activeEditField = null;
          _editErrorText = null;
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
      _emailController.text = _emailController.text.trim();
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

    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
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
            _buildEditableProfileRow(
              context: context,
              field: _ProfileEditField.password,
              label: t.newPasswordLabel,
              displayValue:
                  (_draftPassword.isNotEmpty || _draftRepeatPassword.isNotEmpty)
                  ? '••••••••'
                  : t.notSetValue,
              editor: _buildPasswordInlineEditor,
            ),
            if (_editErrorText != null) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _editErrorText!,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeactivateAccountPage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          key: ValueKey('deactivate-page-$_editSession'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deactivate Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can deactivate account access with password or request an email link to permanently delete the account.',
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
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
              ),
              onChanged: _onDeactivatePasswordChanged,
              onFieldSubmitted: (_) => _onDeactivateAccountPressed(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _onDeactivateAccountPressed,
                icon: const Icon(Icons.person_off),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
                label: const Text('Deactivate account'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _onSendDeletionLinkPressed,
                icon: const Icon(Icons.mark_email_read_outlined),
                label: const Text('Send deletion link to email'),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _closeDeactivateAccountPage,
                child: const Text('Back to edit profile'),
              ),
            ),
          ],
        ),
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
          decoration: InputDecoration(
            isDense: true,
            hintText: t.emailHint,
          ),
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

  Widget _buildPasswordInlineEditor(BuildContext context) {
    final t = context.l10n;
    return Column(
      children: [
        TextFormField(
          key: ValueKey('edit-password-$_editSession'),
          initialValue: _draftPassword,
          textInputAction: TextInputAction.next,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            isDense: true,
            labelText: t.newPasswordLabel,
            helperText: t.leaveEmptyKeepPasswordHelper,
          ),
          onChanged: _onDraftPasswordChanged,
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: ValueKey('edit-repeat-password-$_editSession'),
          initialValue: _draftRepeatPassword,
          textInputAction: TextInputAction.done,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
            isDense: true,
            labelText: t.repeatNewPasswordLabel,
          ),
          onChanged: _onDraftRepeatPasswordChanged,
          onFieldSubmitted: (_) => _saveInlineField(_ProfileEditField.password),
        ),
      ],
    );
  }
}
