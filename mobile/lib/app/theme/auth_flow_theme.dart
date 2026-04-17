import 'package:flutter/material.dart';

import 'app_design.dart';
import 'app_overlay_style.dart';
import 'app_semantic_colors.dart';

/// Route-level theme wrapper for pre-auth flow.
///
/// Keeps intro/choice/login screens consistently dark regardless of
/// global app theme mode.
class AuthFlowTheme extends StatelessWidget {
  const AuthFlowTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildAuthFlowThemeData(Theme.of(context)),
      child: AppFixedLightSystemOverlay(child: child),
    );
  }
}

ThemeData buildAuthFlowThemeData(ThemeData base) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppDesign.darkPrimary,
    brightness: Brightness.dark,
  );
  final colorScheme = baseScheme.copyWith(
    primary: AppDesign.darkPrimary,
    secondary: AppDesign.darkAccent,
    tertiary: AppDesign.darkPrimaryStrong,
    surface: AppDesign.darkSurface,
    surfaceContainerLowest: AppDesign.darkCanvas,
    surfaceContainerLow: AppDesign.darkCanvasSoft,
    surfaceContainer: AppDesign.darkSurface,
    surfaceContainerHigh: AppDesign.darkSurfaceRaised,
    surfaceContainerHighest: AppDesign.darkSurfaceHighest,
    outline: AppDesign.darkOutline,
    outlineVariant: AppDesign.darkOutlineSoft,
    onSurface: AppDesign.darkForeground,
    onSurfaceVariant: AppDesign.darkMuted,
    primaryContainer: AppDesign.darkPrimaryContainer,
    onPrimaryContainer: AppDesign.darkForeground,
  );

  final textTheme = base.textTheme.apply(
    bodyColor: AppDesign.darkForeground,
    displayColor: AppDesign.darkForeground,
    decorationColor: AppDesign.darkForeground,
  );
  const fieldRadius = AppDesign.radiusSm;
  final fieldBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(fieldRadius),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return base.copyWith(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: AppDesign.authCanvas,
    canvasColor: AppDesign.authCanvasSoft,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: AppDesign.darkSurfaceRaised,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.52),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: fieldBorder,
      enabledBorder: fieldBorder.copyWith(
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      focusedBorder: fieldBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    extensions: const <ThemeExtension<dynamic>>[AppSemanticColors.dark],
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.52),
    ),
  );
}
