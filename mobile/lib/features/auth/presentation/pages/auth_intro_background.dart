import 'dart:math' as math;

import 'package:flutter/material.dart';

const authIntroCanvas = Color(0xFF141E30);
const _teal = Color(0xFF1FA9A2);
const _pink = Color(0xFFE8388F);

/// The dark welcome background: the home page and Quick Start ribbons in the
/// corners, leaving the middle free for the logo and text.
class AuthIntroBackground extends StatelessWidget {
  const AuthIntroBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ColoredBox(
    // The same colour as the native launch screen, so opening the app doesn't flash.
    color: authIntroCanvas,
    child: Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(child: CustomPaint(painter: _RibbonPainter())),
        // Keeps the buttons readable over the lower ribbons.
        const IgnorePointer(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: .28,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, .45],
                    colors: [Color(0x00141E30), authIntroCanvas],
                  ),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    ),
  );
}

class _Ribbon {
  const _Ribbon(
    this.color,
    this.start,
    this.control1,
    this.control2,
    this.end,
    this.width,
    this.phase,
  );

  final Color color;
  final Offset start, control1, control2, end;
  final double width, phase;
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();

  static const _samples = 60;
  // Fractions of the screen. The ends sit off-screen.
  static const _ribbons = [
    _Ribbon(
      _teal,
      Offset(-.25, .2),
      Offset(.15, .26),
      Offset(.45, .02),
      Offset(.95, -.1),
      .2,
      .5,
    ),
    _Ribbon(
      _pink,
      Offset(.5, -.1),
      Offset(.62, .1),
      Offset(.86, .2),
      Offset(1.25, .17),
      .075,
      2.4,
    ),
    _Ribbon(
      _teal,
      Offset(.15, -.08),
      Offset(.1, .1),
      Offset(-.05, .2),
      Offset(-.2, .3),
      .09,
      1,
    ),
    _Ribbon(
      _teal,
      Offset(1.25, .78),
      Offset(.85, .72),
      Offset(.55, .96),
      Offset(.05, 1.08),
      .17,
      .5,
    ),
    _Ribbon(
      _pink,
      Offset(.5, 1.08),
      Offset(.38, .88),
      Offset(.14, .78),
      Offset(-.25, .8),
      .065,
      2.4,
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final ribbon in _ribbons) {
      _paintRibbon(canvas, size, ribbon);
    }
  }

  void _paintRibbon(Canvas canvas, Size size, _Ribbon ribbon) {
    Offset scaled(Offset point) =>
        Offset(point.dx * size.width, point.dy * size.height);
    final p0 = scaled(ribbon.start), p1 = scaled(ribbon.control1);
    final p2 = scaled(ribbon.control2), p3 = scaled(ribbon.end);
    // Wide screens get proportionally slimmer ribbons.
    final maxWidth = ribbon.width * math.min(size.width, size.height * .6);
    final upper = <Offset>[], lower = <Offset>[];
    for (var i = 0; i <= _samples; i++) {
      final t = i / _samples, u = 1 - t;
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
      final turn = math.cos(t * math.pi * 1.5 + ribbon.phase);
      final half = maxWidth * (.16 + .84 * math.sqrt(turn * turn + .012)) / 2;
      upper.add(point + normal * half);
      lower.add(point - normal * half);
    }
    final highlight = Color.lerp(ribbon.color, Colors.white, .28)!;
    final shade = Color.lerp(ribbon.color, Colors.black, .2)!;
    canvas.drawPath(
      Path()..addPolygon([...upper, ...lower.reversed], true),
      Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          colors: [highlight, ribbon.color, shade, ribbon.color, highlight],
          stops: const [0, .3, .5, .7, 1],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_RibbonPainter oldDelegate) => false;
}
