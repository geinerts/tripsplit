-- Only automatic unverified-email cleanup may grant this permission.
-- Historical deactivated accounts have an ambiguous reason: never infer permission.
SET @trip_email_reactivation_exists := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_users'
    AND column_name = 'email_verification_can_reactivate'
);
SET @trip_email_reactivation_sql := IF(
  @trip_email_reactivation_exists = 0,
  'ALTER TABLE trip_users ADD COLUMN email_verification_can_reactivate TINYINT(1) NOT NULL DEFAULT 0 AFTER account_status',
  'SELECT 1'
);
PREPARE stmt_trip_email_reactivation FROM @trip_email_reactivation_sql;
EXECUTE stmt_trip_email_reactivation;
DEALLOCATE PREPARE stmt_trip_email_reactivation;
