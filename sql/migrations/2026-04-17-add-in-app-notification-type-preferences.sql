ALTER TABLE trip_user_notification_preferences
  ADD COLUMN in_app_friend_invite_received_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_friend_invites_enabled,
  ADD COLUMN in_app_friend_invite_accepted_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_friend_invite_received_enabled,
  ADD COLUMN in_app_trip_added_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_trip_updates_enabled,
  ADD COLUMN in_app_trip_member_added_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_trip_added_enabled,
  ADD COLUMN in_app_trip_finished_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_trip_member_added_enabled,
  ADD COLUMN in_app_member_ready_to_settle_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_trip_finished_enabled,
  ADD COLUMN in_app_trip_ready_to_settle_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_member_ready_to_settle_enabled,
  ADD COLUMN in_app_settlement_reminder_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_settlement_updates_enabled,
  ADD COLUMN in_app_settlement_auto_reminder_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_settlement_reminder_enabled,
  ADD COLUMN in_app_settlement_sent_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_settlement_auto_reminder_enabled,
  ADD COLUMN in_app_settlement_confirmed_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_settlement_sent_enabled;
