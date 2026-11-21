import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../../../../core/network/legacy_receipt_uploader.dart';
import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/comment_mention_text.dart';
import '../../domain/entities/expense_comment.dart';
import '../../domain/entities/expense_comment_mention.dart';
import '../../domain/entities/expense_comment_reaction.dart';
import '../../domain/entities/expense_reaction.dart';
import '../../domain/entities/expense_item.dart';
import '../../domain/entities/expense_split_value.dart';
import '../../domain/entities/random_draw_result.dart';
import '../../domain/entities/receipt_scan.dart';
import '../../domain/entities/receipt_upload_payload.dart';
import '../../domain/entities/uploaded_receipt.dart';
import 'workspace_remote_parsers.dart';

/// How long the app waits for one receipt reading: the AI call may take up to
/// 30 s on the server (docs/api/receipt-scan.md), plus upload and checks.
const receiptScanTimeout = Duration(seconds: 50);

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

  Future<void> createTripPayment({
    required int tripId,
    required int toUserId,
    required double amount,
    String note = '',
    String? clientMutationId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('create_trip_payment'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId, clientMutationId: clientMutationId),
      body: <String, dynamic>{
        'to_user_id': toUserId,
        'amount': amount,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  Future<void> createTripPaymentRequest({
    bool sharePaymentDetails = false,
    required int tripId,
    required int fromUserId,
    required double amount,
    String note = '',
    String? clientMutationId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('create_trip_payment_request'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId, clientMutationId: clientMutationId),
      body: <String, dynamic>{
        'from_user_id': fromUserId,
        'share_payment_details': sharePaymentDetails,
        'amount': amount,
        if (note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
  }

  Future<void> markTripPaymentRequestSent({
    required int tripId,
    required int paymentId,
  }) async {
    await _postPaymentRequestAction(
      action: 'mark_trip_payment_request_sent',
      tripId: tripId,
      paymentId: paymentId,
    );
  }

  Future<void> cancelTripPaymentRequest({
    required int tripId,
    required int paymentId,
  }) async {
    await _postPaymentRequestAction(
      action: 'cancel_trip_payment_request',
      tripId: tripId,
      paymentId: paymentId,
    );
  }

  Future<void> declineTripPaymentRequest({
    required int tripId,
    required int paymentId,
  }) async {
    await _postPaymentRequestAction(
      action: 'decline_trip_payment_request',
      tripId: tripId,
      paymentId: paymentId,
    );
  }

  Future<void> _postPaymentRequestAction({
    required String action,
    required int tripId,
    required int paymentId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction(action),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'payment_id': paymentId},
    );
  }

  Future<void> confirmTripPaymentReceived({
    required int tripId,
    required int paymentId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('confirm_trip_payment_received'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'payment_id': paymentId},
    );
  }

  Future<void> cancelTripPaymentSent({
    required int tripId,
    required int paymentId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('cancel_trip_payment_sent'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'payment_id': paymentId},
    );
  }

  Future<void> reportTripPaymentNotReceived({
    required int tripId,
    required int paymentId,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('report_trip_payment_not_received'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'payment_id': paymentId},
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

  /// Reads an uploaded receipt with AI (docs/api/receipt-scan.md). The same
  /// [requestId] never starts a second AI call; asking again returns the
  /// result once ready, or `scan_in_progress` while it runs.
  Future<ReceiptScan> scanReceipt({
    required String receiptPath,
    required String requestId,
  }) async {
    final path = ApiEndpoints.legacyAction('scan_receipt');
    final body = <String, dynamic>{
      'receipt_path': receiptPath,
      'request_id': requestId,
    };
    // Reading takes up to 30 s on the server; waiting for it must not make
    // the rest of the app think it is offline.
    final client = _apiClient;
    final response = client is SlowApiClient
        ? await client.requestSlow(
            path: path,
            method: HttpMethod.post,
            timeout: receiptScanTimeout,
            body: body,
          )
        : await client.request(path: path, method: HttpMethod.post, body: body);
    final scan = response['scan'];
    if (scan is! Map) {
      throw const ApiException('Receipt reading failed.');
    }
    return ReceiptScan.fromJson(Map<String, dynamic>.from(scan));
  }

  /// Returns the new expense id.
  Future<int?> addExpense({
    required int tripId,
    required double amount,
    required String currencyCode,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    List<ExpenseItem> items = const [],
    double extraAmount = 0,
    String? subcategory,
    int? paidBy,
    String? receiptPath,
    String? clientMutationId,
  }) async {
    final response = await _apiClient.request(
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
        if (items.isNotEmpty)
          'items': items.map((item) => item.toJson()).toList(growable: false),
        if (extraAmount > 0) 'extra_amount': extraAmount,
        'subcategory': ?subcategory,
        'paid_by': ?paidBy,
        if (receiptPath != null && receiptPath.trim().isNotEmpty)
          'receipt_path': receiptPath,
      },
    );
    final id = response['expense_id'];
    return id is num ? id.toInt() : null;
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
    List<ExpenseItem> items = const [],
    double extraAmount = 0,
    String? subcategory,
    bool subcategorySet = true,
    int? paidBy,
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
        if (items.isNotEmpty)
          'items': items.map((item) => item.toJson()).toList(growable: false),
        if (extraAmount > 0) 'extra_amount': extraAmount,
        // Always sent: null removes the type, omitted keeps it (old queue).
        if (subcategorySet) 'subcategory': subcategory,
        'paid_by': ?paidBy,
        if (receiptPath != null && receiptPath.trim().isNotEmpty)
          'receipt_path': receiptPath,
        if (removeReceipt) 'remove_receipt': true,
      },
    );
  }

  Future<void> addTripGuest({required int tripId, required String name}) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('add_trip_guest'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'name': name},
    );
  }

  Future<void> renameTripGuest({
    required int tripId,
    required int userId,
    required String name,
  }) async {
    await _apiClient.request(
      path: ApiEndpoints.legacyAction('rename_trip_guest'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{'user_id': userId, 'name': name},
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

  ExpenseComment _expenseCommentFromJson(Map<String, dynamic> m) {
    final rawMentions = m['mentions'];
    return ExpenseComment(
      id: (m['id'] as num?)?.toInt() ?? 0,
      userId: (m['user_id'] as num?)?.toInt() ?? 0,
      userNickname: m['nickname'] as String? ?? '',
      body: m['body'] as String? ?? '',
      createdAt: m['created_at'] as String? ?? '',
      parentCommentId: (m['parent_comment_id'] as num?)?.toInt(),
      parentUserNickname: m['reply_to_nickname'] as String?,
      parentBody: m['reply_to_body'] as String?,
      mentions: rawMentions is List
          ? rawMentions
                .whereType<Map<String, dynamic>>()
                .map(
                  (mention) => ExpenseCommentMention(
                    userId: (mention['user_id'] as num?)?.toInt() ?? 0,
                    name: mention['name'] as String? ?? '',
                    start: (mention['start'] as num?)?.toInt(),
                    end: (mention['end'] as num?)?.toInt(),
                  ),
                )
                .toList(growable: false)
          : const <ExpenseCommentMention>[],
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
        .map((item) => _expenseCommentFromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  static List<Map<String, int>> _mentionSpansJson(
    List<CommentMentionSpan> spans,
  ) => [
    for (final span in spans)
      {'user_id': span.userId, 'start': span.start, 'end': span.end},
  ];

  Future<ExpenseComment> addExpenseComment({
    required int expenseId,
    required int tripId,
    required String body,
    int? parentCommentId,
    List<int> mentionedUserIds = const <int>[],
    List<CommentMentionSpan> mentionSpans = const <CommentMentionSpan>[],
  }) async {
    final payload = <String, dynamic>{'expense_id': expenseId, 'body': body};
    if ((parentCommentId ?? 0) > 0) {
      payload['parent_comment_id'] = parentCommentId;
    }
    if (mentionedUserIds.isNotEmpty) {
      payload['mentioned_user_ids'] = mentionedUserIds;
    }
    if (mentionSpans.isNotEmpty) {
      payload['mentions'] = _mentionSpansJson(mentionSpans);
    }
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('add_expense_comment'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: payload,
    );
    return _expenseCommentFromJson(response['comment'] as Map<String, dynamic>);
  }

  Future<ExpenseComment> updateExpenseComment({
    required int commentId,
    required int expenseId,
    required int tripId,
    required String body,
    List<int> mentionedUserIds = const <int>[],
    List<CommentMentionSpan> mentionSpans = const <CommentMentionSpan>[],
  }) async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('update_expense_comment'),
      method: HttpMethod.post,
      headers: _tripHeaders(tripId),
      body: <String, dynamic>{
        'comment_id': commentId,
        'expense_id': expenseId,
        'body': body,
        'mentioned_user_ids': mentionedUserIds,
        // Positions let the server skip name matching; older servers ignore it.
        'mentions': _mentionSpansJson(mentionSpans),
      },
    );
    return _expenseCommentFromJson(response['comment'] as Map<String, dynamic>);
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
