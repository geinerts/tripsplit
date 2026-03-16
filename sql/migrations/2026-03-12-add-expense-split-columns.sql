SET @trip_expenses_split_mode_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expenses'
    AND column_name = 'split_mode'
);

SET @trip_expenses_split_mode_sql := IF(
  @trip_expenses_split_mode_exists = 0,
  "ALTER TABLE trip_expenses ADD COLUMN split_mode ENUM('equal', 'exact', 'percent', 'shares') NOT NULL DEFAULT 'equal' AFTER note",
  'SELECT 1'
);

PREPARE stmt_trip_expenses_split_mode FROM @trip_expenses_split_mode_sql;
EXECUTE stmt_trip_expenses_split_mode;
DEALLOCATE PREPARE stmt_trip_expenses_split_mode;

SET @trip_expense_participants_owed_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expense_participants'
    AND column_name = 'owed_cents'
);

SET @trip_expense_participants_owed_sql := IF(
  @trip_expense_participants_owed_exists = 0,
  'ALTER TABLE trip_expense_participants ADD COLUMN owed_cents INT UNSIGNED NOT NULL DEFAULT 0 AFTER user_id',
  'SELECT 1'
);

PREPARE stmt_trip_expense_participants_owed FROM @trip_expense_participants_owed_sql;
EXECUTE stmt_trip_expense_participants_owed;
DEALLOCATE PREPARE stmt_trip_expense_participants_owed;

SET @trip_expense_participants_split_value_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expense_participants'
    AND column_name = 'split_value'
);

SET @trip_expense_participants_split_value_sql := IF(
  @trip_expense_participants_split_value_exists = 0,
  'ALTER TABLE trip_expense_participants ADD COLUMN split_value INT UNSIGNED NOT NULL DEFAULT 0 AFTER owed_cents',
  'SELECT 1'
);

PREPARE stmt_trip_expense_participants_split_value FROM @trip_expense_participants_split_value_sql;
EXECUTE stmt_trip_expense_participants_split_value;
DEALLOCATE PREPARE stmt_trip_expense_participants_split_value;
