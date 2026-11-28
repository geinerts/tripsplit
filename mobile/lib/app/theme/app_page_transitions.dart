import 'package:flutter/material.dart';

import '../../core/ui/app_background.dart';
import '../router/app_router.dart';
import 'app_design.dart';

/// Each platform's own page transition: on iOS and macOS the page slides in
/// from the side and can be swiped back from the edge; elsewhere Android's
/// transition, with predictive back where the system supports it.
///
/// Every page is drawn on its own opaque background, because the app's
/// scaffolds are transparent: without it, the page underneath would show
/// through the one sliding over it.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  static const _cupertino = CupertinoPageTransitionsBuilder();
  static const _android = PredictiveBackPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final canvas = AppRouter.authFlowRoutes.contains(route.settings.name)
        ? AppDesign.authCanvas
        : null;
    final opaque = canvas != null
        ? ColoredBox(color: canvas, child: child)
        : AppBackground(force: true, child: child);
    final platform = Theme.of(context).platform;
    final builder =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS
        ? _cupertino
        : _android;
    return builder.buildTransitions<T>(
      route,
      context,
      animation,
      secondaryAnimation,
      opaque,
    );
  }
}

const PageTransitionsTheme appPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: AppPageTransitionsBuilder(),
    TargetPlatform.iOS: AppPageTransitionsBuilder(),
    TargetPlatform.macOS: AppPageTransitionsBuilder(),
    TargetPlatform.windows: AppPageTransitionsBuilder(),
    TargetPlatform.linux: AppPageTransitionsBuilder(),
    TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
  },
);
