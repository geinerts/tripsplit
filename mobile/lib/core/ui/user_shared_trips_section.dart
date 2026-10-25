import 'package:flutter/material.dart';
import 'splyto_illustration.dart';

import '../../app/theme/app_design.dart';
import '../../features/workspace/domain/entities/workspace_shared_trip.dart';
import '../errors/api_exception.dart';
import '../l10n/l10n.dart';
import 'user_profile_page.dart';

/// Opening is optional; the caller must verify access using fresh server data.
class UserSharedTripsSection extends StatefulWidget {
  const UserSharedTripsSection({
    super.key,
    required this.future,
    required this.reload,
    this.fallbackTrip,
    this.onOpenTrip,
  });
  final Future<List<WorkspaceSharedTrip>> future;
  final Future<List<WorkspaceSharedTrip>> Function() reload;
  final WorkspaceSharedTrip? fallbackTrip;
  final ValueChanged<WorkspaceSharedTrip>? onOpenTrip;

  @override
  State<UserSharedTripsSection> createState() => _UserSharedTripsSectionState();
}

class _UserSharedTripsSectionState extends State<UserSharedTripsSection> {
  late Future<List<WorkspaceSharedTrip>> _future = widget.future;
  @override
  void didUpdateWidget(covariant UserSharedTripsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.future != widget.future) _future = widget.future;
  }

  @override
  Widget build(BuildContext context) => UserProfileSectionCard(
    child: FutureBuilder<List<WorkspaceSharedTrip>>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final error = snapshot.error;
        final denied =
            error is ApiException &&
            ([401, 403, 404].contains(error.statusCode) ||
                error.code == 'account_changed');
        final items = denied
            ? <WorkspaceSharedTrip>[]
            : snapshot.data ?? <WorkspaceSharedTrip>[];
        final fallback = widget.fallbackTrip;
        final visible = items.isEmpty && !denied && !loading && fallback != null
            ? [fallback]
            : items;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loading || error != null
                  ? context.l10n.workspaceCommonTrips
                  : '${context.l10n.workspaceCommonTrips} (${visible.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(context.l10n.workspaceLoadingCommonTrips),
            ] else if (error != null) ...[
              Text(context.l10n.friendsCouldNotLoadCommonTripsRightNow),
              TextButton(
                onPressed: () {
                  final request = widget.reload();
                  request.ignore();
                  setState(() {
                    _future = request;
                  });
                },
                child: Text(context.l10n.retryAction),
              ),
            ] else if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.luggage_outlined,
                        size: 40,
                        color: AppDesign.mutedColor(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.workspaceNoCommonTripsFoundYet,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.sharedTripsEmptyBody,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppDesign.mutedColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (!loading)
              for (final trip in visible)
                _SharedTripRow(
                  trip: trip,
                  onTap: widget.onOpenTrip == null
                      ? null
                      : () => widget.onOpenTrip!(trip),
                ),
            if (!loading && items.length >= 20)
              Text(
                context.l10n.sharedTripsLoadedLimit,
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        );
      },
    ),
  );
}

class _SharedTripRow extends StatelessWidget {
  const _SharedTripRow({required this.trip, this.onTap});
  final VoidCallback? onTap;
  final WorkspaceSharedTrip trip;
  @override
  Widget build(BuildContext context) {
    final url = (trip.imageThumbUrl ?? trip.imageUrl ?? '').trim();
    final status = trip.isArchived
        ? context.l10n.archivedStatus
        : trip.isSettling
        ? context.l10n.settlingStatus
        : context.l10n.activeStatus;
    final raw = trip.archivedAt ?? trip.endedAt ?? trip.createdAt;
    final date = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    final thumbSize =
        MediaQuery.sizeOf(context).width < 360 ||
            MediaQuery.textScalerOf(context).scale(16) > 23
        ? 64.0
        : 80.0;
    Widget fallback() => SplytoIllustration(
      'assets/branding/splyto_trip_cover_small.svg',
      width: thumbSize,
      height: thumbSize,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExcludeSemantics(
                    child: SizedBox.square(
                      dimension: thumbSize,
                      child: ClipRRect(
                        borderRadius: AppDesign.cardRadius,
                        child: url.isEmpty
                            ? fallback()
                            : Image.network(
                                url,
                                width: thumbSize,
                                height: thumbSize,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => fallback(),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.name.trim().isEmpty
                              ? context.l10n.tripWithId(trip.id)
                              : trip.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: trip.isArchived
                                    ? AppDesign.mutedColor(context)
                                    : Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (date != null)
                              MaterialLocalizations.of(
                                context,
                              ).formatMediumDate(date),
                            context.l10n.friendsMembers(trip.membersCount),
                          ].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.chevron_right),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
