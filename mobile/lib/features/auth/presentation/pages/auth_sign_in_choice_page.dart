import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/app_semantic_colors.dart';
import '../../../../app/theme/auth_flow_theme.dart';
import '../../../../core/config/app_env.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/auth_user.dart';
import '../controllers/auth_controller.dart';
import 'auth_background_layers.dart';
import 'login_page.dart';

enum _ChoiceSocialProvider { google, apple }

extension _ChoiceSocialProviderValue on _ChoiceSocialProvider {
  String get value {
    switch (this) {
      case _ChoiceSocialProvider.google:
        return 'google';
      case _ChoiceSocialProvider.apple:
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

class AuthSignInChoicePage extends StatefulWidget {
  const AuthSignInChoicePage({
    super.key,
    required this.controller,
    this.presentedAsSheet = false,
  });

  final AuthController controller;
  final bool presentedAsSheet;

  @override
  State<AuthSignInChoicePage> createState() => _AuthSignInChoicePageState();
}

class _AuthSignInChoicePageState extends State<AuthSignInChoicePage> {
  bool _isSubmitting = false;

  String _text(BuildContext context, {required String en, required String lv}) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    return locale == 'lv' ? lv : en;
  }

  Future<void> _openEmail(BuildContext context) async {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    final viewport = MediaQuery.sizeOf(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: semantic.modalBarrier,
      constraints: BoxConstraints(maxWidth: viewport.width),
      builder: (_) {
        return SizedBox(
          width: double.infinity,
          height: viewport.height * 0.78,
          child: LoginPage(
            controller: widget.controller,
            startInRegister: true,
            compactSheet: true,
            showSheetClose: false,
          ),
        );
      },
    );
  }

  Future<void> _onSocialPressed(_ChoiceSocialProvider provider) async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final credential = switch (provider) {
        _ChoiceSocialProvider.google => await _signInWithGoogle(),
        _ChoiceSocialProvider.apple => await _signInWithApple(),
      };
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
      // User cancelled flow.
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message);
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      _showSnack(error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(_socialAuthFallbackError(provider));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<_SocialAuthCredential> _signInWithGoogle() async {
    final isLv =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'lv';
    final serverClientId = AppEnv.current.googleServerClientId.trim();
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
        throw StateError(
          isLv
              ? 'Google pieslēgšanās neatgrieza id token.'
              : 'Google sign-in did not return an id token.',
        );
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
    final isLv =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'lv';
    if (!Platform.isIOS) {
      throw StateError(
        isLv
            ? 'Apple pieslēgšanās ir pieejama iOS ierīcēs.'
            : 'Apple sign-in is available on iOS devices.',
      );
    }
    if (!await SignInWithApple.isAvailable()) {
      throw StateError(
        isLv
            ? 'Apple pieslēgšanās šajā ierīcē nav pieejama.'
            : 'Apple sign-in is not available on this device.',
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
          isLv
              ? 'Apple pieslēgšanās neatgrieza identitātes tokenu.'
              : 'Apple sign-in did not return an identity token.',
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

  String _socialAuthFallbackError(_ChoiceSocialProvider provider) {
    if (provider == _ChoiceSocialProvider.apple) {
      return _text(
        context,
        en: 'Apple sign-in failed. Please try again.',
        lv: 'Apple pieslēgšanās neizdevās. Mēģini vēlreiz.',
      );
    }
    return _text(
      context,
      en: 'Google sign-in failed. Please try again.',
      lv: 'Google pieslēgšanās neizdevās. Mēģini vēlreiz.',
    );
  }

  void _goAfterAuth(AuthUser user) {
    final nextRoute = user.needsCredentials
        ? AppRouter.credentials
        : AppRouter.trips;
    Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
  }

  void _showSnack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowTheme(
      child: Builder(
        builder: (context) {
          final semantic =
              Theme.of(context).extension<AppSemanticColors>() ??
              AppSemanticColors.dark;
          return Scaffold(
            backgroundColor: AppDesign.authCanvas,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                AuthBackgroundLayers(
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final heroWidth = constraints.maxWidth.clamp(
                          240.0,
                          318.0,
                        );
                        final heroViewportHeight =
                            (constraints.maxHeight * 0.44).clamp(260.0, 340.0);
                        const titleSize = 36.0;
                        final titleStyle = Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: AppDesign.darkForeground,
                              fontWeight: FontWeight.w800,
                              fontSize: titleSize,
                              height: 1.05,
                              letterSpacing: -0.9,
                            );
                        final subtitleStyle = Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: semantic.cardGlassBorder.withValues(
                                alpha: 0.78,
                              ),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.65,
                            );

                        return Center(
                          child: Stack(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 480,
                                ),
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.fromLTRB(
                                    24,
                                    12,
                                    24,
                                    24,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight - 34,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: SizedBox(
                                            width: heroWidth,
                                            height: heroViewportHeight,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: FittedBox(
                                                fit: BoxFit.contain,
                                                alignment: Alignment.topCenter,
                                                child: SizedBox(
                                                  width: 318,
                                                  height: 430,
                                                  child: _buildTopHero(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _text(
                                            context,
                                            en: 'Create your account.',
                                            lv: 'Izveido savu kontu.',
                                          ),
                                          maxLines: 1,
                                          softWrap: false,
                                          overflow: TextOverflow.visible,
                                          style: titleStyle,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _text(
                                            context,
                                            en: 'Choose how you want to sign up.',
                                            lv: 'Izvēlies, kā vēlies reģistrēties.',
                                          ),
                                          style: subtitleStyle,
                                        ),
                                        const SizedBox(height: 32),
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
                                          onTap: _isSubmitting
                                              ? null
                                              : () => _onSocialPressed(
                                                  _ChoiceSocialProvider.google,
                                                ),
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
                                            onTap: _isSubmitting
                                                ? null
                                                : () => _onSocialPressed(
                                                    _ChoiceSocialProvider.apple,
                                                  ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 24,
                                child: _buildBackButton(context),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (_isSubmitting)
                  Positioned.fill(
                    child: AbsorbPointer(
                      child: Container(
                        color: semantic.heroMenuBackground,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopHero() {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: CustomPaint(
              size: const Size(300, 300),
              painter: _ChoiceGlobePainter(),
            ),
          ),
        ),
        Positioned(
          top: 34,
          right: 0,
          child: _buildHeroPill(
            label: 'EUR · USD · GBP · JPY',
            background: semantic.cardGlassBackground.withValues(alpha: 0.22),
            border: semantic.cardGlassBorder.withValues(alpha: 0.88),
            textColor: AppDesign.darkForeground.withValues(alpha: 0.44),
          ),
        ),
        Positioned(
          top: 210,
          left: 2,
          child: _buildHeroPill(
            label: _text(context, en: 'Split settled', lv: 'Norēķins pabeigts'),
            background: semantic.statusActiveBackground,
            border: semantic.statusActiveBorder,
            textColor: semantic.statusActiveForeground,
            leadingDot: true,
          ),
        ),
        Positioned(
          top: 258,
          right: 2,
          child: _buildHeroPill(
            label: _text(
              context,
              en: 'Paris · 3 friends',
              lv: 'Parīze · 3 draugi',
            ),
            background: semantic.cardGlassBackground.withValues(alpha: 0.22),
            border: semantic.cardGlassBorder.withValues(alpha: 0.88),
            textColor: AppDesign.darkForeground.withValues(alpha: 0.40),
          ),
        ),
        Positioned(
          top: 312,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.scale(
              scaleX: 1.30,
              scaleY: 1.25,
              child: Image.asset(
                'assets/branding/logo_full_dark.png',
                width: 190,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPill({
    required String label,
    required Color background,
    required Color border,
    required Color textColor,
    bool leadingDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leadingDot)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: AppDesign.authAccentSoft,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    return IconButton(
      onPressed: _isSubmitting ? null : () => Navigator.of(context).maybePop(),
      splashRadius: 22,
      iconSize: 32,
      color: semantic.heroAvatarStroke.withValues(alpha: 0.92),
      icon: Icon(
        widget.presentedAsSheet
            ? Icons.close_rounded
            : Icons.chevron_left_rounded,
      ),
    );
  }

  Widget _buildEmailButton(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppDesign.authButtonGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppDesign.authButtonShadow,
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : () => _openEmail(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size.fromHeight(62),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(
          Icons.mail_outline_rounded,
          color: AppDesign.darkForeground,
        ),
        label: Text(
          _text(
            context,
            en: 'Sign up with email',
            lv: 'Reģistrēties ar e-pastu',
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppDesign.darkForeground,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildOrRow(BuildContext context) {
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
    required VoidCallback? onTap,
  }) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            color: semantic.cardGlassBackground.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: semantic.cardGlassBorder.withValues(alpha: 0.82),
            ),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 18),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: semantic.heroAvatarStroke.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChoiceGlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeMain = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppDesign.authWireMain
      ..strokeWidth = 1;
    final strokeSoft = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppDesign.authWireSoft
      ..strokeWidth = 0.8;

    canvas.drawCircle(center, 136, strokeMain);
    canvas.drawCircle(center, 110, strokeSoft);
    canvas.drawCircle(center, 82, strokeSoft);

    void drawEllipse(double rx, double ry, Paint paint) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
        paint,
      );
    }

    drawEllipse(136, 38, strokeSoft);
    drawEllipse(136, 82, strokeSoft);
    drawEllipse(136, 120, strokeSoft);
    drawEllipse(55, 136, strokeSoft);
    drawEllipse(108, 136, strokeSoft);

    canvas.drawLine(
      Offset(14, center.dy),
      Offset(size.width - 14, center.dy),
      strokeMain..strokeWidth = 0.9,
    );
    canvas.drawLine(
      Offset(center.dx, 14),
      Offset(center.dx, size.height - 14),
      strokeSoft..strokeWidth = 0.9,
    );

    final path = Path()
      ..moveTo(75, 124)
      ..quadraticBezierTo(124, 84, 150, 150)
      ..quadraticBezierTo(176, 210, 238, 170);
    _drawDashedPath(
      canvas,
      path,
      dashLength: 7,
      gapLength: 5,
      paint: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..color = AppDesign.authDashedPath,
    );

    _drawPulse(canvas, const Offset(75, 124), AppDesign.authAccentStrong);
    _drawPulse(canvas, const Offset(238, 170), AppDesign.authAccentMagenta);
    canvas.drawCircle(
      center,
      3,
      Paint()..color = AppDesign.darkForeground.withValues(alpha: 0.18),
    );
  }

  void _drawPulse(Canvas canvas, Offset center, Color color) {
    canvas.drawCircle(
      center,
      4.8,
      Paint()..color = color.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      center,
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = color.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      center,
      16,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.6
        ..color = color.withValues(alpha: 0.10),
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path, {
    required double dashLength,
    required double gapLength,
    required Paint paint,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
