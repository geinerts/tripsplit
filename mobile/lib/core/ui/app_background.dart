import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.force = false});

  final Widget child;
  final bool force;

  @override
  Widget build(BuildContext context) {
    // Prevent stacking multiple identical full-screen backgrounds when
    // pages are wrapped locally and globally.
    if (!force && _AppBackgroundScope.isActive(context)) {
      return child;
    }
    final colors = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final primaryGlowAlpha = brightness == Brightness.dark ? 0.18 : 0.0;
    final secondaryGlowAlpha = brightness == Brightness.dark ? 0.14 : 0.0;
    final glowPrimary = AppDesign.glowPrimary(brightness);
    final glowSecondary = AppDesign.glowSecondary(brightness);
    return _AppBackgroundScope(
      child: DecoratedBox(
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
            child,
          ],
        ),
      ),
    );
  }
}

class _AppBackgroundScope extends InheritedWidget {
  const _AppBackgroundScope({required super.child});

  static bool isActive(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AppBackgroundScope>() !=
        null;
  }

  @override
  bool updateShouldNotify(covariant _AppBackgroundScope oldWidget) => false;
}
