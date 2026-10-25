import 'package:flutter/material.dart';

import 'app_design.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme textTheme(Brightness brightness) {
    final foreground = brightness == Brightness.dark
        ? AppDesign.darkForeground
        : AppDesign.lightForeground;
    final muted = brightness == Brightness.dark
        ? AppDesign.darkMuted
        : AppDesign.lightMuted;
    TextStyle style(double size, FontWeight weight, {bool secondary = false}) =>
        TextStyle(
          fontFamily: 'Inter',
          fontSize: size,
          fontWeight: weight,
          letterSpacing: 0,
          height: 1.35,
          color: secondary ? muted : foreground,
        );
    return TextTheme(
      displayLarge: style(36, FontWeight.w700),
      displayMedium: style(36, FontWeight.w700),
      displaySmall: style(36, FontWeight.w700),
      headlineLarge: style(24, FontWeight.w600),
      headlineMedium: style(24, FontWeight.w600),
      headlineSmall: style(24, FontWeight.w600),
      titleLarge: style(18, FontWeight.w600),
      titleMedium: style(17, FontWeight.w600),
      titleSmall: style(14, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400),
      bodyMedium: style(14, FontWeight.w400),
      bodySmall: style(12, FontWeight.w500, secondary: true),
      labelLarge: style(16, FontWeight.w600),
      labelMedium: style(14, FontWeight.w500, secondary: true),
      labelSmall: style(12, FontWeight.w500, secondary: true),
    );
  }
}
