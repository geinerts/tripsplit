import '../../domain/entities/balance_item.dart';
import '../../domain/entities/expense_participant.dart';
import '../../domain/entities/random_order.dart';
import '../../domain/entities/random_order_member.dart';
import '../../domain/entities/settlement_item.dart';
import '../../domain/entities/trip_expense.dart';
import '../../domain/entities/workspace_notification.dart';
import '../../domain/entities/workspace_snapshot.dart';
import '../../domain/entities/workspace_user.dart';
import '../../../../core/currency/app_currency.dart';
import '../../../../core/network/media_url_resolver.dart';

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
              'bank_account_holder': user.bankAccountHolder,
              'bank_iban': user.bankIban,
              'bank_bic': user.bankBic,
              'revolut_handle': user.revolutHandle,
              'revolut_me_link': user.revolutMeLink,
              'paypal_me_link': user.paypalMeLink,
              'wise_pay_link': user.wisePayLink,
              'is_ready_to_settle': user.isReadyToSettle,
              'ready_to_settle_at': user.readyToSettleAt,
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
              'created_at': item.createdAt,
              'marked_sent_at': item.markedSentAt,
              'confirmed_at': item.confirmedAt,
              'can_mark_sent': item.canMarkSent,
              'can_confirm_received': item.canConfirmReceived,
              'can_cancel_sent': item.canCancelSent,
              'can_report_not_received': item.canReportNotReceived,
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
              'original_amount': expense.originalAmount,
              'trip_currency_code': expense.tripCurrencyCode,
              'expense_currency_code': expense.expenseCurrencyCode,
              'fx_rate_to_trip': expense.fxRateToTrip,
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
        .map((item) {
          final displayName = (item['display_name'] as String?)?.trim();
          final avatarUrl = MediaUrlResolver.normalize(item['avatar_url']);
          final avatarThumbUrl = MediaUrlResolver.normalize(
            item['avatar_thumb_url'],
          );
          final bankAccountHolder = (item['bank_account_holder'] as String?)
              ?.trim();
          final bankIban = (item['bank_iban'] as String?)?.trim();
          final bankBic = (item['bank_bic'] as String?)?.trim();
          final revolutHandle = (item['revolut_handle'] as String?)?.trim();
          final revolutMeLink = (item['revolut_me_link'] as String?)?.trim();
          final paypalMeLink = (item['paypal_me_link'] as String?)?.trim();
          final wisePayLink = (item['wise_pay_link'] as String?)?.trim();
          final readyToSettleAt = (item['ready_to_settle_at'] as String?)
              ?.trim();
          return WorkspaceUser(
            id: (item['id'] as num?)?.toInt() ?? 0,
            nickname: item['nickname'] as String? ?? '',
            displayName: (displayName == null || displayName.isEmpty)
                ? null
                : displayName,
            avatarUrl: avatarUrl,
            avatarThumbUrl: avatarThumbUrl,
            bankAccountHolder:
                bankAccountHolder == null || bankAccountHolder.isEmpty
                ? null
                : bankAccountHolder,
            bankIban: bankIban == null || bankIban.isEmpty ? null : bankIban,
            bankBic: bankBic == null || bankBic.isEmpty ? null : bankBic,
            revolutHandle: revolutHandle == null || revolutHandle.isEmpty
                ? null
                : revolutHandle,
            revolutMeLink: revolutMeLink == null || revolutMeLink.isEmpty
                ? null
                : revolutMeLink,
            paypalMeLink: paypalMeLink == null || paypalMeLink.isEmpty
                ? null
                : paypalMeLink,
            wisePayLink: wisePayLink == null || wisePayLink.isEmpty
                ? null
                : wisePayLink,
            isReadyToSettle:
                item['is_ready_to_settle'] == true ||
                (item['is_ready_to_settle'] as num?)?.toInt() == 1 ||
                (item['is_ready_to_settle'] as String?)?.trim() == '1' ||
                (item['is_ready_to_settle'] as String?)?.trim().toLowerCase() ==
                    'true',
            readyToSettleAt:
                (readyToSettleAt == null || readyToSettleAt.isEmpty)
                ? null
                : readyToSettleAt,
          );
        })
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
            createdAt: item['created_at'] as String?,
            markedSentAt: item['marked_sent_at'] as String?,
            confirmedAt: item['confirmed_at'] as String?,
            canMarkSent: item['can_mark_sent'] == true,
            canConfirmReceived: item['can_confirm_received'] == true,
            canCancelSent: item['can_cancel_sent'] == true,
            canReportNotReceived: item['can_report_not_received'] == true,
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

          final amount = (item['amount'] as num?)?.toDouble() ?? 0;
          final tripCurrencyCode = AppCurrencyCatalog.normalize(
            item['trip_currency_code'] as String?,
          );
          final expenseCurrencyCode = AppCurrencyCatalog.normalize(
            item['expense_currency_code'] as String?,
            fallback: tripCurrencyCode,
          );
          final originalAmount =
              (item['original_amount'] as num?)?.toDouble() ?? amount;
          final rawFxRateToTrip =
              (item['fx_rate_to_trip'] as num?)?.toDouble() ?? 1.0;
          final fxRateToTrip = rawFxRateToTrip > 0 ? rawFxRateToTrip : 1.0;

          return TripExpense(
            id: (item['id'] as num?)?.toInt() ?? 0,
            amount: amount,
            originalAmount: originalAmount,
            tripCurrencyCode: tripCurrencyCode,
            expenseCurrencyCode: expenseCurrencyCode,
            fxRateToTrip: fxRateToTrip,
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
            receiptUrl: MediaUrlResolver.normalize(item['receipt_url']),
            receiptThumbUrl: MediaUrlResolver.normalize(
              item['receipt_thumb_url'],
            ),
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
