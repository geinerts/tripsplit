import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Remembers outages so each offline action need not wait for another timeout.
/// Transport changes restore normal requests; Wi-Fi outages are probed in the
/// background without credentials or replaying a user's mutation.
class NetworkConnection {
  NetworkConnection({
    required Future<bool> Function() probe,
    Future<List<ConnectivityResult>> Function()? check,
    Stream<List<ConnectivityResult>>? changes,
    DateTime Function()? now,
  }) : _probe = probe,
       _now = now ?? DateTime.now {
    final connectivity = Connectivity();
    _subscription = (changes ?? connectivity.onConnectivityChanged).listen(
      _update,
      onError: (Object _) {},
    );
    _initial = _initialize(check ?? connectivity.checkConnectivity);
  }

  final Future<bool> Function() _probe;
  final DateTime Function() _now;
  final ValueNotifier<bool> _status = ValueNotifier<bool>(false);

  /// True while the app is known to be offline: no network transport, or the
  /// last request failed and the server has not answered a probe since.
  /// Drives the single Offline indicator in the app bar.
  ValueListenable<bool> get offlineStatus => _status;

  void _publish() {
    if (_disposed) return;
    _status.value = _noTransport || _failed;
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;
  late final Future<void> _initial;
  Set<ConnectivityResult>? _transports;
  bool _failed = false;
  bool _probing = false;
  bool _disposed = false;
  int _revision = 0;
  DateTime? _nextProbe;

  Future<void> _initialize(
    Future<List<ConnectivityResult>> Function() check,
  ) async {
    final revision = _revision;
    try {
      final results = await check().timeout(const Duration(seconds: 1));
      if (!_disposed && revision == _revision) _update(results);
    } catch (_) {
      // An unavailable platform plugin is not proof of an offline connection.
    }
  }

  void _update(List<ConnectivityResult> results) {
    if (_disposed || results.isEmpty) return;
    final next = results.toSet();
    if (_transports?.length == next.length &&
        next.every((value) => _transports!.contains(value))) {
      return;
    }
    _revision++;
    _transports = next;
    _failed = false;
    _nextProbe = null;
    _publish();
  }

  bool get _noTransport =>
      _transports?.length == 1 &&
      _transports!.contains(ConnectivityResult.none);

  Future<bool> isOffline() async {
    await _initial;
    if (_noTransport) return true;
    if (!_failed) return false;
    if (!_disposed &&
        !_probing &&
        (_nextProbe == null || !_now().isBefore(_nextProbe!))) {
      unawaited(_checkRecovery());
    }
    return true;
  }

  void markNetworkFailure() {
    if (_disposed) return;
    _revision++;
    _failed = true;
    _publish();
  }

  Future<void> _checkRecovery() async {
    _probing = true;
    final revision = _revision;
    _nextProbe = _now().add(const Duration(seconds: 5));
    try {
      final recovered = await _probe().timeout(const Duration(seconds: 3));
      if (!_disposed && revision == _revision && recovered) {
        _failed = false;
        _publish();
      }
    } catch (_) {
      // Keep local operations available while the server is unreachable.
    } finally {
      _probing = false;
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await _subscription.cancel();
    _status.dispose();
  }
}

/// The existing `me` endpoint returns JSON 401 without credentials (also used
/// by the server health monitor). Never sends tokens, cookies or user data.
Future<bool> probeApiConnection(String baseUrl) async {
  final client = http.Client();
  try {
    final base = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
    final response = await client
        .get(
          Uri.parse(base).resolve('api/api.php?action=me'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 3));
    final body = jsonDecode(response.body);
    return response.statusCode == 401 && body is Map && body['ok'] == false;
  } catch (_) {
    return false;
  } finally {
    client.close();
  }
}
