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
    final statusChipGradient = _statusPillGradient(
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final statusChipBorder = _statusPillBorderColor(
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );
    final statusChipForeground = _statusPillForegroundColor(
      context,
      isSettlingState: isSettlingState,
      isFinishedState: isFinishedState,
    );

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
                                  color: Colors.white,
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
                              colors: statusChipGradient,
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
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
                                    ? Colors.white.withValues(alpha: 0.18)
                                    : Colors.black.withValues(alpha: 0.12),
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
                                              ? Colors.white.withValues(
                                                  alpha: 0.84,
                                                )
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

  List<Color> _statusPillGradient({
    required bool isSettlingState,
    required bool isFinishedState,
  }) {
    if (isSettlingState) {
      return const [Color(0xD9D3843C), Color(0xD9E19D4E)];
    }
    if (isFinishedState) {
      return const [Color(0xD95C6470), Color(0xD94B535E)];
    }
    return const [Color(0xFFBFE9D3), Color(0xFF95D7B5)];
  }

  Color _statusPillBorderColor({
    required bool isSettlingState,
    required bool isFinishedState,
  }) {
    if (isSettlingState) {
      return const Color(0x99F4C287);
    }
    if (isFinishedState) {
      return const Color(0x99D4D9DE);
    }
    return const Color(0xFF84CFA9);
  }

  Color _statusPillForegroundColor(
    BuildContext context, {
    required bool isSettlingState,
    required bool isFinishedState,
  }) {
    if (isSettlingState || isFinishedState) {
      return Colors.white;
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
      startRaw: trip.createdAt,
      endRaw: trip.endedAt ?? trip.archivedAt,
      unknownLabel: context.l10n.dateUnknown,
    );
  }
}
