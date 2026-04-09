SET @trip_users_preferred_currency_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_users'
    AND column_name = 'preferred_currency_code'
);

SET @trip_users_preferred_currency_sql := IF(
  @trip_users_preferred_currency_exists = 0,
  "ALTER TABLE trip_users ADD COLUMN preferred_currency_code CHAR(3) NOT NULL DEFAULT 'EUR' AFTER paypal_me_link",
  "SELECT 'trip_users.preferred_currency_code already exists' AS info"
);

PREPARE stmt_trip_users_preferred_currency FROM @trip_users_preferred_currency_sql;
EXECUTE stmt_trip_users_preferred_currency;
DEALLOCATE PREPARE stmt_trip_users_preferred_currency;

UPDATE trip_users
SET preferred_currency_code = 'EUR'
WHERE preferred_currency_code IS NULL
   OR TRIM(preferred_currency_code) = ''
   OR UPPER(preferred_currency_code) NOT IN (
      'EUR', 'GBP', 'CHF', 'NOK', 'SEK', 'DKK',
      'PLN', 'CZK', 'HUF', 'RON', 'BGN', 'ISK',
      'ALL', 'BAM', 'BYN', 'MDL', 'MKD', 'RSD',
      'UAH', 'GEL', 'TRY',
      'USD', 'JPY', 'CNY', 'CAD', 'AUD'
   );

UPDATE trip_users
SET preferred_currency_code = UPPER(preferred_currency_code)
WHERE preferred_currency_code IS NOT NULL
  AND TRIM(preferred_currency_code) <> '';
