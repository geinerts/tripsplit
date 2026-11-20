-- AI receipt scans and their budget. See docs/api/receipt-scan.md.
-- Adds tables only; no existing data changes.

CREATE TABLE IF NOT EXISTS trip_ai_scans (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  request_id VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  receipt_path VARCHAR(255) NOT NULL,
  image_sha256 CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  status ENUM('reserved', 'sent', 'done', 'failed') NOT NULL DEFAULT 'reserved',
  model VARCHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  reserved_microusd INT UNSIGNED NOT NULL DEFAULT 0,
  cost_microusd INT UNSIGNED NULL DEFAULT NULL,
  input_tokens INT UNSIGNED NULL DEFAULT NULL,
  output_tokens INT UNSIGNED NULL DEFAULT NULL,
  duration_ms INT UNSIGNED NULL DEFAULT NULL,
  error_code VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NULL DEFAULT NULL,
  result_json MEDIUMTEXT NULL,
  budget_hour CHAR(15) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  budget_day CHAR(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  budget_month CHAR(9) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_ai_scans_request (user_id, request_id),
  KEY idx_trip_ai_scans_user_created (user_id, created_at),
  KEY idx_trip_ai_scans_hash (user_id, image_sha256, created_at),
  KEY idx_trip_ai_scans_created (created_at),
  CONSTRAINT fk_trip_ai_scans_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_ai_budget (
  period CHAR(15) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  spent_microusd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  reserved_microusd BIGINT UNSIGNED NOT NULL DEFAULT 0,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (period)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
