part of 'profile_page.dart';

class _ChangePasswordPage extends StatefulWidget {
  const _ChangePasswordPage({
    required this.controller,
    required this.email,
    required this.onPasswordChanged,
  });

  final AuthController controller;
  final String email;
  final ValueChanged<AuthUser> onPasswordChanged;

  @override
  State<_ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<_ChangePasswordPage> {
  bool _isSubmitting = false;
  String? _errorText;
  String _currentPassword = '';
  String _newPassword = '';
  String _repeatPassword = '';

  void _clearError() {
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    final t = context.l10n;
    final validationError = _currentPassword.isEmpty
        ? t.profileEditCurrentPassword
        : _newPassword.length < 8
        ? t.passwordMinLength
        : _newPassword != _repeatPassword
        ? t.passwordsDoNotMatch
        : null;
    if (validationError != null) {
      setState(() => _errorText = validationError);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    try {
      final updated = await widget.controller.updateProfile(
        email: widget.email,
        password: _newPassword,
        currentPassword: _currentPassword,
      );
      if (!mounted) {
        return;
      }
      widget.onPasswordChanged(updated);
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) {
        setState(() => _errorText = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorText = t.profileEditFailedUpdatePassword);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return AppPageScaffold(
      appBar: AppBar(title: Text(t.profileChangePassword)),
      body: _ProfileSubpageBody(
        builder: (padding) => ListView(
          padding: padding,
          children: [
            Text(
              t.profileEditEmail(widget.email),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppDesign.mutedColor(context),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const ValueKey('change-password-current'),
              textInputAction: TextInputAction.next,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: t.profileEditCurrentPassword,
              ),
              onChanged: (value) {
                _currentPassword = value;
                _clearError();
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const ValueKey('change-password-new'),
              textInputAction: TextInputAction.next,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(
                labelText: t.newPasswordLabel,
                helperText: t.passwordMinLength,
              ),
              onChanged: (value) {
                _newPassword = value;
                _clearError();
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const ValueKey('change-password-repeat'),
              textInputAction: TextInputAction.done,
              obscureText: true,
              autofillHints: const [AutofillHints.newPassword],
              decoration: InputDecoration(labelText: t.repeatNewPasswordLabel),
              onChanged: (value) {
                _repeatPassword = value;
                _clearError();
              },
              onFieldSubmitted: (_) => unawaited(_submit()),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorText!,
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
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(t.cancelAction),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => unawaited(_submit()),
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
      ),
    );
  }
}
