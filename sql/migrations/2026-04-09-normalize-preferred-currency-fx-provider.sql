UPDATE trip_users
SET preferred_currency_code = UPPER(TRIM(preferred_currency_code))
WHERE preferred_currency_code IS NOT NULL
  AND TRIM(preferred_currency_code) <> '';

UPDATE trip_users
SET preferred_currency_code = 'EUR'
WHERE preferred_currency_code IS NULL
   OR TRIM(preferred_currency_code) = ''
   OR UPPER(preferred_currency_code) NOT IN (
      'AUD', 'BGN', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK',
      'EUR', 'GBP', 'HUF', 'ISK', 'JPY', 'NOK', 'PLN',
      'RON', 'SEK', 'TRY', 'USD'
   );
