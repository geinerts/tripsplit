import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(gradient: AppDesign.pageGradient(colors)),
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
                      AppDesign.brandStart.withValues(alpha: 0.12),
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
                      AppDesign.brandEnd.withValues(alpha: 0.08),
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
