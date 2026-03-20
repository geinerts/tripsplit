SET @trip_members_ready_to_settle_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = CONCAT('trip_', 'trip_members')
    AND COLUMN_NAME = 'ready_to_settle'
);

SET @trip_members_ready_to_settle_sql := IF(
  @trip_members_ready_to_settle_exists = 0,
  "ALTER TABLE trip_trip_members ADD COLUMN ready_to_settle TINYINT(1) NOT NULL DEFAULT 0 AFTER joined_at",
  "SELECT 1"
);

PREPARE stmt_trip_members_ready_to_settle FROM @trip_members_ready_to_settle_sql;
EXECUTE stmt_trip_members_ready_to_settle;
DEALLOCATE PREPARE stmt_trip_members_ready_to_settle;

SET @trip_members_ready_to_settle_at_exists := (
  SELECT COUNT(*)
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = CONCAT('trip_', 'trip_members')
    AND COLUMN_NAME = 'ready_to_settle_at'
);

SET @trip_members_ready_to_settle_at_sql := IF(
  @trip_members_ready_to_settle_at_exists = 0,
  "ALTER TABLE trip_trip_members ADD COLUMN ready_to_settle_at TIMESTAMP NULL DEFAULT NULL AFTER ready_to_settle",
  "SELECT 1"
);

PREPARE stmt_trip_members_ready_to_settle_at FROM @trip_members_ready_to_settle_at_sql;
EXECUTE stmt_trip_members_ready_to_settle_at;
DEALLOCATE PREPARE stmt_trip_members_ready_to_settle_at;

UPDATE trip_trip_members
SET ready_to_settle = 0
WHERE ready_to_settle IS NULL;
