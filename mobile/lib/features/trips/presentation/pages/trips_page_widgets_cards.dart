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

    return Padding(
      padding: EdgeInsets.only(bottom: withBottomSpacing ? 12 : 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => _openWorkspace(trip),
            child: Padding(
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
                                trip.name.isEmpty
                                    ? t.tripWithId(trip.id)
                                    : trip.name,
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
                                const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 16,
                                ),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  t.totalLabel,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCents(trip.totalAmountCents),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
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
          ),
        ),
      ),
    );
  }

  Widget _buildTripThumbnail(BuildContext context, Trip trip) {
    final t = context.l10n;
    final responsive = context.responsive;
    final color = _statusColor(context, trip);
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
        gradient: LinearGradient(
          colors: [
            Color.alphaBlend(
              color.withValues(alpha: 0.48),
              const Color(0xFF0F172A),
            ),
            Color.alphaBlend(
              color.withValues(alpha: 0.12),
              const Color(0xFF334155),
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                        style: const TextStyle(
                          color: Colors.white,
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
                style: const TextStyle(
                  color: Colors.white,
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
                      Colors.black.withValues(alpha: 0.24),
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
    final amount = cents / 100.0;
    return '\u20ac${amount.toStringAsFixed(2)}';
  }

  String _formatTripPeriod(BuildContext context, Trip trip) {
    final start = _parseDate(trip.createdAt);
    final end = _parseDate(trip.endedAt ?? trip.archivedAt);

    if (start == null && end == null) {
      return context.l10n.dateUnknown;
    }

    final locale = Localizations.localeOf(context).toLanguageTag();
    final monthFormatter = DateFormat('MMM', locale);

    if (start != null && end != null) {
      if (start.year == end.year && start.month == end.month) {
        return '${start.day}-${end.day} ${monthFormatter.format(end)}';
      }
      return '${start.day} ${monthFormatter.format(start)} - ${end.day} ${monthFormatter.format(end)}';
    }

    final single = start ?? end!;
    return '${single.day} ${monthFormatter.format(single)}';
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw.trim());
  }
}
