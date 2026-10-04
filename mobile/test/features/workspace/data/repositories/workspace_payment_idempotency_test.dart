import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/auth/auth_session_store.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/account_local_storage.dart';
import 'package:tripsplit/core/auth/device_token_store.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_receipt_uploader.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_data_source.dart';
import 'package:tripsplit/features/workspace/data/local/workspace_local_store.dart';
import 'package:tripsplit/features/workspace/data/repositories/workspace_repository_impl.dart';

void main() {
  test(
    'payment request reuses its mutation id after a network failure',
    () async {
      final apiClient = _RecordingApiClient(failFirstRequest: true);
      final repository = _repository(apiClient);

      await expectLater(
        repository.createTripPaymentRequest(
          tripId: 17,
          fromUserId: 8,
          amount: 42.50,
          note: 'Dinner',
        ),
        throwsA(isA<ApiException>()),
      );

      await repository.createTripPaymentRequest(
        tripId: 17,
        fromUserId: 8,
        amount: 42.50,
        note: 'Dinner',
      );

      expect(apiClient.requests, hasLength(2));
      final firstMutationId =
          apiClient.requests[0].headers['X-Client-Mutation-Id'];
      final secondMutationId =
          apiClient.requests[1].headers['X-Client-Mutation-Id'];
      expect(firstMutationId, isNotNull);
      expect(firstMutationId, secondMutationId);
    },
  );

  test('successful payment request clears its retry mutation id', () async {
    final apiClient = _RecordingApiClient();
    final repository = _repository(apiClient);

    await repository.createTripPaymentRequest(
      tripId: 17,
      fromUserId: 8,
      amount: 10,
    );
    await repository.createTripPaymentRequest(
      tripId: 17,
      fromUserId: 8,
      amount: 10,
    );

    final firstMutationId =
        apiClient.requests[0].headers['X-Client-Mutation-Id'];
    final secondMutationId =
        apiClient.requests[1].headers['X-Client-Mutation-Id'];
    expect(firstMutationId, isNotNull);
    expect(secondMutationId, isNotNull);
    expect(firstMutationId, isNot(secondMutationId));
  });
}

WorkspaceRepositoryImpl _repository(ApiClient apiClient) {
  final uploader = LegacyReceiptUploader(
    baseUrl: 'https://example.test/',
    tokenStore: DeviceTokenStore(),
    authSessionStore: AuthSessionStore(),
  );
  final remote = WorkspaceRemoteDataSourceImpl(apiClient, uploader);
  final session = AccountDataSession()..activate(1);
  return WorkspaceRepositoryImpl(
    remote,
    WorkspaceLocalStore(AccountLocalStorage(session)),
  );
}

class _RecordingApiClient implements ApiClient {
  _RecordingApiClient({this.failFirstRequest = false});

  final bool failFirstRequest;
  final List<_RecordedRequest> requests = <_RecordedRequest>[];

  @override
  Future<void> revokeCurrentSession() async {}

  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    requests.add(
      _RecordedRequest(
        path: path,
        headers: Map<String, String>.from(headers ?? const <String, String>{}),
      ),
    );
    if (failFirstRequest && requests.length == 1) {
      throw const ApiException('Network unavailable.', isNetworkError: true);
    }
    return <String, dynamic>{'ok': true};
  }
}

class _RecordedRequest {
  const _RecordedRequest({required this.path, required this.headers});

  final String path;
  final Map<String, String> headers;
}
