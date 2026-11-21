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

  group('slow requests (AI receipt reading)', () {
    LegacyApiClient client({
      required void Function() onFailure,
      required Future<http.Response> Function(http.Request) handler,
    }) => LegacyApiClient(
      baseUrl: 'https://example.test/',
      tokenStore: _Device(),
      authSessionStore: _Auth(),
      enableVerboseLogs: false,
      requestTimeout: const Duration(milliseconds: 20),
      onNetworkFailure: onFailure,
      httpClient: MockClient(handler),
    );

    test(
      'a slow answer waits longer and never marks the app offline',
      () async {
        var marked = 0;
        final api = client(
          onFailure: () => marked++,
          handler: (_) async {
            await Future<void>.delayed(const Duration(milliseconds: 60));
            return http.Response('{"ok":true,"scan":{}}', 200);
          },
        );
        // 60 ms is past the normal 20 ms limit but inside the slow one.
        final answer = await api.requestSlow(
          path: 'api/api.php?action=scan_receipt',
          method: HttpMethod.post,
          timeout: const Duration(milliseconds: 200),
          body: const {},
        );
        expect(answer['ok'], isTrue);
        // Running out of the slow time is a timeout, still not "offline".
        await expectLater(
          api.requestSlow(
            path: 'api/api.php?action=scan_receipt',
            method: HttpMethod.post,
            timeout: const Duration(milliseconds: 10),
            body: const {},
          ),
          networkError,
        );
        expect(marked, 0);
      },
    );

    test(
      'a lost connection still marks offline, also for slow requests',
      () async {
        var marked = 0;
        final api = client(
          onFailure: () => marked++,
          handler: (_) async => throw const SocketException('Offline'),
        );
        await expectLater(
          api.requestSlow(
            path: 'api/api.php?action=scan_receipt',
            method: HttpMethod.post,
            timeout: const Duration(seconds: 1),
            body: const {},
          ),
          networkError,
        );
        expect(marked, 1);
      },
    );

    test('a normal request that times out still marks offline', () async {
      var marked = 0;
      final api = client(
        onFailure: () => marked++,
        handler: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 60));
          return http.Response('{"ok":true}', 200);
        },
      );
      await expectLater(
        api.request(path: 'api/api.php?action=me', method: HttpMethod.get),
        networkError,
      );
      expect(marked, 1);
    });
  });
}
