import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/locale/app_locale_picker.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_design.dart';
import '../../../../app/theme/theme_mode_picker.dart';
import '../../../../core/deeplink/invite_deep_link_controller.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/notification_localizer.dart';
import '../../../../core/monitoring/app_monitoring.dart';
import '../../../../core/ui/app_bottom_nav_bar.dart';
import '../../../../core/ui/app_components.dart';
import '../../../../core/ui/app_scaffold.dart';
import '../../../../core/ui/app_sheet.dart';
import '../../../../core/ui/test_keys.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';
import '../../../friends/presentation/pages/friends_page.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/domain/entities/trip_invite_preview.dart';
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
    required this.inviteDeepLinkController,
    this.initialTabIndex = 0,
    this.openCreateTripOnStart = false,
    this.openAddExpenseOnStart = false,
  });

  final AuthController authController;
  final TripsController tripsController;
  final FriendsController friendsController;
  final WorkspaceController workspaceController;
  final InviteDeepLinkController inviteDeepLinkController;
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
  bool _openAddExpenseOnWorkspaceStart = false;
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
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<String>? _inviteCodeSubscription;
  bool _isFlushingWorkspaceQueue = false;
  bool _isProcessingInviteDeepLink = false;
  String? _queuedInviteDeepLinkCode;
  String? _lastProcessedInviteDeepLinkCode;
  DateTime? _lastProcessedInviteDeepLinkAt;

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
    unawaited(() async {
      try {
        await widget.authController.loadNotificationPreferences();
      } catch (_) {
        // Keep default preferences when endpoint/migration is not yet available.
      }
    }());
    unawaited(_refreshGlobalNotifications());
    _startConnectivityQueueSync();
    _bindInviteDeepLinkHandling();
    unawaited(_flushWorkspaceQueueBestEffort());
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
    _connectivitySubscription?.cancel();
    _inviteCodeSubscription?.cancel();
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
      unawaited(_flushWorkspaceQueueBestEffort());
    }
    _syncNotificationsPollingSchedule();
  }

  void _startConnectivityQueueSync() {
    final connectivity = Connectivity();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      results,
    ) {
      if (!_hasOnlineConnectivity(results)) {
        return;
      }
      unawaited(_flushWorkspaceQueueBestEffort());
    });

    unawaited(() async {
      final current = await connectivity.checkConnectivity();
      if (_hasOnlineConnectivity(current)) {
        await _flushWorkspaceQueueBestEffort();
      }
    }());
  }

  void _bindInviteDeepLinkHandling() {
    final pending = widget.inviteDeepLinkController.consumePendingInviteCode();
    if (pending != null && pending.trim().isNotEmpty) {
      unawaited(_handleInviteDeepLinkCode(pending));
    }
    _inviteCodeSubscription = widget.inviteDeepLinkController.inviteCodeStream
        .listen((inviteCode) {
          unawaited(_handleInviteDeepLinkCode(inviteCode));
        });
  }

  Future<void> _handleInviteDeepLinkCode(String rawInviteCode) async {
    final inviteCode = rawInviteCode.trim().toLowerCase();
    if (inviteCode.isEmpty || _isLoggingOut) {
      return;
    }

    if (_isProcessingInviteDeepLink) {
      _queuedInviteDeepLinkCode = inviteCode;
      return;
    }

    final now = DateTime.now();
    final lastCode = _lastProcessedInviteDeepLinkCode;
    final lastAt = _lastProcessedInviteDeepLinkAt;
    if (lastCode == inviteCode &&
        lastAt != null &&
        now.difference(lastAt) < const Duration(seconds: 3)) {
      return;
    }
    _lastProcessedInviteDeepLinkCode = inviteCode;
    _lastProcessedInviteDeepLinkAt = now;
    _isProcessingInviteDeepLink = true;

    try {
      final preview = await widget.tripsController.previewTripInvite(
        inviteToken: inviteCode,
      );
      if (!mounted) {
        return;
      }

      final confirmed = await _showInviteJoinConfirmDialog(preview);
      if (!mounted || !confirmed) {
        return;
      }

      final joined = await widget.tripsController.joinTripInvite(
        inviteToken: inviteCode,
        previewNonce: preview.previewNonce,
      );
      if (!mounted) {
        return;
      }

      Trip resolvedTrip = joined.trip;
      try {
        final refreshedTrips = await widget.tripsController.loadTrips(
          forceRefresh: true,
        );
        if (!mounted) {
          return;
        }
        for (final trip in refreshedTrips) {
          if (trip.id == joined.trip.id) {
            resolvedTrip = trip;
            break;
          }
        }
      } catch (_) {
        // Keep fallback trip from join payload when reload fails.
      }

      if (!mounted) {
        return;
      }
      _showSnack(
        joined.alreadyMember
            ? context.l10n.shellTripAlreadyInListOpened
            : context.l10n.shellJoinedTripFromInviteLink,
        isError: false,
      );
      _openWorkspaceInShell(resolvedTrip);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.trim();
      _showSnack(
        message.isNotEmpty ? message : context.l10n.shellFailedToOpenInviteLink,
        isError: true,
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.shellFailedToOpenInviteLink, isError: true);
    } finally {
      _isProcessingInviteDeepLink = false;
      final queued = _queuedInviteDeepLinkCode;
      _queuedInviteDeepLinkCode = null;
      if (queued != null &&
          queued.isNotEmpty &&
          queued != inviteCode &&
          mounted) {
        unawaited(_handleInviteDeepLinkCode(queued));
      }
    }
  }

  Future<bool> _showInviteJoinConfirmDialog(TripInvitePreview preview) async {
    final inviterName = preview.inviterName.trim();
    final tripName = preview.tripName.trim().isNotEmpty
        ? preview.tripName.trim()
        : context.l10n.tripTitleShort;
    final inviterLabel = inviterName.isNotEmpty
        ? inviterName
        : context.l10n.unknownLabel;

    final message = preview.alreadyMember
        ? context.l10n.shellInviteAlreadyMemberOpenTripNow(
            tripName,
            inviterLabel,
          )
        : context.l10n.shellInviteJoinTripQuestion(tripName, inviterLabel);

    final decision = await showAppConfirmationDialog(
      context: context,
      title: context.l10n.shellTripInviteTitle,
      message: message,
      confirmLabel: context.l10n.shellYesAction,
      cancelLabel: context.l10n.shellNoAction,
      icon: Icons.group_add_outlined,
    );

    return decision;
  }

  bool _hasOnlineConnectivity(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> _flushWorkspaceQueueBestEffort() async {
    if (_isFlushingWorkspaceQueue || _isLoggingOut) {
      return;
    }
    _isFlushingWorkspaceQueue = true;
    try {
      await widget.workspaceController.flushPendingMutations();
    } catch (_) {
      // Queue flush is best-effort and must never block UI flow.
    } finally {
      _isFlushingWorkspaceQueue = false;
    }
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
