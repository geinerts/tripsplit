import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

class AppSkeletonBlock extends StatelessWidget {
  const AppSkeletonBlock({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 12,
    this.margin,
  });

  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark
        ? colors.surfaceContainerHigh.withValues(alpha: 0.64)
        : AppDesign.lightSurfaceMutedAlt;
    final highlight = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: 0.90)
        : Colors.white.withValues(alpha: 0.86);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isDark
              ? colors.outlineVariant.withValues(alpha: 0.22)
              : AppDesign.lightStroke,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [base, highlight, base],
          stops: const <double>[0.06, 0.5, 0.94],
        ),
      ),
    );
  }
}
