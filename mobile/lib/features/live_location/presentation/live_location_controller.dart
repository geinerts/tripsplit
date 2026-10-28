import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/auth/account_data_session.dart';
import '../../../core/errors/api_exception.dart';
import '../data/live_location_device.dart';
import '../data/live_location_repository.dart';
import '../domain/live_location.dart';

/// App-scoped consent sessions: navigating away does not stop a timed share.
/// Coordinates and tokens are memory-only; restarting never resumes tracking.
class LiveLocationController extends ChangeNotifier {
  LiveLocationController(
    this.repository,
    this.device,
    this.account, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;
  final DateTime Function() _now;
  final LiveLocationRepository repository;
  final LiveLocationDevice device;
  final AccountDataSession account;
  final Map<int, LiveShareSession> _shares = {};
  final Set<int> _stopping = {}, _busy = {};
  final Map<int, Object> errors = {};
  AccountDataLease? _lease;
  StreamSubscription<LiveFix>? _stream;
  Timer? _timer;
  LiveFix? _fix;
  DateTime? _lastSend;
  bool _sending = false, _disposed = false;
  int _generation = 0;
  bool busy(int trip) => _busy.contains(trip);
  bool stopping(int trip) => _stopping.contains(trip);
  LiveShareSession? sharing(int trip) => _shares[trip];
  void _changed() {
    if (!_disposed) notifyListeners();
  }

  Future<void> start(
    int trip,
    int minutes, {
    required String title,
    required String text,
  }) async {
    if (_busy.contains(trip)) return;
    final lease = account.capture(), generation = _generation;
    _busy.add(trip);
    errors.remove(trip);
    _changed();
    var created = false;
    try {
      final fix = await device.requestFix();
      lease.check();
      if (_disposed || generation != _generation) return;
      final share = await repository.start(trip, minutes, fix);
      created = true;
      lease.check();
      if (_disposed || generation != _generation) {
        await repository.stop(trip);
        return;
      }
      _lease = lease;
      _fix = fix;
      _shares[trip] = share;
      _stopping.remove(trip);
      _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      _stream ??= device
          .watch(title, text)
          .listen(
            (fix) {
              if (_lease?.isCurrent != true) {
                _clear();
                return;
              }
              _fix = fix;
              // A native location event can wake iOS while Dart timers are suspended.
              // Apply the same expiry/throttle checks before sending from that event.
              _tick();
            },
            onError: (Object error) {
              // Stop tracking if permission/services are revoked, and remove remote fixes.
              for (final id in _shares.keys.toList()) {
                unawaited(stop(id));
              }
            },
          );
    } catch (error) {
      if (created && lease.isCurrent) {
        await stop(trip);
      }
      errors[trip] = error;
      rethrow;
    } finally {
      _busy.remove(trip);
      _changed();
    }
  }

  void _tick() {
    if (_lease?.isCurrent != true) {
      _clear();
      return;
    }
    final now = _now();
    for (final entry in _shares.entries.toList()) {
      if (!entry.value.expiresAt.isAfter(now)) {
        _shares.remove(entry.key);
        _stopping.remove(entry.key);
        errors.remove(entry.key);
      }
    }
    if (_shares.isEmpty) {
      _clear();
      return;
    }
    if (!_sending &&
        (_lastSend == null || now.difference(_lastSend!).inSeconds >= 10)) {
      unawaited(_send());
    }
    _changed();
  }

  Future<void> _send() async {
    _sending = true;
    _lastSend = _now();
    try {
      for (final entry in _shares.entries.toList()) {
        if (_lease?.isCurrent != true || _disposed) return;
        if (_stopping.contains(entry.key)) {
          await stop(entry.key);
          continue;
        }
        final fix = _fix;
        if (fix == null || _now().difference(fix.observedAt).inSeconds > 90) {
          errors[entry.key] = LiveLocationPermissionError();
          continue;
        }
        try {
          await repository.update(entry.key, entry.value.token, fix);
          errors.remove(entry.key);
        } on ApiException catch (error) {
          errors[entry.key] = error;
          if ([401, 403, 404, 409].contains(error.statusCode)) {
            _shares.remove(entry.key);
          }
        } catch (error) {
          errors[entry.key] = error;
        }
      }
    } finally {
      _sending = false;
      _changed();
    }
  }

  Future<bool> stop(int trip) async {
    _stopping.add(trip);
    _changed();
    // Cancel native tracking immediately when no other trip still needs it.
    if (_shares.keys.every(_stopping.contains)) {
      unawaited(_stream?.cancel());
      _stream = null;
      _fix = null;
    }
    try {
      await repository.stop(trip);
      _shares.remove(trip);
      _stopping.remove(trip);
      errors.remove(trip);
      if (_shares.isEmpty) _clear();
      return true;
    } catch (error) {
      errors[trip] = error;
      return false;
    } finally {
      _changed();
    }
  }

  Future<void> stopAll() async {
    _generation++;
    unawaited(_stream?.cancel());
    _stream = null;
    _fix = null;
    await Future.wait(_shares.keys.toList().map(stop));
    _clear();
  }

  void _clear() {
    _timer?.cancel();
    _timer = null;
    unawaited(_stream?.cancel());
    _stream = null;
    _fix = null;
    _shares.clear();
    _stopping.clear();
    _lease = null;
    _lastSend = null;
    _changed();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _clear();
    super.dispose();
  }
}
