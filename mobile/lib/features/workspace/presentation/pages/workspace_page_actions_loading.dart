part of 'workspace_page.dart';

extension _WorkspacePageLoadingActions on _WorkspacePageState {
  Future<void> _runStartupAddExpenseFlow() async {
    await _onAddExpensePressed();
    if (!mounted) {
      return;
    }
    _updateState(() {
      _isStartingWithAddExpense = false;
    });
  }

  Future<void> _loadData({required bool showLoader}) async {
    final generation = ++_loadGeneration;
    ++_activityGeneration;
    _isLoadingActivity = false;
    final tripId = widget.trip.id;
    bool current() =>
        mounted && generation == _loadGeneration && tripId == widget.trip.id;
    final trace = PerfMonitor.start('screen.workspace.load');
    var success = false;
    _updateState(() {
      _isLoading = _snapshot == null;
      _errorText = null;
      _refreshError = null;
      _syncState = _SyncState.syncing;
    });
    try {
      if (_snapshot == null && _mayUseWorkspaceCache) {
        try {
          final cached = await widget.workspaceController.readCachedSnapshot(
            tripId: tripId,
          );
          if (!current()) return;
          if (cached != null) {
            _updateState(() {
              _snapshot = cached;
              _expensesFeed = cached.expenses;
              _isLoading = false;
            });
          }
        } catch (_) {
          // A failed cache read is not a successful empty/server response.
        }
      }
      final snapshot = await widget.workspaceController
          .refreshSnapshotFromServer(tripId: tripId);
      if (!current()) return;
      final queue = await widget.workspaceController.listQueuedMutations(
        tripId: tripId,
      );
      var userId = _currentUserId;
      try {
        userId = await widget.workspaceController.loadCurrentUserId();
      } on ApiException catch (error) {
        if (!error.isNetworkError) rethrow;
      }
      if (!current()) return;
      final memberIds = snapshot.users.map((user) => user.id).toSet();
      _updateState(() {
        _currentUserId = userId;
        _pendingQueueCount = queue.length;
        _queuedMutations = queue;
        _syncState = queue.isEmpty ? _SyncState.online : _SyncState.onlineQueue;
        _snapshot = snapshot;
        _mayUseWorkspaceCache = true;
        _workspaceOffline = false;
        _expensesFeed = snapshot.expenses;
        _reconcileExpenseSocialPreviewState(snapshot.expenses);
        _expensesHasMore = false;
        _isLoadingMoreExpenses = false;
        _expensesNextCursor = null;
        _expensesNextOffset = null;
        _randomSelection = _normalizeRandomSelection(memberIds);
        if (!memberIds.contains(_expenseFilterUserId)) _expenseFilterUserId = 0;
      });
      unawaited(_primeExpensesFeed());
      if (!widget.trip.isSolo && (_activityLoaded || _workspaceTabIndex == 3)) {
        unawaited(_loadTripActivity(reset: true));
      }
      success = true;
    } on ApiException catch (error) {
      if (!current()) return;
      _workspaceOffline = error.isNetworkError;
      final denied =
          error.statusCode == 401 ||
          error.statusCode == 403 ||
          error.statusCode == 404 ||
          error.code == 'account_changed';
      _updateState(() {
        if (denied) {
          _snapshot = null;
          _expensesFeed = const [];
          _activityEvents = const [];
          _activityLoaded = false;
          _activityError = null;
          _activityHasMore = false;
          _activityNextOffset = null;
          _queuedMutations = const [];
          _pendingQueueCount = 0;
          _mayUseWorkspaceCache = false;
          _reconcileExpenseSocialPreviewState(const []);
        }
        _syncState = _pendingQueueCount > 0
            ? _SyncState.offlineQueue
            : _SyncState.offline;
        if (_snapshot == null) {
          _errorText = error.message;
        } else {
          _refreshError = error.message;
        }
      });
      if (error.isNetworkError && _snapshot != null) {
        try {
          final queue = await widget.workspaceController.listQueuedMutations(
            tripId: tripId,
          );
          if (!current()) return;
          _updateState(() {
            _queuedMutations = queue;
            _pendingQueueCount = queue.length;
            _syncState = queue.isEmpty
                ? _SyncState.offline
                : _SyncState.offlineQueue;
          });
        } catch (_) {
          /* Retain the last known queue on a local read failure. */
        }
      }
    } catch (_) {
      if (!current()) return;
      _workspaceOffline = false;
      _updateState(() {
        _syncState = _pendingQueueCount > 0
            ? _SyncState.offlineQueue
            : _SyncState.offline;
        if (_snapshot == null) {
          _errorText = context.l10n.unexpectedErrorLoadingTripData;
        } else {
          _refreshError = context.l10n.unexpectedErrorLoadingTripData;
        }
      });
    } finally {
      trace.stop(success: success);
      if (current()) {
        _updateState(() => _isLoading = false);
        if (_openAddExpenseAfterLoad &&
            _snapshot != null &&
            (success || _refreshError != null)) {
          _openAddExpenseAfterLoad = false;
          unawaited(_runStartupAddExpenseFlow());
        } else if (_snapshot == null) {
          _openAddExpenseAfterLoad = false;
          _updateState(() => _isStartingWithAddExpense = false);
        }
      }
    }
  }

