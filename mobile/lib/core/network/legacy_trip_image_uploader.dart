import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/auth_session_store.dart';
import '../auth/device_token_store.dart';
import '../errors/api_exception.dart';
import 'media_url_resolver.dart';

class UploadedTripImage {
  const UploadedTripImage({
    required this.imagePath,
    this.imageUrl,
    this.imageThumbUrl,
  });

  final String imagePath;
  final String? imageUrl;
  final String? imageThumbUrl;
}

class LegacyTripImageUploader {
  LegacyTripImageUploader({
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

  Future<UploadedTripImage> uploadTripImage({
    required int tripId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (tripId <= 0) {
      throw const ApiException('Trip id is required.');
    }
    if (bytes.isEmpty) {
      throw const ApiException('Image file is empty.');
    }

    final token = await _tokenStore.getOrCreateToken();
    final uri = Uri.parse(
      _baseUrl,
    ).resolve('api/api.php?action=upload_trip_image');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['X-Device-Token'] = token
      ..headers['X-Trip-Id'] = '$tripId'
      ..files.add(
        http.MultipartFile.fromBytes('trip_image', bytes, filename: fileName),
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

    final imagePath = (payload['image_path'] as String? ?? '').trim();
    if (imagePath.isEmpty) {
      throw ApiException(
        'Upload failed: missing trip image path in response.',
        statusCode: response.statusCode,
      );
    }
    final rawUrl = (payload['image_url'] as String?)?.trim();
    final rawThumbUrl = (payload['image_thumb_url'] as String?)?.trim();
    return UploadedTripImage(
      imagePath: imagePath,
      imageUrl: rawUrl == null || rawUrl.isEmpty
          ? null
          : MediaUrlResolver.normalize(rawUrl),
      imageThumbUrl: rawThumbUrl == null || rawThumbUrl.isEmpty
          ? null
          : MediaUrlResolver.normalize(rawThumbUrl),
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
