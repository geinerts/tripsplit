part of 'trips_page.dart';

extension _TripsPageCardWidgets on _TripsPageState {
  Widget _buildTripCard(
    BuildContext context,
    Trip trip, {
    bool withBottomSpacing = true,
  }) {
    final netBalanceCents = trip.myBalanceCents;
    final netLabel = netBalanceCents > 0
        ? context.l10n.summaryYouOwe
        : (netBalanceCents < 0
              ? context.l10n.summaryYouAreOwed
              : context.l10n.summarySettledUp);
    final netColor = netBalanceCents > 0
        ? Theme.of(context).colorScheme.error
        : (netBalanceCents < 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface);
    final showReadyToSettle =
        trip.readyToSettle && trip.settlementsPending > 0 && !trip.isArchived;
    final coverUrl = _tripCoverUrl(trip);

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

  Widget _buildTripGridTile(
    BuildContext context,
    Trip trip, {
    bool withBottomSpacing = true,
  }) {
    final t = context.l10n;
    final isDark = AppDesign.isDark(context);
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        (isDark ? AppSemanticColors.dark : AppSemanticColors.light);
    final title = trip.name.isEmpty ? t.tripWithId(trip.id) : trip.name;
    final label = trip.name.trim().isEmpty
        ? 'T'
        : trip.name.trim().substring(0, 1).toUpperCase();
    final coverUrl = _tripCoverUrl(trip);
    final netBalanceCents = trip.myBalanceCents;
    final netLabel = netBalanceCents > 0
        ? context.l10n.summaryYouOwe
        : (netBalanceCents < 0
              ? context.l10n.summaryYouAreOwed
              : context.l10n.summarySettledUp);
    final netColor = netBalanceCents > 0
        ? Theme.of(context).colorScheme.error
        : (netBalanceCents < 0
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface);
    final showReadyToSettle =
        trip.readyToSettle && trip.settlementsPending > 0 && !trip.isArchived;
    final isFinishedState = trip.isArchived || trip.allSettled;
    final isSettlingState = showReadyToSettle || trip.isSettling;
    final statusIcon = showReadyToSettle
        ? Icons.payments_outlined
        : (trip.isArchived
              ? Icons.archive_outlined
              : (trip.allSettled
                    ? Icons.check_circle_outline_rounded
                    : _statusIcon(trip)));
    final statusText = showReadyToSettle
        ? t.settlingStatus
        : (trip.isArchived
              ? t.archivedStatus
              : (trip.allSettled
                    ? t.settledStatus
                    : _statusLabel(context, trip)));
    final statusChipBackground = _statusPillBackgroundColor(
      semantic: semantic,
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final statusChipBorder = _statusPillBorderColor(
      semantic: semantic,
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final statusChipForeground = _statusPillForegroundColor(
      semantic: semantic,
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final onCoverStrong = semantic.heroAvatarStroke;
    final onCoverMedium = onCoverStrong.withValues(alpha: 0.90);
    final amountStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.0);

    return Padding(
      padding: EdgeInsets.only(bottom: withBottomSpacing ? 10 : 0),
      child: AppSurfaceCard(
        radius: 20,
        onTap: () => _openWorkspace(trip),
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 192,
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: coverUrl.isNotEmpty
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              _tripCoverFallback(context, label),
                        )
                      : _tripCoverFallback(context, label),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: onCoverStrong,
                                  fontWeight: FontWeight.w800,
                                  height: 1.02,
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Tooltip(
                          message: statusText,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: statusChipBackground,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: statusChipBorder),
                            ),
                            child: Icon(
                              statusIcon,
                              size: 16,
                              color: statusChipForeground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _formatTripPeriod(context, trip),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: onCoverMedium,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: semantic.cardGlassBackground,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: semantic.cardGlassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  netLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: onCoverMedium,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.group_outlined,
                                size: 13,
                                color: onCoverMedium,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${trip.membersCount}',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: onCoverMedium,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _formatCents(trip, netBalanceCents.abs()),
                                    maxLines: 1,
                                    style: amountStyle?.copyWith(
                                      color: netColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 20,
                                color: semantic.cardGlassBorder,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    _formatCents(trip, trip.totalAmountCents),
                                    maxLines: 1,
                                    style: amountStyle?.copyWith(
                                      color: onCoverStrong,
                                    ),
                                  ),
                                ),
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

  String _tripCoverUrl(Trip trip) =>
      (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();

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
    final semantic =
        Theme.of(context).extension<AppSemanticColors>() ??
        (isDark ? AppSemanticColors.dark : AppSemanticColors.light);
    final title = trip.name.isEmpty ? t.tripWithId(trip.id) : trip.name;
    final label = trip.name.trim().isEmpty
        ? 'T'
        : trip.name.trim().substring(0, 1).toUpperCase();
    final isFinishedState = trip.isArchived || trip.allSettled;
    final isSettlingState = showReadyToSettle || trip.isSettling;
    final statusIcon = showReadyToSettle
        ? Icons.payments_outlined
        : (trip.isArchived
              ? Icons.archive_outlined
              : (trip.allSettled
                    ? Icons.check_circle_outline_rounded
                    : _statusIcon(trip)));
    final statusText = showReadyToSettle
        ? t.settlingStatus
        : (trip.isArchived
              ? t.archivedStatus
              : (trip.allSettled
                    ? t.settledStatus
                    : _statusLabel(context, trip)));
    final statusChipBackground = _statusPillBackgroundColor(
      semantic: semantic,
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final statusChipBorder = _statusPillBorderColor(
      semantic: semantic,
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final statusChipForeground = _statusPillForegroundColor(
      semantic: semantic,
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final onCoverStrong = semantic.heroAvatarStroke;
    final onCoverMedium = onCoverStrong.withValues(alpha: 0.94);
    final onCoverMuted = onCoverStrong.withValues(alpha: 0.84);
    final onCoverIcon = onCoverStrong.withValues(alpha: 0.92);

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
                  child: coverUrl.isNotEmpty
                      ? Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.low,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              _tripCoverFallback(context, label),
                        )
                      : _tripCoverFallback(context, label),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: onCoverStrong,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                statusChipBackground,
                                statusChipBackground,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: statusChipBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusIcon,
                                size: 13,
                                color: statusChipForeground,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                statusText,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: statusChipForeground,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: semantic.cardGlassBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: semantic.cardGlassBorder),
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
                                            ? onCoverIcon
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
                                                    ? onCoverMedium
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
                                            ? onCoverIcon
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
                                                  ? onCoverMedium
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: isDark
                                                ? onCoverMuted
                                                : AppDesign.mutedColor(context),
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatCents(trip, netBalanceCents.abs()),
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
                                    ? semantic.cardGlassBorder
                                    : AppDesign.mutedColor(
                                        context,
                                      ).withValues(alpha: 0.24),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    t.totalLabel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDark
                                              ? onCoverMuted
                                              : AppDesign.mutedColor(context),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatCents(trip, trip.totalAmountCents),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? onCoverStrong
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
        style: TextStyle(
          color: AppDesign.darkForeground,
          fontWeight: FontWeight.w800,
          fontSize: 36,
        ),
      ),
    );
  }

  Color _statusPillBackgroundColor({
    required AppSemanticColors semantic,
    required bool isSettlingState,
    required bool isFinishedState,
  }) {
    if (isSettlingState) {
      return semantic.statusSettlingBackground;
    }
    if (isFinishedState) {
      return semantic.statusSettledBackground;
    }
    return semantic.statusActiveBackground;
  }

  Color _statusPillBorderColor({
    required AppSemanticColors semantic,
    required bool isSettlingState,
    required bool isFinishedState,
  }) {
    if (isSettlingState) {
      return semantic.statusSettlingBorder;
    }
    if (isFinishedState) {
      return semantic.statusSettledBorder;
    }
    return semantic.statusActiveBorder;
  }

  Color _statusPillForegroundColor({
    required AppSemanticColors semantic,
    required bool isSettlingState,
    required bool isFinishedState,
  }) {
    if (isSettlingState) {
      return semantic.statusSettlingForeground;
    }
    if (isFinishedState) {
      return semantic.statusSettledForeground;
    }
    return semantic.statusActiveForeground;
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

  String _formatCents(Trip trip, int cents) {
    return AppFormatters.currencyFromCents(
      context,
      cents,
      currencyCode: trip.currencyCode,
    );
  }

  String _formatTripPeriod(BuildContext context, Trip trip) {
    return AppFormatters.tripDateRange(
      context,
      startRaw: trip.dateFrom ?? trip.createdAt,
      endRaw: trip.dateTo ?? trip.endedAt ?? trip.archivedAt,
      unknownLabel: context.l10n.dateUnknown,
    );
  }
}
