import '../../../../core/network/api_client.dart';
import '../../../../core/network/legacy_receipt_uploader.dart';
import '../../domain/entities/expense_comment.dart';
import '../../domain/entities/expense_reaction.dart';
import '../../domain/entities/expense_split_value.dart';
import '../../domain/entities/random_draw_result.dart';
import '../../domain/entities/receipt_upload_payload.dart';
import '../../domain/entities/trip_expenses_page.dart';
import '../../domain/entities/uploaded_receipt.dart';
import '../../domain/entities/workspace_notifications_inbox.dart';
import '../../domain/entities/workspace_shared_trip.dart';
import '../../domain/entities/workspace_snapshot.dart';
import 'workspace_remote_mutation_api.dart';
import 'workspace_remote_snapshot_loader.dart';

abstract class WorkspaceRemoteDataSource {
  Future<int> loadCurrentUserId();

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

  Future<UploadedReceiptData> uploadReceipt({
    required ReceiptUploadPayload payload,
  });

  Future<void> addExpense({
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
    String? clientMutationId,
  });

  Future<void> updateExpense({
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
    String? clientMutationId,
  });

  Future<void> deleteExpense({
    required int tripId,
    required int expenseId,
    String? clientMutationId,
  });

  Future<RandomDrawResult> generateOrder({
    required int tripId,
    required List<int> members,
  });

  Future<List<ExpenseReaction>> listExpenseReactions({
    required int expenseId,
    required int tripId,
  });

  Future<void> toggleExpenseReaction({
    required int expenseId,
    required int tripId,
    required String emoji,
  });

  Future<List<ExpenseComment>> listExpenseComments({
    required int expenseId,
    required int tripId,
  });

  Future<ExpenseComment> addExpenseComment({
    required int expenseId,
    required int tripId,
    required String body,
  });

  Future<void> deleteExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
  });
}

class WorkspaceRemoteDataSourceImpl implements WorkspaceRemoteDataSource {
  WorkspaceRemoteDataSourceImpl(
    ApiClient apiClient,
    LegacyReceiptUploader receiptUploader,
  ) : _snapshotLoader = WorkspaceRemoteSnapshotLoader(apiClient),
      _mutationApi = WorkspaceRemoteMutationApi(apiClient, receiptUploader);

  final WorkspaceRemoteSnapshotLoader _snapshotLoader;
  final WorkspaceRemoteMutationApi _mutationApi;

  @override
  Future<int> loadCurrentUserId() {
    return _snapshotLoader.loadCurrentUserId();
  }

  @override
  Future<WorkspaceSnapshot> loadSnapshot({required int tripId}) {
    return _snapshotLoader.loadSnapshot(tripId: tripId);
  }

  @override
  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 50,
    String? cursor,
    int? offset,
  }) {
    return _snapshotLoader.loadExpensesPage(
      tripId: tripId,
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }

  @override
  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit = 80,
    String? cursor,
    int? offset,
  }) {
    return _snapshotLoader.loadGlobalNotifications(
      limit: limit,
      cursor: cursor,
      offset: offset,
    );
  }

  @override
  Future<List<WorkspaceSharedTrip>> loadSharedTripsWithUser({
    required int userId,
    int limit = 20,
  }) {
    return _snapshotLoader.loadSharedTripsWithUser(
      userId: userId,
      limit: limit,
    );
  }

  @override
  Future<void> endTrip({required int tripId}) {
    return _mutationApi.endTrip(tripId: tripId);
  }

  @override
  Future<void> setReadyToSettle({required int tripId, required bool isReady}) {
    return _mutationApi.setReadyToSettle(tripId: tripId, isReady: isReady);
  }

  @override
  Future<void> markSettlementSent({
    required int tripId,
    required int settlementId,
  }) {
    return _mutationApi.markSettlementSent(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  @override
  Future<void> confirmSettlementReceived({
    required int tripId,
    required int settlementId,
  }) {
    return _mutationApi.confirmSettlementReceived(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  @override
  Future<void> remindSettlement({
    required int tripId,
    required int settlementId,
  }) {
    return _mutationApi.remindSettlement(
      tripId: tripId,
      settlementId: settlementId,
    );
  }

  @override
  Future<void> markNotificationsRead({
    required int tripId,
    List<int> notificationIds = const <int>[],
  }) {
    return _mutationApi.markNotificationsRead(
      tripId: tripId,
      notificationIds: notificationIds,
    );
  }

  @override
  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const <int>[],
  }) {
    return _mutationApi.markGlobalNotificationsRead(
      notificationIds: notificationIds,
    );
  }

  @override
  Future<UploadedReceiptData> uploadReceipt({
    required ReceiptUploadPayload payload,
  }) {
    return _mutationApi.uploadReceipt(payload: payload);
  }

  @override
  Future<void> addExpense({
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
    String? clientMutationId,
  }) {
    return _mutationApi.addExpense(
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
      clientMutationId: clientMutationId,
    );
  }

  @override
  Future<void> updateExpense({
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
    String? clientMutationId,
  }) {
    return _mutationApi.updateExpense(
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
      clientMutationId: clientMutationId,
    );
  }

  @override
  Future<void> deleteExpense({
    required int tripId,
    required int expenseId,
    String? clientMutationId,
  }) {
    return _mutationApi.deleteExpense(
      tripId: tripId,
      expenseId: expenseId,
      clientMutationId: clientMutationId,
    );
  }

  @override
  Future<RandomDrawResult> generateOrder({
    required int tripId,
    required List<int> members,
  }) {
    return _mutationApi.generateOrder(tripId: tripId, members: members);
  }

  @override
  Future<List<ExpenseReaction>> listExpenseReactions({
    required int expenseId,
    required int tripId,
  }) {
    return _mutationApi.listExpenseReactions(
      expenseId: expenseId,
      tripId: tripId,
    );
  }

  @override
  Future<void> toggleExpenseReaction({
    required int expenseId,
    required int tripId,
    required String emoji,
  }) {
    return _mutationApi.toggleExpenseReaction(
      expenseId: expenseId,
      tripId: tripId,
      emoji: emoji,
    );
  }

  @override
  Future<List<ExpenseComment>> listExpenseComments({
    required int expenseId,
    required int tripId,
  }) {
    return _mutationApi.listExpenseComments(
      expenseId: expenseId,
      tripId: tripId,
    );
  }

  @override
  Future<ExpenseComment> addExpenseComment({
    required int expenseId,
    required int tripId,
    required String body,
  }) {
    return _mutationApi.addExpenseComment(
      expenseId: expenseId,
      tripId: tripId,
      body: body,
    );
  }

  @override
  Future<void> deleteExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
  }) {
    return _mutationApi.deleteExpenseComment(
      commentId: commentId,
      expenseId: expenseId,
      tripId: tripId,
    );
  }
}
