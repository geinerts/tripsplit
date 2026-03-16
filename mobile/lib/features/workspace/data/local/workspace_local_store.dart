import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/workspace_snapshot.dart';
import 'workspace_snapshot_codec.dart';

class WorkspaceLocalStore {
  static const String _snapshotPrefix = 'workspace_snapshot_trip_v3_';
  static const String _queueKey = 'workspace_mutation_queue_v1';

  Future<void> writeSnapshot({
    required int tripId,
    required WorkspaceSnapshot snapshot,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_snapshotPrefix$tripId';
    final raw = jsonEncode(WorkspaceSnapshotCodec.toMap(snapshot));
    await prefs.setString(key, raw);
  }

  Future<WorkspaceSnapshot?> readSnapshot({required int tripId}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_snapshotPrefix$tripId';
    final raw = prefs.getString(key);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return WorkspaceSnapshotCodec.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> readQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.trim().isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return <Map<String, dynamic>>[];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> writeQueue(List<Map<String, dynamic>> queue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  Future<void> enqueue(Map<String, dynamic> item) async {
    final queue = await readQueue();
    final next = [...queue, item];
    await writeQueue(next);
  }

  Future<int> queueCount() async {
    final queue = await readQueue();
    return queue.length;
  }
}
