import '../../domain/entities/balance_item.dart';
import '../../domain/entities/expense_participant.dart';
import '../../domain/entities/random_order.dart';
import '../../domain/entities/random_order_member.dart';
import '../../domain/entities/settlement_item.dart';
import '../../domain/entities/trip_expense.dart';
import '../../domain/entities/workspace_activity_event.dart';
import '../../domain/entities/workspace_notification.dart';
import '../../domain/entities/workspace_shared_trip.dart';
import '../../domain/entities/workspace_user.dart';
import '../../../../core/network/media_url_resolver.dart';
import '../../../../core/currency/app_currency.dart';

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
    final avatarUrl = MediaUrlResolver.normalize(
      (item['avatar_url'] as String? ?? '').trim(),
    );
    final avatarThumbUrl = MediaUrlResolver.normalize(
      (item['avatar_thumb_url'] as String? ?? '').trim(),
    );
    final isReadyToSettle = _toBool(
      item['is_ready_to_settle'] ?? item['is_ready'],
    );
    final readyToSettleAt = _toNullableString(
      item['ready_to_settle_at'] ?? item['ready_at'],
    );
    final bankAccountHolder = _toNullableString(item['bank_account_holder']);
    final bankIban = _toNullableString(item['bank_iban']);
    final bankBic = _toNullableString(item['bank_bic']);
    final revolutHandle = _toNullableString(item['revolut_handle']);
    final revolutMeLink = _toNullableString(item['revolut_me_link']);
    final paypalMeLink = _toNullableString(item['paypal_me_link']);
    final wisePayLink = _toNullableString(item['wise_pay_link']);
    return WorkspaceUser(
      id: (item['id'] as num?)?.toInt() ?? 0,
      nickname: item['nickname'] as String? ?? '',
      displayName: displayName.isEmpty ? null : displayName,
      avatarUrl: avatarUrl,
      avatarThumbUrl: avatarThumbUrl,
      bankAccountHolder: bankAccountHolder,
      bankIban: bankIban,
      bankBic: bankBic,
      revolutHandle: revolutHandle,
      revolutMeLink: revolutMeLink,
      paypalMeLink: paypalMeLink,
      wisePayLink: wisePayLink,
      isReadyToSettle: isReadyToSettle,
      readyToSettleAt: readyToSettleAt,
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
      createdAt: _toNullableString(item['created_at']),
      markedSentAt: _toNullableString(item['marked_sent_at']),
      confirmedAt: _toNullableString(item['confirmed_at']),
      canMarkSent: item['can_mark_sent'] == true,
      canConfirmReceived: item['can_confirm_received'] == true,
      canCancelSent: item['can_cancel_sent'] == true,
      canReportNotReceived: item['can_report_not_received'] == true,
      isConfirmed: item['is_confirmed'] == true || status == 'confirmed',
    );
  }

  static TripExpense parseExpense(Map<String, dynamic> item) {
    final splitMode = parseExpenseSplitMode(item['split_mode']);
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
    final fxRateToTrip = (item['fx_rate_to_trip'] as num?)?.toDouble() ?? 1;
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
      amount: amount,
      originalAmount: originalAmount,
      tripCurrencyCode: tripCurrencyCode,
      expenseCurrencyCode: expenseCurrencyCode,
      fxRateToTrip: fxRateToTrip > 0 ? fxRateToTrip : 1,
      category: _parseExpenseCategory(item['category']),
      note: item['note'] as String? ?? '',
      expenseDate: item['expense_date'] as String? ?? '',
      splitMode: splitMode,
      paidById: (item['paid_by_id'] as num?)?.toInt() ?? 0,
      paidByNickname: item['paid_by_nickname'] as String? ?? '',
      receiptUrl: MediaUrlResolver.normalize(item['receipt_url'] as String?),
      receiptThumbUrl: MediaUrlResolver.normalize(
        item['receipt_thumb_url'] as String?,
      ),
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

  static WorkspaceActivityEvent parseActivityEvent(Map<String, dynamic> item) {
    final rawPayload = item['payload'];
    final payload = rawPayload is Map<String, dynamic>
        ? Map<String, dynamic>.unmodifiable(rawPayload)
        : const <String, dynamic>{};
    return WorkspaceActivityEvent(
      id: _toInt(item['id']),
      tripId: _toInt(item['trip_id']),
      actorUserId: item['actor_user_id'] == null
          ? null
          : _toInt(item['actor_user_id']),
      actorName: _toString(item['actor_name'], fallback: 'Trip member').trim(),
      actorAvatarUrl: MediaUrlResolver.normalize(
        item['actor_avatar_url'] as String?,
      ),
      actorAvatarThumbUrl: MediaUrlResolver.normalize(
        item['actor_avatar_thumb_url'] as String?,
      ),
      eventType: _toString(item['event_type']).trim(),
      entityType: _toNullableString(item['entity_type']),
      entityId: item['entity_id'] == null ? null : _toInt(item['entity_id']),
      payload: payload,
      createdAt: _toNullableString(item['created_at']),
    );
  }

  static WorkspaceSharedTrip parseSharedTrip(Map<String, dynamic> item) {
    final name = _toString(item['name']).trim();
    return WorkspaceSharedTrip(
      id: _toInt(item['id']),
      name: name.isEmpty ? 'Trip' : name,
      status: parseTripStatus(item['status']),
      imageUrl: MediaUrlResolver.normalize(item['image_url'] as String?),
      imageThumbUrl: MediaUrlResolver.normalize(
        item['image_thumb_url'] as String?,
      ),
      membersCount: _toInt(item['members_count']),
      createdAt: _toNullableString(item['created_at']),
      endedAt: _toNullableString(item['ended_at']),
      archivedAt: _toNullableString(item['archived_at']),
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
