import 'dart:async';

import 'app/app.dart';
import 'app/app_dependencies.dart';
import 'app/router/app_router.dart';
import 'core/monitoring/app_monitoring.dart';

Future<void> main() async {
  final dependencies = AppDependencies.bootstrap();
  var initialRoute = AppRouter.authFromLaunch;
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
      return _signedOutRoute(dependencies);
    }
    // Whoever already has an account never needs the guide before signing in again.
    unawaited(dependencies.quickStartSeenStore.markSeen());

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

    // No verified account identity means no access to account-scoped offline data.
    return AppRouter.authFromLaunch;
  } catch (_) {
    final fallback = await dependencies.authController.readCachedCurrentUser();
    if (fallback != null) {
      return fallback.needsCredentials
          ? AppRouter.credentials
          : AppRouter.trips;
    }
    return AppRouter.authFromLaunch;
  }
}

/// The guide once on a new install, unless a link opened the app for a reason.
Future<String> _signedOutRoute(AppDependencies dependencies) async {
  if (await dependencies.quickStartSeenStore.isSeen() ||
      await dependencies.inviteDeepLinkController.openedWithLink()) {
    return AppRouter.authFromLaunch;
  }
  return AppRouter.quickStartWelcome;
}
