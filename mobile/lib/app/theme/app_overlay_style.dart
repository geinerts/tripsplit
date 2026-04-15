import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppSystemOverlayStyles {
  const AppSystemOverlayStyles._();

  static const SystemUiOverlayStyle lightContent = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  static const SystemUiOverlayStyle darkContent = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static SystemUiOverlayStyle forBrightness(Brightness brightness) {
    return brightness == Brightness.dark ? lightContent : darkContent;
  }
}

class AppDynamicSystemOverlay extends StatelessWidget {
  const AppDynamicSystemOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlayStyles.forBrightness(Theme.of(context).brightness),
      child: child,
    );
  }
}

class AppFixedLightSystemOverlay extends StatelessWidget {
  const AppFixedLightSystemOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppSystemOverlayStyles.lightContent,
      child: child,
    );
  }
}
