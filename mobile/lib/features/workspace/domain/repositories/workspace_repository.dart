import '../entities/mutation_result.dart';
import '../entities/queued_mutation.dart';
import '../entities/random_draw_result.dart';
import '../entities/expense_split_value.dart';
import '../entities/receipt_upload_payload.dart';
import '../entities/trip_expenses_page.dart';
import '../entities/uploaded_receipt.dart';
import '../entities/workspace_notifications_inbox.dart';
import '../entities/workspace_shared_trip.dart';
import '../entities/workspace_snapshot.dart';

abstract class WorkspaceRepository {
  Future<int> loadCurrentUserId();

  Future<WorkspaceSnapshot?> readCachedSnapshot({required int tripId});
  Future<WorkspaceSnapshot> loadSnapshot({required int tripId});
  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit,
    String? cursor,
    int? offset,
  });
  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit,
    String? cursor,
    int? offset,
  });
  Future<List<WorkspaceSharedTrip>> loadSharedTripsWithUser({
    required int userId,
    int limit,
  });
  Future<int> pendingQueueCount({int? tripId});
  Future<List<QueuedMutation>> listQueuedMutations({int? tripId});
  Future<void> flushPendingMutations();

  Future<UploadedReceiptData> uploadReceipt({
    required ReceiptUploadPayload payload,
  });

  Future<void> endTrip({required int tripId});
  Future<void> setReadyToSettle({required int tripId, required bool isReady});
  Future<void> markSettlementSent({
    required int tripId,
    required int settlementId,
  });
  Future<void> confirmSettlementReceived({
    required int tripId,
    required int settlementId,
  });
  Future<void> remindSettlement({
    required int tripId,
    required int settlementId,
  });
  Future<void> markNotificationsRead({
    required int tripId,
    List<int> notificationIds = const <int>[],
  });
  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const <int>[],
  });

  Future<MutationResult> addExpense({
    required int tripId,
    required double amount,
    required String currencyCode,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    String? receiptPath,
  });

  Future<MutationResult> updateExpense({
    required int tripId,
    required int expenseId,
    required double amount,
    required String currencyCode,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    String? receiptPath,
    bool removeReceipt,
  });

  Future<MutationResult> deleteExpense({
    required int tripId,
    required int expenseId,
  });

  Future<RandomDrawResult> generateOrder({
    required int tripId,
    required List<int> members,
  });
}
