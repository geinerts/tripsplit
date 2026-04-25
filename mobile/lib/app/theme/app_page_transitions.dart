import 'package:flutter/material.dart';

import '../../core/ui/app_background.dart';

/// Unified page transition used across platforms to avoid iOS-style
/// side-slide overlap where previous screen remains visible underneath.
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  static final Animatable<double> _opacityTween = CurveTween(
    curve: Curves.easeOutCubic,
  );

  static final Animatable<Offset> _offsetTween = Tween<Offset>(
    begin: const Offset(0, 0.015),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.fullscreenDialog) {
      return _OpaquePageTransition(
        animation: animation,
        child: FadeTransition(
          opacity: animation.drive(_opacityTween),
          child: child,
        ),
      );
    }

    return _OpaquePageTransition(
      animation: animation,
      child: SlideTransition(
        position: animation.drive(_offsetTween),
        child: FadeTransition(
          opacity: animation.drive(_opacityTween),
          child: child,
        ),
      ),
    );
  }
}

class _OpaquePageTransition extends StatelessWidget {
  const _OpaquePageTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final isPopping = animation.status == AnimationStatus.reverse;
        final backgroundOpacity = isPopping
            ? animation.value.clamp(0.0, 1.0)
            : 1.0;
        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: backgroundOpacity,
              child: const AppBackground(force: true, child: SizedBox.expand()),
            ),
            child!,
          ],
        );
      },
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
