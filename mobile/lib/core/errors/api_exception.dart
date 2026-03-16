class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
    this.requestId,
  });

  final String message;
  final int? statusCode;
  final bool isNetworkError;
  final String? requestId;

  @override
  String toString() {
    return 'ApiException(message: $message, statusCode: $statusCode, isNetworkError: $isNetworkError, requestId: $requestId)';
  }
}
