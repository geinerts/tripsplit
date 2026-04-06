import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/auth_session_store.dart';
import '../auth/device_token_store.dart';
import '../errors/api_exception.dart';
import 'media_url_resolver.dart';

class UploadedAvatar {
  const UploadedAvatar({
    this.avatarPath,
    this.avatarUrl,
    this.avatarThumbUrl,
    this.mePayload,
  });

  final String? avatarPath;
  final String? avatarUrl;
  final String? avatarThumbUrl;
  final Map<String, dynamic>? mePayload;
}

class LegacyAvatarUploader {
  LegacyAvatarUploader({
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

  Future<UploadedAvatar> uploadAvatar({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final token = await _tokenStore.getOrCreateToken();
    final uri = Uri.parse(_baseUrl).resolve('api/api.php?action=upload_avatar');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['X-Device-Token'] = token
      ..files.add(
        http.MultipartFile.fromBytes('avatar', bytes, filename: fileName),
      );
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

    return UploadedAvatar(
      avatarPath: payload['avatar_path'] as String?,
      avatarUrl: MediaUrlResolver.normalize(payload['avatar_url'] as String?),
      avatarThumbUrl: MediaUrlResolver.normalize(
        payload['avatar_thumb_url'] as String?,
      ),
      mePayload: payload['me'] as Map<String, dynamic>?,
    );
  }

  Future<UploadedAvatar> removeAvatar() async {
    final token = await _tokenStore.getOrCreateToken();
    final uri = Uri.parse(_baseUrl).resolve('api/api.php?action=remove_avatar');

    http.Response response;
    try {
      final accessToken = await _authSessionStore.readValidAccessToken();
      final headers = <String, String>{
        'Accept': 'application/json',
        'X-Device-Token': token,
      };
      if (accessToken != null && accessToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
      response = await _httpClient.post(uri, headers: headers);
    } on http.ClientException {
      throw const ApiException('Network unavailable.', isNetworkError: true);
    }

    final payload = _parsePayload(response);
    _ensureOk(payload: payload, statusCode: response.statusCode);

    return UploadedAvatar(
      avatarPath: payload['avatar_path'] as String?,
      avatarUrl: MediaUrlResolver.normalize(payload['avatar_url'] as String?),
      avatarThumbUrl: MediaUrlResolver.normalize(
        payload['avatar_thumb_url'] as String?,
      ),
      mePayload: payload['me'] as Map<String, dynamic>?,
    );
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
