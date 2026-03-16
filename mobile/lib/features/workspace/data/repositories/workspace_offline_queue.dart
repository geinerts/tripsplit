import '../../../../core/errors/api_exception.dart';
import '../../domain/entities/expense_split_value.dart';
import '../../domain/entities/queued_mutation.dart';
import '../datasources/workspace_remote_data_source.dart';
import '../local/workspace_local_store.dart';

class WorkspaceOfflineQueue {
  WorkspaceOfflineQueue({
    required WorkspaceRemoteDataSource remote,
    required WorkspaceLocalStore localStore,
  }) : _remote = remote,
       _localStore = localStore;

  static const String typeAddExpense = 'add_expense';
  static const String typeUpdateExpense = 'update_expense';
  static const String typeDeleteExpense = 'delete_expense';

  final WorkspaceRemoteDataSource _remote;
  final WorkspaceLocalStore _localStore;
  int _queueSeed = 0;

  Future<int> pendingCount({int? tripId}) async {
    final queue = await _localStore.readQueue();
    return _filterQueueByTrip(queue, tripId).length;
  }

  Future<List<QueuedMutation>> listQueuedMutations({int? tripId}) async {
    final queue = await _localStore.readQueue();
    final filtered = _filterQueueByTrip(queue, tripId)
      ..sort((a, b) {
        final aCreated = (a['created_at'] as num?)?.toInt() ?? 0;
        final bCreated = (b['created_at'] as num?)?.toInt() ?? 0;
        return bCreated.compareTo(aCreated);
      });
    return filtered.map(_mapQueuedMutation).toList(growable: false);
  }

