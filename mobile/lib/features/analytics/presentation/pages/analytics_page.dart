import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/expenses/expense_category_catalog.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/perf/perf_monitor.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/ui/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/controllers/trips_controller.dart';
import '../../../workspace/domain/entities/workspace_snapshot.dart';
import '../../../workspace/presentation/controllers/workspace_controller.dart';

part 'analytics_page_actions.dart';
part 'analytics_page_calculations.dart';
part 'analytics_page_widgets.dart';
part 'analytics_page_components.dart';

class AnalyticsPageCommandController extends ChangeNotifier {
  int _refreshRequestCount = 0;

  int get refreshRequestCount => _refreshRequestCount;

  void requestRefresh() {
    _refreshRequestCount += 1;
    notifyListeners();
  }
}

typedef AnalyticsOpenTripCallback = void Function(Trip trip);

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({
    super.key,
    required this.tripsController,
    required this.workspaceController,
    required this.authController,
    this.commandController,
    this.onOpenTrip,
  });

  final TripsController tripsController;
  final WorkspaceController workspaceController;
  final AuthController authController;
  final AnalyticsPageCommandController? commandController;
  final AnalyticsOpenTripCallback? onOpenTrip;

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _isLoadingTrips = true;
  bool _isLoadingSnapshot = false;
  String? _tripsError;
  String? _snapshotError;
  int _handledRefreshRequestCount = 0;
  int? _selectedTripId;
  List<Trip> _trips = const <Trip>[];
  final Map<int, WorkspaceSnapshot> _snapshotCache = <int, WorkspaceSnapshot>{};

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
  }

  @override
  void initState() {
    super.initState();
    _bindCommandController(widget.commandController);
    unawaited(_loadTrips(forceReload: true));
  }

  @override
  void didUpdateWidget(covariant AnalyticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commandController != widget.commandController) {
      _unbindCommandController(oldWidget.commandController);
      _bindCommandController(widget.commandController);
    }
  }

  @override
  void dispose() {
    _unbindCommandController(widget.commandController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildAnalyticsScaffold(context);
  }
}
