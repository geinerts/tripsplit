import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../auth/auth_session_store.dart';
import '../auth/device_token_store.dart';
import '../errors/api_exception.dart';

class LegacyFeedbackReporter {
  LegacyFeedbackReporter({
    required String baseUrl,
    required DeviceTokenStore tokenStore,
    required AuthSessionStore authSessionStore,
    http.Client? httpClient,
  }) : _baseUrl = _ensureTrailingSlash(baseUrl),
       _tokenStore = tokenStore,
       _authSessionStore = authSessionStore,
       _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final DeviceTokenStore _tokenStore;
  final AuthSessionStore _authSessionStore;
  final http.Client _httpClient;

  Future<void> submitFeedback({
    required String type,
    required String note,
    int? tripId,
    String? localeCode,
    Map<String, Object?>? contextData,
    String? screenshotFileName,
    Uint8List? screenshotBytes,
  }) async {
    final normalizedType = type.trim().toLowerCase();
    if (normalizedType != 'bug' && normalizedType != 'suggestion') {
      throw const ApiException('Feedback type must be bug or suggestion.');
    }

    final token = await _tokenStore.getOrCreateToken();
    final uri = Uri.parse(
      _baseUrl,
    ).resolve('api/api.php?action=submit_feedback');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['X-Device-Token'] = token
      ..fields['type'] = normalizedType;

    final trimmedNote = note.trim();
    if (trimmedNote.isNotEmpty) {
      request.fields['note'] = trimmedNote;
    }
    if (tripId != null && tripId > 0) {
      request.fields['trip_id'] = '$tripId';
    }
    final locale = localeCode?.trim() ?? '';
    if (locale.isNotEmpty) {
      request.fields['locale'] = locale;
    }
    request.fields['platform'] = _platformLabel();

    final packageInfo = await _loadPackageInfoSafe();
    if (packageInfo != null) {
      final version = packageInfo.version.trim();
      final build = packageInfo.buildNumber.trim();
      if (version.isNotEmpty) {
        request.fields['app_version'] = version;
      }
      if (build.isNotEmpty) {
        request.fields['build_number'] = build;
      }
    }

    if (contextData != null && contextData.isNotEmpty) {
      request.fields['context_json'] = jsonEncode(contextData);
    }

    final fileBytes = screenshotBytes;
    if (fileBytes != null && fileBytes.isNotEmpty) {
      final fileName = _normalizeFileName(
        screenshotFileName?.trim() ?? 'screenshot.png',
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'screenshot',
          fileBytes,
          filename: fileName,
        ),
      );
    }

    final accessToken = await _authSessionStore.readValidAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    http.StreamedResponse streamed;
    try {
      streamed = await _httpClient.send(request);
    } on http.ClientException {
      throw const ApiException('Network unavailable.', isNetworkError: true);
    }

    final response = await http.Response.fromStream(streamed);
    final payload = _parsePayload(response);
    _ensureOk(payload: payload, statusCode: response.statusCode);
  }

  static String _normalizeFileName(String raw) {
    final fallback = 'screenshot.png';
    if (raw.isEmpty) {
      return fallback;
    }
    final sanitized = raw.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (sanitized.isEmpty) {
      return fallback;
    }
    return sanitized;
  }

  static String _platformLabel() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  static Future<PackageInfo?> _loadPackageInfoSafe() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _parsePayload(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response is not a JSON object.');
      }
      return decoded;
    } on FormatException {
      throw ApiException(
        'Server returned invalid JSON.',
        statusCode: response.statusCode,
      );
    }
  }

  static void _ensureOk({
    required Map<String, dynamic> payload,
    required int statusCode,
  }) {
    final ok = payload['ok'] == true;
    if (statusCode >= 200 && statusCode < 300 && ok) {
      return;
    }
    final raw = payload['error'];
    final message = raw is String && raw.trim().isNotEmpty
        ? raw.trim()
        : 'HTTP $statusCode';
    throw ApiException(message, statusCode: statusCode);
  }

  static String _ensureTrailingSlash(String value) {
    return value.endsWith('/') ? value : '$value/';
  }
}
