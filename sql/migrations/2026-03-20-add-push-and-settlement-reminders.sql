CREATE TABLE IF NOT EXISTS trip_user_push_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  provider ENUM('apns', 'fcm') NOT NULL,
  platform ENUM('ios', 'android', 'web') NOT NULL,
  push_token VARCHAR(512) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  device_uid VARCHAR(128) CHARACTER SET ascii COLLATE ascii_general_ci NULL,
  app_bundle VARCHAR(191) CHARACTER SET ascii COLLATE ascii_general_ci NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  last_seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_user_push_tokens_token (push_token),
  KEY idx_trip_user_push_tokens_user_active (user_id, is_active, last_seen_at, id),
  KEY idx_trip_user_push_tokens_device (device_uid, user_id),
  CONSTRAINT fk_trip_user_push_tokens_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_push_queue (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  notification_id BIGINT UNSIGNED NULL,
  user_id INT UNSIGNED NOT NULL,
  trip_id INT UNSIGNED NULL,
  type VARCHAR(48) NOT NULL,
  title VARCHAR(120) NOT NULL,
  body VARCHAR(255) NOT NULL,
  payload_json JSON NULL,
  status ENUM('pending', 'processing', 'sent', 'failed') NOT NULL DEFAULT 'pending',
  attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
  last_error VARCHAR(1000) NULL,
  next_attempt_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  sent_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_push_queue_status_next (status, next_attempt_at, id),
  KEY idx_trip_push_queue_user_status (user_id, status, id),
  KEY idx_trip_push_queue_created (created_at, id),
  CONSTRAINT fk_trip_push_queue_notification_id FOREIGN KEY (notification_id) REFERENCES trip_notifications(id) ON DELETE SET NULL,
  CONSTRAINT fk_trip_push_queue_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_push_queue_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_settlement_reminder_state (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  settlement_id BIGINT UNSIGNED NOT NULL,
  trip_id INT UNSIGNED NOT NULL,
  settlement_status ENUM('pending', 'sent') NOT NULL,
  last_reminded_at DATETIME NOT NULL,
  reminder_count INT UNSIGNED NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_settlement_reminder_state (settlement_id, settlement_status),
  KEY idx_trip_settlement_reminder_trip (trip_id, last_reminded_at),
  CONSTRAINT fk_trip_settlement_reminder_settlement_id FOREIGN KEY (settlement_id) REFERENCES trip_settlements(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_settlement_reminder_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
