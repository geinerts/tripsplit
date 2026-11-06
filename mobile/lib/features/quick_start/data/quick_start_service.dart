import '../../../core/auth/account_data_session.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/http_method.dart';
import 'quick_start_seen_store.dart';

class QuickStartService {
  QuickStartService(this._client, this.accountSession, {this.seenStore});

  final ApiClient _client;
  final AccountDataSession accountSession;
  final QuickStartSeenStore? seenStore;

  /// Server-side one-time claim, never inferred from an offline trip cache.
  Future<bool> claimAutomaticPresentation() => accountSession.run(() async {
    final result = await _client.request(
      path: ApiEndpoints.legacyAction('claim_quick_start'),
      method: HttpMethod.post,
    );
    return result['show_quick_start'] == true;
  });

  /// True when this device already showed the guide before sign-up.
  Future<bool> isSeenOnDevice() async => await seenStore?.isSeen() ?? false;

  Future<void> markSeenOnDevice() async => seenStore?.markSeen();
}
