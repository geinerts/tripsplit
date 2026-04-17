ALTER TABLE trip_user_notification_preferences
  ADD COLUMN in_app_expense_added_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_banner_enabled,
  ADD COLUMN in_app_friend_invites_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_expense_added_enabled,
  ADD COLUMN in_app_trip_updates_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_friend_invites_enabled,
  ADD COLUMN in_app_settlement_updates_enabled TINYINT(1) NOT NULL DEFAULT 1 AFTER in_app_trip_updates_enabled;
