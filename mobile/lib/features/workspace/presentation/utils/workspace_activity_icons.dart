import 'package:flutter/material.dart';

/// Icon for an activity event type with no entry in [workspaceActivityIcons].
const IconData workspaceActivityFallbackIcon = Icons.history_rounded;

/// One icon per trip activity event type, keyed by the API's `event_type`.
const Map<String, IconData> workspaceActivityIcons = {
  'expense.created': Icons.post_add_rounded,
  'expense.updated': Icons.edit_note_rounded,
  'expense.deleted': Icons.delete_outline_rounded,
  'expense.comment_added': Icons.chat_bubble_outline_rounded,
  'trip.created': Icons.luggage_rounded,
  'trip.updated': Icons.edit_rounded,
  'trip.members_added': Icons.group_add_rounded,
  'trip.members_invited': Icons.forward_to_inbox_rounded,
  'trip.member_joined': Icons.person_add_alt_1_rounded,
  'trip.invitation_declined': Icons.person_off_rounded,
  'trip.invitation_revoked': Icons.cancel_schedule_send_rounded,
  'trip.member_removed': Icons.person_remove_rounded,
  'trip.member_left': Icons.logout_rounded,
  'trip.member_role_updated': Icons.admin_panel_settings_rounded,
  'trip.member_ready': Icons.check_circle_rounded,
  'trip.member_not_ready': Icons.unpublished_rounded,
  'trip.all_members_ready': Icons.done_all_rounded,
  'trip.finished': Icons.flag_rounded,
  'trip.settled': Icons.task_alt_rounded,
  'settlement.marked_sent': Icons.send_rounded,
  'settlement.confirmed': Icons.price_check_rounded,
  'settlement.sent_cancelled': Icons.undo_rounded,
  'settlement.not_received': Icons.report_problem_rounded,
  'settlement.reminder_sent': Icons.notifications_active_rounded,
  'payment.marked_sent': Icons.payments_rounded,
  'payment.requested': Icons.request_quote_rounded,
  'payment.request_marked_sent': Icons.outbox_rounded,
  'payment.request_cancelled': Icons.money_off_rounded,
  'payment.request_declined': Icons.block_rounded,
  'payment.confirmed': Icons.paid_rounded,
  'payment.cancelled': Icons.remove_circle_outline_rounded,
  'payment.not_received': Icons.sms_failed_rounded,
};

/// Returns the icon for [eventType], ignoring case and surrounding whitespace.
IconData workspaceActivityIcon(String eventType) {
  return workspaceActivityIcons[eventType.trim().toLowerCase()] ??
      workspaceActivityFallbackIcon;
}
