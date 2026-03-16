import 'package:flutter/material.dart';

class AppDesign {
  const AppDesign._();

  static const Color brandStart = Color(0xFF4F8BFF);
  static const Color brandEnd = Color(0xFF8B3EFF);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandStart, brandEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient pageGradient(ColorScheme colors) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        colors.surfaceContainerLow.withValues(alpha: 0.95),
        colors.surfaceContainerLowest.withValues(alpha: 0.85),
      ],
    );
  }
}
