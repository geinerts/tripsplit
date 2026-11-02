import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/core/auth/device_token_store.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/push/push_native_bridge.dart';
import 'package:tripsplit/core/push/push_registration_service.dart';
import 'package:tripsplit/core/push/push_registration_store.dart';

class _Api extends ApiClient {
  final locales = <String>[];
  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    if (body?['locale'] case final String code) locales.add(code);
    return {};
  }

  @override
  Future<void> revokeCurrentSession() async {}
}

class _Push extends PushNativeBridge {
  @override
  Future<String?> requestPushToken() async => 'device-token';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'changing language updates registration even when the device token is unchanged',
    () async {
      SharedPreferences.setMockInitialValues({});
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final api = _Api();
      var language = 'en';
      final service = PushRegistrationService(
        apiClient: api,
        deviceTokenStore: DeviceTokenStore(),
        nativeBridge: _Push(),
        registrationStore: PushRegistrationStore(),
        localeCodeProvider: () => language,
      );
      await service.syncRegistration();
      await service.syncRegistration();
      expect(api.locales, ['en']);
      for (final code in [
        'de',
        'fr',
        'it',
        'pt',
        'pl',
        'nl',
        'sv',
        'da',
        'nb',
        'fi',
        'cs',
        'uk',
        'lv',
        'es',
      ]) {
        language = code;
        await service.syncRegistration();
        expect(api.locales.last, code);
      }
      language = 'no-NO';
      await service.syncRegistration();
      expect(api.locales.last, 'nb');
      language = 'ja';
      await service.syncRegistration();
      expect(api.locales.last, 'en');
    },
  );
}
