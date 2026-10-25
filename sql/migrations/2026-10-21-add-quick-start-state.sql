-- Existing accounts stay suppressed, including accounts that deleted all trips.
-- Only accounts created after this migration become automatically eligible.
-- Re-running this migration never resets any account's state.
SET @quick_start_exists := (
  SELECT COUNT(*) FROM information_schema.columns
  WHERE table_schema = DATABASE() AND table_name = 'trip_users'
    AND column_name = 'quick_start_state'
);
SET @quick_start_sql := IF(@quick_start_exists = 0,
  "ALTER TABLE trip_users ADD COLUMN quick_start_state VARCHAR(16) NOT NULL DEFAULT 'legacy'",
  "SELECT 'quick_start_state already exists' AS info"
);
PREPARE quick_start_stmt FROM @quick_start_sql;
EXECUTE quick_start_stmt;
DEALLOCATE PREPARE quick_start_stmt;
ALTER TABLE trip_users ALTER COLUMN quick_start_state SET DEFAULT 'pending';
