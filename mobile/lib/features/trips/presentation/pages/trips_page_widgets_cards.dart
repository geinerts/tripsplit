part of 'trips_page.dart';

extension _TripsPageCardWidgets on _TripsPageState {
  Widget _buildTripCard(
    BuildContext context,
    Trip trip, {
    bool withBottomSpacing = true,
  }) {
    final t = context.l10n;
    final netBalanceCents = trip.myBalanceCents;
    final netLabel = netBalanceCents > 0
        ? t.summaryYouOwe
        : (netBalanceCents < 0 ? t.summaryYouAreOwed : t.summarySettledUp);
    final netColor = netBalanceCents > 0
        ? Theme.of(context).colorScheme.error
        : (netBalanceCents < 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface);
    final showReadyToSettle =
        trip.readyToSettle && trip.settlementsPending > 0 && !trip.isArchived;
    final coverUrl = _tripCoverUrl(trip);

    if (coverUrl.isNotEmpty) {
      return _buildTripCoverCard(
        context,
        trip,
        coverUrl: coverUrl,
        netLabel: netLabel,
        netBalanceCents: netBalanceCents,
        netColor: netColor,
        showReadyToSettle: showReadyToSettle,
        withBottomSpacing: withBottomSpacing,
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: withBottomSpacing ? 12 : 0),
      child: AppSurfaceCard(
        radius: 22,
        onTap: () => _openWorkspace(trip),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTripThumbnail(context, trip),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trip.name.isEmpty ? t.tripWithId(trip.id) : trip.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openTripActions(trip),
                        icon: const Icon(Icons.more_vert),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text(_formatTripPeriod(context, trip)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.group_outlined, size: 16),
                          const SizedBox(width: 4),
                          Text('${trip.membersCount}'),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_statusIcon(trip), size: 16),
                          const SizedBox(width: 4),
                          Text(_statusLabel(context, trip)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              netLabel,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCents(netBalanceCents.abs()),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: netColor,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.25,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            t.totalLabel,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCents(trip.totalAmountCents),
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tripCoverUrl(Trip trip) => (trip.imageThumbUrl ?? trip.imageUrl ?? '')
      .trim();

  Widget _buildTripCoverCard(
    BuildContext context,
    Trip trip, {
    required String coverUrl,
    required String netLabel,
    required int netBalanceCents,
    required Color netColor,
    required bool showReadyToSettle,
    required bool withBottomSpacing,
  }) {
    final t = context.l10n;
    final isDark = AppDesign.isDark(context);
    final title = trip.name.isEmpty ? t.tripWithId(trip.id) : trip.name;
    final label = trip.name.trim().isEmpty
        ? 'T'
        : trip.name.trim().substring(0, 1).toUpperCase();
    final statusIcon = showReadyToSettle
        ? Icons.payments_outlined
        : _statusIcon(trip);
    final statusText = showReadyToSettle
        ? t.settlingStatus
        : _statusLabel(context, trip);

    return Padding(
      padding: EdgeInsets.only(bottom: withBottomSpacing ? 12 : 0),
      child: AppSurfaceCard(
        radius: 22,
        onTap: () => _openWorkspace(trip),
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 220,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(
                    coverUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) =>
                        _tripCoverFallback(context, label),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.26)
                            : Colors.black.withValues(alpha: 0.24),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => _openTripActions(trip),
                            icon: const Icon(Icons.more_vert),
                            color: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.30)
                            : Colors.white.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.60),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 15,
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.92,
                                              )
                                            : AppDesign.titleColor(context),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _formatTripPeriod(context, trip),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.94,
                                                      )
                                                    : AppDesign.titleColor(
                                                        context,
                                                      ),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.group_outlined,
                                        size: 15,
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.92,
                                              )
                                            : AppDesign.titleColor(context),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${trip.membersCount}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.94,
                                                    )
                                                  : AppDesign.titleColor(
                                                      context,
                                                    ),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      netLabel,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.84,
                                              )
                                            : AppDesign.mutedColor(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCents(netBalanceCents.abs()),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            color: netColor,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.25,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 38,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.black.withValues(alpha: 0.12),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    t.totalLabel,
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.84,
                                                )
                                              : AppDesign.mutedColor(context),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCents(trip.totalAmountCents),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.white
                                          : AppDesign.titleColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tripCoverFallback(BuildContext context, String label) {
    return Container(
      color: AppDesign.lightPrimary.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 36,
        ),
      ),
    );
  }

  Widget _buildTripThumbnail(BuildContext context, Trip trip) {
    final t = context.l10n;
    final responsive = context.responsive;
    final color = _statusColor(context, trip);
    final isDark = AppDesign.isDark(context);
    final imageUrl = (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();
    final label = trip.name.trim().isEmpty
        ? 'T'
        : trip.name.trim().substring(0, 1).toUpperCase();
    final size = responsive.pick(compact: 76, medium: 84, expanded: 90);
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: imageUrl.isNotEmpty
            ? (isDark
                  ? Theme.of(context).colorScheme.surfaceContainerHigh
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.60))
            : Color.alphaBlend(
                color.withValues(alpha: isDark ? 0.20 : 0.14),
                AppDesign.cardSurface(context),
              ),
        border: Border.all(color: AppDesign.cardStroke(context)),
      ),
      child: Stack(
        children: [
          if (imageUrl.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.low,
                  gaplessPlayback: true,
                  cacheWidth: imageCacheSize,
                  cacheHeight: imageCacheSize,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Center(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ),
          if (imageUrl.isNotEmpty)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: isDark ? 0.34 : 0.18),
                    ],
                  ),
                ),
              ),
            ),
          if (trip.isArchived || trip.allSettled)
            Positioned(
              left: 6,
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t.settledStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _statusColor(BuildContext context, Trip trip) {
    if (trip.isArchived) {
      return Theme.of(context).colorScheme.secondary;
    }
    if (trip.isSettling) {
      return Theme.of(context).colorScheme.tertiary;
    }
    return Theme.of(context).colorScheme.primary;
  }

  IconData _statusIcon(Trip trip) {
    if (trip.isArchived) {
      return Icons.archive_outlined;
    }
    if (trip.isSettling) {
      return Icons.payments_outlined;
    }
    return Icons.play_circle_outline;
  }

  String _statusLabel(BuildContext context, Trip trip) {
    final t = context.l10n;
    if (trip.isArchived) {
      return t.archivedStatus;
    }
    if (trip.isSettling) {
      return t.settlingStatus;
    }
    return t.activeStatus;
  }

  String _formatCents(int cents) {
    return AppFormatters.euroFromCents(context, cents);
  }

  String _formatTripPeriod(BuildContext context, Trip trip) {
    return AppFormatters.tripDateRange(
      context,
      startRaw: trip.createdAt,
      endRaw: trip.endedAt ?? trip.archivedAt,
      unknownLabel: context.l10n.dateUnknown,
    );
  }
}
