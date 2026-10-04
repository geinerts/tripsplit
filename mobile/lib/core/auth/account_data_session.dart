import 'dart:async';

import '../errors/api_exception.dart';

/// Binds async work to the account and login generation that started it.
class AccountDataSession {
  AccountDataSession({this.namespace = 'default'});

  static final Object _zoneKey = Object();
  final String namespace;
  int? _userId;
  int _generation = 0;

  int? get userId => _userId;
  int get generation => _generation;

  void activate(int userId) {
    if (userId <= 0) throw ArgumentError.value(userId, 'userId');
    if (_userId == userId) return;
    _generation++;
    _userId = userId;
  }

  void invalidate() {
    _generation++;
    _userId = null;
  }

  void checkGeneration(int generation) {
    if (generation != _generation) throw changed;
  }

  static const changed = ApiException(
    'Account changed. Please try again.',
    code: 'account_changed',
  );

  static AccountDataLease? get boundLease =>
      Zone.current[_zoneKey] as AccountDataLease?;

  AccountDataLease capture() {
    final bound = boundLease;
    if (bound != null) {
      if (!identical(bound.session, this)) throw changed;
      bound.check();
      return bound;
    }
    final id = _userId;
    if (id == null) throw changed;
    return AccountDataLease._(this, id, _generation);
  }

  Future<T> run<T>(Future<T> Function() operation) async {
    final lease = capture();
    return runZoned(() async {
      lease.check();
      final result = await operation();
      lease.check();
      return result;
    }, zoneValues: {_zoneKey: lease});
  }
}

class AccountDataLease {
  AccountDataLease._(this.session, this.userId, this.generation);
  final AccountDataSession session;
  final int userId;
  final int generation;

  bool get isCurrent =>
      session.userId == userId && session.generation == generation;

  void check() {
    if (!isCurrent) throw AccountDataSession.changed;
  }
}
