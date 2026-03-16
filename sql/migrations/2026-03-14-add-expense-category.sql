SET @trip_expenses_category_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expenses'
    AND column_name = 'category'
);

SET @trip_expenses_category_sql := IF(
  @trip_expenses_category_exists = 0,
  "ALTER TABLE trip_expenses ADD COLUMN category VARCHAR(64) NOT NULL DEFAULT 'other' AFTER amount",
  'SELECT 1'
);

PREPARE stmt_trip_expenses_category FROM @trip_expenses_category_sql;
EXECUTE stmt_trip_expenses_category;
DEALLOCATE PREPARE stmt_trip_expenses_category;

UPDATE trip_expenses
SET category = 'other'
WHERE category IS NULL OR TRIM(category) = '';
