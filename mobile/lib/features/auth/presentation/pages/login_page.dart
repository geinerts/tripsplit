import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../core/config/app_env.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/responsive.dart';
import '../../../../core/ui/test_keys.dart';
import '../../domain/entities/auth_user.dart';
import '../controllers/auth_controller.dart';

part 'login_page_actions.dart';
part 'login_page_validators.dart';
part 'login_page_widgets.dart';
part 'login_page_widgets_form.dart';

enum _AuthMode { login, register }

enum _SocialAuthProvider { google, apple }

extension _SocialAuthProviderValue on _SocialAuthProvider {
  String get value {
    switch (this) {
      case _SocialAuthProvider.google:
        return 'google';
      case _SocialAuthProvider.apple:
        return 'apple';
    }
  }
}

class _SocialAuthCredential {
  const _SocialAuthCredential({
    required this.idToken,
    this.fullName,
    this.email,
  });

  final String idToken;
  final String? fullName;
  final String? email;
}

class _SocialAuthCancelled implements Exception {}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AuthController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _isSubmitting = false;
  bool _isNavigatingAway = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _obscureRepeat = true;
  String? _errorText;
  late final FlutterAppAuth _googleAppAuth;
  late final String _googleOauthClientId;
  late final String _googleOauthRedirectUri;

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
  }

  String _authText({required String en, required String lv}) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'lv' ? lv : en;
  }

  @override
  void initState() {
    super.initState();
    final env = AppEnv.current;
    _googleAppAuth = const FlutterAppAuth();
    _googleOauthClientId = _resolveGoogleOauthClientId(env);
    _googleOauthRedirectUri = _resolveGoogleOauthRedirectUri(
      env,
      _googleOauthClientId,
    );
    if (kDebugMode) {
      debugPrint(
        'Google OAuth init: platform=${Platform.operatingSystem}, '
        'clientIdSet=${_googleOauthClientId.isNotEmpty}, '
        'redirectUriSet=${_googleOauthRedirectUri.isNotEmpty}',
      );
    }
    _tryRestoreSession();
  }

  String _resolveGoogleOauthClientId(AppEnv env) {
    if (Platform.isIOS) {
      return env.googleIosClientId.trim();
    }
    // Android uses the web client ID with a loopback redirect URI.
    // AppAuth-Android spins up a local HTTP server to capture the response.
    return env.googleServerClientId.trim();
  }

  String _resolveGoogleOauthRedirectUri(AppEnv env, String clientId) {
    if (Platform.isIOS) {
      final iosReversed = env.googleReversedClientId.trim();
      if (iosReversed.isEmpty) return '';
      return '$iosReversed:/oauth2redirect/google';
    }
    // Android: loopback redirect — AppAuth opens a local HTTP server.
    return 'http://localhost';
  }

  String _deriveGoogleReversedClientIdScheme(String clientId) {
    final normalized = clientId.trim();
    const suffix = '.apps.googleusercontent.com';
    if (normalized.isEmpty || !normalized.endsWith(suffix)) {
      return '';
    }
    final core = normalized.substring(0, normalized.length - suffix.length);
    if (core.isEmpty) {
      return '';
    }
    return 'com.googleusercontent.apps.$core';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildLoginScaffold(context);
  }
}
