import 'package:flutter/material.dart';

class AppDesign {
  const AppDesign._();

  static const Color brandStart = Color(0xFF4F8BFF);
  static const Color brandEnd = Color(0xFF8B3EFF);
  static const Color logoBackgroundStart = Color(0xFF141E30);
  static const Color logoBackgroundEnd = Color(0xFF243B55);
  static const Color darkCanvas = Color(0xFF07111F);
  static const Color darkCanvasSoft = Color(0xFF0B1628);
  static const Color darkSurface = Color(0xFF101C30);
  static const Color darkSurfaceRaised = Color(0xFF15243A);
  static const Color darkOutline = Color(0xFF2B4365);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandStart, brandEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoBackgroundGradient = LinearGradient(
    colors: [logoBackgroundStart, logoBackgroundEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient pageGradient(
    ColorScheme colors, {
    required Brightness brightness,
  }) {
    if (brightness == Brightness.dark) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [darkCanvas, darkCanvasSoft, darkSurface],
      );
    }
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
