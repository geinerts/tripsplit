class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
    this.requestId,
    this.code,
  });

  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final String? requestId;
  final String? code;

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode, isNetworkError: $isNetworkError, requestId: $requestId, code: $code)';
  }
}
