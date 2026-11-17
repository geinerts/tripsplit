part of 'main_shell_page.dart';

extension _MainShellPageNotifications on _MainShellPageState {
  bool _inAppCategoryEnabledForType(String rawType) {
    final type = rawType.trim().toLowerCase();
    final prefs = widget.authController.notificationPreferences;
    if (!prefs.inAppBannerEnabled) {
      return false;
    }
    if (type == 'expense_added' || type == 'quick_split_added') {
      return prefs.inAppExpenseAddedEnabled;
    }
    if (type == 'expense_comment_mention' ||
        type == 'expense_comment_added' ||
        type == 'live_location_started' ||
        type == 'trip_starts_tomorrow') {
      return prefs.inAppTripUpdatesEnabled;
    }
    if (type == 'friend_invite' || type == 'friend_invite_received') {
      return prefs.inAppFriendInviteReceivedEnabled;
    }
    if (type == 'friend_invite_accepted') {
      return prefs.inAppFriendInviteAcceptedEnabled;
    }
    if (type == 'trip_added' || type == 'trip_invitation') {
      return prefs.inAppTripAddedEnabled;
    }
    if (type == 'trip_member_added') {
      return prefs.inAppTripMemberAddedEnabled;
    }
    if (type == 'trip_finished') {
      return prefs.inAppTripFinishedEnabled;
    }
    if (type == 'member_ready_to_settle') {
      return prefs.inAppMemberReadyToSettleEnabled;
    }
    if (type == 'trip_ready_to_settle') {
      return prefs.inAppTripReadyToSettleEnabled;
    }
    if (type == 'settlement_reminder') {
      return prefs.inAppSettlementReminderEnabled;
    }
    if (type == 'settlement_auto_reminder') {
      return prefs.inAppSettlementAutoReminderEnabled;
    }
    if (type == 'settlement_sent') {
      return prefs.inAppSettlementSentEnabled;
    }
    if (type == 'settlement_confirmed') {
      return prefs.inAppSettlementConfirmedEnabled;
    }
    return true;
  }

  Future<void> _refreshGlobalNotifications({
    bool showErrorSnack = false,
  }) async {
    if (_isLoggingOut ||
        _isNotificationsLoading ||
        _notificationsSheetOpen ||
        _isMarkingNotifications) {
      return;
    }
    final generation = ++_notificationsGeneration;
    final account = widget.authController.currentUser?.id;
    _isNotificationsLoading = true;
    try {
      _tripsCommandController.requestInvitationsRefresh();
      final previousUnread = _unreadNotificationsCount;
      final inbox = await widget.workspaceController.loadGlobalNotifications(
        limit: 40,
      );
      if (!mounted ||
          generation != _notificationsGeneration ||
          account != widget.authController.currentUser?.id) {
        return;
      }
      _maybeShowForegroundNotificationHint(
        previousUnread: previousUnread,
        inbox: inbox,
      );
      _updateState(() {
        _unreadNotificationsCount = inbox.unreadCount < 0
            ? 0
            : inbox.unreadCount;
      });
    } on ApiException catch (error) {
      if (!mounted || !showErrorSnack) {
        return;
      }
      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : context.l10n.shellFailedToLoadNotifications;
      _showSnack(message, isError: true);
    } catch (_) {
      if (!mounted || !showErrorSnack) {
        return;
      }
      _showSnack(context.l10n.shellFailedToLoadNotifications, isError: true);
    } finally {
      _isNotificationsLoading = false;
    }
  }

  void _maybeShowForegroundNotificationHint({
    required int previousUnread,
    required WorkspaceNotificationsInbox inbox,
  }) {
    if (inbox.isCached ||
        !widget.authController.notificationPreferences.inAppBannerEnabled) {
      return;
    }

    final nextUnread = inbox.unreadCount < 0 ? 0 : inbox.unreadCount;
    if (!_notificationsPrimed) {
      _notificationsPrimed = true;
      return;
    }
    if (!_isAppInForeground || nextUnread <= previousUnread) {
      return;
    }

    final now = DateTime.now();
    final last = _lastUnreadNotificationHintAt;
    if (last != null && now.difference(last) < const Duration(seconds: 12)) {
      return;
    }

    WorkspaceNotification? newestUnread;
    for (final item in sortNotifications(inbox.notifications)) {
      if (!item.isRead && _inAppCategoryEnabledForType(item.type)) {
        newestUnread = item;
        break;
      }
    }
    if (newestUnread == null) {
      return;
    }

    final localized = localizeWorkspaceNotification(context, newestUnread);
    final title = localized.title.trim();
    if (title.isEmpty) {
      return;
    }

    _lastUnreadNotificationHintAt = now;
    _showSnack(context.l10n.shellNewNotificationTitle(title), isError: false);
  }

  Future<void> _onNotificationsPressed() async {
    if (_isLoggingOut || _notificationsSheetOpen) return;
    final account = widget.authController.currentUser?.id;
    if (account == null) return;
    _notificationsSheetOpen = true;
    _notificationsGeneration++;
    WorkspaceNotification? selected;
    try {
      selected = await showAppBottomSheet<WorkspaceNotification>(
        context: context,
        useSafeArea: false,
        builder: (_) => NotificationsSheet(
          controller: widget.workspaceController,
          isAccountCurrent: () =>
              mounted &&
              !_isLoggingOut &&
              widget.authController.currentUser?.id == account,
          onUnreadCount: (count) {
            if (mounted && widget.authController.currentUser?.id == account) {
              _updateState(() => _unreadNotificationsCount = count);
            }
          },
          onAnswer: _answerNotification,
        ),
      );
    } finally {
      _notificationsSheetOpen = false;
    }
    if (!mounted ||
        _isLoggingOut ||
        widget.authController.currentUser?.id != account) {
      return;
    }
    if (selected != null) {
      if (!selected.isRead && selected.id > 0) {
        unawaited(_markNotificationRead(selected.id));
      }
      await _openTripFromNotification(selected);
    } else {
      unawaited(_refreshGlobalNotifications());
    }
  }

