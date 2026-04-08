CREATE TABLE IF NOT EXISTS trip_user_identities (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  provider ENUM('google', 'apple') NOT NULL,
  provider_subject VARCHAR(191) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  email VARCHAR(255) NULL,
  email_verified TINYINT(1) NOT NULL DEFAULT 0,
  payload_json JSON NULL,
  last_login_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_user_identities_provider_subject (provider, provider_subject),
  UNIQUE KEY uq_trip_user_identities_user_provider (user_id, provider),
  KEY idx_trip_user_identities_user (user_id, updated_at, id),
  KEY idx_trip_user_identities_email (email, provider),
  CONSTRAINT fk_trip_user_identities_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
