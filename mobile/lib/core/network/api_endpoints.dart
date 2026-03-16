class ApiEndpoints {
  const ApiEndpoints._();

  // Legacy backend compatibility (current running API).
  static const String legacyBasePath = 'api/api.php';
  static const String legacyRefreshSessionAction = 'refresh_session';

  static String legacyAction(String action) {
    return '$legacyBasePath?action=$action';
  }

  // Target v1 structure for future migration.
  static const String v1BasePath = 'api/v1';
  static const String v1AuthLogin = '$v1BasePath/auth/login';
  static const String v1Trips = '$v1BasePath/trips';
}
