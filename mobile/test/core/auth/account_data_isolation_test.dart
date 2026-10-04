import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/trips/data/datasources/trips_remote_data_source.dart';
import 'package:tripsplit/features/trips/data/local/trips_local_store.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/data/repositories/trips_repository_impl.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_local_store.dart';
import 'package:tripsplit/features/workspace/data/repositories/workspace_offline_queue.dart';
import 'package:tripsplit/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_notifications_inbox.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_snapshot.dart';

final changed = throwsA(
  isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
);
const offline = ApiException('Offline', isNetworkError: true);

class _TripsRemote implements TripsRemoteDataSource {
  final result = Completer<List<TripModel>>();
  @override
  Future<List<TripModel>> listTrips() => result.future;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WorkspaceRemote implements WorkspaceRemoteDataSource {
  final sent = <int>[];
  final entered = Completer<void>();
  final release = Completer<void>();
  bool blockFirst = true;
  bool fail = false;
  @override
  Future<void> deleteExpense({
    required int tripId,
    required int expenseId,
    String? clientMutationId,
  }) async {
    sent.add(expenseId);
    if (!entered.isCompleted) entered.complete();
    if (blockFirst && sent.length == 1) await release.future;
    if (fail) throw offline;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TripModel trip(String name) => TripModel.fromLegacyMap({'id': 7, 'name': name});

WorkspaceSnapshot snapshot(int unread) => WorkspaceSnapshot(
  tripStatus: 'active',
  tripEndedAt: null,
  tripArchivedAt: null,
  users: [],
  balances: [],
  settlements: [],
  payments: [],
  settlementTotal: 0,
  settlementConfirmed: 0,
  settlementRemaining: 0,
  allSettled: false,
  unreadNotifications: unread,
  notifications: [],
  expenses: [],
  orders: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AccountDataSession session;
  late AccountLocalStorage storage;
  late WorkspaceLocalStore workspace;
  late TripsLocalStore trips;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    session = AccountDataSession(namespace: 'https://splyto.test')..activate(1);
    storage = AccountLocalStorage(session);
    workspace = WorkspaceLocalStore(storage);
    trips = TripsLocalStore(storage);
  });

  test(
    'trips, same-ID snapshots, inbox and queue belong only to their account',
    () async {
      await trips.writeTrips([trip('Private A')]);
      await workspace.writeSnapshot(tripId: 7, snapshot: snapshot(11));
      await workspace.writeGlobalNotificationsInbox(
        const WorkspaceNotificationsInbox(unreadCount: 11, notifications: []),
      );
      await workspace.enqueue({'id': 'A', 'trip_id': 7});
      session.activate(2);
      expect(await trips.readTrips(), isEmpty);
      expect(await workspace.readSnapshot(tripId: 7), isNull);
      expect(await workspace.readGlobalNotificationsInbox(), isNull);
      expect(await workspace.readQueue(), isEmpty);
      await trips.writeTrips([trip('Private B')]);
      await workspace.writeSnapshot(tripId: 7, snapshot: snapshot(22));
      await workspace.enqueue({'id': 'B', 'trip_id': 7});
      session.activate(1);
      expect((await trips.readTrips()).single.name, 'Private A');
      expect(
        (await workspace.readSnapshot(tripId: 7))!.unreadNotifications,
        11,
      );
      expect((await workspace.readGlobalNotificationsInbox())!.unreadCount, 11);
      expect((await workspace.readQueue()).single['id'], 'A');
    },
  );

  test(
    'same-account restart restores only that account; API environments are isolated',
    () async {
      await trips.writeTrips([trip('Private A')]);
      final restart = AccountDataSession(namespace: session.namespace)
        ..activate(1);
      expect(
        (await TripsLocalStore(
          AccountLocalStorage(restart),
        ).readTrips()).single.name,
        'Private A',
      );
      final otherHost = AccountDataSession(namespace: 'https://other.test')
        ..activate(1);
      expect(
        await TripsLocalStore(AccountLocalStorage(otherHost)).readTrips(),
        isEmpty,
      );
    },
  );

  test(
    'signed-out access fails closed and logout cleanup cannot be undone by an old write',
    () async {
      await trips.writeTrips([trip('Private A')]);
      final late = trips.writeTrips([trip('Late A')]);
      final rejected = expectLater(late, changed);
      session.invalidate();
      await storage.clear();
      await rejected;
      await expectLater(trips.readTrips(), changed);
      session.activate(1);
      expect(await trips.readTrips(), isEmpty);
    },
  );

  test(
    'legacy caches are discarded; unowned mutations are quarantined, never adopted',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'trips_list_cache_v1',
        jsonEncode([
          {'id': 7, 'name': 'Unknown owner'},
        ]),
      );
      await prefs.setString('workspace_snapshot_trip_v5_7', '{}');
      const oldQueue = '[{"id":"legacy","trip_id":7}]';
      await prefs.setString('workspace_mutation_queue_v1', oldQueue);
      expect(await trips.readTrips(), isEmpty);
      expect(await workspace.readQueue(), isEmpty);
      expect(prefs.containsKey('workspace_snapshot_trip_v5_7'), isFalse);
      expect(prefs.getString('unassigned_workspace_queue_v1'), oldQueue);
      expect(prefs.containsKey('workspace_mutation_queue_v1'), isFalse);
    },
  );

  test(
    'queue rejects an ownership mismatch inside the account namespace',
    () async {
      await storage.write(
        'workspace_mutation_queue_v1',
        '[{"id":"forged","owner_user_id":2}]',
      );
      expect(await workspace.readQueue(), isEmpty);
    },
  );

  for (final networkFailure in [false, true]) {
    test(
      'late trips response cannot write or fall back to the next account: $networkFailure',
      () async {
        final remote = _TripsRemote();
        final repository = TripsRepositoryImpl(remote, trips);
        final pending = repository.listTrips();
        final rejected = expectLater(pending, changed);
        session.activate(2);
        await trips.writeTrips([trip('Private B')]);
        if (networkFailure) {
          remote.result.completeError(offline);
        } else {
          remote.result.complete([trip('Private A')]);
        }
        await rejected;
        expect((await trips.readTrips()).single.name, 'Private B');
      },
    );
  }

  test(
    'failed old-account mutation is never queued under the next account',
    () async {
      final remote = _WorkspaceRemote()..fail = true;
      final repository = WorkspaceRepositoryImpl(remote, workspace);
      final pending = repository.deleteExpense(tripId: 7, expenseId: 101);
      final rejected = expectLater(pending, changed);
      await remote.entered.future;
      session.activate(2);
      remote.release.complete();
      await rejected;
      expect(await workspace.readQueue(), isEmpty);
    },
  );

  test(
    'switching during flush stops subsequent sends and leaves next account intact',
    () async {
      final remote = _WorkspaceRemote();
      final queue = WorkspaceOfflineQueue(
        remote: remote,
        localStore: workspace,
      );
      await queue.enqueueDeleteExpense(tripId: 7, expenseId: 101);
      await queue.enqueueDeleteExpense(tripId: 7, expenseId: 102);
      final flushing = queue.flushBestEffort();
      final rejected = expectLater(flushing, changed);
      await remote.entered.future;
      session.activate(2);
      await queue.enqueueDeleteExpense(tripId: 7, expenseId: 201);
      remote.release.complete();
      await rejected;
      expect(remote.sent, [101]);
      expect(
        (await workspace.readQueue()).single['payload']['expense_id'],
        201,
      );
    },
  );

  test(
    'concurrent flushes share work and preserve newly enqueued items',
    () async {
      final remote = _WorkspaceRemote();
      final queue = WorkspaceOfflineQueue(
        remote: remote,
        localStore: workspace,
      );
      await queue.enqueueDeleteExpense(tripId: 7, expenseId: 101);
      final first = queue.flushBestEffort();
      await remote.entered.future;
      final second = queue.flushBestEffort();
      await queue.enqueueDeleteExpense(tripId: 7, expenseId: 102);
      remote.release.complete();
      await Future.wait([first, second]);
      expect(remote.sent, [101]);
      expect(
        (await workspace.readQueue()).single['payload']['expense_id'],
        102,
      );
      await queue.flushBestEffort();
      expect(remote.sent, [101, 102]);
      expect(await workspace.readQueue(), isEmpty);
    },
  );

  test('parallel enqueues cannot overwrite one another', () async {
    await Future.wait(
      List.generate(30, (i) => workspace.enqueue({'id': '$i'})),
    );
    expect(
      (await workspace.readQueue()).map((item) => item['id']).toSet(),
      hasLength(30),
    );
  });

  test(
    'relogin to the same user still invalidates the old async generation',
    () async {
      final pending = Completer<void>();
      final oldWork = session.run(() async {
        await pending.future;
        await storage.write('private', 'old session');
      });
      final rejected = expectLater(oldWork, changed);
      session.invalidate();
      session.activate(1);
      await storage.write('private', 'new session');
      pending.complete();
      await rejected;
      expect(await storage.read('private'), 'new session');
    },
  );
}
