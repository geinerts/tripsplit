import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../auth/auth_session_store.dart';
import '../auth/device_token_store.dart';
import '../errors/api_exception.dart';
import '../monitoring/app_monitoring.dart';
import '../perf/perf_monitor.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'http_method.dart';

class LegacyApiClient implements ApiClient {
  LegacyApiClient({
    required String baseUrl,
    required DeviceTokenStore tokenStore,
    required AuthSessionStore authSessionStore,
    required bool enableVerboseLogs,
    required Duration requestTimeout,
    http.Client? httpClient,
  }) : _baseUrl = _ensureTrailingSlash(baseUrl),
       _tokenStore = tokenStore,
       _authSessionStore = authSessionStore,
       _enableVerboseLogs = enableVerboseLogs,
       _requestTimeout = requestTimeout,
       _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final DeviceTokenStore _tokenStore;
  final AuthSessionStore _authSessionStore;
  final bool _enableVerboseLogs;
  final Duration _requestTimeout;
  final http.Client _httpClient;
  final Random _requestIdRandom = Random();
  Future<bool>? _refreshInFlight;

  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _requestWithOptionalRefresh(
      path: path,
      method: method,
      query: query,
      body: body,
      headers: headers,
      allowRefreshRetry: true,
    );
  }

  Future<Map<String, dynamic>> _requestWithOptionalRefresh({
    required String path,
    required HttpMethod method,
    required bool allowRefreshRetry,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final metricPath = _metricNameForPath(path);
    final requestWatch = Stopwatch()..start();
    var requestId = _nextRequestId();
    final trace = PerfMonitor.start('api.${method.name}.$metricPath');
    try {
      if (allowRefreshRetry && _shouldTryRefresh(path)) {
        await _tryRefreshBeforeRequest();
      }

      final uri = _buildUri(path: path, query: query);
      if (_enableVerboseLogs) {
        debugPrint('[API] ${method.name.toUpperCase()} $uri');
      }

      final response = await _sendJsonRequest(
        uri: uri,
        method: method,
        body: body,
        headers: headers,
        requestId: requestId,
      );
      requestId = _responseRequestId(response) ?? requestId;
      final payload = _parsePayload(response, requestId: requestId);
      final ok = payload['ok'] == true;

      if (!ok || response.statusCode < 200 || response.statusCode >= 300) {
        final errorCode = _errorCode(payload);
        if (_shouldClearAuthSessionForCode(errorCode)) {
          await _authSessionStore.clear();
        }
        final canRetry =
            allowRefreshRetry &&
            _isUnauthorizedResponse(response: response, payload: payload) &&
            _shouldTryRefresh(path);
        if (canRetry) {
          final refreshed = await _refreshAccessSession();
          if (refreshed) {
            trace.stop(success: false, statusCode: response.statusCode);
            return _requestWithOptionalRefresh(
              path: path,
              method: method,
              query: query,
              body: body,
              headers: headers,
              allowRefreshRetry: false,
            );
          }
        }

        trace.stop(success: false, statusCode: response.statusCode);
        throw ApiException(
          _errorMessage(payload, response.statusCode),
          statusCode: response.statusCode,
          requestId: requestId,
          code: errorCode,
        );
      }

      await _captureAuthPayload(payload);
      trace.stop(success: true, statusCode: response.statusCode);
      AppMonitoring.recordApiRequest(
        endpoint: metricPath,
        method: method.name,
        durationMs: requestWatch.elapsedMilliseconds,
        statusCode: response.statusCode,
        requestId: requestId,
      );
      return payload;
    } on ApiException catch (error) {
      trace.stop(success: false, statusCode: error.statusCode);
      final resolvedRequestId = error.requestId ?? requestId;
      final isTimeout = error.message.toLowerCase().contains('timeout');
      AppMonitoring.recordApiRequest(
        endpoint: metricPath,
        method: method.name,
        durationMs: requestWatch.elapsedMilliseconds,
        statusCode: error.statusCode,
        isNetworkError: error.isNetworkError,
        isTimeout: isTimeout,
        requestId: resolvedRequestId,
      );

      if (error.isNetworkError ||
          (error.statusCode ?? 0) >= 500 ||
          (error.statusCode ?? 0) == 401) {
        unawaited(
          AppMonitoring.captureHandledException(
            error,
            stackTrace: StackTrace.current,
            origin: 'api_client',
            extras: <String, Object?>{
              'path': metricPath,
              'method': method.name.toUpperCase(),
              'status_code': error.statusCode,
              'is_network_error': error.isNetworkError,
              'is_timeout': isTimeout,
              'request_id': resolvedRequestId,
            },
          ),
        );
      }
      rethrow;
    } catch (_) {
      trace.stop(success: false);
      rethrow;
    }
  }

  Future<http.Response> _sendJsonRequest({
    required Uri uri,
    required HttpMethod method,
    required String requestId,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final mergedHeaders = await _buildAuthHeaders(
      extra: headers,
      requestId: requestId,
    );
    Object? requestBody;
    if (_methodHasBody(method)) {
      mergedHeaders['Content-Type'] = 'application/json';
      requestBody = jsonEncode(body ?? <String, dynamic>{});
    }

    try {
      return await _send(
        uri: uri,
        method: method,
        headers: mergedHeaders,
        body: requestBody,
      );
    } on SocketException {
      throw ApiException(
        'Network unavailable.',
        isNetworkError: true,
        requestId: requestId,
      );
    } on http.ClientException {
      throw ApiException(
        'Network unavailable.',
        isNetworkError: true,
        requestId: requestId,
      );
    } on TimeoutException {
      throw ApiException(
        'Network timeout.',
        isNetworkError: true,
        requestId: requestId,
      );
    }
  }

  Future<Map<String, String>> _buildAuthHeaders({
    Map<String, String>? extra,
    required String requestId,
  }) async {
    final token = await _tokenStore.getOrCreateToken();
    final headers = <String, String>{
      'Accept': 'application/json',
      'X-Device-Token': token,
      'X-Request-Id': requestId,
      'X-Client-Request-Id': requestId,
      ...?extra,
    };

    final accessToken = await _authSessionStore.readValidAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  Future<void> _captureAuthPayload(Map<String, dynamic> payload) async {
    final auth = payload['auth'];
    if (auth is Map) {
      final authPayload = <String, dynamic>{};
      auth.forEach((key, value) {
        authPayload['$key'] = value;
      });
      await _authSessionStore.saveFromAuthPayload(authPayload);
    }
  }

  Future<void> _tryRefreshBeforeRequest() async {
    final access = await _authSessionStore.readValidAccessToken();
    if (access != null && access.isNotEmpty) {
      return;
    }

    final refresh = await _authSessionStore.readValidRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      return;
    }

    await _refreshAccessSession();
  }

  bool _isUnauthorizedResponse({
    required http.Response response,
    required Map<String, dynamic> payload,
  }) {
    if (response.statusCode != 401) {
      return false;
    }
    final errorText = (payload['error'] as String? ?? '').toLowerCase();
    if (errorText.contains('email or password')) {
      return false;
    }
    return true;
  }

  bool _shouldTryRefresh(String path) {
    final normalized = path.toLowerCase();
    if (normalized.contains('action=refresh_session')) {
      return false;
    }
    if (normalized.contains('action=login')) {
      return false;
    }
    if (normalized.contains('action=register')) {
      return false;
    }
    return true;
  }

  Future<bool> _refreshAccessSession() {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final next = _refreshAccessSessionInner();
    _refreshInFlight = next;
    return next.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _refreshAccessSessionInner() async {
    final refreshToken = await _authSessionStore.readValidRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    const metricPath = ApiEndpoints.legacyRefreshSessionAction;
    final requestWatch = Stopwatch()..start();
    var requestId = _nextRequestId();
    final trace = PerfMonitor.start('api.post.refresh_session');

    final uri = _buildUri(
      path: ApiEndpoints.legacyAction(ApiEndpoints.legacyRefreshSessionAction),
    );

    http.Response response;
    try {
      response = await _httpClient
          .post(
            uri,
            headers: await _buildAuthHeaders(
              extra: <String, String>{'Content-Type': 'application/json'},
              requestId: requestId,
            ),
            body: jsonEncode(<String, dynamic>{'refresh_token': refreshToken}),
          )
          .timeout(_requestTimeout);
      requestId = _responseRequestId(response) ?? requestId;
    } on SocketException {
      trace.stop(success: false);
      AppMonitoring.recordApiRequest(
        endpoint: metricPath,
        method: HttpMethod.post.name,
        durationMs: requestWatch.elapsedMilliseconds,
        isNetworkError: true,
        requestId: requestId,
      );
      return false;
    } on http.ClientException {
      trace.stop(success: false);
      AppMonitoring.recordApiRequest(
        endpoint: metricPath,
        method: HttpMethod.post.name,
        durationMs: requestWatch.elapsedMilliseconds,
        isNetworkError: true,
        requestId: requestId,
      );
      return false;
    } on TimeoutException {
      trace.stop(success: false);
      AppMonitoring.recordApiRequest(
        endpoint: metricPath,
        method: HttpMethod.post.name,
        durationMs: requestWatch.elapsedMilliseconds,
        isNetworkError: true,
        isTimeout: true,
        requestId: requestId,
      );
      return false;
    }

    Map<String, dynamic> payload;
    try {
      payload = _parsePayload(response, requestId: requestId);
    } on ApiException catch (error) {
      trace.stop(success: false, statusCode: response.statusCode);
      final resolvedRequestId = error.requestId ?? requestId;
      AppMonitoring.recordApiRequest(
        endpoint: metricPath,
        method: HttpMethod.post.name,
        durationMs: requestWatch.elapsedMilliseconds,
        statusCode: error.statusCode ?? response.statusCode,
        isNetworkError: error.isNetworkError,
        isTimeout: error.message.toLowerCase().contains('timeout'),
        requestId: resolvedRequestId,
      );
      return false;
    }

    final ok = payload['ok'] == true;
    if (response.statusCode >= 200 && response.statusCode < 300 && ok) {
      await _captureAuthPayload(payload);
      trace.stop(success: true, statusCode: response.statusCode);
      AppMonitoring.recordApiRequest(
        endpoint: metricPath,
        method: HttpMethod.post.name,
        durationMs: requestWatch.elapsedMilliseconds,
        statusCode: response.statusCode,
        requestId: requestId,
      );
      return true;
    }

    if (response.statusCode == 401 || response.statusCode == 400) {
      await _authSessionStore.clear();
    } else if (_shouldClearAuthSessionForCode(_errorCode(payload))) {
      await _authSessionStore.clear();
    }
    trace.stop(success: false, statusCode: response.statusCode);
    AppMonitoring.recordApiRequest(
      endpoint: metricPath,
      method: HttpMethod.post.name,
      durationMs: requestWatch.elapsedMilliseconds,
      statusCode: response.statusCode,
      requestId: requestId,
    );
    return false;
  }

  Map<String, dynamic> _parsePayload(
    http.Response response, {
    String? requestId,
  }) {
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
        requestId: requestId,
      );
    }
  }

  Uri _buildUri({required String path, Map<String, dynamic>? query}) {
    final relative = path.startsWith('/') ? path.substring(1) : path;
    final baseUri = Uri.parse(_baseUrl);
    final resolved = baseUri.resolve(relative);

    if (query == null || query.isEmpty) {
      return resolved;
    }

    final current = Map<String, String>.from(resolved.queryParameters);
    query.forEach((key, value) {
      if (value != null) {
        current[key] = '$value';
      }
    });

    return resolved.replace(queryParameters: current);
  }

  Future<http.Response> _send({
    required Uri uri,
    required HttpMethod method,
    required Map<String, String> headers,
    Object? body,
  }) {
    late final Future<http.Response> request;
    switch (method) {
      case HttpMethod.get:
        request = _httpClient.get(uri, headers: headers);
        break;
      case HttpMethod.post:
        request = _httpClient.post(uri, headers: headers, body: body);
        break;
      case HttpMethod.put:
        request = _httpClient.put(uri, headers: headers, body: body);
        break;
      case HttpMethod.patch:
        request = _httpClient.patch(uri, headers: headers, body: body);
        break;
      case HttpMethod.delete:
        request = _httpClient.delete(uri, headers: headers, body: body);
        break;
    }
    return request.timeout(_requestTimeout);
  }

  static String _ensureTrailingSlash(String value) {
    return value.endsWith('/') ? value : '$value/';
  }

  static bool _methodHasBody(HttpMethod method) {
    return method == HttpMethod.post ||
        method == HttpMethod.put ||
        method == HttpMethod.patch ||
        method == HttpMethod.delete;
  }

  static String _errorMessage(Map<String, dynamic> payload, int statusCode) {
    final raw = payload['error'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return 'HTTP $statusCode';
  }

  static String? _errorCode(Map<String, dynamic> payload) {
    final raw = payload['code'];
    if (raw is! String) {
      return null;
    }
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static bool _shouldClearAuthSessionForCode(String? code) {
    if (code == null) {
      return false;
    }
    final normalized = code.trim().toUpperCase();
    return normalized == 'ACCOUNT_DEACTIVATED' ||
        normalized == 'ACCOUNT_DELETED' ||
        normalized == 'EMAIL_NOT_VERIFIED';
  }

  String _metricNameForPath(String path) {
    final match = RegExp(
      r'action=([a-z0-9_]+)',
      caseSensitive: false,
    ).firstMatch(path);
    if (match != null) {
      return match.group(1) ?? 'unknown';
    }
    final normalized = path.trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'empty';
    }
    return normalized.replaceAll(RegExp(r'[^a-z0-9_.-]+'), '_');
  }

  String _nextRequestId() {
    final timePart = DateTime.now()
        .toUtc()
        .microsecondsSinceEpoch
        .toRadixString(36);
    final randomPart = _requestIdRandom.nextInt(1 << 32).toRadixString(36);
    return 'rid_${timePart}_$randomPart';
  }

  String? _responseRequestId(http.Response response) {
    final requestId = _headerValue(response.headers, 'x-request-id');
    if (requestId != null && requestId.trim().isNotEmpty) {
      return requestId.trim();
    }
    final clientRequestId = _headerValue(
      response.headers,
      'x-client-request-id',
    );
    if (clientRequestId != null && clientRequestId.trim().isNotEmpty) {
      return clientRequestId.trim();
    }
    return null;
  }

  String? _headerValue(Map<String, String> headers, String targetLowerCase) {
    for (final entry in headers.entries) {
      if (entry.key.toLowerCase() == targetLowerCase) {
        return entry.value;
      }
    }
    return null;
  }
}
