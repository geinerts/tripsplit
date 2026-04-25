import 'package:flutter/material.dart';

import '../../../../app/theme/app_design.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/responsive.dart';
import '../controllers/auth_controller.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, required this.controller});

  final AuthController controller;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final t = context.l10nEn;
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

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.controller.requestPasswordReset(
        email: _emailController.text.trim().toLowerCase(),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitted = true;
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
        _errorText = context.l10nEn.requestFailedTryAgain;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10nEn;
    final responsive = context.responsive;
    final horizontalPadding = responsive.pageHorizontalPadding;

    return AppPageScaffold(
      appBar: AppBar(title: Text(t.forgotPasswordTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.pageMaxWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                18,
                horizontalPadding,
                24,
              ),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: _isSubmitted
                        ? _buildSuccessBody(context)
                        : _buildRequestForm(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestForm(BuildContext context) {
    final t = context.l10nEn;
    final colorScheme = Theme.of(context).colorScheme;
    final muted = AppDesign.mutedColor(context).withValues(alpha: 0.72);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.emailAddressLabel,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: t.emailHint,
              hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: muted,
                fontWeight: FontWeight.w500,
              ),
              filled: false,
              isDense: true,
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: muted,
                size: 22,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  width: 1.2,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                  width: 1.2,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.error, width: 1.4),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.error, width: 1.6),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 16,
              ),
            ),
            validator: _validateEmail,
            onFieldSubmitted: (_) => _submit(),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.sendResetLinkButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBody(BuildContext context) {
    final t = context.l10nEn;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 38,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          t.forgotPasswordSuccessMessage,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.backToLoginAction),
          ),
        ),
      ],
    );
  }
}
