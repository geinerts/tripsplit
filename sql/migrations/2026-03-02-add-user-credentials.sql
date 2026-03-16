ALTER TABLE trip_users
  ADD COLUMN IF NOT EXISTS email VARCHAR(255) NULL AFTER nickname,
  ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255) NULL AFTER email,
  ADD COLUMN IF NOT EXISTS credentials_required TINYINT(1) NOT NULL DEFAULT 1 AFTER password_hash,
  ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMP NULL DEFAULT NULL AFTER credentials_required;

SET @trip_users_email_idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND index_name = 'uq_trip_users_email'
);

SET @trip_users_email_idx_sql := IF(
  @trip_users_email_idx_exists = 0,
  'CREATE UNIQUE INDEX uq_trip_users_email ON trip_users(email)',
  'SELECT 1'
);

PREPARE stmt_trip_users_email_idx FROM @trip_users_email_idx_sql;
EXECUTE stmt_trip_users_email_idx;
DEALLOCATE PREPARE stmt_trip_users_email_idx;
