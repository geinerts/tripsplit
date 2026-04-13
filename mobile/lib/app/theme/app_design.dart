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
  static const Color lightPrimaryDeep = Color(0xFF215A45);
  static const Color lightAccent = Color(0xFFD4915C);
  static const Color lightForeground = Color(0xFF2C2418);
  static const Color lightMuted = Color(0xFF8A8277);
  static const Color lightSuccess = Color(0xFF3D8B5F);
  static const Color lightDestructive = Color(0xFFC45C4A);
  static const Color lightStroke = Color(0xFFE9E4DD);
  static const Color lightSurfaceTab = Color(0xFFF0ECE3);
  static const Color lightSurfaceMuted = Color(0xFFF2EFE8);
  static const Color lightSurfaceMutedAlt = Color(0xFFEDE8DF);
  static const Color lightSurfaceTrack = Color(0xFFE8E2D9);
  static const Color lightSurfaceTrackSoft = Color(0xFFE7E2D9);
  static const Color lightSurfaceSuccessTint = Color(0xFFE6EDE4);

  // Shared dark palette.
  static const Color darkCanvas = Color(0xFF040607);
  static const Color darkCanvasSoft = Color(0xFF07110D);
  static const Color darkSurface = Color(0xFF0C1611);
  static const Color darkSurfaceRaised = Color(0xFF13211A);
  static const Color darkSurfaceHighest = Color(0xFF182C22);
  static const Color darkOutline = Color(0xFF294339);
  static const Color darkOutlineSoft = Color(0xFF22382F);
  static const Color darkPrimary = Color(0xFF57B487);
  static const Color darkPrimaryStrong = Color(0xFF2EAF6E);
  static const Color darkAccent = Color(0xFF53D79B);
  static const Color darkForeground = Color(0xFFF3F8F5);
  static const Color darkMuted = Color(0xFF98AB9F);
  static const Color darkPrimaryContainer = Color(0xFF1B3A2E);

  // Auth/intro visual constants.
  static const Color authCanvas = Color(0xFF040607);
  static const Color authCanvasSoft = Color(0xFF07110D);
  static const Color authGlowTop = Color(0x2200C26D);
  static const Color authGlowBottom = Color(0x3300A95D);
  static const Color authAccent = Color(0xFF53D79B);
  static const Color authAccentStrong = Color(0xFF2EAF6E);
  static const Color authAccentSoft = Color(0xFF4ECD8C);
  static const Color authAccentMagenta = Color(0xFFD44FA8);
  static const Color authWireMain = Color(0x334ECD8C);
  static const Color authWireSoft = Color(0x1F4ECD8C);
  static const Color authDashedPath = Color(0xCC2EAF6E);
  static const Color authButtonShadow = Color(0x4A2EAF6E);

  static const LinearGradient authButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF9BDFC3), Color(0xFF57B487)],
  );

  static const List<Color> memberPalette = <Color>[
    Color(0xFF6BC48E),
    Color(0xFFF48E57),
    Color(0xFFBE6EAF),
    Color(0xFF0E8E96),
    Color(0xFF4E96E8),
    Color(0xFF77A65A),
  ];

  static const Map<String, Color> analyticsCategoryPalette = <String, Color>{
    'accommodation': Color(0xFF4FD180),
    'food': Color(0xFFF7943D),
    'transport': Color(0xFF5A94E5),
    'activities': Color(0xFFE372B3),
    'shopping': Color(0xFF0E8E96),
    'groceries': Color(0xFF7CC06A),
    'nightlife': Color(0xFFBE6EAF),
    'other': Color(0xFF8A8277),
  };

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

  static const LinearGradient darkActionGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0F2219), Color(0xFF1F3A2D)],
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

  static LinearGradient actionGradient(BuildContext context) {
    return isDark(context) ? darkActionGradient : logoBackgroundGradient;
  }

  static Color glowPrimary(Brightness brightness) {
    return brightness == Brightness.dark ? darkPrimaryStrong : brandStart;
  }

  static Color glowSecondary(Brightness brightness) {
    return brightness == Brightness.dark ? darkAccent : brandEnd;
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

  static List<BoxShadow> softShadow(BuildContext context) {
    if (isDark(context)) {
      return const <BoxShadow>[];
    }
    return const <BoxShadow>[
      BoxShadow(color: Color(0x12000000), blurRadius: 12, offset: Offset(0, 4)),
    ];
  }

  static List<BoxShadow> panelShadow(BuildContext context) {
    if (isDark(context)) {
      return const <BoxShadow>[];
    }
    return const <BoxShadow>[
      BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 6)),
    ];
  }

  static List<BoxShadow> heroShadow(BuildContext context) {
    if (isDark(context)) {
      return const <BoxShadow>[];
    }
    return const <BoxShadow>[
      BoxShadow(
        color: Color(0x1E000000),
        blurRadius: 24,
        offset: Offset(0, 10),
      ),
    ];
  }

  static List<BoxShadow> avatarShadow(BuildContext context) {
    final shadowAlpha = isDark(context) ? 0.34 : 0.15;
    return <BoxShadow>[
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowAlpha),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ];
  }

  static Color selectedTabShadow(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return isDark(context)
        ? colors.shadow.withValues(alpha: 0.25)
        : const Color(0x1A2C2418);
  }

  static Color analyticsCategoryColor(String key) {
    return analyticsCategoryPalette[key] ?? analyticsCategoryPalette['other']!;
  }
}
