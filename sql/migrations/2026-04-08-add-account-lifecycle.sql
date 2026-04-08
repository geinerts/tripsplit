SET @trip_users_account_status_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'account_status'
);

SET @trip_users_account_status_sql := IF(
  @trip_users_account_status_exists = 0,
  "ALTER TABLE trip_users
   ADD COLUMN account_status ENUM('active', 'deactivated', 'deleted') NOT NULL DEFAULT 'active' AFTER credentials_required",
  'SELECT 1'
);

PREPARE stmt_trip_users_account_status FROM @trip_users_account_status_sql;
EXECUTE stmt_trip_users_account_status;
DEALLOCATE PREPARE stmt_trip_users_account_status;

SET @trip_users_account_status_modify_sql := IF(
  @trip_users_account_status_exists = 1,
  "ALTER TABLE trip_users
   MODIFY COLUMN account_status ENUM('active', 'deactivated', 'deleted') NOT NULL DEFAULT 'active'",
  'SELECT 1'
);

PREPARE stmt_trip_users_account_status_modify FROM @trip_users_account_status_modify_sql;
EXECUTE stmt_trip_users_account_status_modify;
DEALLOCATE PREPARE stmt_trip_users_account_status_modify;

SET @trip_users_deactivated_at_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'deactivated_at'
);

SET @trip_users_deactivated_at_sql := IF(
  @trip_users_deactivated_at_exists = 0,
  "ALTER TABLE trip_users
   ADD COLUMN deactivated_at TIMESTAMP NULL DEFAULT NULL AFTER email_verified_at",
  'SELECT 1'
);

PREPARE stmt_trip_users_deactivated_at FROM @trip_users_deactivated_at_sql;
EXECUTE stmt_trip_users_deactivated_at;
DEALLOCATE PREPARE stmt_trip_users_deactivated_at;

SET @trip_users_deleted_at_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'deleted_at'
);

SET @trip_users_deleted_at_sql := IF(
  @trip_users_deleted_at_exists = 0,
  "ALTER TABLE trip_users
   ADD COLUMN deleted_at TIMESTAMP NULL DEFAULT NULL AFTER deactivated_at",
  'SELECT 1'
);

PREPARE stmt_trip_users_deleted_at FROM @trip_users_deleted_at_sql;
EXECUTE stmt_trip_users_deleted_at;
DEALLOCATE PREPARE stmt_trip_users_deleted_at;

SET @trip_users_account_status_idx_exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND index_name = 'idx_trip_users_account_status'
);

SET @trip_users_account_status_idx_sql := IF(
  @trip_users_account_status_idx_exists = 0,
  'CREATE INDEX idx_trip_users_account_status ON trip_users(account_status, created_at, id)',
  'SELECT 1'
);

PREPARE stmt_trip_users_account_status_idx FROM @trip_users_account_status_idx_sql;
EXECUTE stmt_trip_users_account_status_idx;
DEALLOCATE PREPARE stmt_trip_users_account_status_idx;

CREATE TABLE IF NOT EXISTS trip_password_resets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_password_resets_token_hash (token_hash),
  KEY idx_trip_password_resets_user (user_id),
  KEY idx_trip_password_resets_expires (expires_at),
  CONSTRAINT fk_trip_password_resets_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_account_action_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  action ENUM('reactivate', 'delete') NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_account_action_tokens_hash (token_hash),
  KEY idx_trip_account_action_tokens_user_action (user_id, action, used_at, expires_at),
  KEY idx_trip_account_action_tokens_expires (expires_at),
  CONSTRAINT fk_trip_account_action_tokens_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
