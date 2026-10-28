CREATE TABLE IF NOT EXISTS trip_live_locations (
  trip_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  session_token CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  latitude DOUBLE NULL,
  longitude DOUBLE NULL,
  accuracy_m DOUBLE NULL,
  observed_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY (trip_id, user_id),
  KEY idx_live_expiry (expires_at),
  KEY idx_live_user (user_id),
  CONSTRAINT fk_live_member FOREIGN KEY (trip_id, user_id)
    REFERENCES trip_trip_members(trip_id, user_id) ON DELETE CASCADE,
  CONSTRAINT fk_live_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_live_trip FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
