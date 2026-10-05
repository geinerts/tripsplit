import 'package:flutter/widgets.dart';

import '../../features/workspace/domain/entities/workspace_notification.dart';
import 'l10n.dart';

class LocalizedWorkspaceNotification {
  const LocalizedWorkspaceNotification({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

final RegExp _friendInviteBodyPattern = RegExp(
  r'^(.+?) sent you a friend invite\.$',
);
final RegExp _friendInviteAcceptedBodyPattern = RegExp(
  r'^(.+?) accepted your friend invite\.$',
);

final RegExp _tripAddedBodyPattern = RegExp(
  r'^(.+?) added you to trip "(.+?)"\.$',
);

final RegExp _expenseAddedWithTripPattern = RegExp(
  r'^(.+?) added an expense of (.+?) in "(.+?)"\.$',
);
final RegExp _expenseAddedWithNotePattern = RegExp(
  r'^(.+?) added an expense of (.+?): (.+)$',
);

final RegExp _tripFinishedSettlingPattern = RegExp(
  r'^(.+?) finished "(.+?)"\. Settlements are ready\.$',
);
final RegExp _tripFinishedArchivedPattern = RegExp(
  r'^(.+?) finished "(.+?)"\. Trip is archived\.$',
);

final RegExp _memberReadyPattern = RegExp(
  r'^(.+?) is ready to settle in "(.+?)"\.$',
);

final RegExp _tripReadyPattern = RegExp(
  r'^All members marked ready in "(.+?)"\. You can start settlements\.$',
);

final RegExp _settlementReminderMarkSentPattern = RegExp(
  r'^(.+?) reminded (.+?) to mark (.+?) as sent\.$',
);
final RegExp _settlementReminderConfirmPattern = RegExp(
  r'^(.+?) reminded (.+?) to confirm receiving (.+?)\.$',
);

final RegExp _settlementAutoPaymentPattern = RegExp(
  r'^Reminder: please mark (.+?) as sent to (.+?) in "(.+?)"\.$',
);
final RegExp _settlementAutoConfirmationPattern = RegExp(
  r'^Reminder: please confirm receiving (.+?) from (.+?) in "(.+?)"\.$',
);

final RegExp _settlementSentPattern = RegExp(
  r'^(.+?) marked (.+?) as sent to you\.$',
);
final RegExp _settlementConfirmedPattern = RegExp(
  r'^(.+?) confirmed receiving (.+?) from you\.$',
);
final RegExp _paymentRequestedPattern = RegExp(
  r'^(.+?) requested (.+?) from you\.$',
);
final RegExp _paymentRequestSentPattern = RegExp(
  r'^(.+?) marked your (.+?) payment request as paid\.$',
);
final RegExp _paymentRequestCancelledPattern = RegExp(
  r'^(.+?) cancelled the (.+?) payment request\.$',
);
final RegExp _paymentRequestDeclinedPattern = RegExp(
  r'^(.+?) declined your (.+?) payment request\.$',
);
final RegExp _paymentSentPattern = RegExp(
  r'^(.+?) marked (.+?) as paid to you\.$',
);
final RegExp _paymentConfirmedPattern = RegExp(
  r'^(.+?) confirmed receiving (.+?) from you\.$',
);
final RegExp _paymentCancelledPattern = RegExp(
  r'^(.+?) cancelled the (.+?) payment mark\.$',
);
final RegExp _paymentNotReceivedPattern = RegExp(
  r'^(.+?) marked the (.+?) payment as not received\.$',
);

LocalizedWorkspaceNotification localizeWorkspaceNotification(
  BuildContext context,
  WorkspaceNotification notification,
) {
  final t = context.l10n;
  final type = notification.type.trim().toLowerCase();
  final rawTitle = notification.title.trim();
  final rawBody = notification.body.trim();
  final tripName = (notification.tripName ?? '').trim();

  switch (type) {
    case 'trip_invitation':
      return LocalizedWorkspaceNotification(
        title: t.shellTripInviteTitle,
        body: t.tripInvitationBody,
      );
    case 'friend_invite':
      {
        final match = _friendInviteBodyPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationFriendInviteTitle,
            body: t.notificationFriendInviteBody(match.group(1)!.trim()),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationFriendInviteTitle,
          body: t.notificationFriendInviteBodyGeneric,
        );
      }
    case 'friend_invite_accepted':
      {
        final match = _friendInviteAcceptedBodyPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationFriendInviteAcceptedTitle,
            body: t.notificationFriendInviteAcceptedBody(
              match.group(1)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationFriendInviteAcceptedTitle,
          body: t.notificationFriendInviteAcceptedBodyGeneric,
        );
      }
    case 'trip_added':
    case 'trip_member_added':
      {
        final match = _tripAddedBodyPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationTripAddedTitle,
            body: t.notificationTripAddedBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        if (tripName.isNotEmpty) {
          return LocalizedWorkspaceNotification(
            title: t.notificationTripAddedTitle,
            body: t.notificationTripAddedBodyNoActor(tripName),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationTripAddedTitle,
          body: t.notificationTripAddedBodyGeneric,
        );
      }
    case 'expense_added':
      {
        final withTrip = _expenseAddedWithTripPattern.firstMatch(rawBody);
        if (withTrip != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationExpenseAddedTitle,
            body: t.notificationExpenseAddedBodyWithTrip(
              withTrip.group(1)!.trim(),
              withTrip.group(2)!.trim(),
              withTrip.group(3)!.trim(),
            ),
          );
        }
        final withNote = _expenseAddedWithNotePattern.firstMatch(rawBody);
        if (withNote != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationExpenseAddedTitle,
            body: t.notificationExpenseAddedBodyWithNote(
              withNote.group(1)!.trim(),
              withNote.group(2)!.trim(),
              withNote.group(3)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationExpenseAddedTitle,
          body: t.notificationExpenseAddedBodyGeneric,
        );
      }
    case 'trip_finished':
      {
        final settling = _tripFinishedSettlingPattern.firstMatch(rawBody);
        if (settling != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationTripFinishedTitle,
            body: t.notificationTripFinishedBodySettlementsReady(
              settling.group(1)!.trim(),
              settling.group(2)!.trim(),
            ),
          );
        }
        final archived = _tripFinishedArchivedPattern.firstMatch(rawBody);
        if (archived != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationTripFinishedTitle,
            body: t.notificationTripFinishedBodyArchived(
              archived.group(1)!.trim(),
              archived.group(2)!.trim(),
            ),
          );
        }
        if (tripName.isNotEmpty) {
          return LocalizedWorkspaceNotification(
            title: t.notificationTripFinishedTitle,
            body: t.notificationTripFinishedBodyNoActor(tripName),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationTripFinishedTitle,
          body: t.notificationTripFinishedBodyGeneric,
        );
      }
    case 'member_ready_to_settle':
      {
        final match = _memberReadyPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationMemberReadyToSettleTitle,
            body: t.notificationMemberReadyToSettleBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        if (tripName.isNotEmpty) {
          return LocalizedWorkspaceNotification(
            title: t.notificationMemberReadyToSettleTitle,
            body: t.notificationMemberReadyToSettleBodyNoActor(tripName),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationMemberReadyToSettleTitle,
          body: t.notificationMemberReadyToSettleBodyGeneric,
        );
      }
    case 'trip_ready_to_settle':
      {
        final match = _tripReadyPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationTripReadyToSettleTitle,
            body: t.notificationTripReadyToSettleBody(match.group(1)!.trim()),
          );
        }
        if (tripName.isNotEmpty) {
          return LocalizedWorkspaceNotification(
            title: t.notificationTripReadyToSettleTitle,
            body: t.notificationTripReadyToSettleBody(tripName),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationTripReadyToSettleTitle,
          body: t.notificationTripReadyToSettleBodyGeneric,
        );
      }
    case 'payment_requested':
      {
        final match = _paymentRequestedPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentRequestedTitle,
            body: t.notificationPaymentRequestedBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentRequestedTitle,
          body: t.notificationPaymentRequestedBodyGeneric,
        );
      }
    case 'payment_request_sent':
      {
        final match = _paymentRequestSentPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentRequestSentTitle,
            body: t.notificationPaymentRequestSentBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentRequestSentTitle,
          body: t.notificationPaymentRequestSentBodyGeneric,
        );
      }
    case 'payment_request_cancelled':
      {
        final match = _paymentRequestCancelledPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentRequestCancelledTitle,
            body: t.notificationPaymentRequestCancelledBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentRequestCancelledTitle,
          body: t.notificationPaymentRequestCancelledBodyGeneric,
        );
      }
    case 'payment_request_declined':
      {
        final match = _paymentRequestDeclinedPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentRequestDeclinedTitle,
            body: t.notificationPaymentRequestDeclinedBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentRequestDeclinedTitle,
          body: t.notificationPaymentRequestDeclinedBodyGeneric,
        );
      }
    case 'payment_sent':
      {
        final match = _paymentSentPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentSentTitle,
            body: t.notificationPaymentSentBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentSentTitle,
          body: t.notificationPaymentSentBodyGeneric,
        );
      }
    case 'payment_confirmed':
      {
        final match = _paymentConfirmedPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentConfirmedTitle,
            body: t.notificationPaymentConfirmedBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentConfirmedTitle,
          body: t.notificationPaymentConfirmedBodyGeneric,
        );
      }
    case 'payment_cancelled':
      {
        final match = _paymentCancelledPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentCancelledTitle,
            body: t.notificationPaymentCancelledBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentCancelledTitle,
          body: t.notificationPaymentCancelledBodyGeneric,
        );
      }
    case 'payment_not_received':
      {
        final match = _paymentNotReceivedPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentNotReceivedTitle,
            body: t.notificationPaymentNotReceivedBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationPaymentNotReceivedTitle,
          body: t.notificationPaymentNotReceivedBodyGeneric,
        );
      }
    case 'settlement_reminder':
      {
        final markSent = _settlementReminderMarkSentPattern.firstMatch(rawBody);
        if (markSent != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationSettlementReminderTitle,
            body: t.notificationSettlementReminderBodyMarkSent(
              markSent.group(1)!.trim(),
              markSent.group(2)!.trim(),
              markSent.group(3)!.trim(),
            ),
          );
        }
        final confirm = _settlementReminderConfirmPattern.firstMatch(rawBody);
        if (confirm != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationSettlementReminderTitle,
            body: t.notificationSettlementReminderBodyConfirm(
              confirm.group(1)!.trim(),
              confirm.group(2)!.trim(),
              confirm.group(3)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationSettlementReminderTitle,
          body: t.notificationSettlementReminderBodyGeneric,
        );
      }
    case 'settlement_auto_reminder':
      {
        final payment = _settlementAutoPaymentPattern.firstMatch(rawBody);
        if (payment != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationPaymentReminderTitle,
            body: t.notificationPaymentReminderBody(
              payment.group(1)!.trim(),
              payment.group(2)!.trim(),
              payment.group(3)!.trim(),
            ),
          );
        }
        final confirmation = _settlementAutoConfirmationPattern.firstMatch(
          rawBody,
        );
        if (confirmation != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationConfirmationReminderTitle,
            body: t.notificationConfirmationReminderBody(
              confirmation.group(1)!.trim(),
              confirmation.group(2)!.trim(),
              confirmation.group(3)!.trim(),
            ),
          );
        }

        final normalizedTitle = rawTitle.toLowerCase();
        final isConfirmation = normalizedTitle.contains('confirmation');
        return LocalizedWorkspaceNotification(
          title: isConfirmation
              ? t.notificationConfirmationReminderTitle
              : t.notificationPaymentReminderTitle,
          body: isConfirmation
              ? t.notificationConfirmationReminderBodyGeneric
              : t.notificationPaymentReminderBodyGeneric,
        );
      }
    case 'settlement_sent':
      {
        final match = _settlementSentPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationSettlementSentTitle,
            body: t.notificationSettlementSentBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationSettlementSentTitle,
          body: t.notificationSettlementSentBodyGeneric,
        );
      }
    case 'settlement_confirmed':
      {
        final match = _settlementConfirmedPattern.firstMatch(rawBody);
        if (match != null) {
          return LocalizedWorkspaceNotification(
            title: t.notificationSettlementConfirmedTitle,
            body: t.notificationSettlementConfirmedBody(
              match.group(1)!.trim(),
              match.group(2)!.trim(),
            ),
          );
        }
        return LocalizedWorkspaceNotification(
          title: t.notificationSettlementConfirmedTitle,
          body: t.notificationSettlementConfirmedBodyGeneric,
        );
      }
    default:
      return LocalizedWorkspaceNotification(
        title: rawTitle.isNotEmpty ? rawTitle : t.notificationFallbackTitle,
        body: rawBody,
      );
  }
}
