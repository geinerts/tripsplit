part of 'main_shell_page.dart';

extension _MainShellPageNotifications on _MainShellPageState {
  String _txt({required String en, required String lv}) {
    final code = Localizations.localeOf(context).languageCode.toLowerCase();
    return code == 'lv' ? lv : en;
  }

  Future<void> _refreshGlobalNotifications({
    bool showErrorSnack = false,
  }) async {
    if (_isLoggingOut || _isNotificationsLoading) {
      return;
    }
    _isNotificationsLoading = true;
    try {
      final inbox = await widget.workspaceController.loadGlobalNotifications(
        limit: 40,
      );
      if (!mounted) {
        return;
      }
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
      final seenIds = _globalNotifications
          .map((item) => item.id)
          .toSet();
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
      // Keep silent in scroll loading to avoid noisy UX.
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
    if (!mounted) {
      return;
    }

    final unreadIds = _globalNotifications
        .where((item) => !item.isRead && item.id > 0)
        .map((item) => item.id)
        .toList(growable: false);
    if (unreadIds.isEmpty) {
      return;
    }

    try {
      final unreadCount = await widget.workspaceController
          .markGlobalNotificationsRead(notificationIds: unreadIds);
      if (!mounted) {
        return;
      }
      _updateState(() {
        _unreadNotificationsCount = unreadCount < 0 ? 0 : unreadCount;
      });
      unawaited(_refreshGlobalNotifications(showErrorSnack: false));
    } on ApiException catch (error) {
      if (!mounted) {
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
      if (mounted) {
        _showSnack(
          _txt(
            en: 'Failed to update notifications.',
            lv: 'Neizdevās atjaunot paziņojumus.',
          ),
          isError: true,
        );
      }
    }
  }

  Future<void> _showNotificationsSheet() async {
    final t = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final sorted = _globalNotifications.toList(growable: false)
              ..sort((a, b) {
                final aTime =
                    DateTime.tryParse(a.createdAt ?? '')
                        ?.millisecondsSinceEpoch ??
                    0;
                final bTime =
                    DateTime.tryParse(b.createdAt ?? '')
                        ?.millisecondsSinceEpoch ??
                    0;
                if (aTime != bTime) {
                  return bTime.compareTo(aTime);
                }
                return b.id.compareTo(a.id);
              });
            final hasFooter = _globalNotificationsHasMore;

            return SafeArea(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 560),
                child: sorted.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(t.noNotificationsYet),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (notification.metrics.pixels <
                              notification.metrics.maxScrollExtent - 180) {
                            return false;
                          }
                          if (_isNotificationsLoadingMore ||
                              !_globalNotificationsHasMore) {
                            return false;
                          }
                          unawaited(
                            _loadMoreGlobalNotifications(
                              onUpdated: () {
                                if (Navigator.of(sheetContext).mounted) {
                                  setSheetState(() {});
                                }
                              },
                            ),
                          );
                          return false;
                        },
                        child: ListView.separated(
                          itemCount: sorted.length + (hasFooter ? 1 : 0),
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            if (hasFooter && index == sorted.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isNotificationsLoadingMore)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    if (_isNotificationsLoadingMore)
                                      const SizedBox(width: 8),
                                    Text(
                                      _isNotificationsLoadingMore
                                          ? _txt(
                                              en: 'Loading more...',
                                              lv: 'Ielādē vēl...',
                                            )
                                          : _txt(
                                              en: 'Scroll for more',
                                              lv: 'Ritini, lai ielādētu vairāk',
                                            ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final notification = sorted[index];
                            final title = notification.title.trim().isNotEmpty
                                ? notification.title.trim()
                                : t.notificationFallbackTitle;
                            final body = notification.body.trim();
                            final tripName = notification.tripName?.trim() ?? '';
                            final createdAtLabel = _formatNotificationTime(
                              notification.createdAt,
                            );
                            final metaParts = <String>[
                              if (tripName.isNotEmpty && notification.tripId > 0)
                                tripName,
                              if (createdAtLabel.isNotEmpty) createdAtLabel,
                            ];
                            final metaText = metaParts.join(' • ');
                            final isUnread = !notification.isRead;
                            IconData icon = Icons.notifications_none_outlined;
                            if (notification.type == 'friend_invite') {
                              icon = Icons.person_add_alt_1_outlined;
                            } else if (notification.type == 'expense_added') {
                              icon = Icons.receipt_long_outlined;
                            } else if (notification.type == 'trip_added' ||
                                notification.type == 'trip_member_added') {
                              icon = Icons.group_add_outlined;
                            } else if (isUnread) {
                              icon = Icons.notifications_active_outlined;
                            }
                            return ListTile(
                              leading: Icon(icon),
                              title: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: isUnread ? FontWeight.w700 : null,
                                ),
                              ),
                              subtitle: (body.isEmpty && metaText.isEmpty)
                                  ? null
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (body.isNotEmpty)
                                          Text(
                                            body,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        if (metaText.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(
                                              metaText,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                          ),
                                      ],
                                    ),
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                unawaited(_openTripFromNotification(notification));
                              },
                            );
                          },
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openTripFromNotification(
    WorkspaceNotification notification,
  ) async {
    if (!mounted) {
      return;
    }
    if (notification.type == 'friend_invite') {
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
