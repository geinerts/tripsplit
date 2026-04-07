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
          onPressed: _isMutating || _isLoading ? null : _onJoinTripPressed,
          icon: const Icon(Icons.link_rounded),
          tooltip: _pageText(
            en: 'Join trip via invite',
            lv: 'Pievienoties ceļojumam ar ielūgumu',
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
    final spentCurrencies = allTrips
        .map((trip) => AppCurrencyCatalog.normalize(trip.currencyCode))
        .toSet();
    final t = context.l10n;
    final totalTripsLabel = _pageText(en: 'Total trips', lv: 'Ceļojumi kopā');
    final totalSpentLabel = _pageText(en: 'Total spent', lv: 'Kopā iztērēts');
    final totalSpentValue = spentCurrencies.length <= 1
        ? AppFormatters.currencyFromCents(
            context,
            totalSpentCents,
            currencyCode: spentCurrencies.isEmpty
                ? AppCurrencyCatalog.defaultCode
                : spentCurrencies.first,
          )
        : _pageText(en: 'Mixed currencies', lv: 'Jauktas valūtas');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            t.overviewTitle.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
              color: AppDesign.mutedColor(context),
            ),
          ),
        ),
        const SizedBox(height: 8),
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
                value: totalSpentValue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripsSectionHeader(BuildContext context) {
    final controlsEnabled = !(_isLoading || _isMutating);
    final title = _showAllTrips
        ? _pageText(en: 'All trips', lv: 'Visi ceļojumi')
        : _pageText(en: 'Active trips', lv: 'Aktīvie ceļojumi');
    final actionLabel = _showAllTrips
        ? _pageText(en: 'Show active', lv: 'Rādīt aktīvos')
        : _pageText(en: 'See all', lv: 'Skatīt visus');

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.9,
                color: AppDesign.mutedColor(context),
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: controlsEnabled
              ? () {
                  _updateState(() {
                    final nextShowAllTrips = !_showAllTrips;
                    _showAllTrips = nextShowAllTrips;
                    if (nextShowAllTrips) {
                      _allTripsVisibleCount =
                          _TripsPageState._allTripsInitialCount;
                    }
                  });
                }
              : null,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            foregroundColor: Theme.of(context).colorScheme.primary,
            textStyle: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          child: Text(actionLabel),
        ),
      ],
    );
  }

  Widget _buildAddTripFloatingButton(BuildContext context) {
    final controlsEnabled = !(_isLoading || _isMutating);
    final label = _pageText(en: 'Add new trip', lv: 'Pievienot ceļojumu');
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      minimum: EdgeInsets.only(bottom: widget.showBottomNav ? 14 : 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFBFE9D3), Color(0xFF95D7B5)],
          ),
        ),
        child: OutlinedButton.icon(
          onPressed: controlsEnabled ? _openCreateTripDialog : null,
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.primary,
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesign.radiusSm),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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

  Widget _buildTripsCollection(
    BuildContext context,
    List<Trip> trips, {
    bool hasMoreAllTrips = false,
  }) {
    if (!_showAllTrips) {
      return _buildActiveTripsCarousel(context, trips);
    }

    final responsive = context.responsive;
    late final Widget listContent;
    if (responsive.isCompact) {
      listContent = Column(
        children: [for (final trip in trips) _buildTripCard(context, trip)],
      );
    } else {
      listContent = LayoutBuilder(
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
                  child: _buildTripCard(
                    context,
                    trip,
                    withBottomSpacing: false,
                  ),
                ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        listContent,
        if (hasMoreAllTrips) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () {
                _updateState(() {
                  final nextCount =
                      _allTripsVisibleCount +
                      _TripsPageState._allTripsLoadMoreStep;
                  _allTripsVisibleCount = nextCount > _trips.length
                      ? _trips.length
                      : nextCount;
                });
              },
              icon: const Icon(Icons.expand_more_rounded),
              label: Text(_pageText(en: 'Load more', lv: 'Ielādēt vēl')),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActiveTripsCarousel(BuildContext context, List<Trip> trips) {
    if (trips.isEmpty) {
      return const SizedBox.shrink();
    }
    if (trips.length == 1) {
      return _buildTripCard(context, trips.first);
    }

    const carouselHeight = 220.0;
    final indicatorIndex = _activeTripsPageIndex.clamp(0, trips.length - 1);
    final indicatorOnColor = Theme.of(context).colorScheme.primary;
    final indicatorOffColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.6);

    return Column(
      children: [
        SizedBox(
          height: carouselHeight,
          child: PageView.builder(
            itemCount: trips.length,
            onPageChanged: (index) {
              if (_activeTripsPageIndex == index) {
                return;
              }
              _updateState(() {
                _activeTripsPageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final trip = trips[index];
              return _buildTripCard(context, trip, withBottomSpacing: false);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < trips.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: i == indicatorIndex ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == indicatorIndex
                      ? indicatorOnColor
                      : indicatorOffColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
