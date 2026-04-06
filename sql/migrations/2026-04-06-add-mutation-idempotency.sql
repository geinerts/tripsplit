CREATE TABLE IF NOT EXISTS trip_mutation_idempotency (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id INT UNSIGNED NOT NULL,
  trip_id INT UNSIGNED NOT NULL,
  action VARCHAR(64) NOT NULL,
  mutation_id VARCHAR(96) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
  response_status SMALLINT UNSIGNED NOT NULL DEFAULT 200,
  response_json LONGTEXT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_mutation_idempotency_user_trip_action_mutation (
    user_id,
    trip_id,
    action,
    mutation_id
  ),
  KEY idx_trip_mutation_idempotency_created (created_at, id),
  CONSTRAINT fk_trip_mutation_idempotency_user_id FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_mutation_idempotency_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
