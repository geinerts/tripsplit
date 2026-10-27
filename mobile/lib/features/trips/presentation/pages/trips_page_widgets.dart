part of 'trips_page.dart';

extension _TripsPageWidgets on _TripsPageState {
  Widget _buildTopHeader(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          context.l10n.yourTrips,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      IconButton(
        onPressed: _isMutating ? null : _openSettingsSheet,
        tooltip: context.l10n.settings,
        icon: const Icon(Icons.settings_outlined),
      ),
    ],
  );

  Widget _buildLoadingState(BuildContext context) => Semantics(
    label: context.l10n.homeLoadingTrips,
    child: ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppSkeletonBlock(width: 170, height: 16, radius: 4),
            const SizedBox(height: 12),
            const AppSkeletonBlock(width: 210, height: 44, radius: 4),
            const SizedBox(height: 40),
            const AppSkeletonBlock(width: 130, height: 24, radius: 4),
            const SizedBox(height: 24),
            for (var i = 0; i < 3; i++) ...[
              const Row(
                children: [
                  AppSkeletonBlock(width: 80, height: 88, radius: 8),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeletonBlock(height: 18, radius: 4),
                        SizedBox(height: 12),
                        AppSkeletonBlock(width: 100, height: 14, radius: 4),
                        SizedBox(height: 12),
                        AppSkeletonBlock(width: 80, height: 20, radius: 4),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _buildErrorState(BuildContext context) => _centeredState(
    context,
    asset: 'splyto_trip_load_error.svg',
    title: _isOffline
        ? context.l10n.homeOfflineTitle
        : context.l10n.homeLoadErrorTitle,
    message: _isOffline
        ? context.l10n.homeOfflineNoData
        : context.l10n.homeLoadErrorBody,
    primary: OutlinedButton.icon(
      onPressed: _isRefreshing ? null : _loadTrips,
      icon: const Icon(Icons.refresh),
      label: Text(context.l10n.retryAction),
    ),
  );

  Widget _buildEmptyTripsState(BuildContext context) => _centeredState(
    context,
    asset: 'splyto_empty_trips.svg',
    title: context.l10n.homeFirstTrip,
    primary: FilledButton.icon(
      key: const ValueKey('home-create-first-trip'),
      onPressed: _isMutating ? null : _openCreateTripDialog,
      icon: const Icon(Icons.add),
      label: Text(context.l10n.createTripAction),
    ),
    secondary: TextButton.icon(
      onPressed: _isMutating ? null : _onJoinTripPressed,
      icon: const Icon(Icons.link),
      label: Text(context.l10n.tripsJoinTripViaInvite),
    ),
  );

  Widget _centeredState(
    BuildContext context, {
    required String asset,
    required String title,
    String? message,
    required Widget primary,
    Widget? secondary,
  }) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SplytoIllustration(
              'assets/branding/$asset',
              width: 180,
              height: 150,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: primary),
            if (secondary != null) ...[
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: secondary),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _buildRefreshNotice(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
        child: Row(
          children: [
            Icon(
              _isOffline
                  ? Icons.wifi_off_outlined
                  : Icons.sync_problem_outlined,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _isOffline
                    ? context.l10n.homeOfflineCached
                    : context.l10n.homeRefreshError,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: context.l10n.retryAction,
              onPressed: _isRefreshing ? null : _loadTrips,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required List<Trip> allTrips,
  }) {
    // Shares are already expressed in each trip's base currency. Do not use
    // myPaidPreferredCents: that is what the payer advanced, not their share.
    final totals = <String, int>{};
    for (final trip in allTrips) {
      final code = AppCurrencyCatalog.normalize(trip.currencyCode);
      totals.update(
        code,
        (value) => value + trip.myOwedCents,
        ifAbsent: () => trip.myOwedCents,
      );
    }
    final currencies = totals.keys.toList()..sort();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.homeYourShareAllTrips,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        for (final currency in currencies)
          Text(
            AppFormatters.displayCurrencyFromCents(
              context,
              totals[currency]!,
              currencyCode: currency,
            ),
            key: ValueKey('home-total-$currency'),
            style: currencies.length == 1
                ? theme.textTheme.displaySmall?.copyWith(height: 1.15)
                : theme.textTheme.headlineSmall,
          ),
        const SizedBox(height: 2),
        Text(
          context.l10n.homeAllTime,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTripsSectionHeader(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          context.l10n.yourTrips,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      IconButton(
        key: const ValueKey('home-trip-invitations'),
        tooltip: context.l10n.homeTripInvitations,
        onPressed: _isMutating ? null : _openReceivedInvitations,
        icon: Badge(
          key: const ValueKey('home-trip-invitation-badge'),
          isLabelVisible: _receivedInvitations.isNotEmpty || _invitationsFailed,
          label: Text(
            _invitationsFailed
                ? '!'
                : (_receivedInvitations.length > 99
                      ? '99+'
                      : '${_receivedInvitations.length}'),
          ),
          child: Icon(
            Icons.mark_email_unread_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      IconButton(
        tooltip: context.l10n.tripsJoinTripViaInvite,
        onPressed: _isMutating ? null : _onJoinTripPressed,
        icon: const Icon(Icons.link),
      ),
      IconButton(
        key: const ValueKey('home-create-trip'),
        tooltip: context.l10n.createTripAction,
        onPressed: _isMutating ? null : _openCreateTripDialog,
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
      ),
    ],
  );

  Widget _buildTripFilters(BuildContext context) {
    final activeCount = _trips.where((trip) => !trip.isArchived).length;
    final archivedCount = _trips.length - activeCount;
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final archived in [false, true])
          Expanded(
            child: Semantics(
              selected: _showArchived == archived,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _showArchived == archived
                          ? colors.primary
                          : colors.outlineVariant,
                      width: _showArchived == archived ? 2 : 1,
                    ),
                  ),
                ),
                child: TextButton(
                  key: ValueKey(archived ? 'home-archived' : 'home-active'),
                  onPressed: () => _updateState(() {
                    _hasChosenFilter = true;
                    _showArchived = archived;
                  }),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    foregroundColor: _showArchived == archived
                        ? colors.primary
                        : colors.onSurfaceVariant,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: Text(
                    '${archived ? context.l10n.archivedStatus : context.l10n.activeStatus}  ${archived ? archivedCount : activeCount}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
