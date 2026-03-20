import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/workspace_notification.dart';
import '../../domain/entities/workspace_notifications_inbox.dart';
import '../../domain/entities/workspace_snapshot.dart';
import 'workspace_snapshot_codec.dart';

class WorkspaceLocalStore {
  static const String _snapshotPrefix = 'workspace_snapshot_trip_v3_';
  static const String _queueKey = 'workspace_mutation_queue_v1';
  static const String _globalNotificationsKey =
      'workspace_global_notifications_v1';

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

  Future<void> writeGlobalNotificationsInbox(
    WorkspaceNotificationsInbox inbox,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(<String, dynamic>{
      'unread_count': inbox.unreadCount,
      'has_more': inbox.hasMore,
      'next_cursor': inbox.nextCursor,
      'next_offset': inbox.nextOffset,
      'notifications': inbox.notifications
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'trip_id': item.tripId,
              'trip_name': item.tripName,
              'type': item.type,
              'title': item.title,
              'body': item.body,
              'is_read': item.isRead,
              'created_at': item.createdAt,
            },
          )
          .toList(growable: false),
    });
    await prefs.setString(_globalNotificationsKey, raw);
  }

  Future<WorkspaceNotificationsInbox?> readGlobalNotificationsInbox() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_globalNotificationsKey);
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final notificationsRaw =
          decoded['notifications'] as List<dynamic>? ?? const <dynamic>[];
      final notifications = notificationsRaw
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => WorkspaceNotification(
              id: (item['id'] as num?)?.toInt() ?? 0,
              tripId: (item['trip_id'] as num?)?.toInt() ?? 0,
              tripName:
                  (item['trip_name'] as String?)?.trim().isNotEmpty == true
                  ? (item['trip_name'] as String).trim()
                  : null,
              type: (item['type'] as String? ?? '').trim(),
              title: (item['title'] as String? ?? '').trim(),
              body: (item['body'] as String? ?? '').trim(),
              isRead: item['is_read'] == true,
              createdAt:
                  (item['created_at'] as String?)?.trim().isNotEmpty == true
                  ? (item['created_at'] as String).trim()
                  : null,
            ),
          )
          .toList(growable: false);

      return WorkspaceNotificationsInbox(
        unreadCount: (decoded['unread_count'] as num?)?.toInt() ?? 0,
        notifications: notifications,
        hasMore: decoded['has_more'] == true,
        nextCursor:
            (decoded['next_cursor'] as String?)?.trim().isNotEmpty == true
            ? (decoded['next_cursor'] as String).trim()
            : null,
        nextOffset: (decoded['next_offset'] as num?)?.toInt(),
      );
    } catch (_) {
      return null;
    }
  }
}
