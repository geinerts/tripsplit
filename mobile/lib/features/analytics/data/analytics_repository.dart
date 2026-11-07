import '../../../core/auth/account_data_session.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_method.dart';
import '../domain/analytics_report.dart';

abstract interface class AnalyticsRepository {
  Future<List<AnalyticsTripSummary>> loadSummary();
}

/// See docs/api/analytics-summary.md.
class ApiAnalyticsRepository implements AnalyticsRepository {
  ApiAnalyticsRepository(this._api, this._accountSession);

  final ApiClient _api;
  final AccountDataSession _accountSession;

  @override
  Future<List<AnalyticsTripSummary>> loadSummary() =>
      _accountSession.run(() async {
        final response = await _api.request(
          path: ApiEndpoints.legacyAction('analytics_summary'),
          method: HttpMethod.get,
        );
        final trips = response['trips'];
        if (trips is! List) {
          throw const FormatException('Analytics summary is missing.');
        }
        return List.unmodifiable(
          trips.map((trip) {
            if (trip is! Map<String, dynamic>) {
              throw const FormatException('Invalid analytics trip');
            }
            return AnalyticsTripSummary.fromMap(trip);
          }),
        );
      });
}
