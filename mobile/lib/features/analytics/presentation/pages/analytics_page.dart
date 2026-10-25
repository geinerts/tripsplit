import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/ui/splyto_illustration.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/expenses/expense_category_catalog.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/ui/app_formatters.dart';
import '../../../../core/ui/app_skeleton.dart';
import '../../../../core/ui/responsive.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/controllers/trips_controller.dart';
import '../../../workspace/presentation/controllers/workspace_controller.dart';
import '../../domain/analytics_report.dart';
part 'analytics_page_actions.dart';
part 'analytics_page_calculations.dart';
part 'analytics_page_widgets.dart';
part 'analytics_page_components.dart';

class AnalyticsPageCommandController extends ChangeNotifier {
  int _refreshRequestCount = 0;
  int get refreshRequestCount => _refreshRequestCount;
  void requestRefresh() {
    _refreshRequestCount++;
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
    this.active = true,
  });
  final TripsController tripsController;
  final WorkspaceController workspaceController;
  final AuthController authController;
  final AnalyticsPageCommandController? commandController;
  final AnalyticsOpenTripCallback? onOpenTrip;
  final bool active;
  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  bool _loading = false, _loaded = false, _byTrip = false, _personal = true;
  String? _error, _currency, _month;
  int? _selectedTripId;
  int _generation = 0, _accountId = 0;
  List<Trip> _trips = [];
  List<AnalyticsEntry> _entries = [];
  @override
  void initState() {
    super.initState();
    _accountId = widget.authController.currentUser?.id ?? 0;
    widget.commandController?.addListener(_refresh);
    if (widget.active) unawaited(_load());
  }

  @override
  void didUpdateWidget(covariant AnalyticsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commandController != widget.commandController) {
      oldWidget.commandController?.removeListener(_refresh);
      widget.commandController?.addListener(_refresh);
    }
    final account = widget.authController.currentUser?.id ?? 0;
    if (account != _accountId) {
      _generation++;
      _accountId = account;
      _trips = [];
      _entries = [];
      _loaded = false;
      _loading = false;
      _selectedTripId = null;
      _currency = null;
      _month = null;
      _error = null;
    }
    if (widget.active && !_loaded && !_loading) unawaited(_load());
  }

  void _updateState(VoidCallback update) {
    if (mounted) setState(update);
  }

  @override
  void dispose() {
    _generation++;
    widget.commandController?.removeListener(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildAnalyticsScaffold(context);
}
