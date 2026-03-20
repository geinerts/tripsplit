import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/expense_split_value.dart';
import '../../domain/entities/mutation_result.dart';
import '../../domain/entities/queued_mutation.dart';
import '../../domain/entities/random_draw_result.dart';
import '../../domain/entities/receipt_upload_payload.dart';
import '../../domain/entities/trip_expenses_page.dart';
import '../../domain/entities/uploaded_receipt.dart';
import '../../domain/entities/workspace_notifications_inbox.dart';
import '../../domain/entities/workspace_snapshot.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/workspace_remote_data_source.dart';
import '../local/workspace_local_store.dart';
import 'workspace_offline_queue.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  WorkspaceRepositoryImpl(this._remote, this._localStore)
    : _offlineQueue = WorkspaceOfflineQueue(
        remote: _remote,
        localStore: _localStore,
      );

  final WorkspaceRemoteDataSource _remote;
  final WorkspaceLocalStore _localStore;
  final WorkspaceOfflineQueue _offlineQueue;

  @override
  Future<int> loadCurrentUserId() {
    return _remote.loadCurrentUserId();
  }

  @override
  Future<WorkspaceSnapshot?> readCachedSnapshot({required int tripId}) {
    return _localStore.readSnapshot(tripId: tripId);
  }

  @override
  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit = 80,
    String? cursor,
    int? offset,
  }) async {
    final isFirstPage =
        (cursor == null || cursor.trim().isEmpty) &&
        (offset == null || offset <= 0);
    try {
      final inbox = await _remote.loadGlobalNotifications(
        limit: limit,
        cursor: cursor,
        offset: offset,
      );
      if (isFirstPage) {
        await _localStore.writeGlobalNotificationsInbox(inbox);
      }
      return inbox;
    } on ApiException catch (error) {
      if (!error.isNetworkError || !isFirstPage) {
        rethrow;
      }
      final cached = await _localStore.readGlobalNotificationsInbox();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<UploadedReceiptData> uploadReceipt({
    required ReceiptUploadPayload payload,
  }) {
    return _remote.uploadReceipt(payload: payload);
  }

  @override
  Future<void> endTrip({required int tripId}) {
    return _remote.endTrip(tripId: tripId);
  }

  @override
  Future<void> setReadyToSettle({
    required int tripId,
    required bool isReady,
  }) {
    return _remote.setReadyToSettle(tripId: tripId, isReady: isReady);
  }

  @override
  Future<void> markSettlementSent({
    required int tripId,
    required int settlementId,
  }) {
    return _remote.markSettlementSent(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  @override
  Future<void> confirmSettlementReceived({
    required int tripId,
    required int settlementId,
  }) {
    return _remote.confirmSettlementReceived(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  @override
  Future<void> remindSettlement({
    required int tripId,
    required int settlementId,
  }) {
    return _remote.remindSettlement(tripId: tripId, settlementId: settlementId);
  }

  @override
  Future<void> markNotificationsRead({
    required int tripId,
    List<int> notificationIds = const <int>[],
  }) {
    return _remote.markNotificationsRead(
      tripId: tripId,
      notificationIds: notificationIds,
    );
  }

  @override
  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const <int>[],
  }) {
    return _remote.markGlobalNotificationsRead(
      notificationIds: notificationIds,
    );
  }

  @override
  Future<WorkspaceSnapshot> loadSnapshot({required int tripId}) async {
    await _offlineQueue.flushBestEffort();

    try {
      final snapshot = await _remote.loadSnapshot(tripId: tripId);
      await _localStore.writeSnapshot(tripId: tripId, snapshot: snapshot);
      return snapshot;
    } on ApiException catch (error) {
      if (!error.isNetworkError) {
        rethrow;
      }

      final cached = await _localStore.readSnapshot(tripId: tripId);
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 50,
    String? cursor,
    int? offset,
  }) {
    return _remote.loadExpensesPage(
      tripId: tripId,
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }

  @override
  Future<int> pendingQueueCount({int? tripId}) {
    return _offlineQueue.pendingCount(tripId: tripId);
  }

  @override
  Future<List<QueuedMutation>> listQueuedMutations({int? tripId}) {
    return _offlineQueue.listQueuedMutations(tripId: tripId);
  }

  @override
  Future<MutationResult> addExpense({
    required int tripId,
    required double amount,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    String? receiptPath,
  }) {
    return _runMutationOrQueue(
      remoteAction: () {
        return _remote.addExpense(
          tripId: tripId,
          amount: amount,
          category: category,
          note: note,
          date: date,
          participants: participants,
          splitMode: splitMode,
          splitValues: splitValues,
          receiptPath: receiptPath,
        );
      },
      enqueueOnNetworkError: () {
        return _offlineQueue.enqueueAddExpense(
          tripId: tripId,
          amount: amount,
          category: category,
          note: note,
          date: date,
          participants: participants,
          splitMode: splitMode,
          splitValues: splitValues,
          receiptPath: receiptPath,
        );
      },
    );
  }

  @override
  Future<MutationResult> updateExpense({
    required int tripId,
    required int expenseId,
    required double amount,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    String? receiptPath,
    bool removeReceipt = false,
  }) {
    return _runMutationOrQueue(
      remoteAction: () {
        return _remote.updateExpense(
          tripId: tripId,
          expenseId: expenseId,
          amount: amount,
          category: category,
          note: note,
          date: date,
          participants: participants,
          splitMode: splitMode,
          splitValues: splitValues,
          receiptPath: receiptPath,
          removeReceipt: removeReceipt,
        );
      },
      enqueueOnNetworkError: () {
        return _offlineQueue.enqueueUpdateExpense(
          tripId: tripId,
          expenseId: expenseId,
          amount: amount,
          category: category,
          note: note,
          date: date,
          participants: participants,
          splitMode: splitMode,
          splitValues: splitValues,
          receiptPath: receiptPath,
          removeReceipt: removeReceipt,
        );
      },
    );
  }

  @override
  Future<MutationResult> deleteExpense({
    required int tripId,
    required int expenseId,
  }) {
    return _runMutationOrQueue(
      remoteAction: () {
        return _remote.deleteExpense(tripId: tripId, expenseId: expenseId);
      },
      enqueueOnNetworkError: () {
        return _offlineQueue.enqueueDeleteExpense(
          tripId: tripId,
          expenseId: expenseId,
        );
      },
    );
  }

  @override
  Future<RandomDrawResult> generateOrder({
    required int tripId,
    required List<int> members,
  }) {
    return _remote.generateOrder(tripId: tripId, members: members);
  }

  Future<MutationResult> _runMutationOrQueue({
    required Future<void> Function() remoteAction,
    required Future<void> Function() enqueueOnNetworkError,
  }) async {
    try {
      await remoteAction();
      return const MutationResult(queued: false);
    } on ApiException catch (error) {
      if (!error.isNetworkError) {
        rethrow;
      }

      await enqueueOnNetworkError();
      return const MutationResult(queued: true);
    }
  }
}
