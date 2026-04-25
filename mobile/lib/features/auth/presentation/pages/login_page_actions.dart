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
            _errorText = context.l10nEn.fullNameValidation;
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
      if (_mode == _AuthMode.register &&
          _isEmailVerificationRequiredError(error)) {
        await _handleRegisterEmailVerification(
          _emailController.text.trim(),
          error.message,
        );
        return;
      }
      if (_mode == _AuthMode.login && _isEmailNotVerifiedError(error)) {
        await _handleEmailNotVerifiedLogin(_emailController.text.trim());
        return;
      }
      if (_mode == _AuthMode.login && _isAccountDeactivatedError(error)) {
        await _handleDeactivatedLogin(_emailController.text.trim());
        return;
      }
      _updateState(() {
        _errorText = error.message;
      });
    } on StateError catch (error) {
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
        _errorText = context.l10nEn.requestFailedTryAgain;
      });
    } finally {
      if (mounted && !_isNavigatingAway) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _onSocialPressed(_SocialAuthProvider provider) async {
    if (_isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    _updateState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    var socialEmail = '';
    try {
      final credential = switch (provider) {
        _SocialAuthProvider.google => await _signInWithGoogle(),
        _SocialAuthProvider.apple => await _signInWithApple(),
      };
      socialEmail = (credential.email ?? '').trim();

      final user = await widget.controller.loginWithSocial(
        provider: provider.value,
        idToken: credential.idToken,
        fullName: credential.fullName,
        email: credential.email,
      );
      if (!mounted) {
        return;
      }
      _goAfterAuth(user);
    } on _SocialAuthCancelled {
      // User cancelled sign-in flow — keep form unchanged.
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (_isAccountDeactivatedError(error)) {
        final fallbackEmail = socialEmail.isNotEmpty
            ? socialEmail
            : _emailController.text.trim();
        await _handleDeactivatedLogin(fallbackEmail);
        return;
      }
      _updateState(() {
        _errorText = error.message;
      });
    } on StateError catch (error) {
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
        _errorText = _socialAuthFallbackError(provider);
      });
    } finally {
      if (mounted && !_isNavigatingAway) {
        _updateState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<_SocialAuthCredential> _signInWithGoogle() async {
    final env = AppEnv.current;
    final serverClientId = env.googleServerClientId.trim();

    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
    );

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw _SocialAuthCancelled();
      }

      final auth = await account.authentication;
      final idToken = (auth.idToken ?? '').trim();
      if (idToken.isEmpty) {
        throw StateError(context.l10nEn.authGoogleSignDidNotReturnIdToken);
      }

      final fullName = (account.displayName ?? '').trim();
      final email = account.email.trim();
      return _SocialAuthCredential(
        idToken: idToken,
        fullName: fullName.isEmpty ? null : fullName,
        email: email.isEmpty ? null : email,
      );
    } on PlatformException catch (error) {
      final combined = '${error.code} ${error.message ?? ''}'.toLowerCase();
      if (combined.contains('canceled') ||
          combined.contains('cancelled') ||
          combined.contains('sign_in_canceled')) {
        throw _SocialAuthCancelled();
      }
      rethrow;
    }
  }

  Future<_SocialAuthCredential> _signInWithApple() async {
    if (!Platform.isIOS) {
      throw StateError(context.l10nEn.authAppleSignAvailableIosDevices);
    }
    if (!await SignInWithApple.isAvailable()) {
      throw StateError(context.l10nEn.authAppleSignNotAvailableDevice);
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = (credential.identityToken ?? '').trim();
      if (idToken.isEmpty) {
        throw StateError(context.l10nEn.authAppleSignDidNotReturnIdentityToken);
      }

      final nameParts = [
        (credential.givenName ?? '').trim(),
        (credential.familyName ?? '').trim(),
      ].where((part) => part.isNotEmpty).toList();
      final fullName = nameParts.isEmpty ? null : nameParts.join(' ');
      final email = (credential.email ?? '').trim();

      return _SocialAuthCredential(
        idToken: idToken,
        fullName: fullName,
        email: email.isEmpty ? null : email,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw _SocialAuthCancelled();
      }
      rethrow;
    }
  }

  String _socialAuthFallbackError(_SocialAuthProvider provider) {
    if (provider == _SocialAuthProvider.apple) {
      return context.l10nEn.authIntroAppleSignFailedPleaseTryAgain;
    }
    return context.l10nEn.authIntroGoogleSignFailedPleaseTryAgain;
  }

  void _goAfterAuth(AuthUser user) {
    if (!mounted || _isNavigatingAway) {
      return;
    }
    _isNavigatingAway = true;
    final nextRoute = user.needsCredentials
        ? AppRouter.credentials
        : AppRouter.trips;
    Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
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

  bool _isAccountDeactivatedError(ApiException error) {
    final code = error.code?.trim().toUpperCase();
    if (code == 'ACCOUNT_DEACTIVATED') {
      return true;
    }
    final message = error.message.toLowerCase();
    return message.contains('deactivated');
  }

  bool _isEmailNotVerifiedError(ApiException error) {
    final code = error.code?.trim().toUpperCase();
    if (code == 'EMAIL_NOT_VERIFIED') {
      return true;
    }
    final message = error.message.toLowerCase();
    return message.contains('not verified');
  }

  bool _isEmailVerificationRequiredError(ApiException error) {
    final code = error.code?.trim().toUpperCase();
    return code == 'EMAIL_VERIFICATION_REQUIRED';
  }

  Future<void> _handleDeactivatedLogin(String rawEmail) async {
    final email = rawEmail.trim().toLowerCase();
    if (email.isEmpty) {
      _updateState(() {
        _errorText = context
            .l10n
            .authAccountDeactivatedEnterEmailRequestReactivationLink;
      });
      return;
    }

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10nEn.authAccountDeactivated),
          content: Text(context.l10nEn.authSendReactivationLinkEmail(email)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10nEn.authCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10nEn.authSendLink),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldSend != true) {
      return;
    }

    try {
      await widget.controller.requestReactivationLink(email: email);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10nEn.authReactivationLinkSentCheckEmail);
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
        _errorText =
            context.l10nEn.authCouldNotSendReactivationLinkPleaseTryAgain;
      });
    }
  }

  Future<void> _handleEmailNotVerifiedLogin(String rawEmail) async {
    final email = rawEmail.trim().toLowerCase();
    if (email.isEmpty) {
      _updateState(() {
        _errorText = context
            .l10nEn
            .authEmailNotVerifiedEnterEmailRequestVerificationLink;
      });
      return;
    }

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10nEn.authEmailNotVerified),
          content: Text(context.l10nEn.authSendVerificationLinkEmail(email)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10nEn.authCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10nEn.authSendLink),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldSend != true) {
      return;
    }

    try {
      await widget.controller.requestEmailVerificationLink(email: email);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10nEn.authVerificationLinkSentCheckEmail);
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
        _errorText =
            context.l10nEn.authCouldNotSendVerificationLinkPleaseTryAgain;
      });
    }
  }

  Future<void> _handleRegisterEmailVerification(
    String rawEmail,
    String backendMessage,
  ) async {
    final email = rawEmail.trim().toLowerCase();
    final message = backendMessage.trim().isNotEmpty
        ? backendMessage.trim()
        : context
              .l10nEn
              .authVerificationEmailSentPleaseVerifyEmailBeforeLogging;

    _updateState(() {
      _mode = _AuthMode.login;
      _repeatController.clear();
      _passwordController.clear();
      _errorText = null;
    });

    final shouldResend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10nEn.authVerifyEmail),
          content: Text(
            email.isEmpty
                ? message
                : '$message\n\n${context.l10nEn.authEmailLabel} $email',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10nEn.authClose),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(context.l10nEn.authResendLink),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldResend != true || email.isEmpty) {
      return;
    }

    try {
      await widget.controller.requestEmailVerificationLink(email: email);
      if (!mounted) {
        return;
      }
      _showSnack(context.l10nEn.authVerificationLinkSentCheckEmail);
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
        _errorText =
            context.l10nEn.authCouldNotSendVerificationLinkPleaseTryAgain;
      });
    }
  }
}
