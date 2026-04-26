import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/auth_session_store.dart';
import '../auth/device_token_store.dart';
import '../errors/api_exception.dart';

class UploadedReceipt {
  const UploadedReceipt({
    required this.receiptPath,
    this.receiptUrl,
    this.receiptThumbUrl,
    this.ocrAmount,
    this.ocrDate,
    this.ocrMerchant,
  });

  final String receiptPath;
  final String? receiptUrl;
  final String? receiptThumbUrl;
  final double? ocrAmount;
  final String? ocrDate;
  final String? ocrMerchant;
}

class LegacyReceiptUploader {
  LegacyReceiptUploader({
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

  Future<UploadedReceipt> uploadReceipt({
    required String fileName,
    required Uint8List bytes,
    int? tripId,
  }) async {
    final token = await _tokenStore.getOrCreateToken();
    final uri = Uri.parse(
      _baseUrl,
    ).resolve('api/api.php?action=upload_receipt');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..headers['X-Device-Token'] = token
      ..files.add(
        http.MultipartFile.fromBytes('receipt', bytes, filename: fileName),
      );
    final accessToken = await _authSessionStore.readValidAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (tripId != null && tripId > 0) {
      request.headers['X-Trip-Id'] = '$tripId';
    }

    http.StreamedResponse streamed;
    try {
      streamed = await _httpClient.send(request);
    } on http.ClientException {
      throw const ApiException('Network unavailable.', isNetworkError: true);
    }

    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic> payload;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Response is not a JSON object.');
      }
      payload = decoded;
    } on FormatException {
      throw ApiException(
        'Server returned invalid JSON.',
        statusCode: response.statusCode,
      );
    }

    final ok = payload['ok'] == true;
    if (response.statusCode < 200 || response.statusCode >= 300 || !ok) {
      final raw = payload['error'];
      final message = raw is String && raw.trim().isNotEmpty
          ? raw.trim()
          : 'HTTP ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }

    final receiptPath = payload['receipt_path'] as String? ?? '';
    if (receiptPath.trim().isEmpty) {
      throw ApiException(
        'Upload failed: missing receipt path in response.',
        statusCode: response.statusCode,
      );
    }

    final ocr = payload['ocr'] is Map<String, dynamic>
        ? payload['ocr'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final ocrAmount = (ocr['amount'] as num?)?.toDouble();
    final ocrDate = (ocr['date'] as String?)?.trim();
    final ocrMerchant = (ocr['merchant'] as String?)?.trim();

    return UploadedReceipt(
      receiptPath: receiptPath,
      receiptUrl: payload['receipt_url'] as String?,
      receiptThumbUrl: payload['receipt_thumb_url'] as String?,
      ocrAmount: ocrAmount != null && ocrAmount > 0 ? ocrAmount : null,
      ocrDate: ocrDate != null && ocrDate.isNotEmpty ? ocrDate : null,
      ocrMerchant: ocrMerchant != null && ocrMerchant.isNotEmpty
          ? ocrMerchant
          : null,
    );
  }

  static String _ensureTrailingSlash(String value) {
    return value.endsWith('/') ? value : '$value/';
  }
}
