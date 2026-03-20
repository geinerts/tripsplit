CREATE TABLE IF NOT EXISTS trip_users (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(64) NULL,
  last_name VARCHAR(64) NULL,
  nickname VARCHAR(32) NOT NULL,
  email VARCHAR(255) NULL,
  password_hash VARCHAR(255) NULL,
  credentials_required TINYINT(1) NOT NULL DEFAULT 1,
  email_verified_at TIMESTAMP NULL DEFAULT NULL,
  device_token CHAR(64) NOT NULL,
  avatar_path VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_users_device_token (device_token),
  UNIQUE KEY uq_trip_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_trips (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  status ENUM('active', 'settling', 'archived') NOT NULL DEFAULT 'active',
  created_by INT UNSIGNED NULL,
  image_path VARCHAR(255) NULL,
  ended_at TIMESTAMP NULL DEFAULT NULL,
  archived_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_trips_status (status, created_at, id),
  KEY idx_trip_trips_created_at (created_at, id),
  KEY idx_trip_trips_created_by (created_by),
  CONSTRAINT fk_trip_trips_created_by FOREIGN KEY (created_by) REFERENCES trip_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_friends (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_a_id INT UNSIGNED NOT NULL,
  user_b_id INT UNSIGNED NOT NULL,
  requested_by INT UNSIGNED NOT NULL,
  status ENUM('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  responded_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_friends_pair (user_a_id, user_b_id),
  KEY idx_trip_friends_a_status (user_a_id, status, updated_at),
  KEY idx_trip_friends_b_status (user_b_id, status, updated_at),
  KEY idx_trip_friends_requested_by (requested_by, status, updated_at),
  CONSTRAINT fk_trip_friends_user_a FOREIGN KEY (user_a_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_friends_user_b FOREIGN KEY (user_b_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_friends_requested_by FOREIGN KEY (requested_by) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_trip_members (
  trip_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ready_to_settle TINYINT(1) NOT NULL DEFAULT 0,
  ready_to_settle_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (trip_id, user_id),
  KEY idx_trip_trip_members_user (user_id),
  CONSTRAINT fk_trip_trip_members_trip FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_trip_members_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_expenses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  category VARCHAR(64) NOT NULL DEFAULT 'other',
  note VARCHAR(255) NOT NULL DEFAULT '',
  split_mode ENUM('equal', 'exact', 'percent', 'shares') NOT NULL DEFAULT 'equal',
  paid_by INT UNSIGNED NOT NULL,
  expense_date DATE NOT NULL,
  receipt_path VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_expenses_trip_id (trip_id),
  KEY idx_trip_expenses_date (expense_date, id),
  KEY idx_trip_expenses_paid_by (paid_by),
  CONSTRAINT fk_trip_expenses_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_expenses_paid_by FOREIGN KEY (paid_by) REFERENCES trip_users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_expense_participants (
  expense_id BIGINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  owed_cents INT UNSIGNED NOT NULL DEFAULT 0,
  split_value INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (expense_id, user_id),
  KEY idx_trip_expense_participants_user (user_id),
  CONSTRAINT fk_trip_expense_participants_expense FOREIGN KEY (expense_id) REFERENCES trip_expenses(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_expense_participants_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_settlements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  from_user_id INT UNSIGNED NOT NULL,
  to_user_id INT UNSIGNED NOT NULL,
  amount_cents INT UNSIGNED NOT NULL,
  status ENUM('pending', 'sent', 'confirmed') NOT NULL DEFAULT 'pending',
  marked_sent_by INT UNSIGNED NULL,
  marked_sent_at TIMESTAMP NULL DEFAULT NULL,
  confirmed_by INT UNSIGNED NULL,
  confirmed_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_settlements_trip_pair (trip_id, from_user_id, to_user_id),
  KEY idx_trip_settlements_trip_status (trip_id, status, id),
  KEY idx_trip_settlements_from_user (from_user_id),
  KEY idx_trip_settlements_to_user (to_user_id),
  CONSTRAINT fk_trip_settlements_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_settlements_from_user FOREIGN KEY (from_user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_settlements_to_user FOREIGN KEY (to_user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_settlements_marked_sent_by FOREIGN KEY (marked_sent_by) REFERENCES trip_users(id) ON DELETE SET NULL,
  CONSTRAINT fk_trip_settlements_confirmed_by FOREIGN KEY (confirmed_by) REFERENCES trip_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  type VARCHAR(48) NOT NULL,
  title VARCHAR(120) NOT NULL,
  body VARCHAR(255) NOT NULL,
  payload_json JSON NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  read_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_notifications_user_trip (user_id, trip_id, is_read, id),
  KEY idx_trip_notifications_trip (trip_id, id),
  CONSTRAINT fk_trip_notifications_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_notifications_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

CREATE TABLE IF NOT EXISTS trip_feedback (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  trip_id INT UNSIGNED NULL,
  type ENUM('bug', 'suggestion') NOT NULL,
  status ENUM('open', 'archived') NOT NULL DEFAULT 'open',
  note TEXT NULL,
  screenshot_path VARCHAR(255) NULL,
  screenshot_size INT UNSIGNED NULL,
  app_platform VARCHAR(32) NULL,
  app_version VARCHAR(64) NULL,
  build_number VARCHAR(32) NULL,
  locale VARCHAR(24) NULL,
  context_json LONGTEXT NULL,
  archived_at TIMESTAMP NULL DEFAULT NULL,
  archived_comment VARCHAR(500) NULL,
  archived_by_admin VARCHAR(80) NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_feedback_status_created (status, created_at, id),
  KEY idx_trip_feedback_user_created (user_id, created_at, id),
  KEY idx_trip_feedback_trip_created (trip_id, created_at, id),
  KEY idx_trip_feedback_type_created (type, created_at, id),
  CONSTRAINT fk_trip_feedback_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_feedback_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_feedback_status_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  feedback_id BIGINT UNSIGNED NOT NULL,
  action ENUM('created', 'archived', 'deleted') NOT NULL,
  from_status ENUM('open', 'archived') NULL,
  to_status ENUM('open', 'archived') NULL,
  comment VARCHAR(500) NULL,
  actor VARCHAR(80) NOT NULL DEFAULT 'system',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_feedback_status_history_feedback (feedback_id, id),
  KEY idx_trip_feedback_status_history_created (created_at, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_request_limits (
  scope VARCHAR(48) NOT NULL,
  subject_hash CHAR(64) NOT NULL,
  window_start INT UNSIGNED NOT NULL,
  hits INT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (scope, subject_hash, window_start),
  KEY idx_trip_request_limits_updated_at (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_upload_daily_usage (
  scope ENUM('user', 'trip') NOT NULL,
  scope_id INT UNSIGNED NOT NULL,
  day_utc DATE NOT NULL,
  files_count INT UNSIGNED NOT NULL DEFAULT 0,
  total_bytes BIGINT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (scope, scope_id, day_utc),
  KEY idx_trip_upload_daily_usage_day (day_utc, updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_refresh_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL DEFAULT NULL,
  last_used_at DATETIME NULL DEFAULT NULL,
  user_agent VARCHAR(255) NULL,
  ip_address VARCHAR(45) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_refresh_tokens_hash (token_hash),
  KEY idx_trip_refresh_tokens_user_active (user_id, revoked_at, expires_at),
  KEY idx_trip_refresh_tokens_expires (expires_at),
  CONSTRAINT fk_trip_refresh_tokens_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_random_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  created_by INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_random_orders_trip_id (trip_id),
  KEY idx_trip_random_orders_created_at (created_at, id),
  CONSTRAINT fk_trip_random_orders_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_random_orders_created_by FOREIGN KEY (created_by) REFERENCES trip_users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_random_order_members (
  order_id BIGINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  position INT UNSIGNED NOT NULL,
  PRIMARY KEY (order_id, user_id),
  KEY idx_trip_random_order_members_position (order_id, position),
  CONSTRAINT fk_trip_random_order_members_order FOREIGN KEY (order_id) REFERENCES trip_random_orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_random_order_members_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_random_draw_state (
  trip_id INT UNSIGNED NOT NULL,
  members_csv VARCHAR(1024) NOT NULL,
  remaining_csv VARCHAR(1024) NOT NULL,
  cycle_no INT UNSIGNED NOT NULL DEFAULT 1,
  draw_no INT UNSIGNED NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (trip_id),
  CONSTRAINT fk_trip_random_draw_state_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
