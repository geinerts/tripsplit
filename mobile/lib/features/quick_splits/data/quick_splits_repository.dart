import '../../../core/auth/account_data_session.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_method.dart';
import '../domain/quick_split.dart';

abstract interface class QuickSplitsRepository {
  Future<QuickSplitPage> list({String? cursor, int limit = 30});
  Future<QuickSplit> get(int id);
  Future<QuickSplit> add(QuickSplitInput input);
  Future<QuickSplit> update(int id, QuickSplitInput input);
  Future<void> delete(int id);
  Future<void> moveToTrip({
    required int id,
    required int tripId,
    required int expenseId,
  });
}

/// Talks to the quick split actions; nothing is cached on the device.
class ApiQuickSplitsRepository implements QuickSplitsRepository {
  ApiQuickSplitsRepository(this.api, this.session);

  final ApiClient api;
  final AccountDataSession session;

  Future<Map<String, dynamic>> _call(
    String action,
    Map<String, dynamic> body,
  ) => session.run(
    () => api.request(
      path: ApiEndpoints.legacyAction(action),
      method: HttpMethod.post,
      body: body,
    ),
  );

  QuickSplit _one(Map<String, dynamic> response) => QuickSplit.fromJson(
    (response['quick_split'] as Map? ?? const {}).cast<String, dynamic>(),
  );

  @override
  Future<QuickSplitPage> list({String? cursor, int limit = 30}) async {
    final response = await _call('list_quick_splits', {
      'limit': limit,
      'cursor': ?cursor,
    });
    return QuickSplitPage(
      items: [
        for (final raw in response['items'] as List? ?? const [])
          if (raw is Map) QuickSplit.fromJson(raw.cast<String, dynamic>()),
      ],
      nextCursor: response['next_cursor'] as String?,
    );
  }

  @override
  Future<QuickSplit> get(int id) async =>
      _one(await _call('get_quick_split', {'id': id}));

  @override
  Future<QuickSplit> add(QuickSplitInput input) async =>
      _one(await _call('add_quick_split', input.toJson()));

  @override
  Future<QuickSplit> update(int id, QuickSplitInput input) async =>
      _one(await _call('update_quick_split', {...input.toJson(), 'id': id}));

  @override
  Future<void> delete(int id) async {
    await _call('delete_quick_split', {'id': id});
  }

  @override
  Future<void> moveToTrip({
    required int id,
    required int tripId,
    required int expenseId,
  }) async {
    await _call('move_quick_split_to_trip', {
      'id': id,
      'trip_id': tripId,
      'expense_id': expenseId,
    });
  }
}
