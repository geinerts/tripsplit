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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
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
    final totalTrips = allTrips.length;
    final totalSpentCents = allTrips.fold<int>(
      0,
      (sum, trip) => sum + trip.myPaidCents,
    );
    final t = context.l10n;
    final totalTripsLabel = _pageText(en: 'Total trips', lv: 'Ceļojumi kopā');
    final totalSpentLabel = _pageText(en: 'Total spent', lv: 'Kopā iztērēts');

    return AppSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.overviewTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              color: AppDesign.titleColor(context),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  icon: Icons.luggage_outlined,
                  label: totalTripsLabel,
                  value: '$totalTrips',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppStatCard(
                  icon: Icons.payments_outlined,
                  label: totalSpentLabel,
                  value: AppFormatters.euroFromCents(context, totalSpentCents),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripsHeader(BuildContext context) {
    final t = context.l10n;
    final controlsEnabled = !(_isLoading || _isMutating);

    return AppSurfaceCard(
      radius: AppDesign.radiusLg,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: _buildTripsToggleButton(
              label: t.activeTrips,
              selected: !_showAllTrips,
              enabled: controlsEnabled,
              onTap: () {
                _updateState(() {
                  _showAllTrips = false;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTripsToggleButton(
              label: t.allTrips,
              selected: _showAllTrips,
              enabled: controlsEnabled,
              onTap: () {
                _updateState(() {
                  _showAllTrips = true;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppDesign.radiusSm),
              onTap: controlsEnabled ? _openCreateTripDialog : null,
              child: Ink(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                  color: controlsEnabled
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.10)
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.70),
                ),
                child: Icon(
                  Icons.add,
                  size: 22,
                  color: controlsEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsToggleButton({
    required String label,
    required bool selected,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (AppDesign.isDark(context)
                      ? colors.primary.withValues(alpha: 0.20)
                      : AppDesign.lightSurface)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
            boxShadow: selected ? AppDesign.cardShadow(context) : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected
                  ? AppDesign.titleColor(context)
                  : AppDesign.mutedColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTripsState(BuildContext context) {
    final t = context.l10n;
    return AppSurfaceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(
            Icons.luggage_outlined,
            size: 32,
            color: AppDesign.mutedColor(context),
          ),
          const SizedBox(height: 8),
          Text(
            t.noTripsYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppDesign.titleColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.createFirstTripHint,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppDesign.mutedColor(context),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _isMutating ? null : _openCreateTripDialog,
            icon: const Icon(Icons.add),
            label: Text(t.createTripAction),
          ),
        ],
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
