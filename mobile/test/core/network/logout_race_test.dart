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

http.Response _json(Map<String, dynamic> body, int status) =>
    http.Response(jsonEncode(body), status);

const _protected = 'api/api.php?action=me';

Future<int> _countInvalidations(
  _Session store,
  Future<http.Response> Function(http.Request) handler, {
  String path = _protected,
  int requests = 1,
}) async {
  final api = _client(store, handler);
  var invalidations = 0;
  api.onSessionInvalidated = () async => invalidations++;
  for (var i = 0; i < requests; i++) {
    await expectLater(
      api.request(path: path, method: HttpMethod.get),
      throwsA(isA<ApiException>()),
    );
  }
  return invalidations;
}

void main() {
  group('session invalidation', () {
    test('rejected refresh reports once and clears the session', () async {
      final store = _Session()..access = 'access';
      final count = await _countInvalidations(
        store,
        (_) async => _json({'ok': false, 'error': 'Invalid token'}, 401),
        requests: 3,
      );
      expect(count, 1);
      expect(store.refresh, isNull);
    });
    test('a deleted account reports even without a refresh attempt', () async {
      final store = _Session()..access = 'access';
      final count = await _countInvalidations(
        store,
        (_) async => _json({'ok': false, 'code': 'ACCOUNT_DELETED'}, 403),
      );
      expect(count, 1);
    });
    test('no network keeps the session and reports nothing', () async {
      final store = _Session()..access = 'access';
      final count = await _countInvalidations(store, (request) async {
        if (request.url.query.contains('refresh_session')) {
          throw http.ClientException('offline');
        }
        return _json({'ok': false, 'error': 'Expired'}, 401);
      });
      expect(count, 0);
      expect(store.refresh, 'old');
    });
    test('a server error during refresh reports nothing', () async {
      final store = _Session()..access = 'access';
      final count = await _countInvalidations(store, (request) async {
        return request.url.query.contains('refresh_session')
            ? _json({'ok': false, 'error': 'Busy'}, 503)
            : _json({'ok': false, 'error': 'Expired'}, 401);
      });
      expect(count, 0);
      expect(store.refresh, 'old');
    });
    test('a blocked account on the login form reports nothing', () async {
      final count = await _countInvalidations(
        _Session(),
        (_) async => _json({'ok': false, 'code': 'ACCOUNT_DEACTIVATED'}, 403),
        path: 'api/api.php?action=login',
      );
      expect(count, 0);
    });
    test('a successful refresh reports nothing', () async {
      final store = _Session()..access = 'access';
      var calls = 0;
      final api = _client(store, (request) async {
        if (request.url.query.contains('refresh_session')) {
          return _json({
            'ok': true,
            'auth': {'access_token': 'new', 'refresh_token': 'new-refresh'},
          }, 200);
        }
        return ++calls == 1
            ? _json({'ok': false, 'error': 'Expired'}, 401)
            : _json({'ok': true}, 200);
      });
      var invalidations = 0;
      api.onSessionInvalidated = () async => invalidations++;
      await api.request(path: _protected, method: HttpMethod.get);
      expect(invalidations, 0);
    });
    test('logging out first does not report a rejected session', () async {
      final store = _Session()..access = 'access';
      final api = _client(store, (_) async => _json({'ok': true}, 200));
      var invalidations = 0;
      api.onSessionInvalidated = () async => invalidations++;
      await api.revokeCurrentSession();
      await expectLater(
        api.request(path: _protected, method: HttpMethod.get),
        throwsA(isA<ApiException>()),
      );
      expect(invalidations, 0);
    });
    test('a failing listener does not hide the API error', () async {
      final api = _client(
        _Session()..access = 'access',
        (_) async => _json({'ok': false, 'error': 'Invalid token'}, 401),
      );
      api.onSessionInvalidated = () async => throw StateError('listener');
      await expectLater(
        api.request(path: _protected, method: HttpMethod.get),
        throwsA(isA<ApiException>()),
      );
    });
  });

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
