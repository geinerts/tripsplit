import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../../../../core/network/legacy_receipt_uploader.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/expense_comment.dart';
import '../../domain/entities/expense_comment_reaction.dart';
import '../../domain/entities/expense_reaction.dart';
import '../../domain/entities/expense_split_value.dart';
import '../../domain/entities/random_draw_result.dart';
import '../../domain/entities/receipt_upload_payload.dart';
import '../../domain/entities/uploaded_receipt.dart';
import 'workspace_remote_parsers.dart';

class WorkspaceRemoteMutationApi {
  const WorkspaceRemoteMutationApi(this._apiClient, this._receiptUploader);

  final ApiClient _apiClient;
  final LegacyReceiptUploader _receiptUploader;

  Future<void> endTrip({required int tripId}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('end_trip'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
    );
  }

  Future<void> setReadyToSettle({
    required int tripId,
    required bool isReady,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('set_ready_to_settle'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'is_ready': isReady},
    );
  }

  Future<void> markSettlementSent({
    required int tripId,
    required int settlementId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('mark_settlement_sent'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'settlement_id': settlementId},
    );
  }

  Future<void> cancelSettlementSent({
    required int tripId,
    required int settlementId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('cancel_settlement_sent'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'settlement_id': settlementId},
    );
  }

  Future<void> reportSettlementNotReceived({
    required int tripId,
    required int settlementId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('report_settlement_not_received'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'settlement_id': settlementId},
    );
  }

  Future<void> confirmSettlementReceived({
    required int tripId,
    required int settlementId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('confirm_settlement_received'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'settlement_id': settlementId},
    );
  }

  Future<void> remindSettlement({
    required int tripId,
    required int settlementId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('remind_settlement'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'settlement_id': settlementId},
    );
  }

