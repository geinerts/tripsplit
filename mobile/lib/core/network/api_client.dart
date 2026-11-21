import 'http_method.dart';

abstract class ApiClient {
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  });

  Future<void> revokeCurrentSession();
}

/// A request that is allowed to take long (AI receipt reading). Only the
/// real client offers it; callers fall back to [ApiClient.request].
abstract interface class SlowApiClient implements ApiClient {
  /// Like [ApiClient.request], but waits up to [timeout], and running out of
  /// time does not mark the app offline: the server is answering, just slowly.
  /// A lost connection still does.
  Future<Map<String, dynamic>> requestSlow({
    required String path,
    required HttpMethod method,
    required Duration timeout,
    Map<String, dynamic>? body,
  });
}
