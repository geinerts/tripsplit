CREATE TABLE IF NOT EXISTS trip_trip_invite_preview_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  trip_id INT UNSIGNED NOT NULL,
  invite_code CHAR(10) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  nonce_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_trip_invite_preview_tokens_nonce_hash (nonce_hash),
  KEY idx_trip_trip_invite_preview_tokens_user_state (user_id, used_at, expires_at, id),
  KEY idx_trip_trip_invite_preview_tokens_trip_invite (trip_id, invite_code, used_at, expires_at, id),
  KEY idx_trip_trip_invite_preview_tokens_expires (expires_at),
  CONSTRAINT fk_trip_trip_invite_preview_tokens_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_trip_invite_preview_tokens_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
