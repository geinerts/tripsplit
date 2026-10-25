import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child, this.force = false});

  final Widget child;
  final bool force;

  @override
  Widget build(BuildContext context) {
    if (!force && _AppBackgroundScope.isActive(context)) return child;
    return _AppBackgroundScope(
      child: ColoredBox(color: AppDesign.pageBaseColor(context), child: child),
    );
  }
}

class _AppBackgroundScope extends InheritedWidget {
  const _AppBackgroundScope({required super.child});

  static bool isActive(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AppBackgroundScope>() != null;

  @override
  bool updateShouldNotify(covariant _AppBackgroundScope oldWidget) => false;
}
