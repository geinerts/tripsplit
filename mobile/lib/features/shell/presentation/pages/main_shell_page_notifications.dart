part of 'main_shell_page.dart';

extension _MainShellPageNotifications on _MainShellPageState {
  String _txt({required String en, required String lv}) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'lv' ? lv : en;
  }

  bool _isFriendNotificationType(String rawType) {
    final type = rawType.trim().toLowerCase();
    return type == 'friend_invite' ||
        type == 'friend_invite_accepted' ||
        type == 'friend_invite_rejected';
  }

  Future<void> _refreshGlobalNotifications({
    bool showErrorSnack = false,
  }) async {
    if (_isLoggingOut || _isNotificationsLoading) {
      return;
    }
    _isNotificationsLoading = true;
    try {
      final previousUnread = _unreadNotificationsCount;
      final inbox = await widget.workspaceController.loadGlobalNotifications(
        limit: 40,
      );
      if (!mounted) {
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
        _globalNotifications = inbox.notifications;
        _globalNotificationsHasMore = inbox.hasMore;
        _globalNotificationsNextCursor = inbox.nextCursor;
        _globalNotificationsNextOffset = inbox.nextOffset;
      });
    } on ApiException catch (error) {
      if (!mounted || !showErrorSnack) {
        return;
      }
      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : _txt(
              en: 'Failed to load notifications.',
              lv: 'Neizdevās ielādēt paziņojumus.',
            );
      _showSnack(message, isError: true);
    } catch (_) {
      if (!mounted || !showErrorSnack) {
        return;
      }
      _showSnack(
        _txt(
          en: 'Failed to load notifications.',
          lv: 'Neizdevās ielādēt paziņojumus.',
        ),
        isError: true,
      );
    } finally {
      _isNotificationsLoading = false;
    }
  }

  void _maybeShowForegroundNotificationHint({
    required int previousUnread,
    required WorkspaceNotificationsInbox inbox,
  }) {
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
    for (final item in _sortNotifications(inbox.notifications)) {
      if (!item.isRead) {
        newestUnread = item;
        break;
      }
    }
    if (newestUnread == null) {
      return;
    }

    final title = newestUnread.title.trim();
    if (title.isEmpty) {
      return;
    }

    _lastUnreadNotificationHintAt = now;
    _showSnack(
      _txt(en: 'New notification: $title', lv: 'Jauns paziņojums: $title'),
      isError: false,
    );
  }

  Future<void> _loadMoreGlobalNotifications({
    required VoidCallback onUpdated,
  }) async {
    if (_isLoggingOut ||
        _isNotificationsLoading ||
        _isNotificationsLoadingMore ||
        !_globalNotificationsHasMore) {
      return;
    }

    _isNotificationsLoadingMore = true;
    onUpdated();
    try {
      final inbox = await widget.workspaceController.loadGlobalNotifications(
        limit: 40,
        cursor: _globalNotificationsNextCursor,
        offset: _globalNotificationsNextCursor == null
            ? _globalNotificationsNextOffset
            : null,
      );
      if (!mounted) {
        return;
      }
      final seenIds = _globalNotifications.map((item) => item.id).toSet();
      final merged = <WorkspaceNotification>[..._globalNotifications];
      for (final item in inbox.notifications) {
        if (seenIds.add(item.id)) {
          merged.add(item);
        }
      }

      _updateState(() {
        _unreadNotificationsCount = inbox.unreadCount < 0
            ? 0
            : inbox.unreadCount;
        _globalNotifications = merged;
        _globalNotificationsHasMore = inbox.hasMore;
        _globalNotificationsNextCursor = inbox.nextCursor;
        _globalNotificationsNextOffset = inbox.nextOffset;
      });
    } catch (_) {
      // Keep silent in manual load-more to avoid noisy UX.
    } finally {
      _isNotificationsLoadingMore = false;
      if (mounted) {
        onUpdated();
      }
    }
  }

  Future<void> _onNotificationsPressed() async {
    if (_isLoggingOut) {
      return;
    }
    await _refreshGlobalNotifications(showErrorSnack: true);
    if (!mounted) {
      return;
    }
    await _showNotificationsSheet();
  }

  Future<void> _markGlobalNotificationsRead({
    List<int> notificationIds = const <int>[],
    bool markAll = false,
    bool showErrorSnack = true,
  }) async {
    final ids = notificationIds
        .where((id) => id > 0)
        .toSet()
        .toList(growable: false);
    if (!markAll && ids.isEmpty) {
      return;
    }

    try {
      final unreadCount = await widget.workspaceController
          .markGlobalNotificationsRead(
            notificationIds: markAll ? const <int>[] : ids,
          );
      if (!mounted) {
        return;
      }

      final readIdSet = markAll
          ? _globalNotifications
                .where((item) => item.id > 0)
                .map((item) => item.id)
                .toSet()
          : ids.toSet();

      final updatedNotifications = _globalNotifications
          .map((item) {
            if (item.isRead || !readIdSet.contains(item.id)) {
              return item;
            }
            return WorkspaceNotification(
              id: item.id,
              tripId: item.tripId,
              tripName: item.tripName,
              type: item.type,
              title: item.title,
              body: item.body,
              isRead: true,
              createdAt: item.createdAt,
            );
          })
          .toList(growable: false);

      _updateState(() {
        _unreadNotificationsCount = unreadCount < 0 ? 0 : unreadCount;
        _globalNotifications = updatedNotifications;
      });
      unawaited(_refreshGlobalNotifications(showErrorSnack: false));
    } on ApiException catch (error) {
      if (!mounted || !showErrorSnack) {
        return;
      }
      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : _txt(
              en: 'Failed to update notifications.',
              lv: 'Neizdevās atjaunot paziņojumus.',
            );
      _showSnack(message, isError: true);
    } catch (_) {
      if (!mounted || !showErrorSnack) {
        return;
      }
      _showSnack(
        _txt(
          en: 'Failed to update notifications.',
          lv: 'Neizdevās atjaunot paziņojumus.',
        ),
        isError: true,
      );
    }
  }

  Widget _buildNotificationSectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  List<WorkspaceNotification> _sortNotifications(
    List<WorkspaceNotification> source,
  ) {
    final sorted = source.toList(growable: false)
      ..sort((a, b) {
        final aTime =
            DateTime.tryParse(a.createdAt ?? '')?.millisecondsSinceEpoch ?? 0;
        final bTime =
            DateTime.tryParse(b.createdAt ?? '')?.millisecondsSinceEpoch ?? 0;
        if (aTime != bTime) {
          return bTime.compareTo(aTime);
        }
        return b.id.compareTo(a.id);
      });
    return sorted;
  }

  Widget _buildNotificationTile(
    BuildContext context,
    BuildContext sheetContext,
    WorkspaceNotification notification,
  ) {
    final t = context.l10n;
    final title = notification.title.trim().isNotEmpty
        ? notification.title.trim()
        : t.notificationFallbackTitle;
    final body = notification.body.trim();
    final tripName = notification.tripName?.trim() ?? '';
    final createdAtLabel = _formatNotificationTime(notification.createdAt);
    final isFriendNotification = _isFriendNotificationType(notification.type);
    final metaParts = <String>[
      if (!isFriendNotification &&
          tripName.isNotEmpty &&
          notification.tripId > 0)
        tripName,
      if (createdAtLabel.isNotEmpty) createdAtLabel,
    ];
    final metaText = metaParts.join(' • ');
    final isUnread = !notification.isRead;
    IconData icon = Icons.notifications_none_outlined;
    if (notification.type == 'friend_invite') {
      icon = Icons.person_add_alt_1_outlined;
    } else if (notification.type == 'friend_invite_accepted') {
      icon = Icons.how_to_reg_outlined;
    } else if (notification.type == 'friend_invite_rejected') {
      icon = Icons.person_off_outlined;
    } else if (notification.type == 'expense_added') {
      icon = Icons.receipt_long_outlined;
    } else if (notification.type == 'trip_finished') {
      icon = Icons.flag_outlined;
    } else if (notification.type == 'settlement_reminder') {
      icon = Icons.notifications_active_outlined;
    } else if (notification.type == 'member_ready_to_settle') {
      icon = Icons.person_pin_circle_outlined;
    } else if (notification.type == 'trip_ready_to_settle') {
      icon = Icons.task_alt_outlined;
    } else if (notification.type == 'trip_added' ||
        notification.type == 'trip_member_added') {
      icon = Icons.group_add_outlined;
    } else if (isUnread) {
      icon = Icons.notifications_active_outlined;
    }

    return ListTile(
      leading: Icon(icon),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: isUnread ? FontWeight.w700 : null),
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
        ],
      ),
      subtitle: (body.isEmpty && metaText.isEmpty)
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (body.isNotEmpty)
                  Text(body, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (metaText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      metaText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
      onTap: () {
        if (!notification.isRead && notification.id > 0) {
          unawaited(
            _markGlobalNotificationsRead(
              notificationIds: [notification.id],
              showErrorSnack: false,
            ),
          );
        }
        Navigator.of(sheetContext).pop();
        unawaited(_openTripFromNotification(notification));
      },
    );
  }

  Future<void> _showNotificationsSheet() async {
    final t = context.l10n;
    const initialEarlierVisibleCount = 5;
    var earlierVisibleCount = initialEarlierVisibleCount;
    var isSheetActive = true;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final sorted = _sortNotifications(_globalNotifications);
            final newNotifications = sorted
                .where((item) => !item.isRead)
                .toList(growable: false);
            final earlierNotifications = sorted
                .where((item) => item.isRead)
                .toList(growable: false);
            final visibleEarlierCount =
                earlierVisibleCount < earlierNotifications.length
                ? earlierVisibleCount
                : earlierNotifications.length;
            final visibleEarlier = earlierNotifications
                .take(visibleEarlierCount)
                .toList(growable: false);
            final hasMoreEarlierHidden =
                earlierNotifications.length > visibleEarlier.length;
            final canMarkAllRead = newNotifications.any((item) => item.id > 0);

            return SafeArea(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 620),
                child: sorted.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(t.noNotificationsYet),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 12),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.notificationsTitle,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                TextButton(
                                  onPressed:
                                      (!canMarkAllRead ||
                                          _isNotificationsLoading)
                                      ? null
                                      : () async {
                                          await _markGlobalNotificationsRead(
                                            markAll: true,
                                            showErrorSnack: true,
                                          );
                                          if (!mounted || !isSheetActive) {
                                            return;
                                          }
                                          setSheetState(() {});
                                        },
                                  child: Text(
                                    _txt(
                                      en: 'Mark all as read',
                                      lv: 'Atzīmēt visu kā lasītu',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (newNotifications.isNotEmpty) ...[
                            _buildNotificationSectionHeader(
                              context,
                              _txt(en: 'New', lv: 'Jaunie'),
                            ),
                            ...newNotifications.map(
                              (item) => _buildNotificationTile(
                                context,
                                sheetContext,
                                item,
                              ),
                            ),
                          ],
                          if (earlierNotifications.isNotEmpty) ...[
                            _buildNotificationSectionHeader(
                              context,
                              _txt(en: 'Earlier', lv: 'Iepriekšējie'),
                            ),
                            ...visibleEarlier.map(
                              (item) => _buildNotificationTile(
                                context,
                                sheetContext,
                                item,
                              ),
                            ),
                            if (hasMoreEarlierHidden)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  6,
                                  16,
                                  0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      setSheetState(() {
                                        earlierVisibleCount += 10;
                                      });
                                    },
                                    child: Text(
                                      _txt(
                                        en: 'Show more earlier',
                                        lv: 'Rādīt vairāk iepriekšējos',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                          if (_globalNotificationsHasMore)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                              child: OutlinedButton(
                                onPressed: _isNotificationsLoadingMore
                                    ? null
                                    : () async {
                                        await _loadMoreGlobalNotifications(
                                          onUpdated: () {
                                            if (isSheetActive) {
                                              setSheetState(() {});
                                            }
                                          },
                                        );
                                        if (!mounted || !isSheetActive) {
                                          return;
                                        }
                                        setSheetState(() {});
                                      },
                                child: Text(
                                  _isNotificationsLoadingMore
                                      ? _txt(
                                          en: 'Loading more...',
                                          lv: 'Ielādē vēl...',
                                        )
                                      : _txt(
                                          en: 'Load more notifications',
                                          lv: 'Ielādēt vēl paziņojumus',
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      isSheetActive = false;
    });
  }

  Future<void> _openTripFromNotification(
    WorkspaceNotification notification,
  ) async {
    if (!mounted) {
      return;
    }
    if (_isFriendNotificationType(notification.type)) {
      if (_selectedTabIndex != _MainShellPageState._tabFriends ||
          _isWorkspaceOpen) {
        _updateState(() {
          _selectedTabIndex = _MainShellPageState._tabFriends;
          _openedTrip = null;
        });
      }
      _friendsCommandController.requestRefresh();
      return;
    }

    final tripId = notification.tripId;
    if (tripId <= 0) {
      return;
    }

    if (_openedTrip != null && _openedTrip!.id == tripId) {
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
        _showSnack(
          _txt(
            en: 'This trip is no longer available.',
            lv: 'Šis ceļojums vairs nav pieejams.',
          ),
          isError: true,
        );
        return;
      }
      _openWorkspaceInShell(target);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      final message = error.message.trim().isNotEmpty
          ? error.message.trim()
          : _txt(en: 'Failed to open trip.', lv: 'Neizdevās atvērt ceļojumu.');
      _showSnack(message, isError: true);
    } catch (_) {
      if (mounted) {
        _showSnack(
          _txt(en: 'Failed to open trip.', lv: 'Neizdevās atvērt ceļojumu.'),
          isError: true,
        );
      }
    }
  }

  String _formatNotificationTime(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) {
      return '';
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      return '';
    }

    final local = parsed.toLocal();
    final now = DateTime.now();
    final nowDate = DateTime(now.year, now.month, now.day);
    final valueDate = DateTime(local.year, local.month, local.day);
    final dayDiff = nowDate.difference(valueDate).inDays;

    if (dayDiff == 0) {
      final hh = local.hour.toString().padLeft(2, '0');
      final mm = local.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    if (dayDiff == 1) {
      return _txt(en: 'Yesterday', lv: 'Vakar');
    }

    final dd = local.day.toString().padLeft(2, '0');
    final mon = local.month.toString().padLeft(2, '0');
    if (local.year == now.year) {
      return '$dd.$mon';
    }
    return '$dd.$mon.${local.year}';
  }
}
