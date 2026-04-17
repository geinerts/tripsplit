part of 'login_page.dart';

extension _LoginPageWidgetsForm on _LoginPageState {
  Widget _buildAuthCard(
    BuildContext context, {
    required bool asStandaloneContent,
  }) {
    final t = context.l10nEn;
    final isLogin = _mode == _AuthMode.login;
    final responsive = context.responsive;
    final cardPadding = responsive.pick(compact: 16, medium: 20, expanded: 22);
    final colorScheme = Theme.of(context).colorScheme;

    final content = Padding(
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
            leadingIcon: Icons.mail_outline_rounded,
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
          if (isLogin) _buildForgotPasswordRow(context),
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
            const SizedBox(height: 14),
            _buildOrRow(context),
            const SizedBox(height: 12),
            _buildSocialButtons(context),
          ],
          if (!widget.compactSheet) ...[
            const SizedBox(height: 14),
            _buildModeSwitchRow(context),
          ],
        ],
      ),
    );

    if (asStandaloneContent) {
      return content;
    }

    return Card(child: content);
  }

  List<Widget> _buildRegistrationFields(BuildContext context) {
    final t = context.l10nEn;
    return [
      _buildLabeledTextField(
        context: context,
        label: t.fullNameLabel,
        hint: t.fullNameHint,
        leadingIcon: Icons.person_outline_rounded,
        controller: _fullNameController,
        validator: _validateFullName,
        autocorrect: false,
      ),
      const SizedBox(height: 8),
      Text(
        t.fullNameHelper,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppDesign.mutedColor(context)),
      ),
    ];
  }

  Widget _buildSocialButtons(BuildContext context) {
    final t = context.l10nEn;
    final showApple = Platform.isIOS;
    if (!showApple) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSocialButton(
            context: context,
            semanticLabel: t.authIntroContinueGoogle,
            label: t.authIntroContinueGoogle,
            icon: _buildGoogleLogo(context),
            onPressed: _isSubmitting
                ? null
                : () => _onSocialPressed(_SocialAuthProvider.google),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSocialButton(
          context: context,
          semanticLabel: t.authIntroContinueGoogle,
          label: t.authIntroContinueGoogle,
          icon: _buildGoogleLogo(context),
          onPressed: _isSubmitting
              ? null
              : () => _onSocialPressed(_SocialAuthProvider.google),
        ),
        const SizedBox(height: 10),
        _buildSocialButton(
          context: context,
          semanticLabel: t.authIntroContinueApple,
          label: t.authIntroContinueApple,
          icon: _buildAppleLogo(context),
          onPressed: _isSubmitting
              ? null
              : () => _onSocialPressed(_SocialAuthProvider.apple),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String semanticLabel,
    required String label,
    required Widget icon,
    required VoidCallback? onPressed,
  }) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: semantic.heroAvatarStroke.withValues(alpha: 0.95),
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: semantic.heroAvatarStroke.withValues(alpha: 0.95),
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: semantic.cardGlassBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );
  }

  Widget _buildGoogleLogo(BuildContext context) {
    const iconSize = 24.0;
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

  Widget _buildAppleLogo(BuildContext context) {
    const iconSize = 24.0;
    final isDark = AppDesign.isDark(context);
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: SvgPicture.asset(
        isDark
            ? 'assets/branding/apple_logo_white.svg'
            : 'assets/branding/apple_logo.svg',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context, bool isLogin) {
    return _buildLabeledTextField(
      context: context,
      label: context.l10nEn.passwordLabel,
      hint: '••••••••',
      leadingIcon: Icons.lock_outline_rounded,
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
      label: context.l10nEn.repeatPasswordLabel,
      hint: '••••••••',
      leadingIcon: Icons.lock_outline_rounded,
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
    final strength = _resolvePasswordStrength(
      context,
      _passwordController.text,
    );
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
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.8,
                    ),
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

  _PasswordStrength _resolvePasswordStrength(
    BuildContext context,
    String text,
  ) {
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
    final requiredChecksMet = [
      minLengthMet,
      hasUpper,
      hasNumber,
      hasSymbol,
    ].where((met) => met).length;

    final meetsGreenLevel = minLengthMet && hasUpper && hasNumber && hasSymbol;
    if (meetsGreenLevel) {
      final veryStrong = value.length >= 14;
      return _PasswordStrength(
        fillFactor: veryStrong ? 1.0 : 0.8,
        color: veryStrong ? colors.primary : AppDesign.successColor(context),
      );
    }

    if (requiredChecksMet <= 1) {
      return _PasswordStrength(
        fillFactor: requiredChecksMet == 0 ? 0.0 : 0.25,
        color: AppDesign.destructiveColor(context),
      );
    }
    if (requiredChecksMet == 2) {
      return const _PasswordStrength(
        fillFactor: 0.5,
        color: AppDesign.lightAccent,
      );
    }
    return const _PasswordStrength(
      fillFactor: 0.72,
      color: AppDesign.lightAccent,
    );
  }

  Widget _buildForgotPasswordRow(BuildContext context) {
    final t = context.l10nEn;
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isSubmitting
            ? null
            : () => Navigator.of(context).pushNamed(AppRouter.forgotPassword),
        child: Text(t.forgotPassword),
      ),
    );
  }

  Widget _buildOrRow(BuildContext context) {
    final t = context.l10nEn;
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    final lineColor = semantic.cardGlassBorder.withValues(alpha: 0.42);
    final textColor = semantic.cardGlassBorder.withValues(alpha: 0.62);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [lineColor, Colors.transparent],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            t.authIntroOr,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [lineColor, Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isLogin = _mode == _AuthMode.login;
    final t = context.l10nEn;
    final responsive = context.responsive;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: AppDesign.authButtonGradient,
        ),
        child: ElevatedButton(
          key: const ValueKey(AppTestKeys.authSubmitButton),
          onPressed: _isSubmitting ? null : _onSubmitPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: AppDesign.darkForeground,
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
                    color: AppDesign.darkForeground,
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
    final t = context.l10nEn;
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
    required IconData leadingIcon,
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
    return Semantics(
      label: label,
      textField: true,
      child: TextFormField(
        key: fieldKey,
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        autocorrect: autocorrect,
        obscureText: obscureText,
        decoration: _buildInputDecoration(
          context,
          hint: hint,
          leadingIcon: leadingIcon,
          suffixIcon: suffixIcon,
          contentPadding: contentPadding,
        ),
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hint,
    required IconData leadingIcon,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final muted = AppDesign.mutedColor(context).withValues(alpha: 0.72);
    return InputDecoration(
      hintText: hint,
      hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: muted,
        fontWeight: FontWeight.w500,
      ),
      filled: false,
      isDense: true,
      prefixIcon: Icon(leadingIcon, color: muted, size: 22),
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
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      suffixIcon: suffixIcon,
    );
  }
}

class _PasswordStrength {
  const _PasswordStrength({required this.fillFactor, required this.color});

  final double fillFactor;
  final Color color;
}
