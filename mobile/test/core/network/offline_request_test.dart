import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tripsplit/core/auth/auth_session_store.dart';
import 'package:tripsplit/core/auth/device_token_store.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_api_client.dart';
import 'package:tripsplit/core/network/legacy_receipt_uploader.dart';

class _Auth extends AuthSessionStore {
  _Auth({this.expired = false});
  final bool expired;
  @override
  Future<String?> readValidAccessToken({
    Duration leeway = Duration.zero,
  }) async => expired ? null : 'test-access';
  @override
  Future<String?> readValidRefreshToken({
    Duration leeway = Duration.zero,
  }) async => 'test-refresh';
}

class _Device extends DeviceTokenStore {
  @override
  Future<String> getOrCreateToken() async => 'test-device';
}

void main() {
  final networkError = throwsA(
    isA<ApiException>().having(
      (e) => e.isNetworkError,
      'network failure',
      isTrue,
    ),
  );
  for (final expired in [false, true]) {
    test(
      'outage is reused across actions; expired credentials: $expired',
      () async {
        var offline = false;
        var requests = 0;
        final client = LegacyApiClient(
          baseUrl: 'https://example.test/',
          tokenStore: _Device(),
          authSessionStore: _Auth(expired: expired),
          enableVerboseLogs: false,
          requestTimeout: const Duration(seconds: 30),
          isOffline: () async => offline,
          onNetworkFailure: () => offline = true,
          httpClient: MockClient((_) async {
            requests++;
            throw const SocketException('Offline');
          }),
        );
        for (var i = 0; i < 3; i++) {
          await expectLater(
            client.request(
              path: 'api/api.php?action=add_expense',
              method: HttpMethod.post,
            ),
            networkError,
          );
        }
        // Includes refresh: a failed refresh must not be followed by a second
        // slow request, and subsequent expense saves must go straight to queue.
        expect(requests, 1);
        expect(offline, isTrue);
      },
    );
  }
  test('offline receipt fails before multipart upload', () async {
    var requests = 0;
    final uploader = LegacyReceiptUploader(
      baseUrl: 'https://example.test/',
      tokenStore: _Device(),
      authSessionStore: _Auth(),
      isOffline: () async => true,
      httpClient: MockClient((_) async {
        requests++;
        return http.Response('{}', 200);
      }),
    );
    await expectLater(
      uploader.uploadReceipt(
        fileName: 'receipt.jpg',
        bytes: Uint8List.fromList([1]),
        tripId: 1,
      ),
      networkError,
    );
    expect(requests, 0);
  });
}
