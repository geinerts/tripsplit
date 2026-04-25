import '../../domain/entities/expense_comment.dart';
import '../../domain/entities/expense_comment_reaction.dart';
import '../../domain/entities/expense_reaction.dart';
import '../../domain/entities/mutation_result.dart';
import '../../domain/entities/queued_mutation.dart';
import '../../domain/entities/random_draw_result.dart';
import '../../domain/entities/expense_split_value.dart';
import '../../domain/entities/receipt_upload_payload.dart';
import '../../domain/entities/trip_expenses_page.dart';
import '../../domain/entities/uploaded_receipt.dart';
import '../../domain/entities/workspace_activity_event.dart';
import '../../domain/entities/workspace_notifications_inbox.dart';
import '../../domain/entities/workspace_shared_trip.dart';
import '../../domain/entities/workspace_snapshot.dart';
import '../../domain/repositories/workspace_repository.dart';

class WorkspaceController {
  WorkspaceController(this._repository);

  final WorkspaceRepository _repository;

  Future<int> loadCurrentUserId() {
    return _repository.loadCurrentUserId();
  }

  Future<WorkspaceSnapshot?> readCachedSnapshot({required int tripId}) {
    return _repository.readCachedSnapshot(tripId: tripId);
  }

  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit = 80,
    String? cursor,
    int? offset,
  }) {
    return _repository.loadGlobalNotifications(
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }

  Future<WorkspaceActivityPage> loadTripActivity({
    required int tripId,
    int limit = 50,
    int? offset,
  }) {
    return _repository.loadTripActivity(
      tripId: tripId,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<WorkspaceSharedTrip>> loadSharedTripsWithUser({
    required int userId,
    int limit = 20,
  }) {
    return _repository.loadSharedTripsWithUser(userId: userId, limit: limit);
  }

  Future<UploadedReceiptData> uploadReceipt({
    required ReceiptUploadPayload payload,
  }) {
    return _repository.uploadReceipt(payload: payload);
  }

  Future<void> endTrip({required int tripId}) {
    return _repository.endTrip(tripId: tripId);
  }

  Future<void> setReadyToSettle({required int tripId, required bool isReady}) {
    return _repository.setReadyToSettle(tripId: tripId, isReady: isReady);
  }

  Future<void> markSettlementSent({
    required int tripId,
    required int settlementId,
  }) {
    return _repository.markSettlementSent(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  Future<void> cancelSettlementSent({
    required int tripId,
    required int settlementId,
  }) {
    return _repository.cancelSettlementSent(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  Future<void> reportSettlementNotReceived({
    required int tripId,
    required int settlementId,
  }) {
    return _repository.reportSettlementNotReceived(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  Future<void> confirmSettlementReceived({
    required int tripId,
    required int settlementId,
  }) {
    return _repository.confirmSettlementReceived(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  Future<void> remindSettlement({
    required int tripId,
    required int settlementId,
  }) {
    return _repository.remindSettlement(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  Future<void> markNotificationsRead({
    required int tripId,
    List<int> notificationIds = const <int>[],
  }) {
    return _repository.markNotificationsRead(
      tripId: tripId,
      notificationIds: notificationIds,
    );
  }

  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const <int>[],
  }) {
    return _repository.markGlobalNotificationsRead(
      notificationIds: notificationIds,
    );
  }

  Future<WorkspaceSnapshot> loadSnapshot({required int tripId}) {
    return _repository.loadSnapshot(tripId: tripId);
  }

  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 50,
    String? cursor,
    int? offset,
  }) {
    return _repository.loadExpensesPage(
      tripId: tripId,
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }

  Future<int> pendingQueueCount({int? tripId}) {
    return _repository.pendingQueueCount(tripId: tripId);
  }

  Future<List<QueuedMutation>> listQueuedMutations({int? tripId}) {
    return _repository.listQueuedMutations(tripId: tripId);
  }

  Future<void> flushPendingMutations() {
    return _repository.flushPendingMutations();
  }

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
  }) {
    return _repository.addExpense(
      tripId: tripId,
      amount: amount,
      currencyCode: currencyCode,
      category: category,
      note: note,
      date: date,
      participants: participants,
      splitMode: splitMode,
      splitValues: splitValues,
      receiptPath: receiptPath,
    );
  }

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
    bool removeReceipt = false,
  }) {
    return _repository.updateExpense(
      tripId: tripId,
      expenseId: expenseId,
      amount: amount,
      currencyCode: currencyCode,
      category: category,
      note: note,
      date: date,
      participants: participants,
      splitMode: splitMode,
      splitValues: splitValues,
      receiptPath: receiptPath,
      removeReceipt: removeReceipt,
    );
  }

  Future<MutationResult> deleteExpense({
    required int tripId,
    required int expenseId,
  }) {
    return _repository.deleteExpense(tripId: tripId, expenseId: expenseId);
  }

  Future<RandomDrawResult> generateOrder({
    required int tripId,
    required List<int> members,
  }) {
    return _repository.generateOrder(tripId: tripId, members: members);
  }

  Future<List<ExpenseReaction>> listExpenseReactions({
    required int expenseId,
    required int tripId,
  }) {
    return _repository.listExpenseReactions(
      expenseId: expenseId,
      tripId: tripId,
    );
  }

  Future<void> toggleExpenseReaction({
    required int expenseId,
    required int tripId,
    required String emoji,
  }) {
    return _repository.toggleExpenseReaction(
      expenseId: expenseId,
      tripId: tripId,
      emoji: emoji,
    );
  }

  Future<List<ExpenseCommentReaction>> listExpenseCommentReactions({
    required int expenseId,
    required int tripId,
  }) {
    return _repository.listExpenseCommentReactions(
      expenseId: expenseId,
      tripId: tripId,
    );
  }

  Future<void> toggleExpenseCommentReaction({
    required int commentId,
    required int expenseId,
    required int tripId,
    required String emoji,
  }) {
    return _repository.toggleExpenseCommentReaction(
      commentId: commentId,
      expenseId: expenseId,
      tripId: tripId,
      emoji: emoji,
    );
  }

  Future<List<ExpenseComment>> listExpenseComments({
    required int expenseId,
    required int tripId,
  }) {
    return _repository.listExpenseComments(
      expenseId: expenseId,
      tripId: tripId,
    );
  }

  Future<ExpenseComment> addExpenseComment({
    required int expenseId,
    required int tripId,
    required String body,
    int? parentCommentId,
  }) {
    return _repository.addExpenseComment(
      expenseId: expenseId,
      tripId: tripId,
      body: body,
      parentCommentId: parentCommentId,
    );
  }

  Future<ExpenseComment> updateExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
    required String body,
  }) {
    return _repository.updateExpenseComment(
      commentId: commentId,
      expenseId: expenseId,
      tripId: tripId,
      body: body,
    );
  }

  Future<void> deleteExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
  }) {
    return _repository.deleteExpenseComment(
      commentId: commentId,
      expenseId: expenseId,
      tripId: tripId,
    );
  }
}
