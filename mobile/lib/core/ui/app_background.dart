import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final primaryGlowAlpha = brightness == Brightness.dark ? 0.18 : 0.12;
    final secondaryGlowAlpha = brightness == Brightness.dark ? 0.14 : 0.08;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppDesign.pageGradient(colors, brightness: brightness),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -80,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppDesign.brandStart.withValues(alpha: primaryGlowAlpha),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const SizedBox(width: 220, height: 220),
              ),
            ),
          ),
          Positioned(
            left: -90,
            bottom: -120,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppDesign.brandEnd.withValues(alpha: secondaryGlowAlpha),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const SizedBox(width: 280, height: 280),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
