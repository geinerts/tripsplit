import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PushNativeBridge {
  PushNativeBridge();

  static const MethodChannel _channel = MethodChannel('app.splyto/push');

  Future<String?> requestPushToken() async {
    if (!_isSupportedPlatform) {
      return null;
    }
    try {
      final raw = await _channel.invokeMethod<String>('requestPushToken');
      return _normalizeToken(raw);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<String?> readCachedPushToken() async {
    if (!_isSupportedPlatform) {
      return null;
    }
    try {
      final raw = await _channel.invokeMethod<String>('getCachedPushToken');
      return _normalizeToken(raw);
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static bool get _isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
  }

  static String? _normalizeToken(String? raw) {
    final token = (raw ?? '').trim();
    if (token.isEmpty) {
      return null;
    }
    return token;
  }
}
