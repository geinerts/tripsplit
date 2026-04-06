SET @trip_trips_currency_code_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND column_name = 'currency_code'
);

SET @trip_trips_currency_code_sql := IF(
  @trip_trips_currency_code_exists = 0,
  "ALTER TABLE trip_trips ADD COLUMN currency_code CHAR(3) NOT NULL DEFAULT 'EUR' AFTER name",
  'SELECT 1'
);

PREPARE stmt_trip_trips_currency_code FROM @trip_trips_currency_code_sql;
EXECUTE stmt_trip_trips_currency_code;
DEALLOCATE PREPARE stmt_trip_trips_currency_code;

UPDATE trip_trips
SET currency_code = 'EUR'
WHERE currency_code IS NULL OR TRIM(currency_code) = '';

SET @trip_expenses_currency_code_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expenses'
    AND column_name = 'currency_code'
);

SET @trip_expenses_currency_code_sql := IF(
  @trip_expenses_currency_code_exists = 0,
  "ALTER TABLE trip_expenses ADD COLUMN currency_code CHAR(3) NOT NULL DEFAULT 'EUR' AFTER amount",
  'SELECT 1'
);

PREPARE stmt_trip_expenses_currency_code FROM @trip_expenses_currency_code_sql;
EXECUTE stmt_trip_expenses_currency_code;
DEALLOCATE PREPARE stmt_trip_expenses_currency_code;

SET @trip_expenses_source_amount_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expenses'
    AND column_name = 'source_amount'
);

SET @trip_expenses_source_amount_sql := IF(
  @trip_expenses_source_amount_exists = 0,
  "ALTER TABLE trip_expenses ADD COLUMN source_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00 AFTER currency_code",
  'SELECT 1'
);

PREPARE stmt_trip_expenses_source_amount FROM @trip_expenses_source_amount_sql;
EXECUTE stmt_trip_expenses_source_amount;
DEALLOCATE PREPARE stmt_trip_expenses_source_amount;

SET @trip_expenses_fx_rate_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expenses'
    AND column_name = 'fx_rate_to_trip'
);

SET @trip_expenses_fx_rate_sql := IF(
  @trip_expenses_fx_rate_exists = 0,
  "ALTER TABLE trip_expenses ADD COLUMN fx_rate_to_trip DECIMAL(18,8) NOT NULL DEFAULT 1.00000000 AFTER source_amount",
  'SELECT 1'
);

PREPARE stmt_trip_expenses_fx_rate FROM @trip_expenses_fx_rate_sql;
EXECUTE stmt_trip_expenses_fx_rate;
DEALLOCATE PREPARE stmt_trip_expenses_fx_rate;

UPDATE trip_expenses
SET currency_code = 'EUR'
WHERE currency_code IS NULL OR TRIM(currency_code) = '';

UPDATE trip_expenses
SET source_amount = amount
WHERE source_amount IS NULL OR source_amount <= 0;

UPDATE trip_expenses
SET fx_rate_to_trip = 1.00000000
WHERE fx_rate_to_trip IS NULL OR fx_rate_to_trip <= 0;
