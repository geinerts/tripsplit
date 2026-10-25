import '../../../../core/errors/api_exception.dart';
import '../../../trips/domain/entities/trip.dart';
import '../../../trips/presentation/controllers/trips_controller.dart';
import '../../../workspace/presentation/controllers/workspace_controller.dart';

/// Uses fresh server reads: a shared-trip summary is not an access grant.
class FriendTripActions {
  const FriendTripActions({
    required this.trips,
    required this.workspace,
    required this.accountIsCurrent,
  });
  final TripsController trips;
  final WorkspaceController workspace;
  final bool Function() accountIsCurrent;
  void _checkAccount() {
    if (!accountIsCurrent()) {
      throw const ApiException('Account changed', code: 'account_changed');
    }
  }

  bool _eligible(Trip trip) =>
      trip.isActive && !trip.isSolo && trip.canCurrentUserManageTrip;
  Future<bool> _canInvite(Trip trip, int friendId) async {
    final snapshot = await workspace.refreshSnapshotFromServer(tripId: trip.id);
    _checkAccount();
    if (!snapshot.isActive || snapshot.users.any((u) => u.id == friendId)) {
      return false;
    }
    final pending = await trips.listPendingInvitations(tripId: trip.id);
    _checkAccount();
    return !pending.any((p) => p.userId == friendId);
  }

  Future<List<Trip>> invitableTrips(int friendId) async {
    _checkAccount();
    final all = await trips.refreshTripsFromServer();
    _checkAccount();
    final result = <Trip>[];
    for (final trip in all.where(_eligible)) {
      if (await _canInvite(trip, friendId)) result.add(trip);
    }
    return result;
  }

  Future<bool> invite(int tripId, int friendId) async {
    _checkAccount();
    final all = await trips.refreshTripsFromServer();
    _checkAccount();
    final matches = all.where((t) => t.id == tripId && _eligible(t));
    if (matches.isEmpty || !await _canInvite(matches.first, friendId)) {
      return false;
    }
    _checkAccount();
    final count = await trips.addMembers(tripId: tripId, memberIds: [friendId]);
    _checkAccount();
    return count > 0;
  }

  Future<Trip?> accessibleTrip(int tripId) async {
    _checkAccount();
    final all = await trips.refreshTripsFromServer();
    _checkAccount();
    final matches = all.where((t) => t.id == tripId);
    if (matches.isEmpty) return null;
    await workspace.refreshSnapshotFromServer(tripId: tripId);
    _checkAccount();
    return matches.first;
  }
}
