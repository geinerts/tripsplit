CREATE TABLE IF NOT EXISTS trip_friends (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_a_id INT UNSIGNED NOT NULL,
  user_b_id INT UNSIGNED NOT NULL,
  requested_by INT UNSIGNED NOT NULL,
  status ENUM('pending','accepted','rejected') NOT NULL DEFAULT 'pending',
  responded_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_friends_pair (user_a_id, user_b_id),
  KEY idx_trip_friends_a_status (user_a_id, status, updated_at),
  KEY idx_trip_friends_b_status (user_b_id, status, updated_at),
  KEY idx_trip_friends_requested_by (requested_by, status, updated_at),
  CONSTRAINT fk_trip_friends_user_a FOREIGN KEY (user_a_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_friends_user_b FOREIGN KEY (user_b_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_friends_requested_by FOREIGN KEY (requested_by) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
