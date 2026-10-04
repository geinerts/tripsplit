import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/auth_session_store.dart';
import 'package:tripsplit/core/auth/device_token_store.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_api_client.dart';

class _Session extends AuthSessionStore {
  String access = 'account-A';
  @override
  Future<String?> readValidAccessToken({
    Duration leeway = Duration.zero,
  }) async => access;
}

class _Device extends DeviceTokenStore {
  final entered = Completer<void>();
  final release = Completer<void>();
  @override
  Future<String> getOrCreateToken() async {
    entered.complete();
    await release.future;
    return 'device';
  }
}

void main() {
  test(
    'old queued request cannot use credentials read after an account switch',
    () async {
      final account = AccountDataSession()..activate(1);
      final auth = _Session();
      final device = _Device();
      var sent = 0;
      final client = LegacyApiClient(
        baseUrl: 'https://splyto.test',
        tokenStore: device,
        authSessionStore: auth,
        enableVerboseLogs: false,
        requestTimeout: const Duration(seconds: 2),
        httpClient: MockClient((_) async {
          sent++;
          return http.Response('{"ok":true}', 200);
        }),
      );
      final pending = account.run(
        () => client.request(
          path: 'api/api.php?action=delete_expense',
          method: HttpMethod.post,
          body: {'expense_id': 7},
        ),
      );
      final rejected = expectLater(
        pending,
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
        ),
      );
      await device.entered.future;
      account.activate(2);
      auth.access = 'account-B';
      device.release.complete();
      await rejected;
      expect(sent, 0);
    },
  );
}
