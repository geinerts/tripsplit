part of 'analytics_page.dart';

extension _AnalyticsPageActions on _AnalyticsPageState {
  void _refresh() {
    if (widget.active) {
      unawaited(_load());
    } else {
      _loaded = false;
    }
  }

  Future<void> _load() async {
    final request = ++_generation;
    final account = widget.authController.currentUser?.id ?? 0;
    bool current() =>
        mounted &&
        request == _generation &&
        account > 0 &&
        widget.authController.currentUser?.id == account;
    if (account <= 0) return;
    _updateState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Force a server read: cached trip totals must not silently mix with fresh pages.
      final trips = await widget.tripsController.loadTrips(forceRefresh: true);
      if (!current()) return;
      final entries = await loadAnalyticsEntries(
        trips: trips,
        userId: account,
        loadPage: widget.workspaceController.loadExpensesPage,
        isCurrent: current,
      );
      if (!current()) return;
      _updateState(() {
        _trips = trips;
        _entries = entries;
        _loaded = true;
        if (!trips.any((t) => t.id == _selectedTripId)) {
          _selectedTripId = trips.firstOrNull?.id;
        }
        final codes = trips.map((t) => t.currencyCode).toSet();
        if (!codes.contains(_currency)) {
          _currency = (codes.toList()..sort()).firstOrNull;
        }
        if (!_months.contains(_month)) _month = null;
      });
    } catch (error) {
      if (!current()) return;
      _updateState(() {
        final denied =
            error is ApiException &&
            ([401, 403, 404].contains(error.statusCode) ||
                error.code == 'account_changed');
        if (denied) {
          _entries = [];
          _trips = [];
          _loaded = false;
        }
        _error = context.l10n.analyticsLoadFailed;
      });
    } finally {
      if (current()) _updateState(() => _loading = false);
    }
  }

  Future<void> _chooseTrip() async {
    final choice = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .7,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                context.l10n.analyticsByTrip,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            for (final trip in _trips)
              ListTile(
                leading: _tripCover(trip, width: 52, height: 48),
                title: Text(trip.name),
                subtitle: Text('${_tripDates(trip)} · ${trip.currencyCode}'),
                trailing: trip.id == _selectedTripId
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(context, trip.id),
              ),
          ],
        ),
      ),
    );
    if (mounted && choice != null) _updateState(() => _selectedTripId = choice);
  }

  Future<void> _chooseMonth() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .65,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(context.l10n.homeAllTime),
              trailing: _month == null ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, 'all'),
            ),
            for (final month in _months)
              ListTile(
                title: Text(_monthLabel(month)),
                trailing: _month == month ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(context, month),
              ),
          ],
        ),
      ),
    );
    if (mounted && choice != null) {
      _updateState(() => _month = choice == 'all' ? null : choice);
    }
  }
}
