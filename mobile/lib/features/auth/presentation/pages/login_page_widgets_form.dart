part of 'login_page.dart';

extension _LoginPageWidgetsForm on _LoginPageState {
  Widget _buildAuthCard(BuildContext context) {
    final t = context.l10n;
    final isLogin = _mode == _AuthMode.login;
    final responsive = context.responsive;
    final cardPadding = responsive.pick(compact: 16, medium: 20, expanded: 22);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isLogin) ...[
              ..._buildRegistrationFields(context),
              const SizedBox(height: 16),
            ],
            _buildLabeledTextField(
              context: context,
              label: t.emailAddressLabel,
              hint: t.emailHint,
              controller: _emailController,
              validator: _validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              fieldKey: const ValueKey(AppTestKeys.loginEmailField),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(context, isLogin),
            if (!isLogin) ...[
              const SizedBox(height: 10),
              _buildPasswordStrengthIndicator(context),
              const SizedBox(height: 16),
              _buildRepeatPasswordField(context),
            ],
            const SizedBox(height: 12),
            if (isLogin) _buildRememberAndForgotRow(context),
            if (_errorText != null) ...[
              const SizedBox(height: 2),
              Text(
                _errorText!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildSubmitButton(context),
            if (isLogin) ...[
              const SizedBox(height: 12),
              _buildSocialPlaceholders(context),
            ],
            const SizedBox(height: 14),
            _buildModeSwitchRow(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRegistrationFields(BuildContext context) {
    final t = context.l10n;
    return [
      _buildSocialPlaceholders(context),
      const SizedBox(height: 14),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildLabeledTextField(
              context: context,
              label: t.firstNameLabel,
              hint: t.firstNameHint,
              controller: _firstNameController,
              validator: _validateFirstName,
              autocorrect: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildLabeledTextField(
              context: context,
              label: t.lastNameLabel,
              hint: t.lastNameHint,
              controller: _lastNameController,
              validator: _validateLastName,
              autocorrect: false,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSocialPlaceholders(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSocialPlaceholderButton(
            context: context,
            label: 'Google',
            icon: _buildGooglePlaceholderLogo(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSocialPlaceholderButton(
            context: context,
            label: 'Apple',
            icon: _buildApplePlaceholderLogo(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPlaceholderButton({
    required BuildContext context,
    required String label,
    required Widget icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: _isSubmitting ? null : () => _showSnack('Coming soon'),
      icon: icon,
      label: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
        minimumSize: const Size.fromHeight(46),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
          width: 1.0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildGooglePlaceholderLogo(BuildContext context) {
    const iconSize = 26.0;
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: SvgPicture.asset(
        'assets/branding/google_g_logo.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildApplePlaceholderLogo(BuildContext context) {
    const iconSize = 26.0;
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: SvgPicture.asset(
        'assets/branding/apple_logo.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context, bool isLogin) {
    return _buildLabeledTextField(
      context: context,
      label: context.l10n.passwordLabel,
      hint: '••••••••',
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: _obscurePassword,
      textInputAction: isLogin ? TextInputAction.done : TextInputAction.next,
      fieldKey: const ValueKey(AppTestKeys.loginPasswordField),
      suffixIcon: IconButton(
        onPressed: () {
          _updateState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        icon: Icon(
          _obscurePassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
      onChanged: isLogin
          ? null
          : (_) {
              _updateState(() {});
            },
      onFieldSubmitted: isLogin ? (_) => _onSubmitPressed() : null,
    );
  }

  Widget _buildRepeatPasswordField(BuildContext context) {
    return _buildLabeledTextField(
      context: context,
      label: context.l10n.repeatPasswordLabel,
      hint: '••••••••',
      controller: _repeatController,
      validator: _validateRepeat,
      obscureText: _obscureRepeat,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        onPressed: () {
          _updateState(() {
            _obscureRepeat = !_obscureRepeat;
          });
        },
        icon: Icon(
          _obscureRepeat
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
      onFieldSubmitted: (_) => _onSubmitPressed(),
    );
  }

  Widget _buildPasswordStrengthIndicator(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strength = _resolvePasswordStrength(context, _passwordController.text);
    return SizedBox(
      height: 7,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fullWidth = constraints.maxWidth;
          final fillWidth = (fullWidth * strength.fillFactor).clamp(
            0.0,
            fullWidth,
          );
          return ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.8),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: fillWidth,
                  color: strength.color,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  _PasswordStrength _resolvePasswordStrength(BuildContext context, String text) {
    final value = text.trim();
    if (value.isEmpty) {
      return _PasswordStrength(
        fillFactor: 0,
        color: Theme.of(context).colorScheme.outlineVariant,
      );
    }

    final colors = Theme.of(context).colorScheme;
    final minLengthMet = value.length >= 8;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(value);
    final requiredChecksMet = [minLengthMet, hasUpper, hasNumber, hasSymbol]
        .where((met) => met)
        .length;

    final meetsGreenLevel =
        minLengthMet && hasUpper && hasNumber && hasSymbol;
    if (meetsGreenLevel) {
      final veryStrong = value.length >= 14;
      return _PasswordStrength(
        fillFactor: veryStrong ? 1.0 : 0.8,
        color: veryStrong ? colors.primary : const Color(0xFF3B9A62),
      );
    }

    if (requiredChecksMet <= 1) {
      return _PasswordStrength(
        fillFactor: requiredChecksMet == 0 ? 0.0 : 0.25,
        color: const Color(0xFFE35D50),
      );
    }
    if (requiredChecksMet == 2) {
      return const _PasswordStrength(
        fillFactor: 0.5,
        color: Color(0xFFD4A72C),
      );
    }
    return const _PasswordStrength(
      fillFactor: 0.72,
      color: Color(0xFFD4A72C),
    );
  }

  Widget _buildRememberAndForgotRow(BuildContext context) {
    final t = context.l10n;
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: _isSubmitting
              ? null
              : (value) {
                  _updateState(() {
                    _rememberMe = value ?? false;
                  });
                },
        ),
        Text(t.rememberMe),
        const Spacer(),
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => _showSnack(t.passwordResetComingSoon),
          child: Text(t.forgotPassword),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isLogin = _mode == _AuthMode.login;
    final t = context.l10n;
    final responsive = context.responsive;
    const gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF9BDFC3), Color(0xFF57B487)],
    );

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: gradient,
        ),
        child: ElevatedButton(
          key: const ValueKey(AppTestKeys.authSubmitButton),
          onPressed: _isSubmitting ? null : _onSubmitPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  isLogin ? t.logInButton : t.signUpButton,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: responsive.pick(
                      compact: 17,
                      medium: 18,
                      expanded: 19,
                    ),
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildModeSwitchRow(BuildContext context) {
    final isLogin = _mode == _AuthMode.login;
    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final responsive = context.responsive;

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            isLogin ? t.noAccountQuestion : t.hasAccountQuestion,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.outline,
              fontSize: responsive.pick(compact: 16, medium: 17, expanded: 18),
            ),
          ),
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => _onModeChanged(
                    isLogin ? _AuthMode.register : _AuthMode.login,
                  ),
            child: Text(
              isLogin ? t.signUpButton : t.logInButton,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: responsive.pick(
                  compact: 16,
                  medium: 17,
                  expanded: 18,
                ),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required BuildContext context,
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    TextInputAction textInputAction = TextInputAction.next,
    TextInputType? keyboardType,
    bool autocorrect = true,
    bool obscureText = false,
    Widget? suffixIcon,
    Key? fieldKey,
    ValueChanged<String>? onFieldSubmitted,
    ValueChanged<String>? onChanged,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autocorrect: autocorrect,
          obscureText: obscureText,
          decoration: _buildInputDecoration(
            context,
            hint: hint,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding,
          ),
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          onChanged: onChanged,
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hint,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.75),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      suffixIcon: suffixIcon,
    );
  }
}

class _PasswordStrength {
  const _PasswordStrength({required this.fillFactor, required this.color});

  final double fillFactor;
  final Color color;
}
