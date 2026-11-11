part of 'trips_page.dart';

/// Large photo card shown instead of the list when exactly one trip is active.
extension _TripsPageHeroWidgets on _TripsPageState {
  Widget _buildActiveTripHero(BuildContext context, Trip trip) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final muted = colors.onSurfaceVariant;
    final title = trip.name.trim().isEmpty ? t.tripWithId(trip.id) : trip.name;
    final coverUrl = (trip.imageUrl ?? trip.imageThumbUrl ?? '').trim();
    final dates = AppFormatters.tripDateRange(
      context,
      startRaw: trip.dateFrom ?? trip.createdAt,
      endRaw: trip.dateTo ?? trip.endedAt,
      unknownLabel: '',
    );
    final pending =
        !trip.isSolo &&
        (trip.isSettling ||
            (trip.readyToSettle && trip.settlementsPending > 0));

    Widget fallback() => ColoredBox(
      color: colors.surfaceContainerHighest,
      child: SplytoIllustration(
        'assets/branding/splyto_trip_cover_large.svg',
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
    final photo = ClipRRect(
      borderRadius: AppDesign.cardRadius,
      child: AspectRatio(
        aspectRatio: AppImageCropper.tripAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              child: coverUrl.isEmpty
                  ? fallback()
                  : LayoutBuilder(
                      builder: (context, box) => TripCoverImage(
                        tripId: trip.id,
                        url: coverUrl,
                        fallback: fallback(),
                        imageKey: const ValueKey('home-active-trip-photo'),
                        fit: BoxFit.cover,
                        cacheWidth:
                            (box.maxWidth *
                                    MediaQuery.devicePixelRatioOf(context))
                                .round(),
                      ),
                    ),
            ),
            // The name sits in a small dark pill at the bottom left, styled
            // like the Live map button on the trip page.
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Align(
                alignment: AlignmentDirectional.bottomStart,
                child: DecoratedBox(
                  key: const ValueKey('home-active-trip-name'),
                  decoration: ShapeDecoration(
                    color: const Color(0xB8101214),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: .20),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // The full name is still read out through the card
                      // semantics; large text would cover the photo.
                      textScaler: MediaQuery.textScalerOf(
                        context,
                      ).clamp(maxScaleFactor: 1.5),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final status = Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              trip.isSettling ? Icons.sync : Icons.circle,
              size: 9,
              color: colors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              trip.isSettling ? t.settlingStatus : t.activeStatus,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (dates.isNotEmpty)
          Text(
            '·  $dates',
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
      ],
    );

    final members = trip.isSolo ? null : _buildHeroMembers(context, trip);
    final share = Text(
      AppFormatters.displayCurrencyFromCents(
        context,
        trip.myOwedCents,
        currencyCode: trip.currencyCode,
      ),
      style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
    );

    return Column(
      key: ValueKey('home-active-trip-${trip.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          key: ValueKey('home-trip-${trip.id}'),
          onTap: () => _openWorkspace(trip),
          borderRadius: AppDesign.cardRadius,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              photo,
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, box) {
                  if (members == null) return status;
                  final stacked =
                      MediaQuery.textScalerOf(context).scale(16) > 23 ||
                      box.maxWidth < 300;
                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [status, const SizedBox(height: 8), members],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: status),
                      const SizedBox(width: 8),
                      members,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t.yourShare,
          style: theme.textTheme.bodyMedium?.copyWith(color: muted),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: share),
            if (!trip.isSolo && trip.isActive && trip.canCurrentUserManageTrip)
              Builder(
                builder: (shareContext) => IconButton(
                  key: ValueKey('home-trip-share-${trip.id}'),
                  tooltip: t.shareAction,
                  onPressed: _isMutating || _sharingTripId != null
                      ? null
                      : () => _shareTrip(trip, shareContext),
                  icon: _sharingTripId == trip.id
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          CupertinoIcons.arrowshape_turn_up_right,
                          color: colors.primary,
                        ),
                ),
              ),
            IconButton(
              key: ValueKey('home-trip-menu-${trip.id}'),
              tooltip: t.homeTripActions(title),
              onPressed: _isMutating ? null : () => _openTripActions(trip),
              icon: const Icon(Icons.more_horiz),
            ),
          ],
        ),
        if (pending && !trip.isSettling) ...[
          const SizedBox(height: 4),
          Text(
            t.settlingStatus,
            style: theme.textTheme.labelMedium?.copyWith(color: colors.primary),
          ),
        ],
      ],
    );
  }

  /// Up to three member avatars and "+N" for the rest. Falls back to the
  /// member count when the server sent no preview (older server or cache).
  Widget _buildHeroMembers(BuildContext context, Trip trip) {
    final theme = Theme.of(context);
    final label = context.l10n.homePeople(trip.membersCount);
    final preview = trip.membersPreview.take(3).toList(growable: false);
    if (preview.isEmpty) {
      return Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    final extra = trip.membersCount - preview.length;
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        key: const ValueKey('home-active-trip-members'),
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, member) in preview.indexed)
            Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 4),
              child: _TripMemberAvatar(member: member, size: 32),
            ),
          if (extra > 0)
            // Same filled pill as on the trip page, so the count is noticed.
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.2,
                child: Container(
                  height: 32,
                  constraints: const BoxConstraints(minWidth: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '+$extra',
                    key: const ValueKey('home-active-trip-members-extra'),
                    maxLines: 1,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TripMemberAvatar extends StatelessWidget {
  const _TripMemberAvatar({required this.member, required this.size});
  final TripMemberPreview member;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final name = member.displayName.trim();
    final initial = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        name.isEmpty ? '?' : name.characters.first.toUpperCase(),
        textScaler: TextScaler.noScaling,
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.42,
        ),
      ),
    );
    final url = (member.avatarThumbUrl ?? member.avatarUrl ?? '').trim();
    if (url.isEmpty) return initial;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        gaplessPlayback: true,
        errorBuilder: (context, error, stack) => initial,
      ),
    );
  }
}
