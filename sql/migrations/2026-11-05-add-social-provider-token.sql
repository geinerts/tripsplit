SET @trip_identity_token_column_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_user_identities'
    AND column_name = 'provider_token_enc'
);

SET @trip_identity_token_column_sql := IF(
  @trip_identity_token_column_exists = 0,
  'ALTER TABLE trip_user_identities ADD COLUMN provider_token_enc TEXT NULL AFTER payload_json',
  'SELECT 1'
);

PREPARE stmt_trip_identity_token_column FROM @trip_identity_token_column_sql;
EXECUTE stmt_trip_identity_token_column;
DEALLOCATE PREPARE stmt_trip_identity_token_column;
