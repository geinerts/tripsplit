import 'package:flutter/material.dart';

import '../../../../app/theme/app_design.dart';

class AuthBackgroundLayers extends StatelessWidget {
  const AuthBackgroundLayers({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final primaryGlowAlpha = brightness == Brightness.dark ? 0.18 : 0.12;
    final secondaryGlowAlpha = brightness == Brightness.dark ? 0.14 : 0.08;
    final glowPrimary = AppDesign.glowPrimary(brightness);
    final glowSecondary = AppDesign.glowSecondary(brightness);

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppDesign.pageGradient(colors, brightness: brightness),
            ),
          ),
        ),
        Positioned(
          right: -60,
          top: -80,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowPrimary.withValues(alpha: primaryGlowAlpha),
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
                    glowSecondary.withValues(alpha: secondaryGlowAlpha),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const SizedBox(width: 280, height: 280),
            ),
          ),
        ),
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
                  colors: [AppDesign.authGlowTop, Colors.transparent],
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
                  colors: [AppDesign.authGlowBottom, Colors.transparent],
                ),
              ),
              child: const SizedBox(height: 320),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
