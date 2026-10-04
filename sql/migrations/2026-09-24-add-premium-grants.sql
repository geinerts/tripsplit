CREATE TABLE IF NOT EXISTS trip_premium_partners (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_premium_partner_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_premium_grants (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  partner_id BIGINT UNSIGNED NULL,
  source ENUM('partner', 'testing', 'compensation') NOT NULL,
  starts_at DATETIME NOT NULL,
  ends_at DATETIME NOT NULL,
  reason VARCHAR(500) NOT NULL,
  revoked_at DATETIME NULL,
  version INT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_premium_grants_user (user_id, revoked_at, ends_at),
  KEY idx_premium_grants_expiry (revoked_at, ends_at),
  KEY idx_premium_grants_partner (partner_id, ends_at),
  CONSTRAINT fk_premium_grant_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_premium_grant_partner FOREIGN KEY (partner_id) REFERENCES trip_premium_partners(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_premium_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  request_id CHAR(36) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  request_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  admin_user_id INT UNSIGNED NOT NULL,
  admin_username VARCHAR(120) NOT NULL,
  user_id INT UNSIGNED NULL,
  grant_id BIGINT UNSIGNED NULL,
  partner_id BIGINT UNSIGNED NULL,
  action VARCHAR(40) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  reason VARCHAR(500) NOT NULL,
  before_json JSON NULL,
  after_json JSON NOT NULL,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_premium_event_request (request_id),
  KEY idx_premium_events_user (user_id, id),
  KEY idx_premium_events_grant (grant_id, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
