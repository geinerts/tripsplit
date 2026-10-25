part of 'trips_page.dart';

extension _TripsPageCardWidgets on _TripsPageState {
  Widget _buildTripCard(BuildContext context, Trip trip) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final title = trip.name.trim().isEmpty ? t.tripWithId(trip.id) : trip.name;
    final coverUrl = (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();
    final pending =
        !trip.isSolo &&
        !trip.isArchived &&
        (trip.isSettling ||
            (trip.readyToSettle && trip.settlementsPending > 0));
    final metadata = [
      AppFormatters.tripDateRange(
        context,
        startRaw: trip.dateFrom ?? trip.createdAt,
        endRaw: trip.dateTo ?? trip.endedAt ?? trip.archivedAt,
        unknownLabel: t.dateUnknown,
      ),
      trip.isSolo ? t.homeSolo : t.homePeople(trip.membersCount),
    ].join(' · ');
    Widget fallback() => SplytoIllustration(
      'assets/branding/splyto_trip_cover_small.svg',
      fit: BoxFit.cover,
      excludeFromSemantics: true,
    );
    final cover = ClipRRect(
      borderRadius: AppDesign.cardRadius,
      child: SizedBox(
        width: 84,
        height: 84,
        child: coverUrl.isEmpty
            ? fallback()
            : Image.network(
                coverUrl,
                fit: BoxFit.cover,
                cacheWidth: (84 * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                errorBuilder: (context, error, stack) => fallback(),
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback(),
              ),
      ),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          semanticsLabel: title,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          metadata,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.yourShare,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          AppFormatters.displayCurrencyFromCents(
            context,
            trip.myOwedCents,
            currencyCode: trip.currencyCode,
          ),
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
        ),
        if (pending) ...[
          const SizedBox(height: 8),
          Text(
            t.settlingStatus,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ],
    );
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: InkWell(
                key: ValueKey('home-trip-${trip.id}'),
                onTap: () => _openWorkspace(trip),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked =
                          MediaQuery.textScalerOf(context).scale(16) > 24 ||
                          constraints.maxWidth < 230;
                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            cover,
                            const SizedBox(height: 12),
                            details,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          cover,
                          const SizedBox(width: 16),
                          Expanded(child: details),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: IconButton(
                key: ValueKey('home-trip-menu-${trip.id}'),
                tooltip: t.homeTripActions(title),
                onPressed: _isMutating ? null : () => _openTripActions(trip),
                icon: const Icon(Icons.more_horiz),
              ),
            ),
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }
}
