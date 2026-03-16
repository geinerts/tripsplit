import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class DeviceTokenStore {
  static const String _storageKey = 'trip_device_token_v1';
  static final RegExp _tokenPattern = RegExp(r'^[a-f0-9]{64}$');

  String? _cachedToken;

  Future<String> getOrCreateToken() async {
    if (_cachedToken != null) {
      return _cachedToken!;
    }

    final prefs = await SharedPreferences.getInstance();
    final stored = (prefs.getString(_storageKey) ?? '').trim().toLowerCase();
    if (_tokenPattern.hasMatch(stored)) {
      _cachedToken = stored;
      return stored;
    }

    final next = _generateToken();
    await prefs.setString(_storageKey, next);
    _cachedToken = next;
    return next;
  }

  Future<String> resetToken() async {
    final prefs = await SharedPreferences.getInstance();
    final next = _generateToken();
    await prefs.setString(_storageKey, next);
    _cachedToken = next;
    return next;
  }

  String _generateToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}
