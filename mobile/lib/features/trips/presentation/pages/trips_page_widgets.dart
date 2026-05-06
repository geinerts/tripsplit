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
          tooltip: context.l10n.tripsJoinTripViaInvite,
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
    final totalSpentCentsRaw = allTrips.fold<int>(0, (sum, trip) {
      return sum + trip.myPaidCents;
    });
    final spentCurrencies = allTrips
        .map((trip) => AppCurrencyCatalog.normalize(trip.currencyCode))
        .toSet();
    final firstTripPreferredCode = allTrips
        .map((trip) => (trip.preferredCurrencyCode ?? '').trim())
        .firstWhere((code) => code.isNotEmpty, orElse: () => '');
    final preferredCurrencyCode = AppCurrencyCatalog.normalizeProfilePreferred(
      firstTripPreferredCode.isNotEmpty
          ? firstTripPreferredCode
          : widget.authController.currentUser?.preferredCurrencyCode,
    );
    final canUsePreferredTotals =
        allTrips.isNotEmpty &&
        allTrips.every((trip) => trip.myPaidPreferredCents != null);
    final preferredTotalSpentCents = canUsePreferredTotals
        ? allTrips.fold<int>(
            0,
            (sum, trip) => sum + (trip.myPaidPreferredCents ?? 0),
          )
        : 0;
    final t = context.l10n;
    final totalTripsLabel = context.l10n.tripsTotalTrips;
    final totalSpentLabel = context.l10n.tripsTotalSpent;
    final totalSpentValue = totalTrips == 0
        ? AppFormatters.currencyCodeFromCents(
            context,
            0,
            currencyCode: preferredCurrencyCode,
          )
        : canUsePreferredTotals
        ? AppFormatters.currencyCodeFromCents(
            context,
            preferredTotalSpentCents,
            currencyCode: preferredCurrencyCode,
          )
        : spentCurrencies.length <= 1
        ? AppFormatters.currencyCodeFromCents(
            context,
            totalSpentCentsRaw,
            currencyCode: spentCurrencies.isEmpty
                ? preferredCurrencyCode
                : spentCurrencies.first,
          )
        : context.l10n.tripsMixedCurrencies;

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
                valueWidget: _buildOverviewTotalSpentValue(
                  context,
                  totalSpentValue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewTotalSpentValue(BuildContext context, String rawValue) {
    final colors = Theme.of(context).colorScheme;
    final baseStyle =
        Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: colors.onSurface,
        ) ??
        TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        );

    final value = rawValue.trim();
    final match = RegExp(r'^([A-Z]{3})\s+(.+)$').firstMatch(value);
    if (match == null) {
      return Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final code = (match.group(1) ?? '').trim();
    final amount = (match.group(2) ?? '').trim();
    if (amount.isEmpty) {
      return Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final codeStyle = baseStyle.copyWith(
      fontSize: (baseStyle.fontSize ?? 34) * 0.56,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      height: 1.0,
    );

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: '$code ', style: codeStyle),
          TextSpan(text: amount, style: baseStyle),
        ],
      ),
    );
  }

  Widget _buildTripsSectionHeader(BuildContext context) {
    final controlsEnabled = !(_isLoading || _isMutating);
    final title = _showAllTrips
        ? context.l10n.allTrips
        : context.l10n.activeTrips;
    final actionLabel = _showAllTrips
        ? context.l10n.tripsShowActive
        : context.l10n.tripsSeeAll;

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
        if (_showAllTrips)
          IconButton(
            onPressed: controlsEnabled
                ? () {
                    _updateState(() {
                      final nextGridMode = !_showAllTripsGrid;
                      _showAllTripsGrid = nextGridMode;
                      if (nextGridMode &&
                          _allTripsVisibleCount <
                              _TripsPageState._allTripsGridInitialCount) {
                        _allTripsVisibleCount =
                            _TripsPageState._allTripsGridInitialCount;
                      }
                    });
                  }
                : null,
            tooltip: _showAllTripsGrid
                ? context.l10n.tripsListView
                : context.l10n.tripsGridView,
            icon: Icon(
              _showAllTripsGrid
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_rounded,
              size: 20,
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.10),
            ),
          ),
        if (_showAllTrips) const SizedBox(width: 4),
        TextButton(
          onPressed: controlsEnabled
              ? () {
                  _updateState(() {
                    final nextShowAllTrips = !_showAllTrips;
                    _showAllTrips = nextShowAllTrips;
                    if (nextShowAllTrips) {
                      _allTripsVisibleCount = _showAllTripsGrid
                          ? _TripsPageState._allTripsGridInitialCount
                          : _TripsPageState._allTripsInitialCount;
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
    final label = context.l10n.tripsAddNewTrip;
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
    if (_trips.isNotEmpty) {
      return AppEmptyState(
        icon: Icons.archive_outlined,
        title: 'No active trips right now',
        message:
            'Your finished trips are still saved. Switch to all trips or start a new one when the next plan appears.',
        actionLabel: t.tripsSeeAll,
        onAction: () {
          _updateState(() {
            _showAllTrips = true;
            _allTripsVisibleCount = _showAllTripsGrid
                ? _TripsPageState._allTripsGridInitialCount
                : _TripsPageState._allTripsInitialCount;
          });
        },
        secondaryActionLabel: t.createTripAction,
        onSecondaryAction: _isMutating ? null : _openCreateTripDialog,
      );
    }

    return AppOnboardingChecklist(
      title: 'Split your first trip in 3 steps',
      subtitle:
          'Splyto works best when you create the trip, invite the people, then add the first expense together.',
      primaryActionLabel: t.createTripAction,
      onPrimaryAction: _isMutating ? null : _openCreateTripDialog,
      secondaryActionLabel: t.tripsJoinTripViaInvite,
      onSecondaryAction: _isMutating ? null : _onJoinTripPressed,
      steps: const [
        AppOnboardingStep(
          icon: Icons.luggage_outlined,
          title: 'Create trip',
          message: 'Name the trip, choose dates and set the main currency.',
        ),
        AppOnboardingStep(
          icon: Icons.group_add_outlined,
          title: 'Invite friends',
          message: 'Add friends now or share an invite link after creating.',
        ),
        AppOnboardingStep(
          icon: Icons.receipt_long_outlined,
          title: 'Add first expense',
          message: 'Add a receipt, choose who joined, and Splyto tracks it.',
        ),
      ],
    );
  }

  Widget _buildTripNextStepCard(BuildContext context, Trip trip) {
    final isSettling =
        trip.readyToSettle && trip.settlementsPending > 0 && !trip.isArchived;
    if (isSettling) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: AppEmptyState(
          icon: Icons.payments_outlined,
          title: 'Settlements are waiting',
          message:
              '${trip.settlementsConfirmed} of ${trip.settlementsTotal} payments confirmed. Open the trip to finish the money flow.',
          actionLabel: context.l10n.openSettlements,
          onAction: () => _openWorkspace(trip),
        ),
      );
    }

    return const SizedBox.shrink();
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
    if (!_showAllTripsGrid) {
      listContent = Column(
        children: [for (final trip in trips) _buildTripCard(context, trip)],
      );
    } else {
      listContent = LayoutBuilder(
        builder: (context, constraints) {
          var columns = responsive.isExpanded ? 3 : 2;
          if (constraints.maxWidth < 330) {
            columns = 1;
          } else if (columns == 3 && constraints.maxWidth < 760) {
            columns = 2;
          }
          const spacing = 10.0;
          final itemWidth =
              (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (final trip in trips)
                SizedBox(
                  width: itemWidth,
                  child: _buildTripGridTile(
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
              label: Text(context.l10n.tripsLoadMore),
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
      final trip = trips.first;
      return Column(
        children: [
          _buildTripNextStepCard(context, trip),
          _buildTripCard(context, trip),
        ],
      );
    }

    const carouselHeight = 220.0;
    final indicatorIndex = _activeTripsPageIndex.clamp(0, trips.length - 1);
    final indicatorOnColor = Theme.of(context).colorScheme.primary;
    final indicatorOffColor = Theme.of(
      context,
    ).colorScheme.outlineVariant.withValues(alpha: 0.6);

    return Column(
      children: [
        _buildTripNextStepCard(context, trips[indicatorIndex]),
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