  Future<void> markNotificationsRead({
    required int tripId,
    List<int> notificationIds = const <int>[],
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('mark_notifications_read'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{
        if (notificationIds.isNotEmpty) 'notification_ids': notificationIds,
      },
    );
  }

  Future<int> markGlobalNotificationsRead({
    List<int> notificationIds = const <int>[],
  }) async {
    Map<String, dynamic> response;
    try {
      response = await _apiClient.request(
        path: ApiEndpoints.legacyAction('mark_notifications_read_global'),
        method: HttpMethod.post,
        body: <String, dynamic>{
          if (notificationIds.isNotEmpty) 'notification_ids': notificationIds,
        },
      );
    } on ApiException catch (error) {
      if (_isMissingGlobalNotificationsAction(error)) {
        return 0;
      }
      rethrow;
    }
    final unreadCount = (response['unread_count'] as num?)?.toInt() ?? 0;
    return unreadCount < 0 ? 0 : unreadCount;
  }

  Future<UploadedReceiptData> uploadReceipt({
    required ReceiptUploadPayload payload,
  }) async {
    final uploaded = await _receiptUploader.uploadReceipt(
      fileName: payload.fileName,
      bytes: payload.bytes,
      tripId: payload.tripId,
    );
    return UploadedReceiptData(
      path: uploaded.receiptPath,
      url: uploaded.receiptUrl,
      thumbUrl: uploaded.receiptThumbUrl,
    );
  }

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
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('add_expense'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId, clientMutationId: clientMutationId),
      body: <String, dynamic>{
        'amount': amount,
        'currency_code': currencyCode,
        'category': category,
        'note': note,
        'date': date,
        'participants': participants,
        'split_mode': splitMode,
        if (splitValues.isNotEmpty)
          'splits': splitValues
              .map(
                (item) => <String, dynamic>{
                  'user_id': item.userId,
                  'value': item.value,
                },
              )
              .toList(growable: false),
        if (receiptPath != null && receiptPath.trim().isNotEmpty)
          'receipt_path': receiptPath,
      },
    );
  }

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
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('update_expense'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId, clientMutationId: clientMutationId),
      body: <String, dynamic>{
        'id': expenseId,
        'amount': amount,
        'currency_code': currencyCode,
        'category': category,
        'note': note,
        'date': date,
        'participants': participants,
        'split_mode': splitMode,
        if (splitValues.isNotEmpty)
          'splits': splitValues
              .map(
                (item) => <String, dynamic>{
                  'user_id': item.userId,
                  'value': item.value,
                },
              )
              .toList(growable: false),
        if (receiptPath != null && receiptPath.trim().isNotEmpty)
          'receipt_path': receiptPath,
        if (removeReceipt) 'remove_receipt': true,
      },
    );
  }

  Future<void> deleteExpense({
    required int tripId,
    required int expenseId,
    String? clientMutationId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('delete_expense'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId, clientMutationId: clientMutationId),
      body: <String, dynamic>{'id': expenseId},
    );
  }

  Future<RandomDrawResult> generateOrder({
    required int tripId,
    required List<int> members,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('generate_order'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'members': members},
    );

    return RandomDrawResult(
      pickedUserId: (response['picked_user_id'] as num?)?.toInt() ?? 0,
      pickedUserNickname: response['picked_user_nickname'] as String? ?? '',
      membersIds: WorkspaceRemoteParsers.toIntList(response['members_ids']),
      remainingIds: WorkspaceRemoteParsers.toIntList(response['remaining_ids']),
      remainingCount: (response['remaining_count'] as num?)?.toInt() ?? 0,
      cycleNo: (response['cycle_no'] as num?)?.toInt() ?? 1,
      drawNo: (response['draw_no'] as num?)?.toInt() ?? 1,
      cycleCompleted: response['cycle_completed'] == true,
    );
  }

  // ── Expense social ────────────────────────────────────────────────────────

  Future<List<ExpenseReaction>> listExpenseReactions({
    required int expenseId,
    required int tripId,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('list_expense_reactions'),
      method: HttpMethod.get,
      headers: _tripHeaders(tripId),
      query: <String, dynamic>{'expense_id': '$expenseId'},
    );
    final raw = response['reactions'];
    if (raw is! List) return const [];
    return raw
        .map((item) {
          final m = item as Map<String, dynamic>;
          return ExpenseReaction(
            emoji: m['emoji'] as String? ?? '',
            userId: (m['user_id'] as num?)?.toInt() ?? 0,
            userNickname: m['nickname'] as String? ?? '',
            createdAt: m['created_at'] as String? ?? '',
          );
        })
        .toList(growable: false);
  }

  Future<void> toggleExpenseReaction({
    required int expenseId,
    required int tripId,
    required String emoji,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('toggle_expense_reaction'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'expense_id': expenseId, 'emoji': emoji},
    );
  }

  Future<List<ExpenseCommentReaction>> listExpenseCommentReactions({
    required int expenseId,
    required int tripId,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('list_expense_comment_reactions'),
      method: HttpMethod.get,
      headers: _tripHeaders(tripId),
      query: <String, dynamic>{'expense_id': '$expenseId'},
    );
    final raw = response['reactions'];
    if (raw is! List) return const [];
    return raw
        .map((item) {
          final m = item as Map<String, dynamic>;
          return ExpenseCommentReaction(
            commentId: (m['comment_id'] as num?)?.toInt() ?? 0,
            emoji: m['emoji'] as String? ?? '',
            userId: (m['user_id'] as num?)?.toInt() ?? 0,
            userNickname: m['nickname'] as String? ?? '',
            createdAt: m['created_at'] as String? ?? '',
          );
        })
        .toList(growable: false);
  }

  Future<void> toggleExpenseCommentReaction({
    required int commentId,
    required int expenseId,
    required int tripId,
    required String emoji,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('toggle_expense_comment_reaction'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{
        'comment_id': commentId,
        'expense_id': expenseId,
        'emoji': emoji,
      },
    );
  }

  Future<List<ExpenseComment>> listExpenseComments({
    required int expenseId,
    required int tripId,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('list_expense_comments'),
      method: HttpMethod.get,
      headers: _tripHeaders(tripId),
      query: <String, dynamic>{'expense_id': '$expenseId'},
    );
    final raw = response['comments'];
    if (raw is! List) return const [];
    return raw
        .map((item) {
          final m = item as Map<String, dynamic>;
          return ExpenseComment(
            id: (m['id'] as num?)?.toInt() ?? 0,
            userId: (m['user_id'] as num?)?.toInt() ?? 0,
            userNickname: m['nickname'] as String? ?? '',
            body: m['body'] as String? ?? '',
            createdAt: m['created_at'] as String? ?? '',
            parentCommentId: (m['parent_comment_id'] as num?)?.toInt(),
            parentUserNickname: m['reply_to_nickname'] as String?,
            parentBody: m['reply_to_body'] as String?,
          );
        })
        .toList(growable: false);
  }

  Future<ExpenseComment> addExpenseComment({
    required int expenseId,
    required int tripId,
    required String body,
    int? parentCommentId,
  }) async {
    final payload = <String, dynamic>{'expense_id': expenseId, 'body': body};
    if ((parentCommentId ?? 0) > 0) {
      payload['parent_comment_id'] = parentCommentId;
    }
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('add_expense_comment'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: payload,
    );
    final m = response['comment'] as Map<String, dynamic>;
    return ExpenseComment(
      id: (m['id'] as num?)?.toInt() ?? 0,
      userId: (m['user_id'] as num?)?.toInt() ?? 0,
      userNickname: m['nickname'] as String? ?? '',
      body: m['body'] as String? ?? '',
      createdAt: m['created_at'] as String? ?? '',
      parentCommentId: (m['parent_comment_id'] as num?)?.toInt(),
      parentUserNickname: m['reply_to_nickname'] as String?,
      parentBody: m['reply_to_body'] as String?,
    );
  }

  Future<ExpenseComment> updateExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
    required String body,
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('update_expense_comment'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{
        'comment_id': commentId,
        'expense_id': expenseId,
        'body': body,
      },
    );
    final m = response['comment'] as Map<String, dynamic>;
    return ExpenseComment(
      id: (m['id'] as num?)?.toInt() ?? 0,
      userId: (m['user_id'] as num?)?.toInt() ?? 0,
      userNickname: m['nickname'] as String? ?? '',
      body: m['body'] as String? ?? '',
      createdAt: m['created_at'] as String? ?? '',
      parentCommentId: (m['parent_comment_id'] as num?)?.toInt(),
      parentUserNickname: m['reply_to_nickname'] as String?,
      parentBody: m['reply_to_body'] as String?,
    );
  }

  Future<void> deleteExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('delete_expense_comment'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'comment_id': commentId, 'expense_id': expenseId},
    );
  }

  Map<String, String> _tripHeaders(int tripId, {String? clientMutationId}) {
    final headers = <String, String>{'X-Trip-Id': '$tripId'};
    final mutationId = (clientMutationId ?? '').trim();
    if (mutationId.isNotEmpty) {
      headers['X-Client-Mutation-Id'] = mutationId;
    }
    return headers;
  }

  bool _isMissingGlobalNotificationsAction(ApiException error) {
    final normalized = error.message.toLowerCase();
    final statusCode = error.statusCode ?? 0;
    if (statusCode != 404 && statusCode != 400) {
      return false;
    }
    return normalized.contains('unknown action');
  }
}
