#!/usr/bin/env python3
"""Export server push phrases from the app catalogs. Run after updating ARB files."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
KEYS = {'friend_invite_title': 'notificationFriendInviteTitle',
 'friend_invite_body': 'notificationFriendInviteBody',
 'friend_invite_body_generic': 'notificationFriendInviteBodyGeneric',
 'friend_invite_accepted_title': 'notificationFriendInviteAcceptedTitle',
 'friend_invite_accepted_body': 'notificationFriendInviteAcceptedBody',
 'friend_invite_accepted_body_generic': 'notificationFriendInviteAcceptedBodyGeneric',
 'trip_added_title': 'notificationTripAddedTitle',
 'trip_added_body': 'notificationTripAddedBody',
 'trip_added_body_generic': 'notificationTripAddedBodyGeneric',
 'expense_added_title': 'notificationExpenseAddedTitle',
 'expense_added_body_trip': 'notificationExpenseAddedBodyWithTrip',
 'expense_added_body_note': 'notificationExpenseAddedBodyWithNote',
 'expense_added_body_generic': 'notificationExpenseAddedBodyGeneric',
 'comment_mention_title': 'notificationCommentMentionTitle',
 'comment_mention_body': 'notificationCommentMentionBody',
 'comment_mention_body_generic': 'notificationCommentMentionBodyGeneric',
 'trip_finished_title': 'notificationTripFinishedTitle',
 'trip_finished_body_settling': 'notificationTripFinishedBodySettlementsReady',
 'trip_finished_body_archived': 'notificationTripFinishedBodyArchived',
 'trip_finished_body_generic': 'notificationTripFinishedBodyGeneric',
 'member_ready_title': 'notificationMemberReadyToSettleTitle',
 'member_ready_body': 'notificationMemberReadyToSettleBody',
 'member_ready_body_generic': 'notificationMemberReadyToSettleBodyGeneric',
 'trip_ready_title': 'notificationTripReadyToSettleTitle',
 'trip_ready_body': 'notificationTripReadyToSettleBody',
 'trip_ready_body_generic': 'notificationTripReadyToSettleBodyGeneric',
 'payment_requested_title': 'notificationPaymentRequestedTitle',
 'payment_requested_body': 'notificationPaymentRequestedBody',
 'payment_requested_body_generic': 'notificationPaymentRequestedBodyGeneric',
 'payment_request_sent_title': 'notificationPaymentRequestSentTitle',
 'payment_request_sent_body': 'notificationPaymentRequestSentBody',
 'payment_request_sent_body_generic': 'notificationPaymentRequestSentBodyGeneric',
 'payment_request_cancelled_title': 'notificationPaymentRequestCancelledTitle',
 'payment_request_cancelled_body': 'notificationPaymentRequestCancelledBody',
 'payment_request_cancelled_body_generic': 'notificationPaymentRequestCancelledBodyGeneric',
 'payment_request_declined_title': 'notificationPaymentRequestDeclinedTitle',
 'payment_request_declined_body': 'notificationPaymentRequestDeclinedBody',
 'payment_request_declined_body_generic': 'notificationPaymentRequestDeclinedBodyGeneric',
 'payment_sent_title': 'notificationPaymentSentTitle',
 'payment_sent_body': 'notificationPaymentSentBody',
 'payment_sent_body_generic': 'notificationPaymentSentBodyGeneric',
 'payment_confirmed_title': 'notificationPaymentConfirmedTitle',
 'payment_confirmed_body': 'notificationPaymentConfirmedBody',
 'payment_confirmed_body_generic': 'notificationPaymentConfirmedBodyGeneric',
 'payment_cancelled_title': 'notificationPaymentCancelledTitle',
 'payment_cancelled_body': 'notificationPaymentCancelledBody',
 'payment_cancelled_body_generic': 'notificationPaymentCancelledBodyGeneric',
 'payment_not_received_title': 'notificationPaymentNotReceivedTitle',
 'payment_not_received_body': 'notificationPaymentNotReceivedBody',
 'payment_not_received_body_generic': 'notificationPaymentNotReceivedBodyGeneric',
 'settlement_reminder_title': 'notificationSettlementReminderTitle',
 'settlement_reminder_mark_sent_body': 'notificationSettlementReminderBodyMarkSent',
 'settlement_reminder_confirm_body': 'notificationSettlementReminderBodyConfirm',
 'settlement_reminder_body_generic': 'notificationSettlementReminderBodyGeneric',
 'payment_reminder_title': 'notificationPaymentReminderTitle',
 'payment_reminder_body': 'notificationPaymentReminderBody',
 'payment_reminder_body_generic': 'notificationPaymentReminderBodyGeneric',
 'confirmation_reminder_title': 'notificationConfirmationReminderTitle',
 'confirmation_reminder_body': 'notificationConfirmationReminderBody',
 'confirmation_reminder_body_generic': 'notificationConfirmationReminderBodyGeneric',
 'settlement_sent_title': 'notificationSettlementSentTitle',
 'settlement_sent_body': 'notificationSettlementSentBody',
 'settlement_sent_body_generic': 'notificationSettlementSentBodyGeneric',
 'settlement_confirmed_title': 'notificationSettlementConfirmedTitle',
 'settlement_confirmed_body': 'notificationSettlementConfirmedBody',
 'settlement_confirmed_body_generic': 'notificationSettlementConfirmedBodyGeneric',
 'trip_invitation_title': 'homeTripInvitations',
 'trip_invitation_body': 'tripInvitationBody'}


def export():
    destination = ROOT / 'api/lib/helpers/push/locales'
    destination.mkdir(exist_ok=True)
    for path in sorted((ROOT / 'mobile/lib/l10n').glob('app_*.arb')):
        catalog = json.loads(path.read_text())
        phrases = {
            key: catalog[arb_key].replace('{arg1}', '{name}').replace('{arg2}', '{amount}')
            for key, arb_key in KEYS.items()
        }
        (destination / (catalog['@@locale'] + '.json')).write_text(
            json.dumps(phrases, ensure_ascii=False, indent=2) + '\n'
        )


if __name__ == '__main__':
    export()
