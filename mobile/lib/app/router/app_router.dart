import 'package:flutter/material.dart';

import '../app_dependencies.dart';
import '../../core/l10n/l10n.dart';
import '../../features/auth/presentation/pages/credentials_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/auth_intro_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../theme/auth_flow_theme.dart';
import '../theme/app_overlay_style.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/workspace/presentation/pages/workspace_page.dart';
import '../../features/trips/domain/entities/trip.dart';

class AppRouter {
  const AppRouter(this._dependencies);

  static const String shell = '/app';
  static const String authIntro = '/auth-intro';
  static const String authSignInChoice = '/auth-sign-in-choice';
  static const String login = '/login';
  static const String credentials = '/credentials';
  static const String forgotPassword = '/forgot-password';
  static const String profile = '/profile';
  static const String trips = '/trips';
  static const String workspace = '/workspace';

  final AppDependencies _dependencies;

  Map<String, WidgetBuilder> get routes {
    return <String, WidgetBuilder>{
      authIntro: (_) => AuthFlowTheme(
        child: AuthIntroPage(controller: _dependencies.authController),
      ),
      authSignInChoice: (_) => AuthFlowTheme(
        child: AuthIntroPage(
          controller: _dependencies.authController,
          initialStage: AuthIntroStage.choice,
        ),
      ),
      login: (_) => AuthFlowTheme(
        child: LoginPage(controller: _dependencies.authController),
      ),
      credentials: (_) => AuthFlowTheme(
        child: CredentialsPage(controller: _dependencies.authController),
      ),
      forgotPassword: (_) => AuthFlowTheme(
        child: ForgotPasswordPage(controller: _dependencies.authController),
      ),
      shell: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final initialTab = args is Map && args['initial_tab'] is int
            ? (args['initial_tab'] as int)
            : 0;
        final openCreateTrip = args is Map && args['open_create_trip'] == true;
        final openAddExpense = args is Map && args['open_add_expense'] == true;
        return AppDynamicSystemOverlay(
          child: MainShellPage(
            authController: _dependencies.authController,
            tripsController: _dependencies.tripsController,
            friendsController: _dependencies.friendsController,
            workspaceController: _dependencies.workspaceController,
            inviteDeepLinkController: _dependencies.inviteDeepLinkController,
            initialTabIndex: initialTab,
            openCreateTripOnStart: openCreateTrip,
            openAddExpenseOnStart: openAddExpense,
          ),
        );
      },
      profile: (_) => AppDynamicSystemOverlay(
        child: MainShellPage(
          authController: _dependencies.authController,
          tripsController: _dependencies.tripsController,
          friendsController: _dependencies.friendsController,
          workspaceController: _dependencies.workspaceController,
          inviteDeepLinkController: _dependencies.inviteDeepLinkController,
          initialTabIndex: 4,
        ),
      ),
      trips: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final openCreateTrip = args is Map && args['open_create_trip'] == true;
        final openAddExpense = args is Map && args['open_add_expense'] == true;
        return AppDynamicSystemOverlay(
          child: MainShellPage(
            authController: _dependencies.authController,
            tripsController: _dependencies.tripsController,
            friendsController: _dependencies.friendsController,
            workspaceController: _dependencies.workspaceController,
            inviteDeepLinkController: _dependencies.inviteDeepLinkController,
            initialTabIndex: 0,
            openCreateTripOnStart: openCreateTrip,
            openAddExpenseOnStart: openAddExpense,
          ),
        );
      },
      workspace: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        Trip? trip;
        var openAddExpense = false;
        if (args is Trip) {
          trip = args;
        } else if (args is Map && args['trip'] is Trip) {
          trip = args['trip'] as Trip;
          openAddExpense = args['open_add_expense'] == true;
        }
        if (trip == null) {
          return const AppDynamicSystemOverlay(child: _WorkspaceRouteError());
        }
        return AppDynamicSystemOverlay(
          child: WorkspacePage(
            trip: trip,
            workspaceController: _dependencies.workspaceController,
            tripsController: _dependencies.tripsController,
            friendsController: _dependencies.friendsController,
            authController: _dependencies.authController,
            openAddExpenseOnStart: openAddExpense,
          ),
        );
      },
    };
  }
}

class _WorkspaceRouteError extends StatelessWidget {
  const _WorkspaceRouteError();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(t.tripTitleShort)),
      body: Center(child: Text(t.missingTripRouteArgument)),
    );
  }
}
