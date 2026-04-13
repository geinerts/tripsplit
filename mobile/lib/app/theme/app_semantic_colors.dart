import 'package:flutter/material.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.modalBarrier,
    required this.heroGlassBackground,
    required this.heroGlassBorder,
    required this.cardGlassBackground,
    required this.cardGlassBorder,
    required this.heroMenuBackground,
    required this.heroAvatarStroke,
    required this.heroAvatarOverflowBackground,
    required this.statusActiveForeground,
    required this.statusActiveBackground,
    required this.statusActiveBorder,
    required this.statusSettledForeground,
    required this.statusSettledBackground,
    required this.statusSettledBorder,
    required this.statusSettlingForeground,
    required this.statusSettlingBackground,
    required this.statusSettlingBorder,
    required this.statusPendingForeground,
    required this.statusPendingBackground,
    required this.statusPendingBorder,
    required this.statusSentForeground,
    required this.statusSentBackground,
    required this.statusSentBorder,
    required this.statusConfirmedForeground,
    required this.statusConfirmedBackground,
    required this.statusConfirmedBorder,
    required this.sheetSurface,
    required this.sheetPanelSurface,
    required this.sheetPanelSurfaceMuted,
    required this.sheetPanelSurfaceHighlighted,
    required this.sheetBorder,
    required this.sheetHandle,
    required this.flowStepDone,
    required this.flowStepCurrent,
    required this.flowStepPending,
    required this.flowConnectorDone,
    required this.flowConnectorPending,
    required this.flowHighlightShadow,
  });

  final Color modalBarrier;
  final Color heroGlassBackground;
  final Color heroGlassBorder;
  final Color cardGlassBackground;
  final Color cardGlassBorder;
  final Color heroMenuBackground;
  final Color heroAvatarStroke;
  final Color heroAvatarOverflowBackground;
  final Color statusActiveForeground;
  final Color statusActiveBackground;
  final Color statusActiveBorder;
  final Color statusSettledForeground;
  final Color statusSettledBackground;
  final Color statusSettledBorder;
  final Color statusSettlingForeground;
  final Color statusSettlingBackground;
  final Color statusSettlingBorder;
  final Color statusPendingForeground;
  final Color statusPendingBackground;
  final Color statusPendingBorder;
  final Color statusSentForeground;
  final Color statusSentBackground;
  final Color statusSentBorder;
  final Color statusConfirmedForeground;
  final Color statusConfirmedBackground;
  final Color statusConfirmedBorder;
  final Color sheetSurface;
  final Color sheetPanelSurface;
  final Color sheetPanelSurfaceMuted;
  final Color sheetPanelSurfaceHighlighted;
  final Color sheetBorder;
  final Color sheetHandle;
  final Color flowStepDone;
  final Color flowStepCurrent;
  final Color flowStepPending;
  final Color flowConnectorDone;
  final Color flowConnectorPending;
  final Color flowHighlightShadow;

  static const AppSemanticColors light = AppSemanticColors(
    modalBarrier: Color(0xB8000000),
    heroGlassBackground: Color(0xDBFFFFFF),
    heroGlassBorder: Color(0xBDFFFFFF),
    cardGlassBackground: Color(0xB3FFFFFF),
    cardGlassBorder: Color(0x99FFFFFF),
    heroMenuBackground: Color(0x38000000),
    heroAvatarStroke: Color(0xFFFFFFFF),
    heroAvatarOverflowBackground: Color(0x2EFFFFFF),
    statusActiveForeground: Color(0xFF2D7A5E),
    statusActiveBackground: Color(0x1F2D7A5E),
    statusActiveBorder: Color(0x6654B77E),
    statusSettledForeground: Color(0xFF5E5448),
    statusSettledBackground: Color(0xB8FFFFFF),
    statusSettledBorder: Color(0xFFE9E4DD),
    statusSettlingForeground: Color(0xFF9A5A16),
    statusSettlingBackground: Color(0x22D4915C),
    statusSettlingBorder: Color(0x66D4915C),
    statusPendingForeground: Color(0xFFC45C4A),
    statusPendingBackground: Color(0x1FC45C4A),
    statusPendingBorder: Color(0x66C45C4A),
    statusSentForeground: Color(0xFF8A8277),
    statusSentBackground: Color(0x1F8A8277),
    statusSentBorder: Color(0x668A8277),
    statusConfirmedForeground: Color(0xFF3D8B5F),
    statusConfirmedBackground: Color(0x1F3D8B5F),
    statusConfirmedBorder: Color(0x663D8B5F),
    sheetSurface: Color(0xFFFFFFFF),
    sheetPanelSurface: Color(0xFFFFFFFF),
    sheetPanelSurfaceMuted: Color(0xFFF2EFE8),
    sheetPanelSurfaceHighlighted: Color(0xFFE6EDE4),
    sheetBorder: Color(0xFFE9E4DD),
    sheetHandle: Color(0xFFE8E2D9),
    flowStepDone: Color(0xFF3D8B5F),
    flowStepCurrent: Color(0xFF2D7A5E),
    flowStepPending: Color(0xFF8A8277),
    flowConnectorDone: Color(0x8C3D8B5F),
    flowConnectorPending: Color(0x668A8277),
    flowHighlightShadow: Color(0x1A2D7A5E),
  );

  static const AppSemanticColors dark = AppSemanticColors(
    modalBarrier: Color(0xB8000000),
    heroGlassBackground: Color(0x57000000),
    heroGlassBorder: Color(0x33FFFFFF),
    cardGlassBackground: Color(0x4D000000),
    cardGlassBorder: Color(0x2EFFFFFF),
    heroMenuBackground: Color(0x38000000),
    heroAvatarStroke: Color(0xFFFFFFFF),
    heroAvatarOverflowBackground: Color(0x2EFFFFFF),
    statusActiveForeground: Color(0xFFA6E7C8),
    statusActiveBackground: Color(0x332D7A5E),
    statusActiveBorder: Color(0x6654B77E),
    statusSettledForeground: Color(0xFFE7E2D8),
    statusSettledBackground: Color(0x1AFFFFFF),
    statusSettledBorder: Color(0x3DFFFFFF),
    statusSettlingForeground: Color(0xFFFFC278),
    statusSettlingBackground: Color(0x33D4915C),
    statusSettlingBorder: Color(0x66D4915C),
    statusPendingForeground: Color(0xFFFFA593),
    statusPendingBackground: Color(0x33C45C4A),
    statusPendingBorder: Color(0x66C45C4A),
    statusSentForeground: Color(0xFFC4CCC6),
    statusSentBackground: Color(0x2EFFFFFF),
    statusSentBorder: Color(0x4DFFFFFF),
    statusConfirmedForeground: Color(0xFFA6E7C8),
    statusConfirmedBackground: Color(0x332D7A5E),
    statusConfirmedBorder: Color(0x6654B77E),
    sheetSurface: Color(0xFF0C1611),
    sheetPanelSurface: Color(0xFF0F1C16),
    sheetPanelSurfaceMuted: Color(0xFF182C22),
    sheetPanelSurfaceHighlighted: Color(0xFF1B3528),
    sheetBorder: Color(0x47294339),
    sheetHandle: Color(0x3DF3F8F5),
    flowStepDone: Color(0xFFA6E7C8),
    flowStepCurrent: Color(0xFF57B487),
    flowStepPending: Color(0xFF98AB9F),
    flowConnectorDone: Color(0x8C57B487),
    flowConnectorPending: Color(0x6698AB9F),
    flowHighlightShadow: Color(0x2E57B487),
  );

  @override
  AppSemanticColors copyWith({
    Color? modalBarrier,
    Color? heroGlassBackground,
    Color? heroGlassBorder,
    Color? cardGlassBackground,
    Color? cardGlassBorder,
    Color? heroMenuBackground,
    Color? heroAvatarStroke,
    Color? heroAvatarOverflowBackground,
    Color? statusActiveForeground,
    Color? statusActiveBackground,
    Color? statusActiveBorder,
    Color? statusSettledForeground,
    Color? statusSettledBackground,
    Color? statusSettledBorder,
    Color? statusSettlingForeground,
    Color? statusSettlingBackground,
    Color? statusSettlingBorder,
    Color? statusPendingForeground,
    Color? statusPendingBackground,
    Color? statusPendingBorder,
    Color? statusSentForeground,
    Color? statusSentBackground,
    Color? statusSentBorder,
    Color? statusConfirmedForeground,
    Color? statusConfirmedBackground,
    Color? statusConfirmedBorder,
    Color? sheetSurface,
    Color? sheetPanelSurface,
    Color? sheetPanelSurfaceMuted,
    Color? sheetPanelSurfaceHighlighted,
    Color? sheetBorder,
    Color? sheetHandle,
    Color? flowStepDone,
    Color? flowStepCurrent,
    Color? flowStepPending,
    Color? flowConnectorDone,
    Color? flowConnectorPending,
    Color? flowHighlightShadow,
  }) {
    return AppSemanticColors(
      modalBarrier: modalBarrier ?? this.modalBarrier,
      heroGlassBackground: heroGlassBackground ?? this.heroGlassBackground,
      heroGlassBorder: heroGlassBorder ?? this.heroGlassBorder,
      cardGlassBackground: cardGlassBackground ?? this.cardGlassBackground,
      cardGlassBorder: cardGlassBorder ?? this.cardGlassBorder,
      heroMenuBackground: heroMenuBackground ?? this.heroMenuBackground,
      heroAvatarStroke: heroAvatarStroke ?? this.heroAvatarStroke,
      heroAvatarOverflowBackground:
          heroAvatarOverflowBackground ?? this.heroAvatarOverflowBackground,
      statusActiveForeground:
          statusActiveForeground ?? this.statusActiveForeground,
      statusActiveBackground:
          statusActiveBackground ?? this.statusActiveBackground,
      statusActiveBorder: statusActiveBorder ?? this.statusActiveBorder,
      statusSettledForeground:
          statusSettledForeground ?? this.statusSettledForeground,
      statusSettledBackground:
          statusSettledBackground ?? this.statusSettledBackground,
      statusSettledBorder: statusSettledBorder ?? this.statusSettledBorder,
      statusSettlingForeground:
          statusSettlingForeground ?? this.statusSettlingForeground,
      statusSettlingBackground:
          statusSettlingBackground ?? this.statusSettlingBackground,
      statusSettlingBorder: statusSettlingBorder ?? this.statusSettlingBorder,
      statusPendingForeground:
          statusPendingForeground ?? this.statusPendingForeground,
      statusPendingBackground:
          statusPendingBackground ?? this.statusPendingBackground,
      statusPendingBorder: statusPendingBorder ?? this.statusPendingBorder,
      statusSentForeground: statusSentForeground ?? this.statusSentForeground,
      statusSentBackground: statusSentBackground ?? this.statusSentBackground,
      statusSentBorder: statusSentBorder ?? this.statusSentBorder,
      statusConfirmedForeground:
          statusConfirmedForeground ?? this.statusConfirmedForeground,
      statusConfirmedBackground:
          statusConfirmedBackground ?? this.statusConfirmedBackground,
      statusConfirmedBorder:
          statusConfirmedBorder ?? this.statusConfirmedBorder,
      sheetSurface: sheetSurface ?? this.sheetSurface,
      sheetPanelSurface: sheetPanelSurface ?? this.sheetPanelSurface,
      sheetPanelSurfaceMuted:
          sheetPanelSurfaceMuted ?? this.sheetPanelSurfaceMuted,
      sheetPanelSurfaceHighlighted:
          sheetPanelSurfaceHighlighted ?? this.sheetPanelSurfaceHighlighted,
      sheetBorder: sheetBorder ?? this.sheetBorder,
      sheetHandle: sheetHandle ?? this.sheetHandle,
      flowStepDone: flowStepDone ?? this.flowStepDone,
      flowStepCurrent: flowStepCurrent ?? this.flowStepCurrent,
      flowStepPending: flowStepPending ?? this.flowStepPending,
      flowConnectorDone: flowConnectorDone ?? this.flowConnectorDone,
      flowConnectorPending: flowConnectorPending ?? this.flowConnectorPending,
      flowHighlightShadow: flowHighlightShadow ?? this.flowHighlightShadow,
    );
  }

  @override
  AppSemanticColors lerp(
    covariant ThemeExtension<AppSemanticColors>? other,
    double t,
  ) {
    if (other is! AppSemanticColors) {
      return this;
    }
    return AppSemanticColors(
      modalBarrier: Color.lerp(modalBarrier, other.modalBarrier, t)!,
      heroGlassBackground: Color.lerp(
        heroGlassBackground,
        other.heroGlassBackground,
        t,
      )!,
      heroGlassBorder: Color.lerp(heroGlassBorder, other.heroGlassBorder, t)!,
      cardGlassBackground: Color.lerp(
        cardGlassBackground,
        other.cardGlassBackground,
        t,
      )!,
      cardGlassBorder: Color.lerp(cardGlassBorder, other.cardGlassBorder, t)!,
      heroMenuBackground: Color.lerp(
        heroMenuBackground,
        other.heroMenuBackground,
        t,
      )!,
      heroAvatarStroke: Color.lerp(
        heroAvatarStroke,
        other.heroAvatarStroke,
        t,
      )!,
      heroAvatarOverflowBackground: Color.lerp(
        heroAvatarOverflowBackground,
        other.heroAvatarOverflowBackground,
        t,
      )!,
      statusActiveForeground: Color.lerp(
        statusActiveForeground,
        other.statusActiveForeground,
        t,
      )!,
      statusActiveBackground: Color.lerp(
        statusActiveBackground,
        other.statusActiveBackground,
        t,
      )!,
      statusActiveBorder: Color.lerp(
        statusActiveBorder,
        other.statusActiveBorder,
        t,
      )!,
      statusSettledForeground: Color.lerp(
        statusSettledForeground,
        other.statusSettledForeground,
        t,
      )!,
      statusSettledBackground: Color.lerp(
        statusSettledBackground,
        other.statusSettledBackground,
        t,
      )!,
      statusSettledBorder: Color.lerp(
        statusSettledBorder,
        other.statusSettledBorder,
        t,
      )!,
      statusSettlingForeground: Color.lerp(
        statusSettlingForeground,
        other.statusSettlingForeground,
        t,
      )!,
      statusSettlingBackground: Color.lerp(
        statusSettlingBackground,
        other.statusSettlingBackground,
        t,
      )!,
      statusSettlingBorder: Color.lerp(
        statusSettlingBorder,
        other.statusSettlingBorder,
        t,
      )!,
      statusPendingForeground: Color.lerp(
        statusPendingForeground,
        other.statusPendingForeground,
        t,
      )!,
      statusPendingBackground: Color.lerp(
        statusPendingBackground,
        other.statusPendingBackground,
        t,
      )!,
      statusPendingBorder: Color.lerp(
        statusPendingBorder,
        other.statusPendingBorder,
        t,
      )!,
      statusSentForeground: Color.lerp(
        statusSentForeground,
        other.statusSentForeground,
        t,
      )!,
      statusSentBackground: Color.lerp(
        statusSentBackground,
        other.statusSentBackground,
        t,
      )!,
      statusSentBorder: Color.lerp(
        statusSentBorder,
        other.statusSentBorder,
        t,
      )!,
      statusConfirmedForeground: Color.lerp(
        statusConfirmedForeground,
        other.statusConfirmedForeground,
        t,
      )!,
      statusConfirmedBackground: Color.lerp(
        statusConfirmedBackground,
        other.statusConfirmedBackground,
        t,
      )!,
      statusConfirmedBorder: Color.lerp(
        statusConfirmedBorder,
        other.statusConfirmedBorder,
        t,
      )!,
      sheetSurface: Color.lerp(sheetSurface, other.sheetSurface, t)!,
      sheetPanelSurface: Color.lerp(
        sheetPanelSurface,
        other.sheetPanelSurface,
        t,
      )!,
      sheetPanelSurfaceMuted: Color.lerp(
        sheetPanelSurfaceMuted,
        other.sheetPanelSurfaceMuted,
        t,
      )!,
      sheetPanelSurfaceHighlighted: Color.lerp(
        sheetPanelSurfaceHighlighted,
        other.sheetPanelSurfaceHighlighted,
        t,
      )!,
      sheetBorder: Color.lerp(sheetBorder, other.sheetBorder, t)!,
      sheetHandle: Color.lerp(sheetHandle, other.sheetHandle, t)!,
      flowStepDone: Color.lerp(flowStepDone, other.flowStepDone, t)!,
      flowStepCurrent: Color.lerp(flowStepCurrent, other.flowStepCurrent, t)!,
      flowStepPending: Color.lerp(flowStepPending, other.flowStepPending, t)!,
      flowConnectorDone: Color.lerp(
        flowConnectorDone,
        other.flowConnectorDone,
        t,
      )!,
      flowConnectorPending: Color.lerp(
        flowConnectorPending,
        other.flowConnectorPending,
        t,
      )!,
      flowHighlightShadow: Color.lerp(
        flowHighlightShadow,
        other.flowHighlightShadow,
        t,
      )!,
    );
  }
}
