-- Phone notifications when a trip member starts sharing their live location.
-- New switch, on for everyone. Safe to run again.

SET @push_location_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'push_location_enabled'
);
SET @push_location_sql := IF(@push_location_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN push_location_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1');
PREPARE stmt FROM @push_location_sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
