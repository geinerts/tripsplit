import 'package:flutter/material.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/responsive.dart';
import '../controllers/auth_controller.dart';

class CredentialsPage extends StatefulWidget {
  const CredentialsPage({super.key, required this.controller});

  final AuthController controller;

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatController = TextEditingController();

  bool _isSubmitting = false;
  bool _isNavigatingAway = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final email = widget.controller.currentUser?.email;
    if (email != null && email.trim().isNotEmpty) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  Future<void> _onSavePressed() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.controller.setCredentials(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }
      _isNavigatingAway = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRouter.trips, (route) => false);
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = context.l10n.unexpectedErrorSavingCredentials;
      });
    } finally {
      if (mounted && !_isNavigatingAway) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    final t = context.l10n;
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return t.emailRequired;
    }
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
    if (!ok) {
      return t.invalidEmailFormat;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final t = context.l10n;
    final text = value ?? '';
    if (text.length < 8) {
      return t.passwordMinLengthShort;
    }
    return null;
  }

  String? _validateRepeat(String? value) {
    final t = context.l10n;
    if ((value ?? '') != _passwordController.text) {
      return t.passwordsDoNotMatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final responsive = context.responsive;
    final colorScheme = Theme.of(context).colorScheme;
    final horizontalPadding = responsive.pageHorizontalPadding;
    final cardPadding = responsive.pick(compact: 16, medium: 20, expanded: 24);
    final heroSize = responsive.pick(compact: 72, medium: 80, expanded: 88);
    final iconSize = responsive.pick(compact: 34, medium: 38, expanded: 42);

    return AppPageScaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: responsive.pageMaxWidth,
                    minHeight: constraints.maxHeight,
                  ),
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      12,
                      horizontalPadding,
                      24,
                    ),
                    children: [
                      Row(
                        children: [
                          const Spacer(),
                          IconButton(
                            tooltip: t.languageAction,
                            onPressed: _isSubmitting
                                ? null
                                : () => showAppLocalePicker(context),
                            icon: const Icon(Icons.translate_outlined),
                          ),
                          IconButton(
                            tooltip: t.appearance,
                            onPressed: _isSubmitting
                                ? null
                                : () => showThemeModePicker(context),
                            icon: const Icon(Icons.brightness_6_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          width: heroSize,
                          height: heroSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: AppDesign.brandGradient,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x335D6DFF),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.verified_user_outlined,
                            color: Colors.white,
                            size: iconSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        t.completeAccountSetupTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.completeAccountSetupDescription,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: t.emailLabel,
                                ),
                                validator: _validateEmail,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: t.passwordLabel,
                                ),
                                validator: _validatePassword,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _repeatController,
                                obscureText: true,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  labelText: t.repeatPasswordLabel,
                                ),
                                validator: _validateRepeat,
                                onFieldSubmitted: (_) => _onSavePressed(),
                              ),
                              const SizedBox(height: 16),
                              if (_errorText != null) ...[
                                Text(
                                  _errorText!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _onSavePressed,
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(t.saveCredentialsButton),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
