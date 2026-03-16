import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/http_method.dart';
import '../../domain/entities/workspace_notifications_inbox.dart';
import '../../domain/entities/workspace_snapshot.dart';
import '../../domain/entities/trip_expenses_page.dart';
import 'workspace_remote_parsers.dart';

class WorkspaceRemoteSnapshotLoader {
  WorkspaceRemoteSnapshotLoader(this._apiClient);

  final ApiClient _apiClient;
  final Map<int, WorkspaceSnapshot> _snapshotCacheByTrip =
      <int, WorkspaceSnapshot>{};
  final Map<int, int> _syncCursorByTrip = <int, int>{};

  Future<int> loadCurrentUserId() async {
    final response = await _apiClient.request(
      path: ApiEndpoints.legacyAction('me'),
      method: HttpMethod.get,
    );

    final me = response['me'] as Map<String, dynamic>?;
    if (me == null) {
      throw StateError('Missing me payload in me response.');
    }
    return (me['id'] as num?)?.toInt() ?? 0;
  }

  Future<WorkspaceSnapshot> loadSnapshot({required int tripId}) async {
    try {
      return await _loadSnapshotIncremental(tripId: tripId);
    } on ApiException catch (error) {
      if (_isMissingWorkspaceSnapshotAction(error)) {
        final legacy = await _loadSnapshotLegacy(tripId: tripId);
        _snapshotCacheByTrip[tripId] = legacy;
        _syncCursorByTrip.remove(tripId);
        return legacy;
      }
      rethrow;
    }
  }

