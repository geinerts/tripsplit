import '../../../core/auth/account_data_session.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_method.dart';
import '../domain/live_location.dart';

abstract interface class LiveLocationRepository {
  Future<LiveMapSnapshot> load(int trip);
  Future<LiveShareSession> start(int trip, int minutes, LiveFix fix);
  Future<void> update(int trip, String token, LiveFix fix);
  Future<void> stop(int trip);
}

class ApiLiveLocationRepository implements LiveLocationRepository {
  ApiLiveLocationRepository(this.api, this.session);
  final ApiClient api;
  final AccountDataSession session;
  Future<Map<String, dynamic>> _call(
    String action,
    int trip, [
    Map<String, dynamic>? body,
  ]) => session.run(
    () => api.request(
      path: ApiEndpoints.legacyAction(action),
      method: body == null ? HttpMethod.get : HttpMethod.post,
      headers: {'X-Trip-Id': '$trip'},
      body: body,
    ),
  );
  @override
  Future<LiveMapSnapshot> load(int trip) async =>
      LiveMapSnapshot.fromJson(await _call('list_trip_live_locations', trip));
  @override
  Future<LiveShareSession> start(int trip, int minutes, LiveFix fix) async {
    final response = await _call('start_trip_live_location', trip, {
      'minutes': minutes,
      ...fix.toJson(),
    });
    final seconds =
        (response['expires_at'] as num).toInt() -
        (response['server_time'] as num).toInt();
    return LiveShareSession(
      response['session_token'] as String,
      DateTime.now().add(Duration(seconds: seconds)),
    );
  }

  @override
  Future<void> update(int trip, String token, LiveFix fix) async {
    await _call('update_trip_live_location', trip, {
      'session_token': token,
      ...fix.toJson(),
    });
  }

  @override
  Future<void> stop(int trip) async {
    await _call('stop_trip_live_location', trip, {'trip_id': trip});
  }
}
