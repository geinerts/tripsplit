import 'package:flutter/material.dart';

import '../app_dependencies.dart';
import '../../core/l10n/l10n.dart';
import '../../features/auth/presentation/pages/credentials_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../../features/workspace/presentation/pages/workspace_page.dart';
import '../../features/trips/domain/entities/trip.dart';

class AppRouter {
  const AppRouter(this._dependencies);

  static const String shell = '/app';
  static const String login = '/login';
  static const String credentials = '/credentials';
  static const String profile = '/profile';
  static const String trips = '/trips';
  static const String workspace = '/workspace';

  final AppDependencies _dependencies;

  Map<String, WidgetBuilder> get routes {
    return <String, WidgetBuilder>{
      login: (_) => LoginPage(controller: _dependencies.authController),
      credentials: (_) =>
          CredentialsPage(controller: _dependencies.authController),
      shell: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final initialTab = args is Map && args['initial_tab'] is int
            ? (args['initial_tab'] as int)
            : 0;
        final openCreateTrip = args is Map && args['open_create_trip'] == true;
        final openAddExpense = args is Map && args['open_add_expense'] == true;
        return MainShellPage(
          authController: _dependencies.authController,
          tripsController: _dependencies.tripsController,
          friendsController: _dependencies.friendsController,
          workspaceController: _dependencies.workspaceController,
          initialTabIndex: initialTab,
          openCreateTripOnStart: openCreateTrip,
          openAddExpenseOnStart: openAddExpense,
        );
      },
      profile: (_) => MainShellPage(
        authController: _dependencies.authController,
        tripsController: _dependencies.tripsController,
        friendsController: _dependencies.friendsController,
        workspaceController: _dependencies.workspaceController,
        initialTabIndex: 4,
      ),
      trips: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        final openCreateTrip = args is Map && args['open_create_trip'] == true;
        final openAddExpense = args is Map && args['open_add_expense'] == true;
        return MainShellPage(
          authController: _dependencies.authController,
          tripsController: _dependencies.tripsController,
          friendsController: _dependencies.friendsController,
          workspaceController: _dependencies.workspaceController,
          initialTabIndex: 0,
          openCreateTripOnStart: openCreateTrip,
          openAddExpenseOnStart: openAddExpense,
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
          return const _WorkspaceRouteError();
        }
        return WorkspacePage(
          trip: trip,
          workspaceController: _dependencies.workspaceController,
          tripsController: _dependencies.tripsController,
          authController: _dependencies.authController,
          openAddExpenseOnStart: openAddExpense,
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
