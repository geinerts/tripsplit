import 'package:flutter/material.dart';

import 'app_design.dart';
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
    return Theme(data: buildAuthFlowThemeData(Theme.of(context)), child: child);
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

  return base.copyWith(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: AppDesign.authCanvas,
    canvasColor: AppDesign.authCanvasSoft,
    extensions: const <ThemeExtension<dynamic>>[AppSemanticColors.dark],
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.52),
    ),
  );
}
