import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_local_store.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_snapshot_codec.dart';
import 'package:tripsplit/features/workspace/data/repositories/workspace_repository_impl.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_snapshot.dart';

WorkspaceSnapshot snapshot() => WorkspaceSnapshotCodec.fromMap({
  'users': [
    {'id': 7, 'nickname': 'Matiss', 'is_ready_to_settle': false},
    {'id': 8, 'nickname': 'Igors', 'is_ready_to_settle': true},
  ],
  'notifications': [
    {'id': 1, 'is_read': false},
  ],
});

class Remote extends Fake implements WorkspaceRemoteDataSource {
  bool offline = true;
  final mutationIds = <String?>[];
  final confirmed = <String, Map<String, dynamic>>{};
  @override
  Future<WorkspaceSnapshot> loadSnapshot({required int tripId}) async {
    if (offline) throw const ApiException('Offline', isNetworkError: true);
    final map = WorkspaceSnapshotCodec.toMap(snapshot());
    map['expenses'] = confirmed.values.toList();
    return WorkspaceSnapshotCodec.fromMap(map);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #addExpense) {
      return Future<void>(() {
        final args = invocation.namedArguments;
        final id = args[#clientMutationId] as String;
        mutationIds.add(id);
        if (offline) throw const ApiException('Offline', isNetworkError: true);
        confirmed.putIfAbsent(
          id,
          () => {
            'id': confirmed.length + 1,
            'amount': args[#amount],
            'original_amount': args[#amount],
            'category': args[#category],
            'note': args[#note],
            'expense_date': args[#date],
            'paid_by_id': 7,
          },
        );
      });
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'active trip with not-ready users and unread notifications survives restart',
    () async {
      final storage = AccountLocalStorage(AccountDataSession()..activate(7));
      await WorkspaceLocalStore(
        storage,
      ).writeSnapshot(tripId: 1, snapshot: snapshot());
      final restored = await WorkspaceLocalStore(
        AccountLocalStorage(AccountDataSession()..activate(7)),
      ).readSnapshot(tripId: 1);
      expect(restored, isNotNull);
      expect(restored!.users.first.isReadyToSettle, isFalse);
      expect(restored.users.last.isReadyToSettle, isTrue);
      expect(restored.notifications.single.isRead, isFalse);
      expect(restored.isActive, isTrue);
    },
  );

  test('legacy boolean representations remain readable', () {
    for (final value in [
      false,
      true,
      0,
      1,
      '0',
      '1',
      ' true ',
      'false',
      null,
    ]) {
      final read = WorkspaceSnapshotCodec.fromMap({
        'users': [
          {'id': 7, 'is_ready_to_settle': value},
        ],
        'notifications': [
          {'id': 1, 'is_read': value},
        ],
      });
      final expected = [true, 1, '1', ' true '].contains(value);
      expect(read.users.single.isReadyToSettle, expected);
      expect(read.notifications.single.isRead, expected);
    }
  });

  test(
    'offline expense survives repository restart and syncs once with the same mutation id',
    () async {
      final remote = Remote();
      final store = WorkspaceLocalStore(
        AccountLocalStorage(AccountDataSession()..activate(7)),
      );
      await store.writeSnapshot(tripId: 1, snapshot: snapshot());
      final repository = WorkspaceRepositoryImpl(remote, store);
      final result = await repository.addExpense(
        tripId: 1,
        amount: 10.01,
        currencyCode: 'EUR',
        category: 'food',
        note: 'Lunch',
        date: '2026-11-09',
        participants: [7, 8],
        splitMode: 'equal',
        splitValues: [],
        paidBy: 7,
      );
      expect(result.queued, isTrue);
      final restartedStore = WorkspaceLocalStore(
        AccountLocalStorage(AccountDataSession()..activate(7)),
      );
      final restarted = WorkspaceRepositoryImpl(remote, restartedStore);
      final cached = (await restarted.readCachedSnapshot(tripId: 1))!;
      final expense = cached.expenses.single;
      expect(expense.id, isNegative);
      expect(expense.note, 'Lunch [queued]');
      expect(expense.amount, 10.01);
      expect(expense.participants.map((p) => p.owedAmount), [5.01, 5.00]);
      expect((await restartedStore.readSnapshot(tripId: 1))!.expenses, isEmpty);
      expect((await restarted.loadSnapshot(tripId: 1)).expenses, hasLength(1));
      expect(await restarted.pendingQueueCount(), 1);
      remote.offline = false;
      final synced = await restarted.loadSnapshot(tripId: 1);
      expect(synced.expenses.single.id, isPositive);
      expect(synced.expenses.single.note, 'Lunch');
      expect(await restarted.pendingQueueCount(), 0);
      expect(remote.mutationIds.toSet(), hasLength(1));
      expect(remote.confirmed, hasLength(1));
      expect(
        (await restarted.readCachedSnapshot(tripId: 1))!.expenses,
        hasLength(1),
      );
      final other = WorkspaceRepositoryImpl(
        remote,
        WorkspaceLocalStore(
          AccountLocalStorage(AccountDataSession()..activate(8)),
        ),
      );
      expect(await other.readCachedSnapshot(tripId: 1), isNull);
      expect(await other.pendingQueueCount(), 0);
    },
  );

  test(
    'pending edits and deletes overlay only their trip and do not change server cache',
    () async {
      final store = WorkspaceLocalStore(
        AccountLocalStorage(AccountDataSession()..activate(7)),
      );
      final base = WorkspaceSnapshotCodec.fromMap({
        ...WorkspaceSnapshotCodec.toMap(snapshot()),
        'expenses': [
          {'id': 11, 'amount': 10, 'category': 'food'},
          {'id': 12, 'amount': 20, 'category': 'transport'},
        ],
      });
      await store.writeSnapshot(tripId: 1, snapshot: base);
      await store.enqueue({
        'id': 'edit',
        'type': 'update_expense',
        'trip_id': 1,
        'payload': {
          'expense_id': 11,
          'amount': 15,
          'note': 'Updated',
          'participants': [7, 8],
          'split_mode': 'exact',
          'splits': [
            {'user_id': 7, 'value': 5},
            {'user_id': 8, 'value': 10},
          ],
        },
      });
      await store.enqueue({
        'id': 'delete',
        'type': 'delete_expense',
        'trip_id': 1,
        'payload': {'expense_id': 12},
      });
      await store.enqueue({
        'id': 'other',
        'type': 'delete_expense',
        'trip_id': 2,
        'payload': {'expense_id': 11},
      });
      final repo = WorkspaceRepositoryImpl(Remote(), store);
      final restored = (await repo.readCachedSnapshot(tripId: 1))!;
      expect(restored.expenses.single.amount, 15);
      expect(restored.expenses.single.participants.map((p) => p.owedAmount), [
        5,
        10,
      ]);
      expect((await store.readSnapshot(tripId: 1))!.expenses.length, 2);
    },
  );
}
