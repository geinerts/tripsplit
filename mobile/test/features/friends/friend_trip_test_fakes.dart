import 'dart:async';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:tripsplit/features/trips/domain/entities/pending_trip_invitation.dart';
import 'package:tripsplit/features/trips/presentation/controllers/trips_controller.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_snapshot_codec.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_snapshot.dart';
import 'package:tripsplit/features/workspace/presentation/controllers/workspace_controller.dart';

Trip testTrip(
  int id, {
  String role = 'owner',
  String status = 'active',
  String mode = 'group',
  String? name,
}) => TripModel.fromLegacyMap({
  'id': id,
  'name': name ?? 'Trip $id',
  'current_user_role': role,
  'status': status,
  'trip_mode': mode,
  'currency_code': 'EUR',
  'members_count': 2,
});

class FriendTestTrips implements TripsController {
  List<Trip> items = [
    testTrip(1, name: 'Lisbon getaway'),
    testTrip(2, name: 'Weekend in Copenhagen'),
  ];
  final pending = <int, List<PendingTripInvitation>>{};
  final invites = <(int, List<int>)>[];
  int loads = 0;
  int result = 1;
  Object? failure;
  Object? inviteFailure;
  Completer<List<Trip>>? loadGate;
  Completer<int>? sendGate;
  @override
  Future<List<Trip>> refreshTripsFromServer() async {
    loads++;
    if (failure != null) throw failure!;
    return loadGate == null ? items : loadGate!.future;
  }

  @override
  Future<List<PendingTripInvitation>> listPendingInvitations({
    required int tripId,
  }) async => pending[tripId] ?? [];
  @override
  Future<int> addMembers({
    required int tripId,
    required List<int> memberIds,
  }) async {
    invites.add((tripId, memberIds));
    if (inviteFailure != null) throw inviteFailure!;
    return sendGate == null ? result : sendGate!.future;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class FriendTestWorkspace implements WorkspaceController {
  final snapshots = <int, WorkspaceSnapshot>{};
  final reads = <int>[];
  Object? accessFailure;
  @override
  Future<WorkspaceSnapshot> refreshSnapshotFromServer({
    required int tripId,
  }) async {
    reads.add(tripId);
    if (accessFailure != null) throw accessFailure!;
    return snapshots[tripId] ??
        WorkspaceSnapshotCodec.fromMap({
          'trip_status': 'active',
          'users': [
            {'id': 7, 'nickname': 'Matiss', 'role': 'owner'},
          ],
        });
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
