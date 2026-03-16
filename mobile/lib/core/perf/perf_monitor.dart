import 'dart:collection';

import 'package:flutter/foundation.dart';

class PerfMonitor {
  PerfMonitor._();

  static bool _enabled = kDebugMode;
  static const int _maxSamplesPerMetric = 120;
  static final Map<String, _PerfMetricBucket> _metrics =
      <String, _PerfMetricBucket>{};

  static void configure({required bool enabled}) {
    _enabled = enabled;
  }

  static PerfTrace start(String metric) {
    return PerfTrace._(metric);
  }

  static void record(
    String metric,
    Duration duration, {
    required bool success,
    int? statusCode,
  }) {
    if (!_enabled) {
      return;
    }

    final elapsedMs = duration.inMilliseconds;
    final bucket = _metrics.putIfAbsent(
      metric,
      () => _PerfMetricBucket(_maxSamplesPerMetric),
    );
    bucket.add(elapsedMs, success: success);

    // Log aggregated metrics every 10 samples or immediately when very slow.
    final shouldLog = bucket.count % 10 == 0 || elapsedMs >= 1200;
    if (!shouldLog) {
      return;
    }

    final statusLabel = statusCode == null ? '-' : '$statusCode';
    debugPrint(
      '[PERF] $metric '
      'last=${elapsedMs}ms '
      'avg=${bucket.averageMs.toStringAsFixed(1)}ms '
      'p95=${bucket.percentile(0.95)}ms '
      'ok=${bucket.successCount}/${bucket.count} '
      'status=$statusLabel',
    );
  }
}

class PerfTrace {
  PerfTrace._(this._metric) : _stopwatch = Stopwatch()..start();

  final String _metric;
  final Stopwatch _stopwatch;
  bool _isStopped = false;

  void stop({bool success = true, int? statusCode}) {
    if (_isStopped) {
      return;
    }
    _isStopped = true;
    _stopwatch.stop();
    PerfMonitor.record(
      _metric,
      _stopwatch.elapsed,
      success: success,
      statusCode: statusCode,
    );
  }
}

class _PerfMetricBucket {
  _PerfMetricBucket(this._maxSamples);

  final int _maxSamples;
  final Queue<int> _samples = ListQueue<int>();
  int _sum = 0;
  int successCount = 0;
  int failureCount = 0;

  int get count => successCount + failureCount;

  double get averageMs {
    if (_samples.isEmpty) {
      return 0;
    }
    return _sum / _samples.length;
  }

  void add(int elapsedMs, {required bool success}) {
    _samples.addLast(elapsedMs);
    _sum += elapsedMs;
    if (_samples.length > _maxSamples) {
      _sum -= _samples.removeFirst();
    }

    if (success) {
      successCount += 1;
    } else {
      failureCount += 1;
    }
  }

  int percentile(double value) {
    if (_samples.isEmpty) {
      return 0;
    }
    final sorted = _samples.toList(growable: false)..sort();
    final index = ((sorted.length - 1) * value).round().clamp(
      0,
      sorted.length - 1,
    );
    return sorted[index];
  }
}
