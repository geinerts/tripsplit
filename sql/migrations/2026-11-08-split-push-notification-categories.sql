-- Split the trip and settlement push switches into finer categories.
-- Each new column starts from the user's current value of the switch it came from.
-- Safe to run again: existing columns are left alone and are not copied over twice.

SET @push_comments_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'push_comments_enabled'
);
SET @push_comments_sql := IF(@push_comments_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN push_comments_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1');
PREPARE stmt FROM @push_comments_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @push_comments_copy := IF(@push_comments_exists = 0,
  'UPDATE trip_user_notification_preferences SET push_comments_enabled = push_trip_updates_enabled',
  'SELECT 1');
PREPARE stmt FROM @push_comments_copy; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @push_trip_invites_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'push_trip_invites_enabled'
);
SET @push_trip_invites_sql := IF(@push_trip_invites_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN push_trip_invites_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1');
PREPARE stmt FROM @push_trip_invites_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @push_trip_invites_copy := IF(@push_trip_invites_exists = 0,
  'UPDATE trip_user_notification_preferences SET push_trip_invites_enabled = push_trip_updates_enabled',
  'SELECT 1');
PREPARE stmt FROM @push_trip_invites_copy; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @push_trip_status_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'push_trip_status_enabled'
);
SET @push_trip_status_sql := IF(@push_trip_status_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN push_trip_status_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1');
PREPARE stmt FROM @push_trip_status_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @push_trip_status_copy := IF(@push_trip_status_exists = 0,
  'UPDATE trip_user_notification_preferences SET push_trip_status_enabled = push_trip_updates_enabled',
  'SELECT 1');
PREPARE stmt FROM @push_trip_status_copy; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @push_payment_requests_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'push_payment_requests_enabled'
);
SET @push_payment_requests_sql := IF(@push_payment_requests_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN push_payment_requests_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1');
PREPARE stmt FROM @push_payment_requests_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @push_payment_requests_copy := IF(@push_payment_requests_exists = 0,
  'UPDATE trip_user_notification_preferences SET push_payment_requests_enabled = push_settlement_updates_enabled',
  'SELECT 1');
PREPARE stmt FROM @push_payment_requests_copy; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @push_payments_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'push_payments_enabled'
);
SET @push_payments_sql := IF(@push_payments_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN push_payments_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1');
PREPARE stmt FROM @push_payments_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @push_payments_copy := IF(@push_payments_exists = 0,
  'UPDATE trip_user_notification_preferences SET push_payments_enabled = push_settlement_updates_enabled',
  'SELECT 1');
PREPARE stmt FROM @push_payments_copy; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @push_reminders_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'push_reminders_enabled'
);
SET @push_reminders_sql := IF(@push_reminders_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN push_reminders_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1');
PREPARE stmt FROM @push_reminders_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
SET @push_reminders_copy := IF(@push_reminders_exists = 0,
  'UPDATE trip_user_notification_preferences SET push_reminders_enabled = push_settlement_updates_enabled',
  'SELECT 1');
PREPARE stmt FROM @push_reminders_copy; EXECUTE stmt; DEALLOCATE PREPARE stmt;
