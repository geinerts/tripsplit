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
import '../../../../core/config/app_env.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_sheet.dart';
import '../../domain/entities/auth_user.dart';
import '../controllers/auth_controller.dart';
import 'auth_intro_background.dart';
import 'login_page.dart';

// Match LaunchImage in ios/Runner/Base.lproj/LaunchScreen.storyboard, so the logo
// keeps its size when the app takes over from the launch screen.
const _logoWidth = 260.0;
const _logoAspectRatio = 1200 / 475;
const _contentPadding = EdgeInsets.fromLTRB(24, 12, 24, 22);

enum _IntroSocialProvider { google, apple }

extension _IntroSocialProviderValue on _IntroSocialProvider {
  String get value {
    switch (this) {
      case _IntroSocialProvider.google:
        return 'google';
      case _IntroSocialProvider.apple:
        return 'apple';
    }
  }
}

class _IntroSocialCredential {
  const _IntroSocialCredential({
    required this.idToken,
    this.fullName,
    this.email,
    this.authorizationCode,
  });

  final String idToken;
  final String? fullName;
  final String? email;
  final String? authorizationCode;
}

class _IntroSocialCancelled implements Exception {}

class AuthIntroPage extends StatefulWidget {
  const AuthIntroPage({
    super.key,
    required this.controller,
    this.fromLaunch = false,
  });

  final AuthController controller;

  /// First screen after the launch screen: the logo moves up from where that left
  /// it, and the buttons fade in.
  final bool fromLaunch;

  @override
  State<AuthIntroPage> createState() => _AuthIntroPageState();
}

