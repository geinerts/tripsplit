import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../app/app_dependencies.dart';
import '../config/app_env.dart';

class AppMonitoring {
  AppMonitoring._();

  static AppDependencies? _dependencies;
  static bool _enabled = false;
  static bool _handlersInstalled = false;
  static int? _activeUserId;
  static int? _activeTripId;
  static String _release = 'splyto@dev+0';
  static String _releaseChannel = 'dev';
  static String _monitoringEnvironment = 'dev';
  static String _appVersion = 'unknown';
  static String _buildNumber = '0';
  static final Map<String, _ApiMetricBucket> _apiMetrics =
      <String, _ApiMetricBucket>{};
  static DateTime _lastApiMetricsPublishAt =
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  static int _apiRequestsSincePublish = 0;

  static Future<void> bootstrapAndRun({
    required AppDependencies dependencies,
    required Widget Function() appBuilder,
  }) async {
    _dependencies = dependencies;

    final env = AppEnv.current;
    _releaseChannel = _nonEmptyOrFallback(env.releaseChannel, 'dev');
    _monitoringEnvironment = _nonEmptyOrFallback(
      env.monitoringEnvironment,
      _releaseChannel,
    );

    final packageInfo = await _loadPackageInfo();
    _appVersion = packageInfo?.version.trim().isNotEmpty == true
        ? packageInfo!.version.trim()
        : 'unknown';
    _buildNumber = packageInfo?.buildNumber.trim().isNotEmpty == true
        ? packageInfo!.buildNumber.trim()
        : '0';
    _release = 'splyto@$_appVersion+$_buildNumber';

    _activeUserId = dependencies.authController.currentUser?.id;
    _activeTripId = null;

    final dsn = env.monitoringDsn.trim();
    if (dsn.isEmpty) {
      _enabled = false;
      _installGlobalHandlers();
      runZonedGuarded(
        () {
          runApp(appBuilder());
        },
        (error, stackTrace) {
          unawaited(
            _captureException(
              error,
              stackTrace: stackTrace,
              origin: 'zone',
              isFatal: true,
            ),
          );
        },
      );
      return;
    }

    final tracesSampleRate = _normalizeSampleRate(
      env.monitoringTraceSampleRate,
    );
    _enabled = true;
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.environment = _monitoringEnvironment;
        options.release = _release;
        options.attachStacktrace = true;
        options.sendDefaultPii = false;
        options.tracesSampleRate = tracesSampleRate;
      },
      appRunner: () {
        _installGlobalHandlers();
        runZonedGuarded(
          () {
            runApp(appBuilder());
          },
          (error, stackTrace) {
            unawaited(
              _captureException(
                error,
                stackTrace: stackTrace,
                origin: 'zone',
                isFatal: true,
              ),
            );
          },
        );
      },
    );
    await _syncScope();
  }

  static Future<void> updateRuntimeContext({int? userId, int? tripId}) async {
    _activeUserId = userId;
    _activeTripId = tripId;
    await _syncScope();
  }

  static Future<void> captureHandledException(
    Object error, {
    StackTrace? stackTrace,
    String origin = 'handled',
    Map<String, Object?> extras = const <String, Object?>{},
  }) {
    return _captureException(
      error,
      stackTrace: stackTrace ?? StackTrace.current,
      origin: origin,
      isFatal: false,
      extras: extras,
    );
  }

  static void recordApiRequest({
    required String endpoint,
    required String method,
    required int durationMs,
    int? statusCode,
    bool isNetworkError = false,
    bool isTimeout = false,
    String? requestId,
  }) {
    final normalizedMethod = method.trim().toUpperCase();
    final normalizedEndpoint = endpoint.trim().isEmpty
        ? 'unknown'
        : endpoint.trim();
    final key = '$normalizedMethod $normalizedEndpoint';
    final bucket = _apiMetrics.putIfAbsent(
      key,
      () => _ApiMetricBucket(
        method: normalizedMethod,
        endpoint: normalizedEndpoint,
      ),
    );
    bucket.add(
      durationMs: durationMs,
      statusCode: statusCode,
      isNetworkError: isNetworkError,
      isTimeout: isTimeout,
      requestId: requestId,
    );

    _apiRequestsSincePublish += 1;
    final now = DateTime.now().toUtc();
    final dueByCount = _apiRequestsSincePublish >= 40;
    final dueByTime =
        now.difference(_lastApiMetricsPublishAt) >= const Duration(minutes: 2);
    if (dueByCount || dueByTime) {
      _publishApiMetricsSnapshot(now);
    }
  }

  static void _installGlobalHandlers() {
    if (_handlersInstalled) {
      return;
    }
    _handlersInstalled = true;

    final previousFlutterOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (previousFlutterOnError != null &&
          previousFlutterOnError != FlutterError.presentError) {
        previousFlutterOnError(details);
      }
      unawaited(
        _captureException(
          details.exception,
          stackTrace: details.stack ?? StackTrace.current,
          origin: 'flutter',
          isFatal: true,
        ),
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      unawaited(
        _captureException(
          error,
          stackTrace: stackTrace,
          origin: 'platform',
          isFatal: true,
        ),
      );
      return true;
    };
  }

  static Future<void> _captureException(
    Object error, {
    required StackTrace stackTrace,
    required String origin,
    required bool isFatal,
    Map<String, Object?> extras = const <String, Object?>{},
  }) async {
    final userId =
        _activeUserId ?? _dependencies?.authController.currentUser?.id;
    final tripId = _activeTripId;

    if (!_enabled) {
      debugPrint(
        '[Monitoring:$origin] $error'
        ' user=$userId trip=$tripId fatal=$isFatal\n$stackTrace',
      );
      return;
    }

    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) {
        scope.level = SentryLevel.error;
        scope.setTag('origin', origin);
        scope.setTag('release_channel', _releaseChannel);
        scope.setTag('app_version', _appVersion);
        scope.setTag('build_number', _buildNumber);
        scope.setTag('platform', defaultTargetPlatform.name);
        scope.setTag('fatal', isFatal ? 'true' : 'false');

        if (userId != null && userId > 0) {
          scope.setUser(SentryUser(id: '$userId'));
        }
        if (tripId != null && tripId > 0) {
          scope.setTag('trip_id', '$tripId');
        }

        if (extras.isNotEmpty) {
          final serialized = <String, String>{};
          extras.forEach((key, value) {
            if (value == null) {
              return;
            }
            serialized[key] = '$value';
          });
          if (serialized.isNotEmpty) {
            scope.setContexts('extras', serialized);
          }
        }
      },
    );
  }

  static Future<void> _syncScope() async {
    if (!_enabled) {
      return;
    }

    await Sentry.configureScope((scope) {
      scope.setTag('release_channel', _releaseChannel);
      scope.setTag('app_version', _appVersion);
      scope.setTag('build_number', _buildNumber);
      scope.setTag('platform', defaultTargetPlatform.name);
      if (_activeUserId != null && _activeUserId! > 0) {
        scope.setUser(SentryUser(id: '$_activeUserId'));
      } else {
        scope.setUser(null);
      }
      if (_activeTripId != null && _activeTripId! > 0) {
        scope.setTag('trip_id', '$_activeTripId');
      } else {
        scope.removeTag('trip_id');
      }
    });
  }

  static void _publishApiMetricsSnapshot(DateTime nowUtc) {
    if (_apiMetrics.isEmpty) {
      _lastApiMetricsPublishAt = nowUtc;
      _apiRequestsSincePublish = 0;
      return;
    }

    _lastApiMetricsPublishAt = nowUtc;
    _apiRequestsSincePublish = 0;
    final top = _apiMetrics.values.toList(growable: false)
      ..sort((a, b) => b.total.compareTo(a.total));
    final topSummary = top
        .take(8)
        .map((bucket) => bucket.toSummaryMap())
        .toList(growable: false);

    if (!_enabled) {
      debugPrint('[Monitoring:api_metrics] ${jsonEncode(topSummary)}');
      return;
    }

    unawaited(
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'API metrics snapshot',
          category: 'api.metrics',
          type: 'http',
          data: <String, Object?>{'top_endpoints': topSummary},
        ),
      ),
    );
    Sentry.configureScope((scope) {
      scope.setContexts('api_metrics', <String, Object?>{
        'updated_at_utc': nowUtc.toIso8601String(),
        'top_endpoints': topSummary,
      });
    });
  }

  static Future<PackageInfo?> _loadPackageInfo() async {
    try {
      return await PackageInfo.fromPlatform();
    } catch (_) {
      return null;
    }
  }

  static String _nonEmptyOrFallback(String value, String fallback) {
    final normalized = value.trim();
    return normalized.isEmpty ? fallback : normalized;
  }

  static double _normalizeSampleRate(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0.0;
    }
    if (value < 0) {
      return 0.0;
    }
    if (value > 1) {
      return 1.0;
    }
    return value;
  }
}

