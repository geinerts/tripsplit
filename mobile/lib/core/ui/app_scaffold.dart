import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';
import 'app_background.dart';

class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({required super.builder, super.settings});
}

class AppFormPageRoute<T> extends MaterialPageRoute<T> {
  AppFormPageRoute({required super.builder, super.settings})
    : super(fullscreenDialog: true);
}

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.forceBackground = false,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool forceBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: extendBody,
      appBar: appBar,
      body: AppBackground(force: forceBackground, child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class AppFormScaffold extends StatelessWidget {
  const AppFormScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.pageBaseColor(context),
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: AppBackground(force: true, child: SafeArea(child: child)),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
