import '../../domain/entities/balance_item.dart';
import '../../domain/entities/expense_participant.dart';
import '../../domain/entities/random_order.dart';
import '../../domain/entities/random_order_member.dart';
import '../../domain/entities/settlement_item.dart';
import '../../domain/entities/trip_expense.dart';
import '../../domain/entities/workspace_notification.dart';
import '../../domain/entities/workspace_snapshot.dart';
import '../../domain/entities/workspace_user.dart';

class WorkspaceSnapshotCodec {
  static Map<String, dynamic> toMap(WorkspaceSnapshot snapshot) {
    return <String, dynamic>{
      'trip_status': snapshot.tripStatus,
      'trip_ended_at': snapshot.tripEndedAt,
      'trip_archived_at': snapshot.tripArchivedAt,
      'users': snapshot.users
          .map(
            (user) => <String, dynamic>{
              'id': user.id,
              'nickname': user.nickname,
              'display_name': user.displayName,
              'avatar_url': user.avatarUrl,
              'avatar_thumb_url': user.avatarThumbUrl,
            },
          )
          .toList(growable: false),
      'balances': snapshot.balances
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'nickname': item.nickname,
              'paid': item.paid,
              'owed': item.owed,
              'net': item.net,
            },
          )
          .toList(growable: false),
      'settlements': snapshot.settlements
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'from_user_id': item.fromUserId,
              'to_user_id': item.toUserId,
              'from': item.from,
              'to': item.to,
              'amount': item.amount,
              'status': item.status,
              'can_mark_sent': item.canMarkSent,
              'can_confirm_received': item.canConfirmReceived,
              'is_confirmed': item.isConfirmed,
            },
          )
          .toList(growable: false),
      'settlement_total': snapshot.settlementTotal,
      'settlement_confirmed': snapshot.settlementConfirmed,
      'settlement_remaining': snapshot.settlementRemaining,
      'all_settled': snapshot.allSettled,
      'unread_notifications': snapshot.unreadNotifications,
      'notifications': snapshot.notifications
          .map(
            (item) => <String, dynamic>{
              'id': item.id,
              'trip_id': item.tripId,
              'type': item.type,
              'title': item.title,
              'body': item.body,
              'is_read': item.isRead,
              'created_at': item.createdAt,
            },
          )
          .toList(growable: false),
      'expenses': snapshot.expenses
          .map(
            (expense) => <String, dynamic>{
              'id': expense.id,
              'amount': expense.amount,
              'category': expense.category,
              'note': expense.note,
              'expense_date': expense.expenseDate,
              'split_mode': expense.splitMode,
              'paid_by_id': expense.paidById,
              'paid_by_nickname': expense.paidByNickname,
              'receipt_url': expense.receiptUrl,
              'receipt_thumb_url': expense.receiptThumbUrl,
              'participants': expense.participants
                  .map(
                    (participant) => <String, dynamic>{
                      'id': participant.id,
                      'nickname': participant.nickname,
                      'owed': participant.owedAmount,
                      'split_value': participant.splitValue,
                    },
                  )
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
      'orders': snapshot.orders
          .map(
            (order) => <String, dynamic>{
              'id': order.id,
              'created_at': order.createdAt,
              'created_by': order.createdBy,
              'created_by_nickname': order.createdByNickname,
              'members': order.members
                  .map(
                    (member) => <String, dynamic>{
                      'position': member.position,
                      'nickname': member.nickname,
                    },
                  )
                  .toList(growable: false),
            },
          )
          .toList(growable: false),
    };
  }

  static WorkspaceSnapshot fromMap(Map<String, dynamic> map) {
    final rawTripStatus = (map['trip_status'] as String? ?? '')
        .trim()
        .toLowerCase();
    final tripStatus =
        (rawTripStatus == 'settling' || rawTripStatus == 'archived')
        ? rawTripStatus
        : 'active';

    final users = (map['users'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => WorkspaceUser(
            id: (item['id'] as num?)?.toInt() ?? 0,
            nickname: item['nickname'] as String? ?? '',
            displayName: ((item['display_name'] as String?) ?? '').trim().isEmpty
                ? null
                : (item['display_name'] as String?)?.trim(),
            avatarUrl: ((item['avatar_url'] as String?) ?? '').trim().isEmpty
                ? null
                : (item['avatar_url'] as String?)?.trim(),
            avatarThumbUrl:
                ((item['avatar_thumb_url'] as String?) ?? '').trim().isEmpty
                ? null
                : (item['avatar_thumb_url'] as String?)?.trim(),
          ),
        )
        .toList(growable: false);

    final balances = (map['balances'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => BalanceItem(
            id: (item['id'] as num?)?.toInt() ?? 0,
            nickname: item['nickname'] as String? ?? '',
            paid: (item['paid'] as num?)?.toDouble() ?? 0,
            owed: (item['owed'] as num?)?.toDouble() ?? 0,
            net: (item['net'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList(growable: false);

    final settlements = (map['settlements'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => SettlementItem(
            id: (item['id'] as num?)?.toInt(),
            fromUserId: (item['from_user_id'] as num?)?.toInt() ?? 0,
            toUserId: (item['to_user_id'] as num?)?.toInt() ?? 0,
            from: item['from'] as String? ?? '',
            to: item['to'] as String? ?? '',
            amount: (item['amount'] as num?)?.toDouble() ?? 0,
            status: (item['status'] as String? ?? 'suggested')
                .trim()
                .toLowerCase(),
            canMarkSent: item['can_mark_sent'] == true,
            canConfirmReceived: item['can_confirm_received'] == true,
            isConfirmed:
                item['is_confirmed'] == true ||
                (item['status'] as String? ?? '').trim().toLowerCase() ==
                    'confirmed',
          ),
        )
        .toList(growable: false);

    final expenses = (map['expenses'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final participants =
              (item['participants'] as List<dynamic>? ?? <dynamic>[])
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (part) => ExpenseParticipant(
                      id: (part['id'] as num?)?.toInt() ?? 0,
                      nickname: part['nickname'] as String? ?? '',
                      owedAmount: (part['owed'] as num?)?.toDouble(),
                      splitValue: (part['split_value'] as num?)?.toDouble(),
                    ),
                  )
                  .toList(growable: false);

          return TripExpense(
            id: (item['id'] as num?)?.toInt() ?? 0,
            amount: (item['amount'] as num?)?.toDouble() ?? 0,
            category: (item['category'] as String? ?? '').trim().isEmpty
                ? 'other'
                : (item['category'] as String? ?? '').trim(),
            note: item['note'] as String? ?? '',
            expenseDate: item['expense_date'] as String? ?? '',
            splitMode: WorkspaceSnapshotCodec._parseSplitMode(
              item['split_mode'],
            ),
            paidById: (item['paid_by_id'] as num?)?.toInt() ?? 0,
            paidByNickname: item['paid_by_nickname'] as String? ?? '',
            receiptUrl: item['receipt_url'] as String?,
            receiptThumbUrl: item['receipt_thumb_url'] as String?,
            participants: participants,
          );
        })
        .toList(growable: false);

    final notifications =
        (map['notifications'] as List<dynamic>? ?? <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(
              (item) => WorkspaceNotification(
                id: (item['id'] as num?)?.toInt() ?? 0,
                tripId: (item['trip_id'] as num?)?.toInt() ?? 0,
                type: (item['type'] as String? ?? 'info').trim(),
                title: (item['title'] as String? ?? '').trim(),
                body: (item['body'] as String? ?? '').trim(),
                isRead:
                    item['is_read'] == true ||
                    (item['is_read'] as num?)?.toInt() == 1,
                createdAt: item['created_at'] as String?,
              ),
            )
            .toList(growable: false);

    final orders = (map['orders'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final members = (item['members'] as List<dynamic>? ?? <dynamic>[])
              .whereType<Map<String, dynamic>>()
              .map(
                (member) => RandomOrderMember(
                  position: (member['position'] as num?)?.toInt() ?? 0,
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
        })
        .toList(growable: false);

    return WorkspaceSnapshot(
      tripStatus: tripStatus,
      tripEndedAt: map['trip_ended_at'] as String?,
      tripArchivedAt: map['trip_archived_at'] as String?,
      users: users,
      balances: balances,
      settlements: settlements,
      settlementTotal: (map['settlement_total'] as num?)?.toInt() ?? 0,
      settlementConfirmed: (map['settlement_confirmed'] as num?)?.toInt() ?? 0,
      settlementRemaining: (map['settlement_remaining'] as num?)?.toInt() ?? 0,
      allSettled: map['all_settled'] == true,
      unreadNotifications:
          (map['unread_notifications'] as num?)?.toInt() ??
          notifications.where((item) => !item.isRead).length,
      notifications: notifications,
      expenses: expenses,
      orders: orders,
    );
  }

  static String _parseSplitMode(Object? raw) {
    final value = (raw as String? ?? '').trim().toLowerCase();
    if (value == 'exact' || value == 'percent' || value == 'shares') {
      return value;
    }
    return 'equal';
  }
}
