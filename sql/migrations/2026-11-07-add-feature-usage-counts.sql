-- Monthly totals per feature. No user, trip, device, IP address, day or individual events.
CREATE TABLE IF NOT EXISTS trip_feature_usage_counts (
  usage_month CHAR(7) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  feature VARCHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  use_count BIGINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (usage_month, feature)
) ENGINE=InnoDB;
