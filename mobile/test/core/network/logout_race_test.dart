import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tripsplit/core/auth/auth_session_store.dart';
import 'package:tripsplit/core/auth/device_token_store.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_api_client.dart';

class _Session extends AuthSessionStore {
  String? access;
  String? refresh = 'old';
  @override
  Future<String?> readValidAccessToken({
    Duration leeway = Duration.zero,
  }) async => access;
  @override
  Future<String?> readValidRefreshToken({
    Duration leeway = Duration.zero,
  }) async => refresh;
  @override
  Future<void> saveFromAuthPayload(Map<String, dynamic> payload) async {
    access = payload['access_token'] as String?;
    refresh = payload['refresh_token'] as String?;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}

class _Device extends DeviceTokenStore {
  @override
  Future<String> getOrCreateToken() async => 'test-device';
}

LegacyApiClient _client(
  _Session store,
  Future<http.Response> Function(http.Request) handler,
) => LegacyApiClient(
  baseUrl: 'https://example.test',
  tokenStore: _Device(),
  authSessionStore: store,
  enableVerboseLogs: false,
  requestTimeout: const Duration(seconds: 3),
  httpClient: MockClient(handler),
);

void main() {
  test('password recovery remains available after logout', () async {
    final api = _client(
      _Session()..access = 'access',
      (_) async => http.Response('{"ok":true}', 200),
    );
    await api.revokeCurrentSession();
    final result = await api.request(
      path: 'api/api.php?action=forgot_password',
      method: HttpMethod.post,
    );
    expect(result['ok'], isTrue);
  });
  test('logout waits for rotation and revokes the new refresh token', () async {
    final store = _Session();
    final started = Completer<void>();
    final rotation = Completer<http.Response>();
    String? revoked;
    final api = _client(store, (request) async {
      if (request.url.queryParameters['action'] == 'refresh_session') {
        started.complete();
        return rotation.future;
      }
      if (request.url.queryParameters['action'] == 'logout_session') {
        revoked = jsonDecode(request.body)['refresh_token'] as String;
      }
      return http.Response('{"ok":true}', 200);
    });
    final request = api.request(
      path: 'api/api.php?action=me',
      method: HttpMethod.get,
    );
    final rejected = expectLater(request, throwsA(isA<ApiException>()));
    await started.future;
    final logout = api.revokeCurrentSession();
    expect(revoked, isNull);
    rotation.complete(
      http.Response(
        '{"ok":true,"auth":{"access_token":"new-access","refresh_token":"new"}}',
        200,
      ),
    );
    await logout;
    await rejected;
    expect(revoked, 'new');
    await expectLater(
      api.request(path: 'api/api.php?action=me', method: HttpMethod.get),
      throwsA(isA<ApiException>()),
    );
  });

  test('failed revocation preserves credentials and permits retry', () async {
    final store = _Session()..access = 'access';
    var attempts = 0;
    final api = _client(
      store,
      (_) async => ++attempts == 1
          ? http.Response('{"ok":false,"error":"Unavailable"}', 503)
          : http.Response('{"ok":true}', 200),
    );
    await expectLater(api.revokeCurrentSession(), throwsA(isA<ApiException>()));
    expect(store.refresh, 'old');
    expect(store.access, 'access');
    await api.revokeCurrentSession();
    expect(attempts, 2);
  });

  test('late account responses cannot restore auth after logout', () async {
    final store = _Session()..access = 'access';
    final started = Completer<void>();
    final response = Completer<http.Response>();
    final api = _client(store, (request) async {
      if (request.url.queryParameters['action'] == 'me') {
        started.complete();
        return response.future;
      }
      return http.Response('{"ok":true}', 200);
    });
    final request = api.request(
      path: 'api/api.php?action=me',
      method: HttpMethod.get,
    );
    final rejected = expectLater(request, throwsA(isA<ApiException>()));
    await started.future;
    await api.revokeCurrentSession();
    await store.clear();
    response.complete(
      http.Response(
        '{"ok":true,"auth":{"access_token":"late","refresh_token":"late"}}',
        200,
      ),
    );
    await rejected;
    expect(store.refresh, isNull);
  });
}