  Future<TripExpensesPage> loadExpensesPage({
    required int tripId,
    int limit = 50,
    String? cursor,
    int? offset,
  }) async {
    final headers = _tripHeaders(tripId);
    final normalizedLimit = limit.clamp(1, 300);
    final queryParts = <String>['limit=$normalizedLimit'];
    if (cursor != null && cursor.trim().isNotEmpty) {
      queryParts.add('cursor=${Uri.encodeQueryComponent(cursor.trim())}');
    } else if (offset != null && offset > 0) {
      queryParts.add('offset=$offset');
    }

    final response = await _apiClient.request(
      path: '${ApiEndpoints.legacyAction('list_expenses')}&${queryParts.join('&')}',
      method: HttpMethod.get,
      headers: headers,
    );
    final items = (response['expenses'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(WorkspaceRemoteParsers.parseExpense)
        .toList(growable: false);
    final pagination = response['pagination'] as Map<String, dynamic>?;
    return TripExpensesPage(
      items: items,
      hasMore: pagination?['has_more'] == true,
      nextCursor: (pagination?['next_cursor'] as String?)?.trim().isEmpty ==
              true
          ? null
          : pagination?['next_cursor'] as String?,
      nextOffset: (pagination?['next_offset'] as num?)?.toInt(),
    );
  }

  Future<WorkspaceSnapshot> _loadSnapshotIncremental({
    required int tripId,
  }) async {
    final headers = _tripHeaders(tripId);
    final since = _syncCursorByTrip[tripId] ?? 0;
    final path = since > 0
        ? '${ApiEndpoints.legacyAction('workspace_snapshot')}&since=$since'
        : ApiEndpoints.legacyAction('workspace_snapshot');

    final response = await _apiClient.request(
      path: path,
      method: HttpMethod.get,
      headers: headers,
    );
    final sync = response['sync'] as Map<String, dynamic>?;
    final changed = sync?['changed'] != false;
    final nextCursor = (sync?['cursor'] as num?)?.toInt() ?? 0;
    if (nextCursor > 0) {
      _syncCursorByTrip[tripId] = nextCursor;
    }

    if (!changed) {
      final cached = _snapshotCacheByTrip[tripId];
      if (cached != null) {
        return cached;
      }
      final legacy = await _loadSnapshotLegacy(tripId: tripId);
      _snapshotCacheByTrip[tripId] = legacy;
      return legacy;
    }

    final snapshot = _buildSnapshotFromParts(
      usersResponse: response,
      balancesResponse: response,
      expensesResponse: response,
      ordersResponse: response,
      notificationsResponse: response,
    );
    _snapshotCacheByTrip[tripId] = snapshot;
    return snapshot;
  }

  Future<WorkspaceSnapshot> _loadSnapshotLegacy({required int tripId}) async {
    final headers = _tripHeaders(tripId);
    final responses = await Future.wait<Map<String, dynamic>>([
      _apiClient.request(
        path: ApiEndpoints.legacyAction('users'),
        method: HttpMethod.get,
        headers: headers,
      ),
      _apiClient.request(
        path: ApiEndpoints.legacyAction('balances'),
        method: HttpMethod.get,
        headers: headers,
      ),
      _apiClient.request(
        path: ApiEndpoints.legacyAction('list_expenses'),
        method: HttpMethod.get,
        headers: headers,
      ),
      _apiClient.request(
        path: ApiEndpoints.legacyAction('list_orders'),
        method: HttpMethod.get,
        headers: headers,
      ),
      _apiClient.request(
        path: ApiEndpoints.legacyAction('list_notifications'),
        method: HttpMethod.get,
        headers: headers,
      ),
    ]);

    return _buildSnapshotFromParts(
      usersResponse: responses[0],
      balancesResponse: responses[1],
      expensesResponse: responses[2],
      ordersResponse: responses[3],
      notificationsResponse: responses[4],
    );
  }

  WorkspaceSnapshot _buildSnapshotFromParts({
    required Map<String, dynamic> usersResponse,
    required Map<String, dynamic> balancesResponse,
    required Map<String, dynamic> expensesResponse,
    required Map<String, dynamic> ordersResponse,
    required Map<String, dynamic> notificationsResponse,
  }) {
    final tripPayload = balancesResponse['trip'] as Map<String, dynamic>?;
    final tripStatus = WorkspaceRemoteParsers.parseTripStatus(
      tripPayload?['status'],
    );

    final settlementsRaw =
        balancesResponse['settlements'] as List<dynamic>? ?? const <dynamic>[];
    final progressPayload =
        balancesResponse['settlement_progress'] as Map<String, dynamic>?;
    final settlementTotal =
        (progressPayload?['total'] as num?)?.toInt() ?? settlementsRaw.length;
    final settlementConfirmed =
        (progressPayload?['confirmed'] as num?)?.toInt() ?? 0;
    final settlementRemaining =
        (progressPayload?['remaining'] as num?)?.toInt() ??
        (settlementTotal - settlementConfirmed);
    final allSettled =
        progressPayload?['all_settled'] == true ||
        balancesResponse['all_settled'] == true;

    final users = (usersResponse['users'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(WorkspaceRemoteParsers.parseUser)
        .toList(growable: false);

    final balances =
        (balancesResponse['balances'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(WorkspaceRemoteParsers.parseBalance)
            .toList(growable: false);

    final settlements = settlementsRaw
        .whereType<Map<String, dynamic>>()
        .map(WorkspaceRemoteParsers.parseSettlement)
        .toList(growable: false);

    final expenses =
        (expensesResponse['expenses'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(WorkspaceRemoteParsers.parseExpense)
            .toList(growable: false);

    final orders = (ordersResponse['orders'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(WorkspaceRemoteParsers.parseOrder)
        .toList(growable: false);

    final notifications =
        (notificationsResponse['notifications'] as List<dynamic>? ??
                <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(WorkspaceRemoteParsers.parseNotification)
            .toList(growable: false);
    final unreadNotifications =
        (notificationsResponse['unread_count'] as num?)?.toInt() ??
        notifications.where((item) => !item.isRead).length;

    return WorkspaceSnapshot(
      tripStatus: tripStatus,
      tripEndedAt: tripPayload?['ended_at'] as String?,
      tripArchivedAt: tripPayload?['archived_at'] as String?,
      users: users,
      balances: balances,
      settlements: settlements,
      settlementTotal: settlementTotal,
      settlementConfirmed: settlementConfirmed,
      settlementRemaining: settlementRemaining < 0 ? 0 : settlementRemaining,
      allSettled: allSettled,
      unreadNotifications: unreadNotifications < 0 ? 0 : unreadNotifications,
      notifications: notifications,
      expenses: expenses,
      orders: orders,
    );
  }

  Future<WorkspaceNotificationsInbox> loadGlobalNotifications({
    int limit = 80,
    String? cursor,
    int? offset,
  }) async {
    final normalizedLimit = limit.clamp(1, 200);
    final normalizedOffset = offset != null && offset > 0 ? offset : null;

    final queryParts = <String>['limit=$normalizedLimit', 'paged=1'];
    if (cursor != null && cursor.trim().isNotEmpty) {
      queryParts.add('cursor=${Uri.encodeQueryComponent(cursor.trim())}');
    } else if (normalizedOffset != null) {
      queryParts.add('offset=$normalizedOffset');
    }

    Map<String, dynamic> response;
    try {
      response = await _apiClient.request(
        path:
            '${ApiEndpoints.legacyAction('list_notifications_global')}&${queryParts.join('&')}',
        method: HttpMethod.get,
      );
    } on ApiException catch (error) {
      if (_isMissingGlobalNotificationsAction(error)) {
        return const WorkspaceNotificationsInbox(
          unreadCount: 0,
          notifications: [],
          hasMore: false,
          nextCursor: null,
          nextOffset: null,
        );
      }
      rethrow;
    }

    final notifications =
        (response['notifications'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(WorkspaceRemoteParsers.parseNotification)
            .toList(growable: false);

    final unreadCount = (response['unread_count'] as num?)?.toInt() ?? 0;
    final pagination = response['pagination'] as Map<String, dynamic>?;
    return WorkspaceNotificationsInbox(
      unreadCount: unreadCount < 0 ? 0 : unreadCount,
      notifications: notifications,
      hasMore: pagination?['has_more'] == true,
      nextCursor: (pagination?['next_cursor'] as String?)?.trim().isEmpty == true
          ? null
          : pagination?['next_cursor'] as String?,
      nextOffset: (pagination?['next_offset'] as num?)?.toInt(),
    );
  }

  bool _isMissingWorkspaceSnapshotAction(ApiException error) {
    final normalized = error.message.toLowerCase();
    final statusCode = error.statusCode ?? 0;
    if (statusCode != 404 && statusCode != 400) {
      return false;
    }
    return normalized.contains('unknown action');
  }

  bool _isMissingGlobalNotificationsAction(ApiException error) {
    final normalized = error.message.toLowerCase();
    final statusCode = error.statusCode ?? 0;
    if (statusCode != 404 && statusCode != 400) {
      return false;
    }
    return normalized.contains('unknown action');
  }

  Map<String, String> _tripHeaders(int tripId) {
    return <String, String>{'X-Trip-Id': '$tripId'};
  }
}
