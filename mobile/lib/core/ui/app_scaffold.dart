import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';
import 'app_background.dart';
import 'app_bottom_nav_bar.dart';
import 'app_form_safe_area.dart';

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
    final navigation = bottomNavigationBar;
    final availableWidth =
        MediaQuery.sizeOf(context).width -
        MediaQuery.paddingOf(context).horizontal;
    final useRail = navigation is AppBottomNavBar && availableWidth >= 700;
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: extendBody,
      appBar: appBar,
      body: SafeArea(
        top: false,
        bottom: useRail || navigation == null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Keep the body at the same element-tree position when folding.
            // Moving it between two layout branches would discard page state.
            SizedBox(
              width: useRail ? 104 : 0,
              child: useRail
                  ? AppBottomNavBar(
                      vertical: true,
                      selectedItem: navigation.selectedItem,
                      onSelected: navigation.onSelected,
                      avatarLetter: navigation.avatarLetter,
                      avatarBytes: navigation.avatarBytes,
                      avatarUrl: navigation.avatarUrl,
                    )
                  : null,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      size: Size(
                        constraints.maxWidth,
                        MediaQuery.sizeOf(context).height,
                      ),
                    ),
                    child: AppBackground(force: forceBackground, child: body),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: useRail ? null : navigation,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class AppFormScaffold extends StatelessWidget {
  const AppFormScaffold({
    super.key,
    required this.child,
    this.header,
    this.appBar,
    this.resizeToAvoidBottomInset,
    this.bottomNavigationBar,
  });

  final Widget child;
  final Widget? header;
  final PreferredSizeWidget? appBar;
  final bool? resizeToAvoidBottomInset;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.pageBaseColor(context),
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: AppBackground(
        force: true,
        child: AppFormSafeArea(header: header, child: child),
      ),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : SafeArea(
              top: false,
              child: Align(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: bottomNavigationBar,
                ),
              ),
            ),
    );
  }
}
