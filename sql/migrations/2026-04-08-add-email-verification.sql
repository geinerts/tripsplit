CREATE TABLE IF NOT EXISTS trip_email_verification_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  email VARCHAR(255) NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_email_verification_tokens_hash (token_hash),
  KEY idx_trip_email_verification_tokens_user (user_id, used_at, expires_at),
  KEY idx_trip_email_verification_tokens_email (email, used_at, expires_at),
  KEY idx_trip_email_verification_tokens_expires (expires_at),
  CONSTRAINT fk_trip_email_verification_tokens_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
