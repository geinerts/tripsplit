import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../app/router/app_router.dart';

class AuthSignInChoicePage extends StatelessWidget {
  const AuthSignInChoicePage({super.key});

  String _text(BuildContext context, {required String en, required String lv}) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    return locale == 'lv' ? lv : en;
  }

  void _openEmail(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRouter.login,
      arguments: const <String, Object?>{'start_register': false},
    );
  }

  void _openSocial(BuildContext context, String provider) {
    Navigator.of(context).pushNamed(
      AppRouter.login,
      arguments: <String, Object?>{
        'start_register': false,
        'social_provider': provider,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w800,
      fontSize: 54,
      height: 1,
      letterSpacing: -1.8,
    );
    final subtitleStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: Colors.white.withValues(alpha: 0.32),
      fontWeight: FontWeight.w500,
      height: 1.35,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF040607),
      body: Stack(
        children: [
          Positioned(
            top: 130,
            left: -120,
            right: -120,
            child: IgnorePointer(
              child: Container(
                height: 280,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.05,
                    colors: [Color(0x2200C26D), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -120,
            right: -120,
            child: IgnorePointer(
              child: Container(
                height: 330,
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 1.0,
                    colors: [Color(0x3300A95D), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBackButton(context),
                      const SizedBox(height: 260),
                      Text(
                        _text(
                          context,
                          en: 'Welcome back.',
                          lv: 'Sveiki atkal.',
                        ),
                        style: titleStyle,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _text(
                          context,
                          en: 'Choose how you want to sign in.',
                          lv: 'Izvēlies, kā vēlies pieslēgties.',
                        ),
                        style: subtitleStyle,
                      ),
                      const SizedBox(height: 48),
                      _buildEmailButton(context),
                      const SizedBox(height: 24),
                      _buildOrRow(context),
                      const SizedBox(height: 24),
                      _buildSocialButton(
                        context,
                        label: _text(
                          context,
                          en: 'Continue with Google',
                          lv: 'Turpināt ar Google',
                        ),
                        icon: SvgPicture.asset(
                          'assets/branding/google_g_logo.svg',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        onTap: () => _openSocial(context, 'google'),
                      ),
                      if (Platform.isIOS) ...[
                        const SizedBox(height: 14),
                        _buildSocialButton(
                          context,
                          label: _text(
                            context,
                            en: 'Continue with Apple',
                            lv: 'Turpināt ar Apple',
                          ),
                          icon: SvgPicture.asset(
                            'assets/branding/apple_logo_white.svg',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                          onTap: () => _openSocial(context, 'apple'),
                        ),
                      ],
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).pop(),
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: const Icon(Icons.chevron_left_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmailButton(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF9BDFC3), Color(0xFF57B487)],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4A2EAF6E),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _openEmail(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size.fromHeight(62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.mail_outline_rounded, color: Colors.white),
        label: Text(
          _text(
            context,
            en: 'Sign in with email',
            lv: 'Pieslēgties ar e-pastu',
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildOrRow(BuildContext context) {
    final lineColor = Colors.white.withValues(alpha: 0.12);
    final textColor = Colors.white.withValues(alpha: 0.18);
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
            _text(context, en: 'OR', lv: 'VAI'),
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

  Widget _buildSocialButton(
    BuildContext context, {
    required String label,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 22),
              icon,
              const SizedBox(width: 18),
              Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
