-- Premium that belongs to one trip and covers all of its current members.
-- No end date; revoked_at ends it. Deleting the trip deletes it.
CREATE TABLE IF NOT EXISTS trip_premium_trip_grants (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  source ENUM('testing', 'compensation') NOT NULL,
  reason VARCHAR(500) NOT NULL,
  revoked_at DATETIME NULL,
  version INT UNSIGNED NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_premium_trip_grants_trip (trip_id, revoked_at),
  CONSTRAINT fk_premium_trip_grant_trip FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
