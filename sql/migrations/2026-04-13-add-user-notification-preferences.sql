CREATE TABLE IF NOT EXISTS trip_user_notification_preferences (
  user_id INT UNSIGNED NOT NULL,
  in_app_banner_enabled TINYINT(1) NOT NULL DEFAULT 1,
  push_expense_added_enabled TINYINT(1) NOT NULL DEFAULT 1,
  push_friend_invites_enabled TINYINT(1) NOT NULL DEFAULT 1,
  push_trip_updates_enabled TINYINT(1) NOT NULL DEFAULT 1,
  push_settlement_updates_enabled TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_trip_user_notification_preferences_user_id
    FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
