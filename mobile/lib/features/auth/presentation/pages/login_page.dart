import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/app_semantic_colors.dart';
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
  const LoginPage({
    super.key,
    required this.controller,
    this.startInRegister = false,
    this.autoSocialProvider,
    this.showSheetClose = false,
    this.compactSheet = false,
  });

  final AuthController controller;
  final bool startInRegister;
  final String? autoSocialProvider;
  final bool showSheetClose;
  final bool compactSheet;

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
  bool _didApplyInitialModeFromRoute = false;
  _SocialAuthProvider? _pendingSocialProvider;
  bool _didAutoTriggerSocial = false;

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
  }

  @override
  void initState() {
    super.initState();
    _tryRestoreSession();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didApplyInitialModeFromRoute) {
      return;
    }
    _didApplyInitialModeFromRoute = true;
    if (widget.startInRegister) {
      _mode = _AuthMode.register;
    }
    final providerFromWidget = (widget.autoSocialProvider ?? '').trim();
    if (providerFromWidget == 'google') {
      _mode = _AuthMode.login;
      _pendingSocialProvider = _SocialAuthProvider.google;
    } else if (providerFromWidget == 'apple') {
      _mode = _AuthMode.login;
      _pendingSocialProvider = _SocialAuthProvider.apple;
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args['start_register'] == true) {
      _mode = _AuthMode.register;
    }
    if (args is Map && args['social_provider'] is String) {
      final providerRaw = (args['social_provider'] as String).trim();
      if (providerRaw == 'google') {
        _mode = _AuthMode.login;
        _pendingSocialProvider = _SocialAuthProvider.google;
      } else if (providerRaw == 'apple') {
        _mode = _AuthMode.login;
        _pendingSocialProvider = _SocialAuthProvider.apple;
      }
    }
    if (_pendingSocialProvider != null && !_didAutoTriggerSocial) {
      _didAutoTriggerSocial = true;
      final provider = _pendingSocialProvider!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _onSocialPressed(provider);
      });
    }
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
