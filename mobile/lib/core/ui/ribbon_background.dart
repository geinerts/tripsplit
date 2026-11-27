import 'dart:math' as math;

import 'package:flutter/material.dart';

const quickStartInk = Color(0xFF0B1B3A);
const quickStartCream = Color(0xFFFFF8EC);

const _teal = Color(0xFF2FB8B0);
const _green = Color(0xFF3DBB8C);
const _pink = Color(0xFFE8388F);

/// Main and accent ribbon colours for each slide.
const _slideRibbons = [
  (_teal, _pink),
  (_green, _teal),
  (_teal, _pink),
  (_pink, _teal),
  (_green, _pink),
  (_teal, _green),
];

/// The App Store preview look: a mint-to-cream wash with ribbons behind the phone.
/// Same background on every slide, only the ribbons change colour and shape.
class QuickStartBackground extends StatelessWidget {
  const QuickStartBackground({super.key, required this.page});

  final double page;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment(.6, 1),
        stops: [0, .4, 1],
        colors: [Color(0xFFBFEFEA), Color(0xFFEFF9F3), quickStartCream],
      ),
    ),
    child: RepaintBoundary(
      child: CustomPaint(painter: _RibbonPainter(page), size: Size.infinite),
    ),
  );
}

class _Ribbon {
  const _Ribbon({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
    required this.width,
    required this.drift,
    required this.phase,
    required this.accent,
  });

  // Offsets are fractions of the screen; the ends sit off-screen so that drifting
  // never reveals them.
  final Offset start;
  final Offset control1;
  final Offset control2;
  final Offset end;
  final double width;
  final double drift;
  final double phase;
  final bool accent;
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter(this.page);

  static const _samples = 48;
  static const _ribbons = [
    _Ribbon(
      start: Offset(-.25, .56),
      control1: Offset(.3, .5),
      control2: Offset(.7, .84),
      end: Offset(1.25, .7),
      width: .13,
      drift: .05,
      phase: 2.1,
      accent: false,
    ),
    _Ribbon(
      start: Offset(1.25, .47),
      control1: Offset(.85, .4),
      control2: Offset(.4, .62),
      end: Offset(-.25, .66),
      width: .08,
      drift: .07,
      phase: 4.0,
      accent: true,
    ),
    _Ribbon(
      start: Offset(-.25, .25),
      control1: Offset(.2, .24),
      control2: Offset(.3, .52),
      end: Offset(1.25, .4),
      width: .15,
      drift: .04,
      phase: .4,
      accent: false,
    ),
  ];

  final double page;

  @override
  void paint(Canvas canvas, Size size) {
    final clamped = page.clamp(0.0, _slideRibbons.length - 1.0);
    final from = _slideRibbons[clamped.floor()];
    final to = _slideRibbons[clamped.ceil()];
    final progress = clamped - clamped.floor();
    // Blending in HSV keeps the colours clean halfway between pink and green.
    Color blend(Color a, Color b) => HSVColor.lerp(
      HSVColor.fromColor(a),
      HSVColor.fromColor(b),
      progress,
    )!.toColor();
    final main = blend(from.$1, to.$1);
    final accent = blend(from.$2, to.$2);
    for (final ribbon in _ribbons) {
      _paintRibbon(
        canvas,
        size,
        ribbon,
        ribbon.accent ? accent : main,
        clamped,
      );
    }
  }

  void _paintRibbon(
    Canvas canvas,
    Size size,
    _Ribbon ribbon,
    Color color,
    double page,
  ) {
    Offset scaled(Offset point) =>
        Offset(point.dx * size.width, point.dy * size.height);
    final shift = Offset(
      math.sin(page * 1.3 + ribbon.phase) * ribbon.drift * size.width,
      0,
    );
    final bend = Offset(
      0,
      math.sin(page * .9 + ribbon.phase) * .035 * size.height,
    );
    final p0 = scaled(ribbon.start) + shift;
    final p1 = scaled(ribbon.control1) + shift + bend;
    final p2 = scaled(ribbon.control2) + shift - bend;
    final p3 = scaled(ribbon.end) + shift;
    final maxWidth = ribbon.width * size.width;
    final upper = <Offset>[];
    final lower = <Offset>[];
    for (var i = 0; i <= _samples; i++) {
      final t = i / _samples;
      final u = 1 - t;
      final point =
          p0 * (u * u * u) +
          p1 * (3 * u * u * t) +
          p2 * (3 * u * t * t) +
          p3 * (t * t * t);
      final tangent =
          (p1 - p0) * (3 * u * u) +
          (p2 - p1) * (6 * u * t) +
          (p3 - p2) * (3 * t * t);
      final normal = Offset(-tangent.dy, tangent.dx) / tangent.distance;
      // A narrowing band reads as a ribbon that turns over.
      final twist = math.cos(t * math.pi * 2.2 + ribbon.phase).abs();
      final half = maxWidth * (.28 + .72 * twist) / 2;
      upper.add(point + normal * half);
      lower.add(point - normal * half);
    }
    final path = Path()..addPolygon([...upper, ...lower.reversed], true);
    final highlight = Color.lerp(color, Colors.white, .28)!;
    final shade = Color.lerp(color, Colors.black, .12)!;
    canvas.drawPath(
      path,
      Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          colors: [highlight, color, shade, color, highlight],
          stops: const [0, .3, .5, .7, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) => oldDelegate.page != page;
}
