import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/router/app_router.dart';

class AuthIntroPage extends StatefulWidget {
  const AuthIntroPage({super.key});

  @override
  State<AuthIntroPage> createState() => _AuthIntroPageState();
}

class _AuthIntroPageState extends State<AuthIntroPage> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

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

  void _openSignIn() {
    Navigator.of(context).pushNamed(
      AppRouter.login,
      arguments: const <String, Object?>{'start_register': false},
    );
  }

  void _openGetStarted() {
    Navigator.of(context).pushNamed(AppRouter.authSignInChoice);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides();
    final colors = Theme.of(context).colorScheme;
    final muted = colors.onSurfaceVariant.withValues(alpha: 0.52);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFF0C0C0C)),
        child: Stack(
          children: [
            Positioned(
              top: -180,
              left: -80,
              right: -80,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.7,
                      colors: [Color(0x332EAF6E), Colors.transparent],
                    ),
                  ),
                  child: const SizedBox(height: 420),
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -120,
              right: -120,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.bottomCenter,
                      radius: 0.9,
                      colors: [Color(0x222EAF6E), Colors.transparent],
                    ),
                  ),
                  child: const SizedBox(height: 320),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
                child: Column(
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
                          return _buildSlide(slides[index], muted: muted);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildDots(slides.length),
                    const SizedBox(height: 26),
                    _buildGetStartedButton(),
                    const SizedBox(height: 12),
                    _buildSignInRow(muted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_IntroSlide slide, {required Color muted}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Center(child: SizedBox(width: 318, height: 430, child: _buildHero())),
        const SizedBox(height: 20),
        Container(
          width: 42,
          height: 1.2,
          color: Colors.white.withValues(alpha: 0.18),
        ),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${slide.titleTop}\n',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.9,
                  height: 1.05,
                ),
              ),
              TextSpan(
                text: slide.titleAccent,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF53D79B),
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
    );
  }

  Widget _buildHero() {
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
            background: Colors.white.withValues(alpha: 0.04),
            border: Colors.white.withValues(alpha: 0.10),
            textColor: Colors.white.withValues(alpha: 0.44),
          ),
        ),
        Positioned(
          top: 210,
          left: 2,
          child: _buildPill(
            label: _text(en: 'Split settled', lv: 'Norēķins pabeigts'),
            background: const Color(0x1F2EAF6E),
            border: const Color(0x3D2EAF6E),
            textColor: const Color(0xFF54D69C),
            leadingDot: true,
          ),
        ),
        Positioned(
          top: 258,
          right: 2,
          child: _buildPill(
            label: _text(en: 'Paris · 3 friends', lv: 'Parīze · 3 draugi'),
            background: Colors.white.withValues(alpha: 0.04),
            border: Colors.white.withValues(alpha: 0.10),
            textColor: Colors.white.withValues(alpha: 0.40),
          ),
        ),
        Positioned(
          top: 312,
          left: 0,
          right: 0,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 232,
                  height: 86,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      radius: 0.9,
                      colors: [Color(0x402EAF6E), Colors.transparent],
                    ),
                  ),
                ),
                Image.asset(
                  'assets/branding/logo_full.png',
                  width: 190,
                  fit: BoxFit.contain,
                ),
              ],
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
                color: Color(0xFF4ECD8C),
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

  Widget _buildDots(int total) {
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
                  ? const Color(0xFF2EAF6E)
                  : Colors.white.withValues(alpha: 0.22),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGetStartedButton() {
    const gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xFF9BDFC3), Color(0xFF57B487)],
    );
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          boxShadow: const [
            BoxShadow(
              color: Color(0x4A2EAF6E),
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
            foregroundColor: Colors.white,
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
            onPressed: _openSignIn,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text(
              _text(en: 'Sign in', lv: 'Ienākt'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
    final strokeMain = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x334ECD8C)
      ..strokeWidth = 1;
    final strokeSoft = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0x1F4ECD8C)
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
        ..color = const Color(0xCC2EAF6E),
    );

    _drawPulse(canvas, const Offset(75, 124), const Color(0xFF2EAF6E));
    _drawPulse(canvas, const Offset(238, 170), const Color(0xFFD44FA8));
    canvas.drawCircle(
      center,
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
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
