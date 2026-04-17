SET @trip_user_push_tokens_locale_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_user_push_tokens'
    AND column_name = 'locale'
);

SET @trip_user_push_tokens_locale_sql := IF(
  @trip_user_push_tokens_locale_exists = 0,
  'ALTER TABLE trip_user_push_tokens ADD COLUMN locale VARCHAR(8) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL DEFAULT ''en'' AFTER app_bundle',
  'SELECT 1'
);

PREPARE stmt_trip_user_push_tokens_locale FROM @trip_user_push_tokens_locale_sql;
EXECUTE stmt_trip_user_push_tokens_locale;
DEALLOCATE PREPARE stmt_trip_user_push_tokens_locale;

UPDATE trip_user_push_tokens
SET locale = 'en'
WHERE locale IS NULL
   OR TRIM(locale) = '';
