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

enum AuthIntroStage { intro, choice }

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
    this.initialStage = AuthIntroStage.intro,
  });

  final AuthController controller;
  final AuthIntroStage initialStage;

  @override
  State<AuthIntroPage> createState() => _AuthIntroPageState();
}

class _AuthIntroPageState extends State<AuthIntroPage> {
  final PageController _pageController = PageController();
  late final PageController _panelPageController;
  int _pageIndex = 0;
  AuthIntroStage _stage = AuthIntroStage.intro;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;
    _panelPageController = PageController(
      initialPage: _stage == AuthIntroStage.intro ? 0 : 1,
    );
  }

  List<_IntroSlide> _slides() {
    return [
      _IntroSlide(
        titleTop: context.l10nEn.authIntroSplitSmarter,
        titleAccent: context.l10nEn.authIntroTravelFree,
        subtitle: context
            .l10n
            .authIntroTrackSharedCostsAcrossCurrenciesSettleInstantlyNo,
      ),
      _IntroSlide(
        titleTop: context.l10nEn.authIntroPlanTogether,
        titleAccent: context.l10nEn.authIntroPayClearly,
        subtitle: context
            .l10nEn
            .authIntroCreateTripsSecondsAddFriendsKeepEveryExpense,
      ),
      _IntroSlide(
        titleTop: context.l10nEn.authIntroSettleFast,
        titleAccent: context.l10nEn.authIntroStayFriends,
        subtitle: context
            .l10nEn
            .authIntroFromSharedDinnersFullTripsSplytoKeepsBalances,
      ),
    ];
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

  void _setStage(AuthIntroStage value) {
    if (!mounted || _stage == value) {
      return;
    }
    final nextPage = value == AuthIntroStage.intro ? 0 : 1;
    setState(() {
      _stage = value;
    });
    if (_panelPageController.hasClients) {
      _panelPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_panelPageController.hasClients) {
          return;
        }
        _panelPageController.jumpToPage(nextPage);
      });
    }
  }

  void _openGetStarted() {
    _setStage(AuthIntroStage.choice);
  }

  void _backToIntro() {
    _setStage(AuthIntroStage.intro);
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
        context.l10nEn.authGoogleSignDidNotReturnIdToken;
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
    final iosOnlyMessage = context.l10nEn.authAppleSignAvailableIosDevices;
    final unavailableMessage = context.l10nEn.authAppleSignNotAvailableDevice;
    final missingIdTokenMessage =
        context.l10nEn.authAppleSignDidNotReturnIdentityToken;
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
      return context.l10nEn.authIntroAppleSignFailedPleaseTryAgain;
    }
    return context.l10nEn.authIntroGoogleSignFailedPleaseTryAgain;
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
  void dispose() {
    _pageController.dispose();
    _panelPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAuthIntroScaffold(context);
  }

  Widget _buildAuthIntroScaffold(BuildContext context) {
    final slides = _slides();
    final colors = Theme.of(context).colorScheme;
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    final muted = colors.onSurfaceVariant.withValues(alpha: 0.52);

    return PopScope(
      canPop: _stage == AuthIntroStage.intro,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          return;
        }
        if (_stage == AuthIntroStage.choice) {
          _backToIntro();
        }
      },
      child: Scaffold(
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
                      final inIntro = _stage == AuthIntroStage.intro;
                      // The logo sits low in this area, just above the text. The
                      // sign-up choice needs the room, so the logo moves aside.
                      final logoAreaHeight = math.min(
                        constraints.maxHeight * (inIntro ? .44 : .16),
                        math.max(
                          0.0,
                          constraints.maxHeight -
                              (220 +
                                  MediaQuery.textScalerOf(context).scale(110)),
                        ),
                      );
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1000),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
                            child: Flex(
                              direction: wide ? Axis.horizontal : Axis.vertical,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AnimatedContainer(
                                  key: ValueKey('intro-logo-area-$wide'),
                                  duration:
                                      MediaQuery.disableAnimationsOf(context)
                                      ? Duration.zero
                                      : const Duration(milliseconds: 320),
                                  curve: Curves.easeOutCubic,
                                  width: wide ? 340 : null,
                                  height: wide ? null : logoAreaHeight,
                                  alignment: wide
                                      ? Alignment.center
                                      : Alignment.bottomCenter,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: inIntro || wide ? 300 : 150,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 1200 / 475,
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
                                SizedBox(
                                  width: wide ? 32 : 0,
                                  height: wide ? 0 : 20,
                                ),
                                Expanded(
                                  child: PageView(
                                    controller: _panelPageController,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      SizedBox.expand(
                                        child: _buildIntroBottom(
                                          key: const ValueKey('intro_bottom'),
                                          slides: slides,
                                          muted: muted,
                                        ),
                                      ),
                                      SizedBox.expand(
                                        child: _buildChoiceBottom(
                                          key: const ValueKey('choice_bottom'),
                                          muted: muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
      ),
    );
  }

  Widget _buildIntroBottom({
    required Key key,
    required List<_IntroSlide> slides,
    required Color muted,
  }) {
    return KeyedSubtree(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              onPageChanged: (index) {
                if (!mounted) {
                  return;
                }
                setState(() {
                  _pageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildTextSlide(slides[index], muted: muted);
              },
            ),
          ),
          const SizedBox(height: 10),
          _buildDots(slides.length),
          const SizedBox(height: 18),
          _buildGetStartedButton(),
          const SizedBox(height: 10),
          _buildSignInRow(muted),
        ],
      ),
    );
  }

  Widget _buildChoiceBottom({required Key key, required Color muted}) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    return KeyedSubtree(
      key: key,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 26, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10nEn.authIntroCreateAccount,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppDesign.darkForeground,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.9,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10nEn.authIntroChooseSign,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: muted,
                fontSize: 14,
                height: 1.65,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildChoiceEmailButton(),
            const SizedBox(height: 18),
            _buildOrRow(),
            const SizedBox(height: 18),
            _buildChoiceSocialButton(
              label: context.l10nEn.authIntroContinueGoogle,
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
                label: context.l10nEn.authIntroContinueApple,
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
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: _isSubmitting ? null : _backToIntro,
                style: TextButton.styleFrom(
                  foregroundColor: semantic.heroAvatarStroke.withValues(
                    alpha: 0.9,
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  context.l10nEn.authIntroBack,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSlide(_IntroSlide slide, {required Color muted}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompactHeight =
            constraints.maxHeight.isFinite && constraints.maxHeight < 132;
        final titleSize = isCompactHeight ? 26.0 : 30.0;
        final subtitleSize = isCompactHeight ? 13.0 : 15.5;
        final subtitleHeight = isCompactHeight ? 1.35 : 1.4;
        final gap = isCompactHeight ? 6.0 : 10.0;
        final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppDesign.darkForeground,
          fontSize: titleSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.9,
          height: 1.08,
        );

        return Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${slide.titleTop}\n${slide.titleAccent}',
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                SizedBox(height: gap),
                Text(
                  slide.subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppDesign.darkForeground.withValues(alpha: .72),
                    fontSize: subtitleSize,
                    height: subtitleHeight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDots(int total) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(total, (index) {
        final isActive = index == _pageIndex;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: isActive ? 22 : 6,
            height: 4,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: isActive
                  ? AppDesign.authAccentStrong
                  : semantic.cardGlassBorder,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppDesign.authButtonGradient,
          boxShadow: const [
            BoxShadow(
              color: AppDesign.authButtonShadow,
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _openGetStarted,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: const Color(0xFF07211A),
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          child: Text(context.l10nEn.authIntroGetStarted),
        ),
      ),
    );
  }

  Widget _buildSignInRow(Color muted) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10nEn.authIntroAlreadyHaveAccount,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: muted, fontSize: 15),
          ),
          TextButton(
            onPressed: () => _openSignIn(),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              context.l10nEn.authIntroSignIn,
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
          context.l10nEn.authIntroSignUpWithEmail,
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
            context.l10nEn.authIntroOr,
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

class _IntroSlide {
  const _IntroSlide({
    required this.titleTop,
    required this.titleAccent,
    required this.subtitle,
  });

  final String titleTop;
  final String titleAccent;
  final String subtitle;
}