class _ApiMetricBucket {
  _ApiMetricBucket({required this.method, required this.endpoint});

  final String method;
  final String endpoint;
  int total = 0;
  int success = 0;
  int http401 = 0;
  int http5xx = 0;
  int networkErrors = 0;
  int timeouts = 0;
  String? lastRequestId;
  final List<int> _durationsMs = <int>[];

  void add({
    required int durationMs,
    required int? statusCode,
    required bool isNetworkError,
    required bool isTimeout,
    required String? requestId,
  }) {
    total += 1;
    if (statusCode != null && statusCode >= 200 && statusCode < 300) {
      success += 1;
    }
    if (statusCode == 401) {
      http401 += 1;
    }
    if (statusCode != null && statusCode >= 500) {
      http5xx += 1;
    }
    if (isNetworkError) {
      networkErrors += 1;
    }
    if (isTimeout) {
      timeouts += 1;
    }
    if (requestId != null && requestId.trim().isNotEmpty) {
      lastRequestId = requestId.trim();
    }

    final normalizedDuration = durationMs < 0 ? 0 : durationMs;
    _durationsMs.add(normalizedDuration);
    if (_durationsMs.length > 500) {
      _durationsMs.removeAt(0);
    }
  }

  Map<String, Object?> toSummaryMap() {
    final errorCount = total - success;
    return <String, Object?>{
      'method': method,
      'endpoint': endpoint,
      'count': total,
      'success': success,
      'errors': errorCount < 0 ? 0 : errorCount,
      'http_401': http401,
      'http_5xx': http5xx,
      'network_errors': networkErrors,
      'timeouts': timeouts,
      'p95_ms': _percentile95Ms(),
      'last_request_id': lastRequestId,
    };
  }

  int _percentile95Ms() {
    if (_durationsMs.isEmpty) {
      return 0;
    }
    final sorted = List<int>.from(_durationsMs)..sort();
    var index = ((sorted.length - 1) * 0.95).round();
    if (index < 0) {
      index = 0;
    }
    if (index >= sorted.length) {
      index = sorted.length - 1;
    }
    return sorted[index];
  }
}
