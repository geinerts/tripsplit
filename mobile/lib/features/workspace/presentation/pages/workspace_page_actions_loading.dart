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
    final trace = PerfMonitor.start('screen.workspace.load');
    var success = false;
    var openedAddExpenseDuringLoad = false;
    final shouldTryCachedFirst = _snapshot == null;
    if (showLoader) {
      _updateState(() {
        _isLoading = true;
        _errorText = null;
        _syncState = _SyncState.syncing;
      });
    } else {
      _updateState(() {
        _errorText = null;
        _syncState = _SyncState.syncing;
      });
    }

    final snapshotFuture = widget.workspaceController.loadSnapshot(
      tripId: widget.trip.id,
    );

    if (shouldTryCachedFirst) {
      try {
        final cachedSnapshot = await widget.workspaceController
            .readCachedSnapshot(tripId: widget.trip.id);
        if (cachedSnapshot != null && mounted) {
          final memberIds = cachedSnapshot.users.map((user) => user.id).toSet();
          final nextSelection = _normalizeRandomSelection(memberIds);
          final nextExpenseFilter = memberIds.contains(_expenseFilterUserId)
              ? _expenseFilterUserId
              : 0;
          _updateState(() {
            _errorText = null;
            _syncState = _SyncState.syncing;
            _expenseFilterUserId = nextExpenseFilter;
            _snapshot = cachedSnapshot;
            _expensesFeed = cachedSnapshot.expenses;
            _reconcileExpenseSocialPreviewState(cachedSnapshot.expenses);
            _expensesHasMore = false;
            _isLoadingMoreExpenses = false;
            _expensesNextCursor = null;
            _expensesNextOffset = null;
            _randomSelection = nextSelection;
            _isLoading = false;
          });
          if (_openAddExpenseAfterLoad) {
            _openAddExpenseAfterLoad = false;
            openedAddExpenseDuringLoad = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }
              unawaited(_runStartupAddExpenseFlow());
            });
          }
        }
      } catch (_) {
        // Ignore cache read errors and continue with live fetch.
      }
    }

    try {
      final snapshot = await snapshotFuture;
      final queuedMutations = await widget.workspaceController
          .listQueuedMutations(tripId: widget.trip.id);
      final queueCount = queuedMutations.length;
      var userId = _currentUserId;
      try {
        userId = await widget.workspaceController.loadCurrentUserId();
      } on ApiException catch (error) {
        if (!error.isNetworkError) {
          rethrow;
        }
      }
      if (!mounted) {
        return;
      }

      final memberIds = snapshot.users.map((user) => user.id).toSet();
      final nextSelection = _normalizeRandomSelection(memberIds);
      final nextExpenseFilter = memberIds.contains(_expenseFilterUserId)
          ? _expenseFilterUserId
          : 0;

      _updateState(() {
        _currentUserId = userId;
        _pendingQueueCount = queueCount;
        _queuedMutations = queuedMutations;
        _syncState = queueCount > 0
            ? _SyncState.onlineQueue
            : _SyncState.online;
        _expenseFilterUserId = nextExpenseFilter;
        _snapshot = snapshot;
        _expensesFeed = snapshot.expenses;
        _reconcileExpenseSocialPreviewState(snapshot.expenses);
        _expensesHasMore = false;
        _isLoadingMoreExpenses = false;
        _expensesNextCursor = null;
        _expensesNextOffset = null;
        _randomSelection = nextSelection;
      });
      unawaited(_primeExpensesFeed());

      if (_openAddExpenseAfterLoad && !openedAddExpenseDuringLoad) {
        _openAddExpenseAfterLoad = false;
        unawaited(_runStartupAddExpenseFlow());
      }
      success = true;
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _openAddExpenseAfterLoad = false;
      _isStartingWithAddExpense = false;
      if (_snapshot != null) {
        _updateState(() {
          if (error.isNetworkError) {
            _syncState = _pendingQueueCount > 0
                ? _SyncState.offlineQueue
                : _SyncState.offline;
          } else {
            _syncState = _pendingQueueCount > 0
                ? _SyncState.onlineQueue
                : _SyncState.online;
          }
        });
        _showSnack(error.message, isError: true);
        return;
      }
      _updateState(() {
        _errorText = error.message;
        if (error.isNetworkError) {
          _syncState = _pendingQueueCount > 0
              ? _SyncState.offlineQueue
              : _SyncState.offline;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _openAddExpenseAfterLoad = false;
      _isStartingWithAddExpense = false;
      if (_snapshot != null) {
        _updateState(() {
          _syncState = _pendingQueueCount > 0
              ? _SyncState.onlineQueue
              : _SyncState.online;
        });
        _showSnack(context.l10n.unexpectedErrorLoadingTripData, isError: true);
        return;
      }
      _updateState(() {
        _errorText = context.l10n.unexpectedErrorLoadingTripData;
      });
    } finally {
      trace.stop(success: success);
      if (mounted) {
        _updateState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _primeExpensesFeed() async {
    final snapshot = _snapshot;
    if (snapshot == null) {
      return;
    }
    try {
      final page = await widget.workspaceController.loadExpensesPage(
        tripId: widget.trip.id,
        limit: 50,
      );
      if (!mounted) {
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
      if (!mounted) {
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
    } finally {
      if (mounted) {
        _updateState(() {
          _isLoadingMoreExpenses = false;
        });
      }
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
