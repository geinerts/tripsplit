part of 'trips_page.dart';

extension _TripsPageDialogs on _TripsPageState {
  Future<_CreateTripResult?> _showCreateTripDialog() async {
    final result = await Navigator.of(context).push<TripFormDraft>(
      AppFormPageRoute(
        builder: (_) => TripFormPage(
          pickImage: _pickTripImageForUploadFromSource,
          loadFriends: () async {
            final snapshot =
                widget.friendsController.peekSnapshotCache(allowStale: false) ??
                await widget.friendsController.loadSnapshot(
                  forceRefresh: false,
                );
            return snapshot.friends
                .map(
                  (friend) => TripUser(
                    id: friend.id,
                    nickname: friend.nickname,
                    avatarUrl: friend.avatarUrl,
                    avatarThumbUrl: friend.avatarThumbUrl,
                  ),
                )
                .toList();
          },
        ),
      ),
    );
    if (result == null) return null;
    return _CreateTripResult(
      name: result.name,
      budgetCents: result.budgetCents,
      destinations: result.destinations,
      currencyCode: result.currencyCode,
      tripMode: result.tripMode,
      memberIds: result.memberIds,
      dateFrom: result.dateFrom!,
      dateTo: result.dateTo!,
      imageFileName: result.image?.fileName,
      imageBytes: result.image?.bytes,
    );
  }
}
