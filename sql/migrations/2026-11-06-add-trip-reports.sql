CREATE TABLE IF NOT EXISTS trip_report_deliveries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  status ENUM('pending', 'sent', 'skipped', 'failed') NOT NULL DEFAULT 'pending',
  attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
  next_attempt_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL,
  finished_at DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_report_delivery (trip_id, user_id),
  KEY idx_trip_report_due (status, next_attempt_at),
  KEY idx_trip_report_user (user_id),
  KEY idx_trip_report_finished (finished_at),
  CONSTRAINT fk_trip_report_trip FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_report_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_fx_rate_cache (
  rate_date DATE NOT NULL,
  from_currency CHAR(3) NOT NULL,
  to_currency CHAR(3) NOT NULL,
  rate DECIMAL(24,10) NOT NULL,
  PRIMARY KEY (rate_date, from_currency, to_currency)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @trip_users_locale_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_users' AND column_name = 'locale'
);
SET @trip_users_locale_sql := IF(
  @trip_users_locale_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN locale VARCHAR(8) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL',
  'SELECT 1'
);
PREPARE stmt_trip_users_locale FROM @trip_users_locale_sql;
EXECUTE stmt_trip_users_locale;
DEALLOCATE PREPARE stmt_trip_users_locale;

SET @trip_report_pref_exists := (
  SELECT COUNT(1) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_user_notification_preferences'
    AND column_name = 'email_trip_report_enabled'
);
SET @trip_report_pref_sql := IF(
  @trip_report_pref_exists = 0,
  'ALTER TABLE trip_user_notification_preferences ADD COLUMN email_trip_report_enabled TINYINT(1) NOT NULL DEFAULT 1',
  'SELECT 1'
);
PREPARE stmt_trip_report_pref FROM @trip_report_pref_sql;
EXECUTE stmt_trip_report_pref;
DEALLOCATE PREPARE stmt_trip_report_pref;
