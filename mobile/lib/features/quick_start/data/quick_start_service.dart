import '../../../core/auth/account_data_session.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_method.dart';

class QuickStartService {
  QuickStartService(this._client, this.accountSession);

  final ApiClient _client;
  final AccountDataSession accountSession;

  /// Server-side one-time claim, never inferred from an offline trip cache.
  Future<bool> claimAutomaticPresentation() => accountSession.run(() async {
    final result = await _client.request(
      path: ApiEndpoints.legacyAction('claim_quick_start'),
      method: HttpMethod.post,
    );
    return result['show_quick_start'] == true;
  });
}
