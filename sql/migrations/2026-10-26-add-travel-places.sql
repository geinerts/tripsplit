CREATE TABLE IF NOT EXISTS trip_travel_places (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  place_key CHAR(64) NOT NULL,
  city VARCHAR(120) NOT NULL,
  region VARCHAR(120) NOT NULL DEFAULT '',
  country VARCHAR(120) NOT NULL,
  country_code CHAR(2) NOT NULL,
  latitude DECIMAL(8,5) NOT NULL,
  longitude DECIMAL(9,5) NOT NULL,
  visited_on DATE NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_travel_visit (user_id, place_key, visited_on),
  KEY idx_travel_places_user_date (user_id, visited_on),
  CONSTRAINT fk_travel_places_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
