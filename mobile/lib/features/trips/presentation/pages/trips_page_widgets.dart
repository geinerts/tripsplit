part of 'trips_page.dart';

extension _TripsPageWidgets on _TripsPageState {
  Widget _buildErrorState(BuildContext context) {
    final t = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorText ?? t.unknownError,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadTrips,
              icon: const Icon(Icons.refresh),
              label: Text(t.retryAction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    final t = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final responsive = context.responsive;

    return Row(
      children: [
        Expanded(
          child: Text(
            t.yourTrips,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (responsive.isCompact
                        ? Theme.of(context).textTheme.headlineSmall
                        : Theme.of(context).textTheme.headlineMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: colorScheme.onSurface,
                    ),
          ),
        ),
        IconButton(
          onPressed: _isMutating || _isLoading ? null : _loadTrips,
          icon: const Icon(Icons.refresh),
          tooltip: t.syncAction,
        ),
        IconButton(
          onPressed: _isMutating ? null : _openSettingsSheet,
          icon: const Icon(Icons.settings_outlined),
          tooltip: t.settings,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required List<Trip> allTrips,
  }) {
    final responsive = context.responsive;
    final totalTrips = allTrips.length;
    final totalSpentCents = allTrips.fold<int>(
      0,
      (sum, trip) => sum + trip.myPaidCents,
    );
    final isLv = Localizations.localeOf(context).languageCode == 'lv';
    final titleText = isLv ? 'Pārskats' : 'Overview';
    final totalTripsLabel = isLv ? 'Kopā ceļojumi' : 'Trips total';
    final totalSpentLabel = isLv ? 'Kopā iztērēts' : 'Total spent';

    final radius = responsive.pick(compact: 20, medium: 24, expanded: 28);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            gradient: AppDesign.logoBackgroundGradient,
            boxShadow: const [
              BoxShadow(
                color: Color(0x2B0F172A),
                blurRadius: 26,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              responsive.pick(compact: 16, medium: 20, expanded: 24),
              responsive.pick(compact: 16, medium: 18, expanded: 20),
              responsive.pick(compact: 16, medium: 20, expanded: 24),
              responsive.pick(compact: 14, medium: 16, expanded: 18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _summaryMetricTile(
                        context,
                        icon: Icons.luggage_outlined,
                        label: totalTripsLabel,
                        value: '$totalTrips',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _summaryMetricTile(
                        context,
                        icon: Icons.payments_outlined,
                        label: totalSpentLabel,
                        value: _formatCents(totalSpentCents),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryMetricTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsHeader(
    BuildContext context, {
    required int currentCount,
    required int archivedCount,
  }) {
    final t = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            _showAllTrips ? t.allTrips : t.activeTrips,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
        TextButton(
          onPressed: (_isLoading || _isMutating)
              ? null
              : () => _updateState(() {
                  _showAllTrips = !_showAllTrips;
                }),
          child: Text(_showAllTrips ? t.showActiveTrips : t.viewAllTrips),
        ),
        IconButton(
          onPressed: (_isLoading || _isMutating) ? null : _openCreateTripDialog,
          icon: const Icon(Icons.add),
          tooltip: t.createTripAction,
        ),
      ],
    );
  }

  Widget _buildEmptyTripsState(BuildContext context) {
    final t = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(Icons.luggage_outlined, size: 32),
            const SizedBox(height: 8),
            Text(t.noTripsYet, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(t.createFirstTripHint, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isMutating ? null : _openCreateTripDialog,
              icon: const Icon(Icons.add),
              label: Text(t.createTripAction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsCollection(BuildContext context, List<Trip> trips) {
    final responsive = context.responsive;
    if (responsive.isCompact) {
      return Column(
        children: [for (final trip in trips) _buildTripCard(context, trip)],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var columns = responsive.isExpanded ? 3 : 2;
        if (columns == 3 && constraints.maxWidth < 860) {
          columns = 2;
        }
        const spacing = 12.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final trip in trips)
              SizedBox(
                width: itemWidth,
                child: _buildTripCard(context, trip, withBottomSpacing: false),
              ),
          ],
        );
      },
    );
  }

}
