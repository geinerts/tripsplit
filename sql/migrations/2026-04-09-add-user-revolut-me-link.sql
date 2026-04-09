SET @trip_users_revolut_me_link_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'revolut_me_link'
);

SET @trip_users_revolut_me_link_sql := IF(
  @trip_users_revolut_me_link_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN revolut_me_link VARCHAR(255) NULL',
  'SELECT 1'
);

PREPARE stmt_trip_users_revolut_me_link FROM @trip_users_revolut_me_link_sql;
EXECUTE stmt_trip_users_revolut_me_link;
DEALLOCATE PREPARE stmt_trip_users_revolut_me_link;
