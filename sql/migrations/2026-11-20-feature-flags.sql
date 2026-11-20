-- Feature flags: a global mode per flag and per-account grants. See docs/api/feature-flags.md.
-- Adds tables only; no existing data changes. receipt_ai starts off with no grants.

CREATE TABLE IF NOT EXISTS trip_feature_flags (
  flag_key VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  mode ENUM('off', 'allowlist', 'everyone') NOT NULL DEFAULT 'off',
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  updated_by_admin_id INT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (flag_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_user_features (
  user_id INT UNSIGNED NOT NULL,
  flag_key VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  granted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  granted_by_admin_id INT UNSIGNED NULL DEFAULT NULL,
  PRIMARY KEY (user_id, flag_key),
  KEY idx_trip_user_features_flag (flag_key),
  CONSTRAINT fk_trip_user_features_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO trip_feature_flags (flag_key, mode) VALUES ('receipt_ai', 'off');
