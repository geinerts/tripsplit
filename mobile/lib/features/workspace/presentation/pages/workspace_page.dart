import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/expenses/expense_category_catalog.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../../core/perf/perf_monitor.dart';
import '../../../../core/ui/app_background.dart';
import '../../../../core/ui/app_bottom_nav_bar.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/domain/entities/trip_user.dart';
import '../../../trips/presentation/controllers/trips_controller.dart';
import '../utils/expense_math.dart';
import '../../domain/entities/balance_item.dart';
import '../../domain/entities/expense_participant.dart';
import '../../domain/entities/expense_split_value.dart';
import '../../domain/entities/queued_mutation.dart';
import '../../domain/entities/random_draw_result.dart';
import '../../domain/entities/receipt_upload_payload.dart';
import '../../domain/entities/settlement_item.dart';
import '../../domain/entities/trip_expense.dart';
import '../../domain/entities/uploaded_receipt.dart';
import '../../domain/entities/workspace_snapshot.dart';
import '../../domain/entities/workspace_user.dart';
import '../controllers/workspace_controller.dart';

part 'workspace_page_actions_loading.dart';
part 'workspace_page_actions_members.dart';
part 'workspace_page_actions_expenses.dart';
part 'workspace_page_actions_expenses_details.dart';
part 'workspace_page_actions_expenses_sheet.dart';
part 'workspace_page_actions_queue.dart';
part 'workspace_page_actions_trip.dart';
part 'workspace_page_layout.dart';
part 'workspace_page_layout_navigation.dart';
part 'workspace_page_layout_overview.dart';
part 'workspace_page_tab_balances.dart';
part 'workspace_page_tab_balances_details.dart';
part 'workspace_page_tab_settlement_details.dart';
part 'workspace_page_tab_expenses.dart';
part 'workspace_page_tab_random.dart';
part 'workspace_page_dialogs.dart';
part 'workspace_page_dialogs_helpers.dart';
part 'workspace_page_support_sync.dart';
part 'workspace_page_support_models.dart';
part 'workspace_page_support_widgets.dart';
part 'workspace_page_formatters.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({
    super.key,
    required this.trip,
    required this.workspaceController,
    required this.tripsController,
    required this.authController,
    this.showAppBar = true,
    this.showBottomNav = true,
    this.openAddExpenseOnStart = false,
    this.commandController,
    this.onExitRequested,
  });

  final Trip trip;
  final WorkspaceController workspaceController;
  final TripsController tripsController;
  final AuthController authController;
  final bool showAppBar;
  final bool showBottomNav;
  final bool openAddExpenseOnStart;
  final WorkspacePageCommandController? commandController;
  final VoidCallback? onExitRequested;

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class WorkspacePageCommandController extends ChangeNotifier {
  int _refreshRequestCount = 0;
  int _openAddExpenseRequestCount = 0;

  int get refreshRequestCount => _refreshRequestCount;
  int get openAddExpenseRequestCount => _openAddExpenseRequestCount;

  void requestRefresh() {
    _refreshRequestCount += 1;
    notifyListeners();
  }

  void requestOpenAddExpense() {
    _openAddExpenseRequestCount += 1;
    notifyListeners();
  }
}

class _WorkspacePageState extends State<WorkspacePage> {
  bool _isLoading = true;
  bool _isMutating = false;
  String? _errorText;

  int _currentUserId = 0;
  int _pendingQueueCount = 0;
  int _expenseFilterUserId = 0;
  int _workspaceTabIndex = 0;
  bool _isOverviewExpanded = false;
  int _handledRefreshRequestCount = 0;
  int _handledOpenAddExpenseRequestCount = 0;
  bool _openAddExpenseAfterLoad = false;
  List<QueuedMutation> _queuedMutations = const <QueuedMutation>[];
  WorkspaceSnapshot? _snapshot;
  List<TripExpense> _expensesFeed = const <TripExpense>[];
  bool _expensesHasMore = false;
  bool _isLoadingMoreExpenses = false;
  String? _expensesNextCursor;
  int? _expensesNextOffset;
  Set<int> _randomSelection = <int>{};
  RandomDrawResult? _lastDraw;
  _SyncState _syncState = _SyncState.online;

  bool get _isTripActive => _snapshot?.isActive ?? widget.trip.isActive;
  bool get _isTripSettling => _snapshot?.isSettling ?? widget.trip.isSettling;

  bool get _canEditMembers {
    if (!_isTripActive) {
      return false;
    }
    final creatorId = widget.trip.createdBy;
    if (creatorId == null || creatorId <= 0) {
      return false;
    }
    return creatorId == _currentUserId;
  }

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
  }

  @override
  void initState() {
    super.initState();
    final initialUserId = widget.authController.currentUser?.id ?? 0;
    if (initialUserId > 0) {
      _currentUserId = initialUserId;
    }
    _openAddExpenseAfterLoad = widget.openAddExpenseOnStart;
    unawaited(
      AppMonitoring.updateRuntimeContext(
        userId: widget.authController.currentUser?.id,
        tripId: widget.trip.id,
      ),
    );
    _bindCommandController(widget.commandController);
    _loadData(showLoader: true);
  }

  @override
  void didUpdateWidget(covariant WorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.commandController != widget.commandController) {
      _unbindCommandController(oldWidget.commandController);
      _bindCommandController(widget.commandController);
    }
  }

  @override
  void dispose() {
    unawaited(
      AppMonitoring.updateRuntimeContext(
        userId: widget.authController.currentUser?.id,
        tripId: null,
      ),
    );
    _unbindCommandController(widget.commandController);
    super.dispose();
  }

  void _bindCommandController(WorkspacePageCommandController? controller) {
    if (controller == null) {
      return;
    }
    _handledRefreshRequestCount = controller.refreshRequestCount;
    _handledOpenAddExpenseRequestCount = controller.openAddExpenseRequestCount;
    controller.addListener(_onCommandControllerChanged);
  }

  void _unbindCommandController(WorkspacePageCommandController? controller) {
    controller?.removeListener(_onCommandControllerChanged);
  }

  void _onCommandControllerChanged() {
    final controller = widget.commandController;
    if (controller == null) {
      return;
    }
    final refreshRequestCount = controller.refreshRequestCount;
    if (refreshRequestCount != _handledRefreshRequestCount) {
      _handledRefreshRequestCount = refreshRequestCount;
      unawaited(_loadData(showLoader: false));
    }

    final openAddExpenseRequestCount = controller.openAddExpenseRequestCount;
    if (openAddExpenseRequestCount != _handledOpenAddExpenseRequestCount) {
      _handledOpenAddExpenseRequestCount = openAddExpenseRequestCount;
      if (_isLoading || _snapshot == null) {
        _openAddExpenseAfterLoad = true;
        unawaited(_loadData(showLoader: false));
        return;
      }
      unawaited(_onAddExpensePressed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = SafeArea(
      top: !widget.showAppBar,
      bottom: !widget.showBottomNav,
      child: _buildBody(context),
    );
    if (!widget.showAppBar && !widget.showBottomNav) {
      return content;
    }
    return Scaffold(
      appBar: widget.showAppBar ? _buildAppBar(context) : null,
      body: content,
      bottomNavigationBar: widget.showBottomNav
          ? _buildAppBottomNavigationBar(context)
          : null,
    );
  }
}
