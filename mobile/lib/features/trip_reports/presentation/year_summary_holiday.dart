part of 'year_summary_page.dart';

/// Whether the card wears its New Year look: December and January.
bool yearSummaryHolidaySeason(DateTime now) =>
    now.month == DateTime.december || now.month == DateTime.january;

/// The year as tilted, extruded digits with snow on top, drawn per digit so
/// it works for any year.
class _HolidayYear extends StatelessWidget {
  const _HolidayYear({required this.year});

  final int year;

  static const _fontSize = 80.0;
  static const _angles = [-7.0, 5.0, -4.0, 8.0];
  static const _lifts = [3.0, -4.0, 1.0, -3.0];
  static const _depth = 7;

  @override
  Widget build(BuildContext context) {
    final digits = '$year'.split('');
    const style = TextStyle(
      fontFamily: 'Inter',
      fontSize: _fontSize,
      height: 1,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
    );
    return Semantics(
      label: '$year',
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.only(top: 14, bottom: 6),
            child: Row(
              key: const ValueKey('year-summary-card-year'),
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < digits.length; i++)
                  Transform.translate(
                    offset: Offset(0, _lifts[i % _lifts.length]),
                    child: Transform.rotate(
                      angle: _angles[i % _angles.length] * math.pi / 180,
                      child: _digit(digits[i], style),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _digit(String digit, TextStyle style) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // The extruded side, darkest at the back.
        for (var d = _depth; d >= 1; d--)
          Transform.translate(
            offset: Offset(d * .9, d * 1.3),
            child: Text(
              digit,
              style: style.copyWith(
                color: Color.lerp(
                  const Color(0xFF0B3325),
                  const Color(0xFF2E9C78),
                  1 - d / _depth,
                ),
              ),
            ),
          ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF2FFF8), _yearSummaryMint, Color(0xFF52CFAE)],
            stops: [0, .45, 1],
          ).createShader(bounds),
          child: Padding(
            // Keeps the slanted edge inside the gradient.
            padding: const EdgeInsets.only(right: 8),
            child: Text(digit, style: style.copyWith(color: Colors.white)),
          ),
        ),
        Positioned(
          // Italic digits lean right, so the cap sits a little to the right.
          top: _fontSize * .07,
          left: _fontSize * .1,
          right: _fontSize * .02,
          child: SvgPicture.asset(
            'assets/branding/year_snow_cap.svg',
            height: _fontSize * .24,
            fit: BoxFit.fill,
          ),
        ),
      ],
    ),
  );
}

/// Soft snowflakes in fixed places, so every shared picture looks the same.
class _SnowfallPainter extends CustomPainter {
  const _SnowfallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(2026);
    final paint = Paint()..color = Colors.white;
    for (var i = 0; i < 46; i++) {
      final radius = .8 + random.nextDouble() * 2.2;
      paint.color = Colors.white.withValues(
        alpha: .25 + random.nextDouble() * .5,
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SnowfallPainter oldDelegate) => false;
}

/// Rolling snow along the bottom edge of the card.
class _SnowDriftPainter extends CustomPainter {
  const _SnowDriftPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final back = Path()
      ..moveTo(0, h * .35)
      ..cubicTo(w * .15, -h * .05, w * .3, h * .45, w * .48, h * .2)
      ..cubicTo(w * .66, -h * .08, w * .84, h * .4, w, h * .05)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(back, Paint()..color = const Color(0xFFD3E5EE));
    final front = Path()
      ..moveTo(0, h * .62)
      ..cubicTo(w * .2, h * .2, w * .42, h * .78, w * .64, h * .45)
      ..cubicTo(w * .8, h * .2, w * .92, h * .55, w, h * .4)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(front, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_SnowDriftPainter oldDelegate) => false;
}
