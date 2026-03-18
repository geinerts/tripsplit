import '../../domain/entities/balance_item.dart';
import '../../domain/entities/expense_participant.dart';
import '../../domain/entities/random_order.dart';
import '../../domain/entities/random_order_member.dart';
import '../../domain/entities/settlement_item.dart';
import '../../domain/entities/trip_expense.dart';
import '../../domain/entities/workspace_notification.dart';
import '../../domain/entities/workspace_user.dart';

class WorkspaceRemoteParsers {
  static int _toInt(Object? value, {int fallback = 0}) {
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return fallback;
      }
      final parsedInt = int.tryParse(normalized);
      if (parsedInt != null) {
        return parsedInt;
      }
      final parsedDouble = double.tryParse(normalized);
      if (parsedDouble != null) {
        return parsedDouble.toInt();
      }
    }
    return fallback;
  }

  static bool _toBool(Object? value, {bool fallback = false}) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value.toInt() == 1;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == '1' ||
          normalized == 'true' ||
          normalized == 'yes' ||
          normalized == 'y') {
        return true;
      }
      if (normalized == '0' ||
          normalized == 'false' ||
          normalized == 'no' ||
          normalized == 'n') {
        return false;
      }
    }
    return fallback;
  }

  static String _toString(Object? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      return value;
    }
    return value.toString();
  }

  static String? _toNullableString(Object? value) {
    final result = _toString(value).trim();
    return result.isEmpty ? null : result;
  }

  static WorkspaceUser parseUser(Map<String, dynamic> item) {
    final displayName = (item['display_name'] as String? ?? '').trim();
    final avatarUrl = (item['avatar_url'] as String? ?? '').trim();
    final avatarThumbUrl = (item['avatar_thumb_url'] as String? ?? '').trim();
    return WorkspaceUser(
      id: (item['id'] as num?)?.toInt() ?? 0,
      nickname: item['nickname'] as String? ?? '',
      displayName: displayName.isEmpty ? null : displayName,
      avatarUrl: avatarUrl.isEmpty ? null : avatarUrl,
      avatarThumbUrl: avatarThumbUrl.isEmpty ? null : avatarThumbUrl,
    );
  }

  static BalanceItem parseBalance(Map<String, dynamic> item) {
    return BalanceItem(
      id: (item['id'] as num?)?.toInt() ?? 0,
      nickname: item['nickname'] as String? ?? '',
      paid: (item['paid'] as num?)?.toDouble() ?? 0,
      owed: (item['owed'] as num?)?.toDouble() ?? 0,
      net: (item['net'] as num?)?.toDouble() ?? 0,
    );
  }

  static SettlementItem parseSettlement(Map<String, dynamic> item) {
    final status = parseSettlementStatus(item['status']);
    return SettlementItem(
      id: (item['id'] as num?)?.toInt(),
      fromUserId: (item['from_user_id'] as num?)?.toInt() ?? 0,
      toUserId: (item['to_user_id'] as num?)?.toInt() ?? 0,
      from: item['from'] as String? ?? '',
      to: item['to'] as String? ?? '',
      amount: (item['amount'] as num?)?.toDouble() ?? 0,
      status: status,
      canMarkSent: item['can_mark_sent'] == true,
      canConfirmReceived: item['can_confirm_received'] == true,
      isConfirmed: item['is_confirmed'] == true || status == 'confirmed',
    );
  }

  static TripExpense parseExpense(Map<String, dynamic> item) {
    final splitMode = parseExpenseSplitMode(item['split_mode']);
    final participants = (item['participants'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (participant) => ExpenseParticipant(
            id: (participant['id'] as num?)?.toInt() ?? 0,
            nickname: participant['nickname'] as String? ?? '',
            owedAmount: (participant['owed'] as num?)?.toDouble(),
            splitValue: (participant['split_value'] as num?)?.toDouble(),
          ),
        )
        .toList(growable: false);

    return TripExpense(
      id: (item['id'] as num?)?.toInt() ?? 0,
      amount: (item['amount'] as num?)?.toDouble() ?? 0,
      category: _parseExpenseCategory(item['category']),
      note: item['note'] as String? ?? '',
      expenseDate: item['expense_date'] as String? ?? '',
      splitMode: splitMode,
      paidById: (item['paid_by_id'] as num?)?.toInt() ?? 0,
      paidByNickname: item['paid_by_nickname'] as String? ?? '',
      receiptUrl: item['receipt_url'] as String?,
      receiptThumbUrl: item['receipt_thumb_url'] as String?,
      participants: participants,
    );
  }

  static RandomOrder parseOrder(Map<String, dynamic> item) {
    final members = (item['members'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (member) => RandomOrderMember(
            position:
                (member['pos'] as num?)?.toInt() ??
                (member['position'] as num?)?.toInt() ??
                0,
            nickname: member['nickname'] as String? ?? '',
          ),
        )
        .toList(growable: false);

    return RandomOrder(
      id: (item['id'] as num?)?.toInt() ?? 0,
      createdAt: item['created_at'] as String? ?? '',
      createdBy: (item['created_by'] as num?)?.toInt() ?? 0,
      createdByNickname: item['created_by_nickname'] as String? ?? '',
      members: members,
    );
  }

  static WorkspaceNotification parseNotification(Map<String, dynamic> item) {
    final tripName = _toNullableString(item['trip_name']);
    return WorkspaceNotification(
      id: _toInt(item['id']),
      tripId: _toInt(item['trip_id']),
      tripName: tripName,
      type: _toString(item['type'], fallback: 'info').trim(),
      title: _toString(item['title']).trim(),
      body: _toString(item['body']).trim(),
      isRead: _toBool(item['is_read']),
      createdAt: _toNullableString(item['created_at']),
    );
  }

  static List<int> toIntList(Object? raw) {
    if (raw is! List<dynamic>) {
      return const <int>[];
    }
    return raw
        .map((item) => (item as num?)?.toInt() ?? 0)
        .where((id) => id > 0)
        .toList(growable: false);
  }

  static String parseTripStatus(Object? raw) {
    final value = (raw as String? ?? '').trim().toLowerCase();
    if (value == 'settling' || value == 'archived') {
      return value;
    }
    return 'active';
  }

  static String parseSettlementStatus(Object? raw) {
    final value = (raw as String? ?? '').trim().toLowerCase();
    if (value == 'pending' ||
        value == 'sent' ||
        value == 'confirmed' ||
        value == 'suggested') {
      return value;
    }
    return 'suggested';
  }

  static String parseExpenseSplitMode(Object? raw) {
    final value = (raw as String? ?? '').trim().toLowerCase();
    if (value == 'exact' || value == 'percent' || value == 'shares') {
      return value;
    }
    return 'equal';
  }

  static String _parseExpenseCategory(Object? raw) {
    final value = (raw as String? ?? '').trim();
    return value.isEmpty ? 'other' : value;
  }
}
