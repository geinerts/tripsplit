class AppEnv {
  const AppEnv({
    required this.apiBaseUrl,
    required this.enableVerboseLogs,
    required this.enablePerformanceLogs,
    required this.apiRequestTimeout,
    required this.googleServerClientId,
    required this.monitoringDsn,
    required this.monitoringEnvironment,
    required this.releaseChannel,
    required this.monitoringTraceSampleRate,
  });

  final String apiBaseUrl;
  final bool enableVerboseLogs;
  final bool enablePerformanceLogs;
  final Duration apiRequestTimeout;
  final String googleServerClientId;
  final String monitoringDsn;
  final String monitoringEnvironment;
  final String releaseChannel;
  final double monitoringTraceSampleRate;

  static final AppEnv current = AppEnv(
    apiBaseUrl: String.fromEnvironment(
      'TRIPSPLIT_API_BASE_URL',
      defaultValue: 'https://splyto.eu',
    ),
    enableVerboseLogs: bool.fromEnvironment(
      'TRIPSPLIT_VERBOSE_LOGS',
      defaultValue: false,
    ),
    enablePerformanceLogs: bool.fromEnvironment(
      'TRIPSPLIT_PERF_LOGS',
      defaultValue: false,
    ),
    apiRequestTimeout: Duration(
      seconds: int.fromEnvironment(
        'TRIPSPLIT_API_TIMEOUT_SEC',
        defaultValue: 15,
      ),
    ),
    googleServerClientId: String.fromEnvironment(
      'TRIPSPLIT_GOOGLE_SERVER_CLIENT_ID',
      defaultValue:
          '126032869696-qvttfvd5p8sq0js3mms0kqfnbpbig0mm.apps.googleusercontent.com',
    ),
    monitoringDsn: String.fromEnvironment(
      'TRIPSPLIT_SENTRY_DSN',
      defaultValue: '',
    ),
    monitoringEnvironment: String.fromEnvironment(
      'TRIPSPLIT_MONITORING_ENV',
      defaultValue: '',
    ),
    releaseChannel: String.fromEnvironment(
      'TRIPSPLIT_RELEASE_CHANNEL',
      defaultValue: 'dev',
    ),
    monitoringTraceSampleRate: _monitoringTraceSampleRateFromEnvironment(),
  );

  static double _monitoringTraceSampleRateFromEnvironment() {
    const raw = String.fromEnvironment(
      'TRIPSPLIT_MONITORING_TRACE_SAMPLE_RATE',
      defaultValue: '0.0',
    );
    final parsed = double.tryParse(raw.trim());
    return parsed ?? 0.0;
  }
}
