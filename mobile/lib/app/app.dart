import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

import 'app_dependencies.dart';
import 'locale/app_locale_scope.dart';
import 'router/app_router.dart';
import 'theme/app_design.dart';
import 'theme/app_semantic_colors.dart';
import 'theme/theme_mode_scope.dart';

class TripSplitApp extends StatefulWidget {
  const TripSplitApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<TripSplitApp> createState() => _TripSplitAppState();
}

class _TripSplitAppState extends State<TripSplitApp> {
  SystemUiOverlayStyle? _lastAppliedOverlayStyle;

  @override
  void initState() {
    super.initState();
    unawaited(widget.dependencies.themeModeController.load());
    unawaited(widget.dependencies.localeController.load());
    widget.dependencies.inviteDeepLinkController.start();
  }

  @override
  void dispose() {
    unawaited(widget.dependencies.inviteDeepLinkController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = AppRouter(widget.dependencies);
    final themeController = widget.dependencies.themeModeController;
    final localeController = widget.dependencies.localeController;

    return AppLocaleScope(
      controller: localeController,
      child: ThemeModeScope(
        controller: themeController,
        child: AnimatedBuilder(
          animation: Listenable.merge([themeController, localeController]),
          builder: (context, _) {
            return MaterialApp(
              title: 'Splyto',
              debugShowCheckedModeBanner: false,
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
              themeMode: themeController.themeMode,
              locale: localeController.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              builder: (context, child) {
                final brightness = Theme.of(context).brightness;
                final style = _overlayStyleFor(brightness);
                _applyOverlayStyle(style);
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: style,
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: _AppLaunchGate(dependencies: widget.dependencies),
              routes: router.routes,
            );
          },
        ),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppDesign.lightPrimary,
      brightness: Brightness.light,
    );
    final colorScheme = baseScheme.copyWith(
      primary: AppDesign.lightPrimary,
      secondary: AppDesign.lightAccent,
      tertiary: const Color(0xFF63B88A),
      surface: AppDesign.lightSurface,
      surfaceContainerLowest: AppDesign.lightCanvas,
      surfaceContainerLow: const Color(0xFFF4F1EA),
      surfaceContainer: const Color(0xFFF0EDE6),
      surfaceContainerHigh: const Color(0xFFECE7DF),
      surfaceContainerHighest: const Color(0xFFE8E2D8),
      onSurface: AppDesign.lightForeground,
      onSurfaceVariant: AppDesign.lightMuted,
      outline: const Color(0xFFAFA79A),
      outlineVariant: AppDesign.lightStroke,
      error: AppDesign.lightDestructive,
      onError: Colors.white,
      primaryContainer: const Color(0xFFDCEFE6),
      onPrimaryContainer: AppDesign.lightPrimary,
      secondaryContainer: const Color(0xFFF3E6DA),
      onSecondaryContainer: const Color(0xFF4E2D13),
    );
    final textTheme = _buildTextTheme(
      ThemeData(brightness: Brightness.light, useMaterial3: true).textTheme,
      brightness: Brightness.light,
    );
    const fieldRadius = AppDesign.radiusSm;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(fieldRadius),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[AppSemanticColors.light],
      scaffoldBackgroundColor: AppDesign.lightCanvas,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: _overlayStyleFor(Brightness.light),
      ),
      cardTheme: CardThemeData(
        color: AppDesign.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusLg),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.60),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder.copyWith(
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: fieldBorder.copyWith(
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
            color: colorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.6,
        ),
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        checkmarkColor: colorScheme.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHighest,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
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
    final textTheme = _buildTextTheme(
      ThemeData(brightness: Brightness.dark, useMaterial3: true).textTheme,
      brightness: Brightness.dark,
    );
    const fieldRadius = AppDesign.radiusSm;
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(fieldRadius),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: textTheme,
      extensions: const <ThemeExtension<dynamic>>[AppSemanticColors.dark],
      scaffoldBackgroundColor: AppDesign.darkCanvas,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: _overlayStyleFor(Brightness.dark),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.07),
        selectedColor: colorScheme.primaryContainer.withValues(alpha: 0.55),
        disabledColor: Colors.white.withValues(alpha: 0.04),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.52),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        secondaryLabelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
        checkmarkColor: colorScheme.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorScheme.surfaceContainerHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppDesign.darkSurfaceRaised.withValues(alpha: 0.92),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.42),
      ),
    );
  }

  TextTheme _buildTextTheme(TextTheme base, {required Brightness brightness}) {
    final titleColor = brightness == Brightness.dark
        ? AppDesign.darkForeground
        : AppDesign.lightForeground;
    final mutedColor = brightness == Brightness.dark
        ? AppDesign.darkMuted
        : AppDesign.lightMuted;
    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        color: titleColor,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.35,
        color: titleColor,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: titleColor,
      ),
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: titleColor,
      ),
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: titleColor,
      ),
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: titleColor,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: titleColor,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: titleColor,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: titleColor,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: mutedColor,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: mutedColor,
      ),
    );
  }

  SystemUiOverlayStyle _overlayStyleFor(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      );
    }
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    );
  }

  void _applyOverlayStyle(SystemUiOverlayStyle style) {
    if (_lastAppliedOverlayStyle == style) {
      return;
    }
    _lastAppliedOverlayStyle = style;
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

class _AppLaunchGate extends StatefulWidget {
  const _AppLaunchGate({required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<_AppLaunchGate> createState() => _AppLaunchGateState();
}

class _AppLaunchGateState extends State<_AppLaunchGate> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveAndNavigate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SizedBox.expand(),
    );
  }

  Future<void> _resolveAndNavigate() async {
    String nextRoute = AppRouter.authIntro;
    try {
      final hasSession = await widget.dependencies.authController
          .hasRecoverableSession();
      if (hasSession) {
        var user = widget.dependencies.authController.currentUser;
        if (user == null) {
          try {
            user = await widget.dependencies.authController
                .loadCurrentUser()
                .timeout(const Duration(seconds: 4));
          } catch (_) {
            user = await widget.dependencies.authController
                .readCachedCurrentUser();
          }
        }
        if (user == null) {
          nextRoute = AppRouter.authIntro;
        } else {
          nextRoute = user.needsCredentials
              ? AppRouter.credentials
              : AppRouter.trips;
        }
      }
    } catch (_) {
      final fallback = await widget.dependencies.authController
          .readCachedCurrentUser();
      if (fallback != null) {
        nextRoute = fallback.needsCredentials
            ? AppRouter.credentials
            : AppRouter.trips;
      } else {
        nextRoute = AppRouter.authIntro;
      }
    }

    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (route) => false);
  }
}
