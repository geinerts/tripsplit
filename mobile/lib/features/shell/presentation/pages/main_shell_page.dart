import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../../core/ui/app_bottom_nav_bar.dart';
import '../../../../core/ui/test_keys.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';
import '../../../friends/presentation/pages/friends_page.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/controllers/trips_controller.dart';
import '../../../trips/presentation/pages/trips_page.dart';
import '../../../workspace/presentation/controllers/workspace_controller.dart';
import '../../../workspace/domain/entities/workspace_notification.dart';
import '../../../workspace/domain/entities/workspace_notifications_inbox.dart';
import '../../../workspace/presentation/pages/workspace_page.dart';

part 'main_shell_page_navigation.dart';
part 'main_shell_page_notifications.dart';
part 'main_shell_page_settings.dart';
part 'main_shell_page_widgets.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({
    super.key,
    required this.authController,
    required this.tripsController,
    required this.friendsController,
    required this.workspaceController,
    this.initialTabIndex = 0,
    this.openCreateTripOnStart = false,
    this.openAddExpenseOnStart = false,
  });

  final AuthController authController;
  final TripsController tripsController;
  final FriendsController friendsController;
  final WorkspaceController workspaceController;
  final int initialTabIndex;
  final bool openCreateTripOnStart;
  final bool openAddExpenseOnStart;

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage>
    with WidgetsBindingObserver {
  static const int _tabHome = 0;
  static const int _tabActivities = 1;
  static const int _tabAddExpense = 2;
  static const int _tabFriends = 3;
  static const int _tabProfile = 4;

  late final TripsPageCommandController _tripsCommandController;
  AnalyticsPageCommandController? _analyticsCommandController;
  late final FriendsPageCommandController _friendsCommandController;
  late final ProfilePageCommandController _profileCommandController;
  late final WorkspacePageCommandController _workspaceCommandController;
  late int _selectedTabIndex;
  Trip? _openedTrip;
  bool _isProfileInEditMode = false;
  bool _isLoggingOut = false;
  bool _isSendingFeedback = false;
  bool _isNotificationsLoading = false;
  bool _isNotificationsLoadingMore = false;
  int _unreadNotificationsCount = 0;
  List<WorkspaceNotification> _globalNotifications =
      const <WorkspaceNotification>[];
  bool _globalNotificationsHasMore = false;
  String? _globalNotificationsNextCursor;
  int? _globalNotificationsNextOffset;
  bool _notificationsPrimed = false;
  DateTime? _lastUnreadNotificationHintAt;
  Timer? _notificationsPollTimer;
  Duration? _activeNotificationsPollInterval;
  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedTabIndex = _normalizeInitialTabIndex(widget.initialTabIndex);
    _tripsCommandController = TripsPageCommandController();
    _analyticsCommandController = AnalyticsPageCommandController();
    _friendsCommandController = FriendsPageCommandController();
    _profileCommandController = ProfilePageCommandController();
    _workspaceCommandController = WorkspacePageCommandController();
    unawaited(
      AppMonitoring.updateRuntimeContext(
        userId: widget.authController.currentUser?.id,
        tripId: _openedTrip?.id,
      ),
    );
    _syncNotificationsPollingSchedule();
    unawaited(_refreshGlobalNotifications());
    if (widget.openCreateTripOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _requestCreateTrip();
      });
    }
    if (widget.openAddExpenseOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        unawaited(_requestAddExpenseFromNav());
      });
    }
  }

  @override
  void dispose() {
    _notificationsPollTimer?.cancel();
    unawaited(
      AppMonitoring.updateRuntimeContext(
        userId: widget.authController.currentUser?.id,
        tripId: null,
      ),
    );
    WidgetsBinding.instance.removeObserver(this);
    _tripsCommandController.dispose();
    _analyticsCommandController?.dispose();
    _friendsCommandController.dispose();
    _profileCommandController.dispose();
    _workspaceCommandController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final nextIsForeground = state == AppLifecycleState.resumed;
    if (_isAppInForeground == nextIsForeground) {
      return;
    }
    _isAppInForeground = nextIsForeground;
    if (_isAppInForeground) {
      unawaited(widget.authController.syncPushRegistration());
    }
    _syncNotificationsPollingSchedule();
  }

  void _syncNotificationsPollingSchedule() {
    final nextInterval = _resolveNotificationsPollInterval();
    if (_activeNotificationsPollInterval == nextInterval &&
        _notificationsPollTimer?.isActive == true) {
      return;
    }

    _notificationsPollTimer?.cancel();
    _activeNotificationsPollInterval = nextInterval;
    _notificationsPollTimer = Timer.periodic(nextInterval, (_) {
      if (_isLoggingOut || !_isAppInForeground) {
        return;
      }
      unawaited(_refreshGlobalNotifications());
    });
  }

  Duration _resolveNotificationsPollInterval() {
    if (!_isAppInForeground) {
      return const Duration(seconds: 120);
    }
    if (_isWorkspaceOpen ||
        _selectedTabIndex == _tabHome ||
        _selectedTabIndex == _tabFriends) {
      return const Duration(seconds: 20);
    }
    if (_selectedTabIndex == _tabActivities) {
      return const Duration(seconds: 35);
    }
    return const Duration(seconds: 45);
  }

  int _normalizeInitialTabIndex(int value) {
    if (value == _tabAddExpense) {
      // Keep compatibility with older links where index 2 used Friends.
      return _tabFriends;
    }
    return value.clamp(_tabHome, _tabProfile);
  }

  int get _stackIndex {
    if (_selectedTabIndex == _tabActivities) {
      return 1;
    }
    if (_selectedTabIndex == _tabFriends) {
      return 2;
    }
    if (_selectedTabIndex == _tabProfile) {
      return 3;
    }
    return 0;
  }

  bool get _isWorkspaceOpen => _openedTrip != null;
  bool get _showTopBackButton =>
      _isWorkspaceOpen || _selectedTabIndex != _tabHome;

  void _updateState(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
    unawaited(
      AppMonitoring.updateRuntimeContext(
        userId: widget.authController.currentUser?.id,
        tripId: _openedTrip?.id,
      ),
    );
    _syncNotificationsPollingSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return _buildShellScaffold(context);
  }
}
