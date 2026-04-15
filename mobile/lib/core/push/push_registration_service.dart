import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../auth/device_token_store.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/http_method.dart';
import 'push_native_bridge.dart';
import 'push_registration_store.dart';

class PushRegistrationService {
  PushRegistrationService({
    required ApiClient apiClient,
    required DeviceTokenStore deviceTokenStore,
    required PushNativeBridge nativeBridge,
    required PushRegistrationStore registrationStore,
  }) : _apiClient = apiClient,
       _deviceTokenStore = deviceTokenStore,
       _nativeBridge = nativeBridge,
       _registrationStore = registrationStore;

  final ApiClient _apiClient;
  final DeviceTokenStore _deviceTokenStore;
  final PushNativeBridge _nativeBridge;
  final PushRegistrationStore _registrationStore;
  String? _verifiedTokenInSession;

  Future<bool> syncRegistration() async {
    if (!_supportsPushRegistration) {
      return false;
    }

    final pushToken = await _nativeBridge.requestPushToken();
    if (pushToken == null || pushToken.isEmpty) {
      return false;
    }

    final previousToken = await _registrationStore.readRegisteredToken();
    // Always verify current token with backend at least once per app session.
    // This recovers from server-side token deactivation (for example after
    // migrations, manual cleanup, or stale-token invalidation) while still
    // avoiding repeated register calls in the same app run.
    if (previousToken == pushToken && _verifiedTokenInSession == pushToken) {
      return true;
    }

    final deviceUid = await _deviceTokenStore.getOrCreateToken();
    final appBundle = await _loadBundleId();

    await _apiClient.request(
      path: ApiEndpoints.legacyAction('register_push_token'),
      method: HttpMethod.post,
      body: <String, dynamic>{
        'push_token': pushToken,
        'platform': _platformLabel,
        'provider': _providerLabel,
        'device_uid': deviceUid,
        if (appBundle.isNotEmpty) 'app_bundle': appBundle,
      },
    );

    await _registrationStore.writeRegisteredToken(pushToken);
    _verifiedTokenInSession = pushToken;
    return true;
  }

  Future<void> unregisterCurrentDevice() async {
    if (!_supportsPushRegistration) {
      return;
    }

    final token =
        await _nativeBridge.readCachedPushToken() ??
        await _registrationStore.readRegisteredToken();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      await _apiClient.request(
        path: ApiEndpoints.legacyAction('unregister_push_token'),
        method: HttpMethod.post,
        body: <String, dynamic>{'push_token': token},
      );
    } finally {
      // Clear local marker even if request fails; next login will re-register.
      await _registrationStore.writeRegisteredToken(null);
      _verifiedTokenInSession = null;
    }
  }

  bool get _supportsPushRegistration {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  String get _platformLabel {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    return 'android';
  }

  String get _providerLabel {
    return 'fcm';
  }

  Future<String> _loadBundleId() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.packageName.trim();
    } catch (_) {
      return '';
    }
  }
}