class _AuthIntroPageState extends State<AuthIntroPage> {
  final _logoKey = GlobalKey();
  late bool _choicesHidden = widget.fromLaunch;
  late bool _logoHidden = widget.fromLaunch;
  double _logoSlide = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.fromLaunch) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _placeLogoAtLaunch());
    }
  }

  /// The first frame only measures, so the logo never shows anywhere else first.
  void _placeLogoAtLaunch() {
    final box = _logoKey.currentContext?.findRenderObject() as RenderBox?;
    if (!mounted) return;
    if (box != null && box.hasSize && box.size.height > 0) {
      final center = box.localToGlobal(box.size.center(Offset.zero)).dy;
      _logoSlide =
          (MediaQuery.sizeOf(context).height / 2 - center) / box.size.height;
    }
    setState(() => _logoHidden = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _logoSlide = 0;
        _choicesHidden = false;
      });
    });
  }

  Future<void> _openSignIn() async {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      barrierColor: semantic.modalBarrier,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) {
        return LoginPage(
          controller: widget.controller,
          startInRegister: false,
          compactSheet: true,
          showSheetClose: false,
        );
      },
    );
  }

  Future<void> _openSignUpWithEmail() async {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    await showAppBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      wrapWithSurface: false,
      barrierColor: semantic.modalBarrier,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) {
        return LoginPage(
          controller: widget.controller,
          startInRegister: true,
          compactSheet: true,
          showSheetClose: false,
        );
      },
    );
  }

  Future<void> _onSocialPressed(_IntroSocialProvider provider) async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final credential = switch (provider) {
        _IntroSocialProvider.google => await _signInWithGoogle(),
        _IntroSocialProvider.apple => await _signInWithApple(),
      };
      final user = await widget.controller.loginWithSocial(
        provider: provider.value,
        idToken: credential.idToken,
        fullName: credential.fullName,
        email: credential.email,
        authorizationCode: credential.authorizationCode,
      );
      if (!mounted) {
        return;
      }
      _goAfterAuth(user);
    } on _IntroSocialCancelled {
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

  Future<_IntroSocialCredential> _signInWithGoogle() async {
    final serverClientId = AppEnv.current.googleServerClientId.trim();
    final missingIdTokenMessage =
        context.l10n.authGoogleSignDidNotReturnIdToken;
    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: serverClientId.isNotEmpty ? serverClientId : null,
    );

    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw _IntroSocialCancelled();
      }

      final auth = await account.authentication;
      final idToken = (auth.idToken ?? '').trim();
      if (idToken.isEmpty) {
        throw StateError(missingIdTokenMessage);
      }

      final fullName = (account.displayName ?? '').trim();
      final email = account.email.trim();
      return _IntroSocialCredential(
        idToken: idToken,
        fullName: fullName.isEmpty ? null : fullName,
        email: email.isEmpty ? null : email,
        authorizationCode: account.serverAuthCode,
      );
    } on PlatformException catch (error) {
      final combined = '${error.code} ${error.message ?? ''}'.toLowerCase();
      if (combined.contains('canceled') ||
          combined.contains('cancelled') ||
          combined.contains('sign_in_canceled')) {
        throw _IntroSocialCancelled();
      }
      rethrow;
    }
  }

  Future<_IntroSocialCredential> _signInWithApple() async {
    final iosOnlyMessage = context.l10n.authAppleSignAvailableIosDevices;
    final unavailableMessage = context.l10n.authAppleSignNotAvailableDevice;
    final missingIdTokenMessage =
        context.l10n.authAppleSignDidNotReturnIdentityToken;
    if (!Platform.isIOS) {
      throw StateError(iosOnlyMessage);
    }
    if (!await SignInWithApple.isAvailable()) {
      throw StateError(unavailableMessage);
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
        throw StateError(missingIdTokenMessage);
      }

      final nameParts = [
        (credential.givenName ?? '').trim(),
        (credential.familyName ?? '').trim(),
      ].where((part) => part.isNotEmpty).toList();
      final fullName = nameParts.isEmpty ? null : nameParts.join(' ');
      final email = (credential.email ?? '').trim();
      return _IntroSocialCredential(
        idToken: idToken,
        fullName: fullName,
        email: email.isEmpty ? null : email,
        authorizationCode: credential.authorizationCode,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw _IntroSocialCancelled();
      }
      rethrow;
    }
  }

  String _socialAuthFallbackError(_IntroSocialProvider provider) {
    if (provider == _IntroSocialProvider.apple) {
      return context.l10n.authIntroAppleSignFailedPleaseTryAgain;
    }
    return context.l10n.authIntroGoogleSignFailedPleaseTryAgain;
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
    return _buildAuthIntroScaffold(context);
  }

  Widget _buildAuthIntroScaffold(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    final muted = colors.onSurfaceVariant.withValues(alpha: 0.52);

    return Scaffold(
      backgroundColor: authIntroCanvas,
      resizeToAvoidBottomInset: false,
      body: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Stack(
          children: [
            AuthIntroBackground(
              child: SafeArea(
                maintainBottomViewPadding: true,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 700;
                    final logo = _buildLogo();
                    final choices = _buildChoices(muted: muted);
                    if (wide) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Padding(
                            padding: _contentPadding,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 340,
                                  child: Center(child: logo),
                                ),
                                const SizedBox(width: 32),
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: choices,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    final padding = _contentPadding.vertical;
                    return SingleChildScrollView(
                      padding: _contentPadding,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(
                            0.0,
                            constraints.maxHeight - padding,
                          ),
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Below the middle of the space above the text. The
                              // spaces give way first, so nothing needs to scroll.
                              Expanded(
                                child: Column(
                                  children: [
                                    const Spacer(flex: 65),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: logo,
                                    ),
                                    const Spacer(flex: 35),
                                  ],
                                ),
                              ),
                              choices,
                            ],
                          ),
                        ),
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
      ),
    );
  }

  Widget _buildLogo() {
    final duration = MediaQuery.disableAnimationsOf(context) || _logoSlide != 0
        ? Duration.zero
        : const Duration(milliseconds: 420);
    return AnimatedSlide(
      offset: Offset(0, _logoSlide),
      duration: duration,
      curve: Curves.easeOutCubic,
      child: Opacity(
        opacity: _logoHidden ? 0 : 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _logoWidth),
          child: AspectRatio(
            key: _logoKey,
            aspectRatio: _logoAspectRatio,
            child: Image.asset(
              'assets/branding/logo_full_dark.png',
              key: const ValueKey('auth-intro-logo'),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: 'Splyto',
            ),
          ),
        ),
      ),
    );
  }

  /// Kept at the bottom, within reach of the thumb.
  Widget _buildChoices({required Color muted}) {
    return AnimatedOpacity(
      opacity: _choicesHidden ? 0 : 1,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              context.l10n.authIntroCreateAccount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppDesign.darkForeground,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildChoiceSocialButton(
            label: context.l10n.authIntroContinueGoogle,
            icon: SvgPicture.asset(
              'assets/branding/google_g_logo.svg',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            onTap: _isSubmitting
                ? null
                : () => _onSocialPressed(_IntroSocialProvider.google),
          ),
          if (Platform.isIOS) ...[
            const SizedBox(height: 12),
            _buildChoiceSocialButton(
              label: context.l10n.authIntroContinueApple,
              icon: SvgPicture.asset(
                'assets/branding/apple_logo_white.svg',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              onTap: _isSubmitting
                  ? null
                  : () => _onSocialPressed(_IntroSocialProvider.apple),
            ),
          ],
          const SizedBox(height: 18),
          _buildOrRow(),
          const SizedBox(height: 18),
          _buildChoiceEmailButton(),
          const SizedBox(height: 10),
          _buildSignInRow(muted),
        ],
      ),
    );
  }

  Widget _buildSignInRow(Color muted) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.authIntroAlreadyHaveAccount,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: muted, fontSize: 15),
          ),
          TextButton(
            onPressed: () => _openSignIn(),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              context.l10n.authIntroSignIn,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppDesign.darkForeground.withValues(alpha: 0.88),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceEmailButton() {
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
        onPressed: _isSubmitting ? null : _openSignUpWithEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF07211A)),
        label: Text(
          context.l10n.authIntroSignUpWithEmail,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFF07211A),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildOrRow() {
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
            context.l10n.authIntroOr,
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

  Widget _buildChoiceSocialButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: semantic.cardGlassBackground.withValues(alpha: 0.20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: semantic.cardGlassBorder.withValues(alpha: 0.82),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(width: 18),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: semantic.heroAvatarStroke.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w700,
                    ),
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
