part of 'login_page.dart';

extension _LoginPageActions on _LoginPageState {
  Future<void> _tryRestoreSession() async {
    try {
      final user = await widget.controller.loadCurrentUser().timeout(
        const Duration(seconds: 4),
      );
      if (!mounted) {
        return;
      }
      _goAfterAuth(user);
    } on TimeoutException {
      // Keep auth form open if restore takes too long.
    } on ApiException catch (_) {
      // Keep auth form open on unauthorized/network restore failures.
    } catch (_) {
      // Keep auth form open on restore failures.
    }
  }

  Future<void> _onSubmitPressed() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    _updateState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      late final AuthUser user;
      if (_mode == _AuthMode.login) {
        user = await widget.controller.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        final fullName = _fullNameController.text.trim();
        final nameParts = _parseFullName(fullName);
        if (nameParts == null) {
          _updateState(() {
            _errorText = context.l10n.fullNameValidation;
            _isSubmitting = false;
          });
          return;
        }
        final firstName = nameParts.key;
        final lastName = nameParts.value;
        user = await widget.controller.register(
          firstName: firstName,
          lastName: lastName,
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) {
        return;
      }
      _goAfterAuth(user);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _errorText = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _errorText = context.l10n.requestFailedTryAgain;
      });
    } finally {
      if (mounted && !_isNavigatingAway) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _goAfterAuth(AuthUser user) {
    if (!mounted || _isNavigatingAway) {
      return;
    }
    _isNavigatingAway = true;
    final nextRoute = user.needsCredentials
        ? AppRouter.credentials
        : AppRouter.trips;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(nextRoute, (route) => false);
    });
  }

  void _onModeChanged(_AuthMode mode) {
    if (_mode == mode) {
      return;
    }

    _updateState(() {
      _mode = mode;
      _errorText = null;
      _repeatController.clear();
    });

    _formKey.currentState?.validate();
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
