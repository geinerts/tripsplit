CREATE TABLE IF NOT EXISTS trip_trip_invites (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  created_by INT UNSIGNED NOT NULL,
  invite_code CHAR(10) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_trip_invites_code (invite_code),
  KEY idx_trip_trip_invites_trip_active (trip_id, revoked_at, expires_at, id),
  KEY idx_trip_trip_invites_expires (expires_at),
  CONSTRAINT fk_trip_trip_invites_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_trip_invites_created_by FOREIGN KEY (created_by) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
