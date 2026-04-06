import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../../../../core/network/legacy_receipt_uploader.dart';
import '../../../../core/errors/api_exception.dart';
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
