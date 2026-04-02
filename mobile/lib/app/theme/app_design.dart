import 'package:flutter/material.dart';

class AppDesign {
  const AppDesign._();

  // Brand
  static const Color brandStart = Color(0xFF4F8BFF);
  static const Color brandEnd = Color(0xFF8B3EFF);
  static const Color logoBackgroundStart = Color(0xFF141E30);
  static const Color logoBackgroundEnd = Color(0xFF243B55);

  // Shared light palette (base for Trips/Friends/Profile/Analytics).
  static const Color lightCanvas = Color(0xFFF7F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF2D7A5E);
  static const Color lightAccent = Color(0xFFD4915C);
  static const Color lightForeground = Color(0xFF2C2418);
  static const Color lightMuted = Color(0xFF8A8277);
  static const Color lightSuccess = Color(0xFF3D8B5F);
  static const Color lightDestructive = Color(0xFFC45C4A);
  static const Color lightStroke = Color(0xFFE9E4DD);

  // Shared dark palette.
  static const Color darkCanvas = Color(0xFF07111F);
  static const Color darkCanvasSoft = Color(0xFF0B1628);
  static const Color darkSurface = Color(0xFF101C30);
  static const Color darkSurfaceRaised = Color(0xFF15243A);
  static const Color darkOutline = Color(0xFF2B4365);
  static const Color darkPrimary = Color(0xFF79A7FF);
  static const Color darkAccent = Color(0xFFB28DFF);
  static const Color darkForeground = Color(0xFFF4F7FD);
  static const Color darkMuted = Color(0xFFB7C6DF);

  // Radius scale.
  static const double radiusXs = 12;
  static const double radiusSm = 16;
  static const double radiusMd = 20;
  static const double radiusLg = 24;

  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(radiusSm),
  );

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
        lightCanvas,
        colors.surfaceContainerLowest.withValues(alpha: 0.92),
      ],
    );
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageSurface(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return isDark(context) ? colors.surface : lightCanvas;
  }

  static Color cardSurface(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return isDark(context) ? colors.surface : lightSurface;
  }

  static Color cardStroke(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return isDark(context)
        ? colors.outlineVariant.withValues(alpha: 0.28)
        : lightStroke;
  }

  static Color titleColor(BuildContext context) {
    return isDark(context) ? darkForeground : lightForeground;
  }

  static Color mutedColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return isDark(context) ? colors.onSurfaceVariant : lightMuted;
  }

  static Color successColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return isDark(context) ? colors.primary : lightSuccess;
  }

  static Color destructiveColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return isDark(context) ? colors.error : lightDestructive;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    if (isDark(context)) {
      return const <BoxShadow>[];
    }
    return const <BoxShadow>[
      BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6)),
    ];
  }
}
