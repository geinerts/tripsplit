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
    final clientId = env.googleServerClientId.trim();
    final baseUrl = env.apiBaseUrl.trim();
    if (clientId.isEmpty || baseUrl.isEmpty) {
      throw StateError(
        _authText(
          en: 'Google sign-in is not configured yet.',
          lv: 'Google pieslēgšanās vēl nav nokonfigurēta.',
        ),
      );
    }

    final redirectUri = '$baseUrl/auth/google/callback';
    final state = DateTime.now().microsecondsSinceEpoch.toRadixString(36);

    final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'response_type': 'code',
      'scope': 'openid email profile',
      'state': state,
      'prompt': 'select_account',
    });

    final completer = Completer<_SocialAuthCredential>();
    final appLinks = AppLinks();
    StreamSubscription<Uri>? subscription;

    subscription = appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme != 'splyto' || uri.host != 'auth') return;
      if (!uri.path.startsWith('/google')) return;

      subscription?.cancel();

      final error = uri.queryParameters['error'] ?? '';
      if (error.isNotEmpty) {
        completer.completeError(StateError(
          _authText(
            en: 'Google sign-in failed: $error',
            lv: 'Google pieslēgšanās neizdevās: $error',
          ),
        ));
        return;
      }

      final returnedState = uri.queryParameters['state'] ?? '';
      if (returnedState != state) {
        completer.completeError(StateError(
          _authText(
            en: 'Google sign-in failed: invalid state.',
            lv: 'Google pieslēgšanās neizdevās: nederīgs state.',
          ),
        ));
        return;
      }

      final idToken = (uri.queryParameters['id_token'] ?? '').trim();
      if (idToken.isEmpty) {
        completer.completeError(StateError(
          _authText(
            en: 'Google sign-in failed: no id_token received.',
            lv: 'Google pieslēgšanās neizdevās: nav saņemts id_token.',
          ),
        ));
        return;
      }

      final payload = _decodeJwtPayload(idToken);
      final fullName = (payload['name'] ?? '').toString().trim();
      final email = (payload['email'] ?? '').toString().trim();
      completer.complete(_SocialAuthCredential(
        idToken: idToken,
        fullName: fullName.isEmpty ? null : fullName,
        email: email.isEmpty ? null : email,
      ));
    });

    final launched = await launchUrl(authUrl, mode: LaunchMode.externalApplication);
    if (!launched) {
      subscription?.cancel();
      throw StateError(
        _authText(
          en: 'Could not open Google sign-in.',
          lv: 'Nevar atvērt Google pieslēgšanos.',
        ),
      );
    }

    try {
      return await completer.future.timeout(const Duration(minutes: 5));
    } on TimeoutException {
      subscription?.cancel();
      throw _SocialAuthCancelled();
    }
  }

  Map<String, dynamic> _decodeJwtPayload(String idToken) {
    final parts = idToken.split('.');
    if (parts.length != 3) {
      return const {};
    }
    final payload = parts[1];
    var normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    try {
      final decoded = utf8.decode(base64.decode(normalized));
      final parsed = jsonDecode(decoded);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
      if (parsed is Map) {
        return parsed.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return const {};
    }
    return const {};
  }

  Future<_SocialAuthCredential> _signInWithApple() async {
    if (!Platform.isIOS) {
      throw StateError(
        _authText(
          en: 'Apple sign-in is available on iOS devices.',
          lv: 'Apple pieslēgšanās ir pieejama iOS ierīcēs.',
        ),
      );
    }
    if (!await SignInWithApple.isAvailable()) {
      throw StateError(
        _authText(
          en: 'Apple sign-in is not available on this device.',
          lv: 'Apple pieslēgšanās šajā ierīcē nav pieejama.',
        ),
      );
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
        throw StateError(
          _authText(
            en: 'Apple sign-in did not return an identity token.',
            lv: 'Apple pieslēgšanās neatgrieza identitātes tokenu.',
          ),
        );
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
      return _authText(
        en: 'Apple sign-in failed. Please try again.',
        lv: 'Apple pieslēgšanās neizdevās. Mēģini vēlreiz.',
      );
    }
    return _authText(
      en: 'Google sign-in failed. Please try again.',
      lv: 'Google pieslēgšanās neizdevās. Mēģini vēlreiz.',
    );
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
        _errorText = _authText(
          en: 'Account is deactivated. Enter your email to request a reactivation link.',
          lv: 'Konts ir deaktivēts. Ievadi e-pastu, lai pieprasītu reaktivācijas saiti.',
        );
      });
      return;
    }

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _authText(en: 'Account is deactivated', lv: 'Konts ir deaktivēts'),
          ),
          content: Text(
            _authText(
              en: 'Send a reactivation link to $email?',
              lv: 'Nosūtīt reaktivācijas saiti uz $email?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_authText(en: 'Cancel', lv: 'Atcelt')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_authText(en: 'Send link', lv: 'Sūtīt saiti')),
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
      _showSnack(
        _authText(
          en: 'Reactivation link sent. Check your email.',
          lv: 'Reaktivācijas saite nosūtīta. Pārbaudi e-pastu.',
        ),
      );
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
        _errorText = _authText(
          en: 'Could not send reactivation link. Please try again.',
          lv: 'Neizdevās nosūtīt reaktivācijas saiti. Mēģini vēlreiz.',
        );
      });
    }
  }

  Future<void> _handleEmailNotVerifiedLogin(String rawEmail) async {
    final email = rawEmail.trim().toLowerCase();
    if (email.isEmpty) {
      _updateState(() {
        _errorText = _authText(
          en: 'Email is not verified. Enter your email to request verification link.',
          lv: 'E-pasts nav verificēts. Ievadi e-pastu, lai pieprasītu verifikācijas saiti.',
        );
      });
      return;
    }

    final shouldSend = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _authText(en: 'Email not verified', lv: 'E-pasts nav verificēts'),
          ),
          content: Text(
            _authText(
              en: 'Send verification link to $email?',
              lv: 'Nosūtīt verifikācijas saiti uz $email?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_authText(en: 'Cancel', lv: 'Atcelt')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_authText(en: 'Send link', lv: 'Sūtīt saiti')),
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
      _showSnack(
        _authText(
          en: 'Verification link sent. Check your email.',
          lv: 'Verifikācijas saite nosūtīta. Pārbaudi e-pastu.',
        ),
      );
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
        _errorText = _authText(
          en: 'Could not send verification link. Please try again.',
          lv: 'Neizdevās nosūtīt verifikācijas saiti. Mēģini vēlreiz.',
        );
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
        : _authText(
            en: 'Verification email sent. Please verify your email before logging in.',
            lv: 'Verifikācijas e-pasts nosūtīts. Pirms ielogošanās verificē e-pastu.',
          );

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
          title: Text(
            _authText(en: 'Verify your email', lv: 'Verificē savu e-pastu'),
          ),
          content: Text(
            email.isEmpty
                ? message
                : '$message\n\n${_authText(en: 'Email:', lv: 'E-pasts:')} $email',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(_authText(en: 'Close', lv: 'Aizvērt')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(_authText(en: 'Resend link', lv: 'Sūtīt vēlreiz')),
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
      _showSnack(
        _authText(
          en: 'Verification link sent. Check your email.',
          lv: 'Verifikācijas saite nosūtīta. Pārbaudi e-pastu.',
        ),
      );
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
        _errorText = _authText(
          en: 'Could not send verification link. Please try again.',
          lv: 'Neizdevās nosūtīt verifikācijas saiti. Mēģini vēlreiz.',
        );
      });
    }
  }
}
