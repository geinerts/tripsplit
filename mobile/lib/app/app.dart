import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

import 'app_dependencies.dart';
import 'locale/app_locale_scope.dart';
import 'router/app_router.dart';
import 'theme/theme_mode_scope.dart';
import 'theme/app_theme.dart';
import '../core/ui/app_background.dart';

class TripSplitApp extends StatefulWidget {
  const TripSplitApp({
    super.key,
    required this.dependencies,
    required this.initialRoute,
  });

  final AppDependencies dependencies;
  final String initialRoute;

  @override
  State<TripSplitApp> createState() => _TripSplitAppState();
}

class _TripSplitAppState extends State<TripSplitApp> {
  void _handleLocaleChanged() {
    if (widget.dependencies.authController.currentUser == null) {
      return;
    }
    unawaited(widget.dependencies.authController.syncPushRegistration());
  }

  @override
  void initState() {
    super.initState();
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(const [
        'Inter',
      ], await rootBundle.loadString('assets/fonts/OFL.txt'));
    });
    widget.dependencies.localeController.addListener(_handleLocaleChanged);
    unawaited(widget.dependencies.themeModeController.load());
    unawaited(widget.dependencies.localeController.load());
    widget.dependencies.inviteDeepLinkController.start();
  }

  @override
  void dispose() {
    widget.dependencies.localeController.removeListener(_handleLocaleChanged);
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
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeController.themeMode,
              locale: localeController.locale,
              builder: (context, child) {
                if (child == null) {
                  return const SizedBox.shrink();
                }
                return AppBackground(child: child);
              },
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: widget.initialRoute,
              routes: router.routes,
            );
          },
        ),
      ),
    );
  }
}
