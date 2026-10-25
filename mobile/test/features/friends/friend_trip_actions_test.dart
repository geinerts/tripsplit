import 'dart:async';
import 'package:tripsplit/features/trips/domain/entities/trip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/friends/presentation/controllers/friend_trip_actions.dart';
import 'package:tripsplit/features/trips/domain/entities/pending_trip_invitation.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_snapshot_codec.dart';
import 'friend_trip_test_fakes.dart';

void main() {
  late FriendTestTrips trips;
  late FriendTestWorkspace workspace;
  late FriendTripActions actions;
  var accountCurrent = true;
  setUp(() {
    trips = FriendTestTrips();
    workspace = FriendTestWorkspace();
    accountCurrent = true;
    actions = FriendTripActions(
      trips: trips,
      workspace: workspace,
      accountIsCurrent: () => accountCurrent,
    );
  });
  test(
    'only active managed groups without member or pending invitation are eligible',
    () async {
      trips.items = [
        testTrip(1),
        testTrip(2, role: 'admin'),
        testTrip(3, role: 'member'),
        testTrip(4, mode: 'solo'),
        testTrip(5, status: 'settling'),
        testTrip(6, status: 'archived'),
        testTrip(7),
        testTrip(8),
        testTrip(9),
      ];
      workspace.snapshots[7] = WorkspaceSnapshotCodec.fromMap({
        'trip_status': 'active',
        'users': [
          {'id': 8},
        ],
      });
      workspace.snapshots[9] = WorkspaceSnapshotCodec.fromMap({
        'trip_status': 'settling',
      });
      trips.pending[8] = [
        const PendingTripInvitation(id: 1, userId: 8, name: 'Anna'),
      ];
      expect((await actions.invitableTrips(8)).map((t) => t.id), [1, 2]);
      expect(workspace.reads, [1, 2, 7, 8, 9]);
      expect(trips.loads, 1);
    },
  );
  for (final change in ['role', 'status', 'member', 'pending', 'removed']) {
    test('invitation rechecks $change before mutation', () async {
      expect(await actions.invitableTrips(8), isNotEmpty);
      if (change == 'role') trips.items = [testTrip(1, role: 'member')];
      if (change == 'status') trips.items = [testTrip(1, status: 'archived')];
      if (change == 'removed') trips.items = [];
      if (change == 'member') {
        workspace.snapshots[1] = WorkspaceSnapshotCodec.fromMap({
          'trip_status': 'active',
          'users': [
            {'id': 8},
          ],
        });
      }
      if (change == 'pending') {
        trips.pending[1] = [
          const PendingTripInvitation(id: 1, userId: 8, name: 'Anna'),
        ];
      }
      expect(await actions.invite(1, 8), isFalse);
      expect(trips.invites, isEmpty);
    });
  }
  test('sends exact selected trip and friend only', () async {
    expect(await actions.invite(2, 8), isTrue);
    expect(trips.invites.single.$1, 2);
    expect(trips.invites.single.$2, [8]);
  });
  test('zero new invitations does not claim successful delivery', () async {
    trips.result = 0;
    expect(await actions.invite(1, 8), isFalse);
  });
  test(
    'permission and network errors propagate without cached fallback',
    () async {
      trips.failure = const ApiException('Offline', isNetworkError: true);
      await expectLater(
        actions.invitableTrips(8),
        throwsA(isA<ApiException>()),
      );
      trips.failure = null;
      workspace.accessFailure = const ApiException(
        'Forbidden',
        statusCode: 403,
      );
      await expectLater(actions.invite(1, 8), throwsA(isA<ApiException>()));
      expect(trips.invites, isEmpty);
    },
  );
  test(
    'common trip summaries require fresh membership and snapshot authorization',
    () async {
      expect(await actions.accessibleTrip(999), isNull);
      expect(workspace.reads, isEmpty);
      workspace.accessFailure = const ApiException(
        'Forbidden',
        statusCode: 403,
      );
      await expectLater(
        actions.accessibleTrip(1),
        throwsA(isA<ApiException>()),
      );
      workspace.accessFailure = null;
      trips.items = [testTrip(1, status: 'archived', role: 'member')];
      expect((await actions.accessibleTrip(1))!.isArchived, isTrue);
    },
  );
  test('late trip list after account change cannot open or invite', () async {
    final pending = Completer<List<Trip>>();
    trips.loadGate = pending;
    final result = actions.invite(1, 8);
    accountCurrent = false;
    pending.complete(trips.items);
    await expectLater(
      result,
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
      ),
    );
    expect(trips.invites, isEmpty);
    expect(workspace.reads, isEmpty);
  });
}
