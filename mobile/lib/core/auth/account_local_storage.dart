import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'account_data_session.dart';

/// Serializes cache writes, queue edits and logout cleanup through one store.
class AccountLocalStorage {
  AccountLocalStorage(this.session);

  final AccountDataSession session;
  Future<void> _tail = Future<void>.value();
  static const _prefix = 'account_data_v1_';

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  String _key(AccountDataLease lease, String key) {
    final host = base64Url.encode(utf8.encode(session.namespace));
    return '$_prefix${host}_${lease.userId}_$key';
  }

  Future<SharedPreferences> _preferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Legacy entries have no provable owner. Never adopt them into a login.
    for (final key in prefs.getKeys().toList()) {
      if (key == 'workspace_mutation_queue_v1') {
        final legacy = prefs.getString(key);
        const quarantine = 'unassigned_workspace_queue_v1';
        if (legacy != null && prefs.getString(quarantine) != legacy) {
          final archiveKey = prefs.containsKey(quarantine)
              ? '${quarantine}_${DateTime.now().microsecondsSinceEpoch}'
              : quarantine;
          // Recovery only after ownership review, never read/replayed by the app.
          if (!await prefs.setString(archiveKey, legacy)) {
            throw StateError('Could not preserve unassigned offline changes.');
          }
        }
      }
      if (key.startsWith('workspace_snapshot_trip_') ||
          key == 'workspace_mutation_queue_v1' ||
          key == 'workspace_global_notifications_v1' ||
          key == 'trips_list_cache_v1') {
        await prefs.remove(key);
      }
    }
    return prefs;
  }

  Future<String?> read(String key) {
    final lease = session.capture();
    return _serial(() async {
      lease.check();
      final prefs = await _preferences();
      lease.check();
      return prefs.getString(_key(lease, key));
    });
  }

  Future<void> write(String key, String value) => update(key, (_) => value);

  Future<void> update(String key, String? Function(String?) change) {
    final lease = session.capture();
    return _serial(() async {
      lease.check();
      final prefs = await _preferences();
      lease.check();
      final scopedKey = _key(lease, key);
      final value = change(prefs.getString(scopedKey));
      if (value == null) {
        if (!await prefs.remove(scopedKey)) {
          throw StateError('Could not clear offline data.');
        }
      } else {
        if (!await prefs.setString(scopedKey, value)) {
          throw StateError('Could not save offline data.');
        }
      }
      if (!lease.isCurrent) {
        // Cleanup precedes any later generation's serialized write.
        await prefs.remove(scopedKey);
        lease.check();
      }
    });
  }

  Future<void> clear() => _serial(() async {
    final prefs = await _preferences();
    for (final key
        in prefs.getKeys().where((key) => key.startsWith(_prefix)).toList()) {
      await prefs.remove(key);
    }
  });
}