  Future<void> _primeExpensesFeed() async {
    final generation = _loadGeneration;
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }
    try {
      final page = await widget.workspaceController.loadExpensesPage(
        tripId: widget.trip.id,
        limit: 50,
      );
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      _updateState(() {
        _expensesFeed = page.items;
        _reconcileExpenseSocialPreviewState(page.items);
        _expensesHasMore = page.hasMore;
        _expensesNextCursor = page.nextCursor;
        _expensesNextOffset = page.nextOffset;
      });
    } catch (_) {
      // Keep snapshot fallback data when paged endpoint is not reachable.
    }
  }

  Future<void> _loadMoreExpensesPage() async {
    final generation = _loadGeneration;
    if (_isLoadingMoreExpenses || !_expensesHasMore) {
      return;
    }
    _updateState(() {
      _isLoadingMoreExpenses = true;
    });
    try {
      final page = await widget.workspaceController.loadExpensesPage(
        tripId: widget.trip.id,
        limit: 50,
        cursor: _expensesNextCursor,
        offset: _expensesNextCursor == null ? _expensesNextOffset : null,
      );
      if (!mounted || generation != _loadGeneration) {
        return;
      }
      final existingIds = _expensesFeed.map((item) => item.id).toSet();
      final merged = <TripExpense>[..._expensesFeed];
      for (final item in page.items) {
        if (existingIds.add(item.id)) {
          merged.add(item);
        }
      }
      _updateState(() {
        _expensesFeed = merged;
        _reconcileExpenseSocialPreviewState(merged);
        _expensesHasMore = page.hasMore;
        _expensesNextCursor = page.nextCursor;
        _expensesNextOffset = page.nextOffset;
      });
    } on ApiException catch (error) {
      if (mounted && generation == _loadGeneration) {
        _showSnack(error.message, isError: true);
      }
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        _showSnack(context.l10n.unexpectedErrorLoadingTripData, isError: true);
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        _updateState(() {
          _isLoadingMoreExpenses = false;
        });
      }
    }
  }

  Future<void> _loadTripActivity({required bool reset}) async {
    if (_isLoadingActivity && !reset) return;
    final generation = ++_activityGeneration;
    final workspaceGeneration = _loadGeneration;
    bool current() =>
        mounted &&
        generation == _activityGeneration &&
        workspaceGeneration == _loadGeneration;
    final offset = reset ? 0 : (_activityNextOffset ?? _activityEvents.length);
    _updateState(() {
      _isLoadingActivity = true;
      _activityError = null;
    });
    try {
      final page = await widget.workspaceController.loadTripActivity(
        tripId: widget.trip.id,
        limit: 50,
        offset: offset,
      );
      if (!current()) return;
      final merged = reset ? <WorkspaceActivityEvent>[] : [..._activityEvents];
      final ids = merged.map((item) => item.id).toSet();
      for (final item in page.items) {
        if (ids.add(item.id)) merged.add(item);
      }
      _updateState(() {
        _activityEvents = merged;
        _activityLoaded = true;
        _activityHasMore = page.hasMore;
        _activityNextOffset = page.nextOffset;
      });
    } catch (error) {
      if (!current()) return;
      _updateState(() {
        _activityError = context.l10n.activityLoadFailed;
        _activityFailedReset = reset;
        if (error is ApiException &&
            (error.statusCode == 401 ||
                error.statusCode == 403 ||
                error.statusCode == 404 ||
                error.code == 'account_changed')) {
          _activityEvents = const [];
          _activityLoaded = false;
          _activityHasMore = false;
          _activityNextOffset = null;
          ++_loadGeneration;
          ++_activityGeneration;
          _isLoadingActivity = false;
          _queuedMutations = const [];
          _pendingQueueCount = 0;
          _reconcileExpenseSocialPreviewState(const []);
          _snapshot = null;
          _expensesFeed = const [];
          _mayUseWorkspaceCache = false;
          _errorText = error.message;
        }
      });
    } finally {
      if (current()) _updateState(() => _isLoadingActivity = false);
    }
  }

  Set<int> _normalizeRandomSelection(Set<int> memberIds) {
    if (memberIds.isEmpty) {
      return <int>{};
    }

    final filtered = _randomSelection.where(memberIds.contains).toSet();
    if (filtered.isEmpty) {
      return memberIds;
    }
    return filtered;
  }

  Future<void> _refreshQueueState() async {
    final queuedMutations = await widget.workspaceController
        .listQueuedMutations(tripId: widget.trip.id);
    final count = queuedMutations.length;
    if (!mounted) {
      return;
    }
    _updateState(() {
      _pendingQueueCount = count;
      _queuedMutations = queuedMutations;
      if (count > 0) {
        _syncState = _syncState == _SyncState.offline
            ? _SyncState.offlineQueue
            : _SyncState.onlineQueue;
      } else {
        _syncState = _syncState == _SyncState.offlineQueue
            ? _SyncState.offline
            : _SyncState.online;
      }
    });
  }

  Future<void> _runMutation({required Future<void> Function() action}) async {
    _updateState(() {
      _isMutating = true;
      _errorText = null;
      _syncState = _SyncState.syncing;
    });

    try {
      await action();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.isNetworkError) {
        _updateState(() {
          _syncState = _pendingQueueCount > 0
              ? _SyncState.offlineQueue
              : _SyncState.offline;
        });
      }
      _showSnack(error.message, isError: true);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showSnack(context.l10n.unexpectedErrorSavingChanges, isError: true);
    } finally {
      if (mounted) {
        _updateState(() {
          _isMutating = false;
          if (_syncState == _SyncState.syncing) {
            _syncState = _pendingQueueCount > 0
                ? _SyncState.onlineQueue
                : _SyncState.online;
          }
        });
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  IconData _queuedMutationIcon(QueuedMutationType type) {
    switch (type) {
      case QueuedMutationType.addExpense:
        return Icons.add_circle_outline;
      case QueuedMutationType.updateExpense:
        return Icons.edit_outlined;
      case QueuedMutationType.deleteExpense:
        return Icons.delete_outline;
      case QueuedMutationType.unknown:
        return Icons.help_outline;
    }
  }

  String _queuedMutationTitle(QueuedMutation mutation) {
    final t = context.l10n;
    switch (mutation.type) {
      case QueuedMutationType.addExpense:
        final amount = mutation.amount;
        if (amount != null && amount > 0) {
          return t.queueAddExpenseAmount(
            _formatMoney(
              context,
              amount,
              currencyCode: widget.trip.currencyCode,
            ),
          );
        }
        return t.queueAddExpense;
      case QueuedMutationType.updateExpense:
        final expenseId = mutation.expenseId;
        return expenseId != null && expenseId > 0
            ? t.queueUpdateExpenseWithId(expenseId)
            : t.queueUpdateExpense;
      case QueuedMutationType.deleteExpense:
        final expenseId = mutation.expenseId;
        return expenseId != null && expenseId > 0
            ? t.queueDeleteExpenseWithId(expenseId)
            : t.queueDeleteExpense;
      case QueuedMutationType.unknown:
        return t.queuedChange;
    }
  }

  String _queuedMutationSubtitle(QueuedMutation mutation) {
    final note = (mutation.note ?? '').trim();
    if (note.isNotEmpty) {
      return note;
    }
    final date = (mutation.date ?? '').trim();
    if (date.isNotEmpty) {
      return _formatDisplayDate(context, date);
    }
    return context.l10n.tripWithId(mutation.tripId);
  }

  String _formatQueueTimestamp(int millis) {
    if (millis <= 0) {
      return '-';
    }
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${AppFormatters.shortDayMonth(context, dt)} $hh:$mm';
  }
}
