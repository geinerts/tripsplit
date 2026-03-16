SET @trip_users_first_name_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'first_name'
);

SET @trip_users_first_name_sql := IF(
  @trip_users_first_name_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN first_name VARCHAR(64) NULL AFTER id',
  'SELECT 1'
);

PREPARE stmt_trip_users_first_name FROM @trip_users_first_name_sql;
EXECUTE stmt_trip_users_first_name;
DEALLOCATE PREPARE stmt_trip_users_first_name;

SET @trip_users_last_name_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'last_name'
);

SET @trip_users_last_name_sql := IF(
  @trip_users_last_name_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN last_name VARCHAR(64) NULL AFTER first_name',
  'SELECT 1'
);

PREPARE stmt_trip_users_last_name FROM @trip_users_last_name_sql;
EXECUTE stmt_trip_users_last_name;
DEALLOCATE PREPARE stmt_trip_users_last_name;

UPDATE trip_users
SET first_name = nickname
WHERE (first_name IS NULL OR first_name = '')
  AND nickname IS NOT NULL
  AND nickname <> '';
