import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSessionStore {
  AuthSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'trip_access_token_v1';
  static const String _accessExpiryKey = 'trip_access_expiry_epoch_ms_v1';
  static const String _refreshTokenKey = 'trip_refresh_token_v1';
  static const String _refreshExpiryKey = 'trip_refresh_expiry_epoch_ms_v1';

  final FlutterSecureStorage _storage;
  String? _memoryAccessToken;
  int _memoryAccessExpiryMs = 0;
  String? _memoryRefreshToken;
  int _memoryRefreshExpiryMs = 0;

  Future<void> saveFromAuthPayload(Map<String, dynamic> payload) async {
    final accessToken = (payload['access_token'] as String? ?? '').trim();
    final refreshToken = (payload['refresh_token'] as String? ?? '').trim();
    final accessExpiresInSec = _parsePositiveInt(
      payload['access_expires_in_sec'],
    );
    final refreshExpiresInSec = _parsePositiveInt(
      payload['refresh_expires_in_sec'],
    );

    if (accessToken.isEmpty ||
        refreshToken.isEmpty ||
        accessExpiresInSec <= 0 ||
        refreshExpiresInSec <= 0) {
      return;
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final accessExpiryMs = now + accessExpiresInSec * 1000;
    final refreshExpiryMs = now + refreshExpiresInSec * 1000;

    _memoryAccessToken = accessToken;
    _memoryAccessExpiryMs = accessExpiryMs;
    _memoryRefreshToken = refreshToken;
    _memoryRefreshExpiryMs = refreshExpiryMs;

    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _accessExpiryKey, value: '$accessExpiryMs');
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _refreshExpiryKey, value: '$refreshExpiryMs');
  }

  Future<String?> readValidAccessToken({
    Duration leeway = const Duration(seconds: 30),
  }) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final memoryAccess = _memoryAccessToken?.trim() ?? '';
    if (memoryAccess.isNotEmpty &&
        _isStillValid(
          expiryMs: _memoryAccessExpiryMs,
          nowMs: nowMs,
          leewayMs: leeway.inMilliseconds,
        )) {
      return memoryAccess;
    }

    final accessToken = (await _storage.read(key: _accessTokenKey) ?? '')
        .trim();
    if (accessToken.isEmpty) {
      return null;
    }

    final expiryRaw = (await _storage.read(key: _accessExpiryKey) ?? '').trim();
    final expiryMs = int.tryParse(expiryRaw) ?? 0;
    if (expiryMs <= 0) {
      return null;
    }

    if (!_isStillValid(
      expiryMs: expiryMs,
      nowMs: nowMs,
      leewayMs: leeway.inMilliseconds,
    )) {
      return null;
    }

    _memoryAccessToken = accessToken;
    _memoryAccessExpiryMs = expiryMs;
    return accessToken;
  }

  Future<String?> readValidRefreshToken({
    Duration leeway = const Duration(minutes: 1),
  }) async {
    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final memoryRefresh = _memoryRefreshToken?.trim() ?? '';
    if (memoryRefresh.isNotEmpty &&
        _isStillValid(
          expiryMs: _memoryRefreshExpiryMs,
          nowMs: nowMs,
          leewayMs: leeway.inMilliseconds,
        )) {
      return memoryRefresh;
    }

    final refreshToken = (await _storage.read(key: _refreshTokenKey) ?? '')
        .trim();
    if (refreshToken.isEmpty) {
      return null;
    }

    final expiryRaw = (await _storage.read(key: _refreshExpiryKey) ?? '')
        .trim();
    final expiryMs = int.tryParse(expiryRaw) ?? 0;
    if (expiryMs <= 0) {
      return null;
    }

    if (!_isStillValid(
      expiryMs: expiryMs,
      nowMs: nowMs,
      leewayMs: leeway.inMilliseconds,
    )) {
      return null;
    }

    _memoryRefreshToken = refreshToken;
    _memoryRefreshExpiryMs = expiryMs;
    return refreshToken;
  }

  Future<void> clear() async {
    _memoryAccessToken = null;
    _memoryAccessExpiryMs = 0;
    _memoryRefreshToken = null;
    _memoryRefreshExpiryMs = 0;
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _accessExpiryKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _refreshExpiryKey);
  }

  bool _isStillValid({
    required int expiryMs,
    required int nowMs,
    required int leewayMs,
  }) {
    if (expiryMs <= 0) {
      return false;
    }
    return nowMs < (expiryMs - leewayMs);
  }

  int _parsePositiveInt(dynamic value) {
    if (value is int && value > 0) {
      return value;
    }
    if (value is num && value > 0) {
      return value.toInt();
    }
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null && parsed > 0) {
        return parsed;
      }
    }
    return 0;
  }
}
