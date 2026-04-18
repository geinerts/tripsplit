SET @trip_users_wise_pay_link_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'wise_pay_link'
);

SET @trip_users_wise_pay_link_sql := IF(
  @trip_users_wise_pay_link_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN wise_pay_link VARCHAR(255) NULL AFTER paypal_me_link',
  'SELECT 1'
);

PREPARE stmt_trip_users_wise_pay_link FROM @trip_users_wise_pay_link_sql;
EXECUTE stmt_trip_users_wise_pay_link;
DEALLOCATE PREPARE stmt_trip_users_wise_pay_link;
