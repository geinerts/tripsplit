import '../../domain/entities/balance_item.dart';
import '../../domain/entities/expense_participant.dart';
import '../../domain/entities/random_order.dart';
import '../../domain/entities/random_order_member.dart';
import '../../domain/entities/settlement_item.dart';
import '../../domain/entities/trip_expense.dart';
import '../../domain/entities/workspace_notification.dart';
import '../../domain/entities/workspace_user.dart';

class WorkspaceRemoteParsers {
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
    final tripName = (item['trip_name'] as String?)?.trim();
    return WorkspaceNotification(
      id: (item['id'] as num?)?.toInt() ?? 0,
      tripId: (item['trip_id'] as num?)?.toInt() ?? 0,
      tripName: tripName != null && tripName.isNotEmpty ? tripName : null,
      type: (item['type'] as String? ?? 'info').trim(),
      title: (item['title'] as String? ?? '').trim(),
      body: (item['body'] as String? ?? '').trim(),
      isRead:
          item['is_read'] == true || (item['is_read'] as num?)?.toInt() == 1,
      createdAt: item['created_at'] as String?,
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
