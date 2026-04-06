import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.controller});

  final AuthController controller;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
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
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