  Future<void> _markNotificationRead(int id) async {
    final account = widget.authController.currentUser?.id;
    final generation = ++_notificationsGeneration;
    _isMarkingNotifications = true;
    try {
      final count = await widget.workspaceController
          .markGlobalNotificationsRead(notificationIds: [id]);
      if (mounted &&
          generation == _notificationsGeneration &&
          !_isLoggingOut &&
          widget.authController.currentUser?.id == account) {
        _updateState(() => _unreadNotificationsCount = count < 0 ? 0 : count);
      }
    } catch (_) {
      // Opening a destination remains possible if marking the item fails.
    } finally {
      _isMarkingNotifications = false;
    }
  }

  /// ✕ or ✓ in the bell list: the same actions as on Settle, Friends and the
  /// invitation page. Joining a trip goes through its preview instead.
  Future<void> _answerNotification(
    WorkspaceNotification item,
    bool accept,
  ) async {
    final workspace = widget.workspaceController;
    switch (notificationAnswerKind(item)) {
      case NotificationAnswerKind.payment:
        final paymentId = item.refs['payment_id']!;
        accept
            ? await workspace.confirmTripPaymentReceived(
                tripId: item.tripId,
                paymentId: paymentId,
              )
            : await workspace.reportTripPaymentNotReceived(
                tripId: item.tripId,
                paymentId: paymentId,
              );
      case NotificationAnswerKind.settlement:
        final settlementId = item.refs['settlement_id']!;
        accept
            ? await workspace.confirmSettlementReceived(
                tripId: item.tripId,
                settlementId: settlementId,
              )
            : await workspace.reportSettlementNotReceived(
                tripId: item.tripId,
                settlementId: settlementId,
              );
      case NotificationAnswerKind.friend:
        await widget.friendsController.respondInvite(
          requestId: item.refs['request_id']!,
          accept: accept,
        );
        _friendsCommandController.requestRefresh();
      case NotificationAnswerKind.tripInvitation:
        if (accept) return;
        await widget.tripsController.declineTripInvite(
          inviteToken: item.inviteToken!,
        );
        _tripsCommandController.requestInvitationsRefresh();
      case null:
        return;
    }
    if (!mounted) return;
    if (item.id > 0 && !item.isRead) unawaited(_markNotificationRead(item.id));
    if (_openedTrip?.id == item.tripId) {
      _workspaceCommandController.requestRefresh();
    }
  }

  /// The bell list opens the same place as the push for this notification.
  Future<void> _openTripFromNotification(
    WorkspaceNotification notification,
  ) async {
    if (!mounted) {
      return;
    }
    final expenseId = notification.expenseId;
    final inviteToken = notification.inviteToken;
    await _openDestination(
      PushTapDestination.of(
        PushTap(
          type: notification.type.trim().toLowerCase(),
          tripId: notification.tripId,
          values: {
            'expense_id': ?expenseId?.toString(),
            'invite_token': ?inviteToken,
          },
        ),
      ),
    );
  }

  void _bindPushTaps() {
    unawaited(() async {
      final launchTap = await PushTapChannel.listen(this, (tap) {
        if (mounted) unawaited(_openFromPush(tap));
      });
      if (launchTap == null) return;
      // The tap that opened the app: wait for the first frame of the shell.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_openFromPush(launchTap));
      });
    }());
  }

  /// Opens what a tapped push is about, like the bell list does.
  Future<void> _openFromPush(PushTap tap) async {
    if (_isLoggingOut || widget.authController.currentUser == null) return;
    unawaited(_refreshGlobalNotifications());
    await _openDestination(PushTapDestination.of(tap));
  }

  Future<void> _openDestination(PushTapDestination destination) async {
    switch (destination) {
      case PushOpenInvitation(:final inviteToken):
        await _handleInviteDeepLinkCode(inviteToken);
      case PushOpenFriends():
        _updateState(() {
          _selectedTabIndex = _MainShellPageState._tabFriends;
          _openedTrip = null;
          _openAddExpenseOnWorkspaceStart = false;
          _workspaceExpenseDraft = null;
          _workspaceFocus = null;
        });
        _friendsCommandController.requestRefresh();
      case PushOpenQuickSplits():
        _showHomeQuickSplits(refresh: true);
      case PushOpenTrip(:final tripId, :final focus):
        await _openTripById(tripId, focus: focus);
      case PushOpenNothing():
        break;
    }
  }

  /// Opens a trip from the server's list; [focus] opens Settle, an expense
  /// or the map inside it.
  Future<void> _openTripById(int tripId, {WorkspaceFocus? focus}) async {
    if (tripId <= 0) {
      return;
    }

    if (focus == null && _openedTrip != null && _openedTrip!.id == tripId) {
      return;
    }

    try {
      final trips = await widget.tripsController.loadTrips(forceRefresh: true);
      if (!mounted) {
        return;
      }
      Trip? target;
      for (final trip in trips) {
        if (trip.id == tripId) {
          target = trip;
          break;
        }
      }
      if (target == null) {
        _showSnack(context.l10n.shellTripNoLongerAvailable, isError: true);
        return;
      }
      _openWorkspaceInShell(target, focus: focus);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : context.l10n.shellFailedToOpenTrip;
      _showSnack(message, isError: true);
    } catch (_) {
      if (mounted) {
        _showSnack(context.l10n.shellFailedToOpenTrip, isError: true);
      }
    }
  }
}
