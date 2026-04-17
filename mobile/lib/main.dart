import 'dart:async';

import 'app/app.dart';
import 'app/app_dependencies.dart';
import 'app/router/app_router.dart';
import 'core/monitoring/app_monitoring.dart';

Future<void> main() async {
  final dependencies = AppDependencies.bootstrap();
  var initialRoute = AppRouter.authIntro;
  await AppMonitoring.bootstrapAndRun(
    dependencies: dependencies,
    beforeRunApp: () async {
      initialRoute = await _resolveInitialRoute(dependencies);
    },
    appBuilder: () =>
        TripSplitApp(dependencies: dependencies, initialRoute: initialRoute),
  );
}

Future<String> _resolveInitialRoute(AppDependencies dependencies) async {
  try {
    final hasSession = await dependencies.authController
        .hasRecoverableSession();
    if (!hasSession) {
      return AppRouter.authIntro;
    }

    var user = dependencies.authController.currentUser;
    user ??= await dependencies.authController.readCachedCurrentUser();
    if (user != null) {
      return user.needsCredentials ? AppRouter.credentials : AppRouter.trips;
    }

    try {
      final loadedUser = await dependencies.authController
          .loadCurrentUser()
          .timeout(const Duration(seconds: 3));
      return loadedUser.needsCredentials
          ? AppRouter.credentials
          : AppRouter.trips;
    } catch (_) {
      // Ignore network/bootstrap errors; route fallback below.
    }

    return AppRouter.trips;
  } catch (_) {
    final fallback = await dependencies.authController.readCachedCurrentUser();
    if (fallback != null) {
      return fallback.needsCredentials
          ? AppRouter.credentials
          : AppRouter.trips;
    }
    return AppRouter.authIntro;
  }
}