  Future<void> enqueueAddExpense({
    required int tripId,
    required double amount,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    String? receiptPath,
  }) {
    return _localStore.enqueue(<String, dynamic>{
      'id': _newQueueId(),
      'type': typeAddExpense,
      'trip_id': tripId,
      'payload': <String, dynamic>{
        'amount': amount,
        'category': category,
        'note': note,
        'date': date,
        'participants': participants,
        'split_mode': splitMode,
        if (splitValues.isNotEmpty)
          'splits': splitValues
              .map(
                (item) => <String, dynamic>{
                  'user_id': item.userId,
                  'value': item.value,
                },
              )
              .toList(growable: false),
        if (receiptPath != null && receiptPath.trim().isNotEmpty)
          'receipt_path': receiptPath,
      },
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> enqueueUpdateExpense({
    required int tripId,
    required int expenseId,
    required double amount,
    required String category,
    required String note,
    required String date,
    required List<int> participants,
    required String splitMode,
    required List<ExpenseSplitValue> splitValues,
    String? receiptPath,
    bool removeReceipt = false,
  }) {
    return _localStore.enqueue(<String, dynamic>{
      'id': _newQueueId(),
      'type': typeUpdateExpense,
      'trip_id': tripId,
      'payload': <String, dynamic>{
        'expense_id': expenseId,
        'amount': amount,
        'category': category,
        'note': note,
        'date': date,
        'participants': participants,
        'split_mode': splitMode,
        if (splitValues.isNotEmpty)
          'splits': splitValues
              .map(
                (item) => <String, dynamic>{
                  'user_id': item.userId,
                  'value': item.value,
                },
              )
              .toList(growable: false),
        if (receiptPath != null && receiptPath.trim().isNotEmpty)
          'receipt_path': receiptPath,
        if (removeReceipt) 'remove_receipt': true,
      },
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> enqueueDeleteExpense({
    required int tripId,
    required int expenseId,
  }) {
    return _localStore.enqueue(<String, dynamic>{
      'id': _newQueueId(),
      'type': typeDeleteExpense,
      'trip_id': tripId,
      'payload': <String, dynamic>{'expense_id': expenseId},
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> flushBestEffort() async {
    final queue = await _localStore.readQueue();
    if (queue.isEmpty) {
      return;
    }

    final keep = <Map<String, dynamic>>[];

    for (var i = 0; i < queue.length; i++) {
      final item = queue[i];
      try {
        await _executeQueuedItem(item);
      } on ApiException catch (error) {
        if (error.isNetworkError) {
          keep.addAll(queue.sublist(i));
          break;
        }
        // Drop invalid or forbidden items and continue.
      } catch (_) {
        // Drop malformed queue item.
      }
    }

    await _localStore.writeQueue(keep);
  }

  Future<void> _executeQueuedItem(Map<String, dynamic> item) async {
    final type = item['type'] as String? ?? '';
    final tripId = (item['trip_id'] as num?)?.toInt() ?? 0;
    final payload = item['payload'];
    if (tripId <= 0 || payload is! Map<String, dynamic>) {
      throw const ApiException('Invalid queued payload.');
    }

    switch (type) {
      case typeAddExpense:
        await _remote.addExpense(
          tripId: tripId,
          amount: (payload['amount'] as num?)?.toDouble() ?? 0,
          category: payload['category'] as String? ?? 'other',
          note: payload['note'] as String? ?? '',
          date: payload['date'] as String? ?? '',
          participants: _toIntList(payload['participants']),
          splitMode: _normalizeSplitMode(payload['split_mode']),
          splitValues: _toSplitValues(payload['splits']),
          receiptPath: payload['receipt_path'] as String?,
        );
        break;
      case typeUpdateExpense:
        await _remote.updateExpense(
          tripId: tripId,
          expenseId: (payload['expense_id'] as num?)?.toInt() ?? 0,
          amount: (payload['amount'] as num?)?.toDouble() ?? 0,
          category: payload['category'] as String? ?? 'other',
          note: payload['note'] as String? ?? '',
          date: payload['date'] as String? ?? '',
          participants: _toIntList(payload['participants']),
          splitMode: _normalizeSplitMode(payload['split_mode']),
          splitValues: _toSplitValues(payload['splits']),
          receiptPath: payload['receipt_path'] as String?,
          removeReceipt: payload['remove_receipt'] == true,
        );
        break;
      case typeDeleteExpense:
        await _remote.deleteExpense(
          tripId: tripId,
          expenseId: (payload['expense_id'] as num?)?.toInt() ?? 0,
        );
        break;
      default:
        throw const ApiException('Unknown queued mutation type.');
    }
  }

  static List<int> _toIntList(Object? value) {
    if (value is! List<dynamic>) {
      return const <int>[];
    }
    return value
        .map((item) => (item as num?)?.toInt() ?? 0)
        .where((id) => id > 0)
        .toList(growable: false);
  }

  String _newQueueId() {
    _queueSeed += 1;
    return '${DateTime.now().microsecondsSinceEpoch}_${_queueSeed.toString().padLeft(4, '0')}';
  }

  static List<Map<String, dynamic>> _filterQueueByTrip(
    List<Map<String, dynamic>> queue,
    int? tripId,
  ) {
    if (tripId == null || tripId <= 0) {
      return queue;
    }
    return queue
        .where((item) => ((item['trip_id'] as num?)?.toInt() ?? 0) == tripId)
        .toList(growable: false);
  }

  static QueuedMutation _mapQueuedMutation(Map<String, dynamic> item) {
    final payload = item['payload'] as Map<String, dynamic>? ?? const {};
    final createdAtMillis = (item['created_at'] as num?)?.toInt() ?? 0;
    final tripId = (item['trip_id'] as num?)?.toInt() ?? 0;
    final typeRaw = item['type'] as String? ?? '';
    final id =
        item['id'] as String? ??
        '${createdAtMillis}_${tripId}_${typeRaw.isEmpty ? 'unknown' : typeRaw}';

    return QueuedMutation(
      id: id,
      tripId: tripId,
      createdAtMillis: createdAtMillis,
      type: _parseMutationType(typeRaw),
      amount: (payload['amount'] as num?)?.toDouble(),
      note: payload['note'] as String?,
      expenseId: (payload['expense_id'] as num?)?.toInt(),
      date: payload['date'] as String?,
    );
  }

  static QueuedMutationType _parseMutationType(String raw) {
    switch (raw) {
      case typeAddExpense:
        return QueuedMutationType.addExpense;
      case typeUpdateExpense:
        return QueuedMutationType.updateExpense;
      case typeDeleteExpense:
        return QueuedMutationType.deleteExpense;
      default:
        return QueuedMutationType.unknown;
    }
  }

  static String _normalizeSplitMode(Object? raw) {
    final value = (raw as String? ?? '').trim().toLowerCase();
    if (value == 'exact' || value == 'percent' || value == 'shares') {
      return value;
    }
    return 'equal';
  }

  static List<ExpenseSplitValue> _toSplitValues(Object? raw) {
    if (raw is! List<dynamic>) {
      return const <ExpenseSplitValue>[];
    }
    final out = <ExpenseSplitValue>[];
    for (final item in raw) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final userId = (item['user_id'] as num?)?.toInt() ?? 0;
      final value = (item['value'] as num?)?.toDouble() ?? 0;
      if (userId <= 0 || value < 0) {
        continue;
      }
      out.add(ExpenseSplitValue(userId: userId, value: value));
    }
    return out;
  }
}
