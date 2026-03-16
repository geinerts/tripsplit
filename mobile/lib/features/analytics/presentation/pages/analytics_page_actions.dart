part of 'analytics_page.dart';

extension _AnalyticsPageActions on _AnalyticsPageState {
  void _bindCommandController(AnalyticsPageCommandController? controller) {
    if (controller == null) {
      return;
    }
    _handledRefreshRequestCount = controller.refreshRequestCount;
    controller.addListener(_onCommandControllerChanged);
  }

  void _unbindCommandController(AnalyticsPageCommandController? controller) {
    controller?.removeListener(_onCommandControllerChanged);
  }

  void _onCommandControllerChanged() {
    final controller = widget.commandController;
    if (controller == null) {
      return;
    }
    if (controller.refreshRequestCount == _handledRefreshRequestCount) {
      return;
    }
    _handledRefreshRequestCount = controller.refreshRequestCount;
    unawaited(_loadTrips(forceReload: true));
  }

  Future<void> _loadTrips({required bool forceReload}) async {
    final trace = PerfMonitor.start('screen.analytics.trips.load');
    var success = false;
    _updateState(() {
      _isLoadingTrips = true;
      _tripsError = null;
    });

    try {
      final trips = await widget.tripsController.loadTrips(
        forceRefresh: forceReload,
      );
      if (!mounted) {
        return;
      }

      final selectedTripId = _selectTripId(
        trips: trips,
        previousTripId: _selectedTripId,
      );
      _updateState(() {
        _trips = trips;
        _selectedTripId = selectedTripId;
      });

      await _loadSelectedTripSnapshot(forceReload: forceReload);
      success = true;
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _tripsError = error.message.trim().isNotEmpty
            ? error.message.trim()
            : context.l10n.unexpectedErrorLoadingTrips;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _tripsError = context.l10n.unexpectedErrorLoadingTrips;
      });
    } finally {
      trace.stop(success: success);
      if (mounted) {
        _updateState(() {
          _isLoadingTrips = false;
        });
      }
    }
  }

  int? _selectTripId({
    required List<Trip> trips,
    required int? previousTripId,
  }) {
    if (trips.isEmpty) {
      return null;
    }
    if (previousTripId != null &&
        trips.any((trip) => trip.id == previousTripId)) {
      return previousTripId;
    }
    for (final trip in trips) {
      if (trip.isActive) {
        return trip.id;
      }
    }
    return trips.first.id;
  }

  Future<void> _loadSelectedTripSnapshot({required bool forceReload}) async {
    final trace = PerfMonitor.start('screen.analytics.snapshot.load');
    var success = false;
    final tripId = _selectedTripId;
    if (tripId == null) {
      _updateState(() {
        _snapshotError = null;
      });
      trace.stop(success: true);
      return;
    }

    if (!forceReload && _snapshotCache.containsKey(tripId)) {
      _updateState(() {
        _snapshotError = null;
      });
      trace.stop(success: true);
      return;
    }

    _updateState(() {
      _isLoadingSnapshot = true;
      _snapshotError = null;
    });

    try {
      final snapshot = await widget.workspaceController.loadSnapshot(
        tripId: tripId,
      );
      if (!mounted) {
        return;
      }
      _updateState(() {
        _snapshotCache[tripId] = snapshot;
      });
      success = true;
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _snapshotError = error.message.trim().isNotEmpty
            ? error.message.trim()
            : context.l10n.unexpectedErrorLoadingTripData;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _updateState(() {
        _snapshotError = context.l10n.unexpectedErrorLoadingTripData;
      });
    } finally {
      trace.stop(success: success);
      if (mounted) {
        _updateState(() {
          _isLoadingSnapshot = false;
        });
      }
    }
  }

  Future<void> _onTripSelected(int tripId) async {
    if (_selectedTripId == tripId) {
      return;
    }
    _updateState(() {
      _selectedTripId = tripId;
      _snapshotError = null;
    });
    await _loadSelectedTripSnapshot(forceReload: false);
  }

  Trip? get _selectedTrip {
    final selectedTripId = _selectedTripId;
    if (selectedTripId == null) {
      return null;
    }
    for (final trip in _trips) {
      if (trip.id == selectedTripId) {
        return trip;
      }
    }
    return null;
  }

  WorkspaceSnapshot? get _selectedSnapshot {
    final selectedTripId = _selectedTripId;
    if (selectedTripId == null) {
      return null;
    }
    return _snapshotCache[selectedTripId];
  }

  int get _currentUserId => widget.authController.currentUser?.id ?? 0;
}
