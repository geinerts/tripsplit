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
import '../../domain/entities/auth_user.dart';
import '../controllers/auth_controller.dart';
import 'auth_background_layers.dart';
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
  });

  final String idToken;
  final String? fullName;
  final String? email;
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

  String _text({required String en, required String lv}) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    return locale == 'lv' ? lv : en;
  }

  List<_IntroSlide> _slides() {
    return [
      _IntroSlide(
        titleTop: _text(en: 'Split smarter.', lv: 'Dali gudrāk.'),
        titleAccent: _text(en: 'Travel free.', lv: 'Ceļo brīvāk.'),
        subtitle: _text(
          en: 'Track shared costs across currencies and settle up instantly - no awkward IOUs.',
          lv: 'Seko kopīgajiem izdevumiem dažādās valūtās un norēķinies uzreiz - bez neērtiem parādiem.',
        ),
      ),
      _IntroSlide(
        titleTop: _text(en: 'Plan together.', lv: 'Plāno kopā.'),
        titleAccent: _text(en: 'Pay clearly.', lv: 'Maksā skaidri.'),
        subtitle: _text(
          en: 'Create trips in seconds, add friends, and keep every expense transparent for everyone.',
          lv: 'Izveido ceļojumu sekundēs, pievieno draugus un padari katru izdevumu caurspīdīgu visiem.',
        ),
      ),
      _IntroSlide(
        titleTop: _text(en: 'Settle fast.', lv: 'Norēķinies ātri.'),
        titleAccent: _text(en: 'Stay friends.', lv: 'Paliec draugos.'),
        subtitle: _text(
          en: 'From shared dinners to full trips, Splyto keeps balances fair and stress-free.',
          lv: 'No kopīgām vakariņām līdz pilniem ceļojumiem - Splyto palīdz saglabāt taisnīgus un vienkāršus norēķinus.',
        ),
      ),
    ];
  }

  Future<void> _openSignIn() async {
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
          height: viewport.height * 0.56,
          child: LoginPage(
            controller: widget.controller,
            startInRegister: false,
            compactSheet: true,
            showSheetClose: false,
          ),
        );
      },
    );
  }

  Future<void> _openSignUpWithEmail() async {
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
          height: viewport.height * 0.82,
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
        throw _IntroSocialCancelled();
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
      return _IntroSocialCredential(
        idToken: idToken,
        fullName: fullName.isEmpty ? null : fullName,
        email: email.isEmpty ? null : email,
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
      return _IntroSocialCredential(
        idToken: idToken,
        fullName: fullName,
        email: email.isEmpty ? null : email,
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
      return _text(
        en: 'Apple sign-in failed. Please try again.',
        lv: 'Apple pieslēgšanās neizdevās. Mēģini vēlreiz.',
      );
    }
    return _text(
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
  void dispose() {
    _pageController.dispose();
    _panelPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: AppDesign.authCanvas,
        body: Stack(
          children: [
            AuthBackgroundLayers(
              child: SafeArea(
                child: Stack(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final heroWidth = constraints.maxWidth.clamp(
                          242.0,
                          315.0,
                        );
                        final heroViewportHeight =
                            (constraints.maxHeight * 0.38).clamp(232.0, 300.0);

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 32,
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Transform.translate(
                                    offset: const Offset(0, -14),
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
                                            child: _buildHero(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Container(
                                width: 42,
                                height: 1.2,
                                color: semantic.cardGlassBorder,
                              ),
                              const SizedBox(height: 4),
                              Flexible(
                                flex: 48,
                                child: PageView(
                                  controller: _panelPageController,
                                  physics: const NeverScrollableScrollPhysics(),
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
                        );
                      },
                    ),
                  ],
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

  Widget _buildIntroBottom({
    required Key key,
    required List<_IntroSlide> slides,
    required Color muted,
  }) {
    return KeyedSubtree(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              _text(en: 'Create your account.', lv: 'Izveido savu kontu.'),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
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
              _text(
                en: 'Choose how you want to sign up.',
                lv: 'Izvēlies, kā vēlies reģistrēties.',
              ),
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
              label: _text(
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
                  : () => _onSocialPressed(_IntroSocialProvider.google),
            ),
            if (Platform.isIOS) ...[
              const SizedBox(height: 12),
              _buildChoiceSocialButton(
                label: _text(
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
                  _text(en: 'Back', lv: 'Atpakaļ'),
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${slide.titleTop}\n',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppDesign.darkForeground,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.9,
                    height: 1.05,
                  ),
                ),
                TextSpan(
                  text: slide.titleAccent,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppDesign.authAccent,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.9,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: muted,
              fontSize: 14,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
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
              painter: _IntroGlobePainter(),
            ),
          ),
        ),
        Positioned(
          top: 34,
          right: 0,
          child: _buildPill(
            label: 'EUR · USD · GBP · JPY',
            background: semantic.cardGlassBackground.withValues(alpha: 0.22),
            border: semantic.cardGlassBorder.withValues(alpha: 0.88),
            textColor: AppDesign.darkForeground.withValues(alpha: 0.44),
          ),
        ),
        Positioned(
          top: 210,
          left: 2,
          child: _buildPill(
            label: _text(en: 'Split settled', lv: 'Norēķins pabeigts'),
            background: semantic.statusActiveBackground,
            border: semantic.statusActiveBorder,
            textColor: semantic.statusActiveForeground,
            leadingDot: true,
          ),
        ),
        Positioned(
          top: 258,
          right: 2,
          child: _buildPill(
            label: _text(en: 'Paris · 3 friends', lv: 'Parīze · 3 draugi'),
            background: semantic.cardGlassBackground.withValues(alpha: 0.22),
            border: semantic.cardGlassBorder.withValues(alpha: 0.88),
            textColor: AppDesign.darkForeground.withValues(alpha: 0.40),
          ),
        ),
        Positioned(
          top: 332,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.scale(
              scaleX: 1.30,
              scaleY: 1.25,
              child: Image.asset(
                'assets/branding/logo_full_dark.png',
                width: 220,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPill({
    required String label,
    required Color background,
    required Color border,
    required Color textColor,
    bool leadingDot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
              width: 9,
              height: 9,
              margin: const EdgeInsets.only(right: 10),
              decoration: const BoxDecoration(
                color: AppDesign.authAccentSoft,
                shape: BoxShape.circle,
              ),
            ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textColor,
              fontSize: 14.1,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(int total) {
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        AppSemanticColors.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
            foregroundColor: AppDesign.darkForeground,
            minimumSize: const Size.fromHeight(58),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          child: Text(_text(en: 'Get started', lv: 'Sākt')),
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
            _text(en: 'Already have an account? ', lv: 'Jau ir konts? '),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: muted, fontSize: 15),
          ),
          TextButton(
            onPressed: () => _openSignIn(),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              _text(en: 'Sign in', lv: 'Ienākt'),
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
        icon: const Icon(
          Icons.mail_outline_rounded,
          color: AppDesign.darkForeground,
        ),
        label: Text(
          _text(en: 'Sign up with email', lv: 'Reģistrēties ar e-pastu'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppDesign.darkForeground,
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
            _text(en: 'OR', lv: 'VAI'),
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
          height: 58,
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

class _IntroGlobePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const scale = 1.10;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale, scale);
    canvas.translate(-center.dx, -center.dy);

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
    canvas.restore();
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
