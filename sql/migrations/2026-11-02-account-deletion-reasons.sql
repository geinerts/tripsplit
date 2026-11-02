-- Anonymous totals for optional feedback on successfully emailed deletion requests.
-- No account identifiers, free text, individual events or timestamps are stored.
CREATE TABLE IF NOT EXISTS trip_account_deletion_reason_counts (
  reason_code VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL PRIMARY KEY,
  request_count BIGINT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB;
