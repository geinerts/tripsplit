SET @trip_trips_status_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND column_name = 'status'
);

SET @trip_trips_status_sql := IF(
  @trip_trips_status_exists = 0,
  "ALTER TABLE trip_trips ADD COLUMN status ENUM('active', 'settling', 'archived') NOT NULL DEFAULT 'active' AFTER name",
  'SELECT 1'
);

PREPARE stmt_trip_trips_status FROM @trip_trips_status_sql;
EXECUTE stmt_trip_trips_status;
DEALLOCATE PREPARE stmt_trip_trips_status;

SET @trip_trips_ended_at_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND column_name = 'ended_at'
);

SET @trip_trips_ended_at_sql := IF(
  @trip_trips_ended_at_exists = 0,
  'ALTER TABLE trip_trips ADD COLUMN ended_at TIMESTAMP NULL DEFAULT NULL AFTER created_by',
  'SELECT 1'
);

PREPARE stmt_trip_trips_ended_at FROM @trip_trips_ended_at_sql;
EXECUTE stmt_trip_trips_ended_at;
DEALLOCATE PREPARE stmt_trip_trips_ended_at;

SET @trip_trips_archived_at_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND column_name = 'archived_at'
);

SET @trip_trips_archived_at_sql := IF(
  @trip_trips_archived_at_exists = 0,
  'ALTER TABLE trip_trips ADD COLUMN archived_at TIMESTAMP NULL DEFAULT NULL AFTER ended_at',
  'SELECT 1'
);

PREPARE stmt_trip_trips_archived_at FROM @trip_trips_archived_at_sql;
EXECUTE stmt_trip_trips_archived_at;
DEALLOCATE PREPARE stmt_trip_trips_archived_at;

SET @trip_trips_status_idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trips'
    AND index_name = 'idx_trip_trips_status'
);

SET @trip_trips_status_idx_sql := IF(
  @trip_trips_status_idx_exists = 0,
  'CREATE INDEX idx_trip_trips_status ON trip_trips(status, created_at, id)',
  'SELECT 1'
);

PREPARE stmt_trip_trips_status_idx FROM @trip_trips_status_idx_sql;
EXECUTE stmt_trip_trips_status_idx;
DEALLOCATE PREPARE stmt_trip_trips_status_idx;

CREATE TABLE IF NOT EXISTS trip_settlements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  trip_id INT UNSIGNED NOT NULL,
  from_user_id INT UNSIGNED NOT NULL,
  to_user_id INT UNSIGNED NOT NULL,
  amount_cents INT UNSIGNED NOT NULL,
  status ENUM('pending', 'sent', 'confirmed') NOT NULL DEFAULT 'pending',
  marked_sent_by INT UNSIGNED NULL,
  marked_sent_at TIMESTAMP NULL DEFAULT NULL,
  confirmed_by INT UNSIGNED NULL,
  confirmed_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_settlements_trip_pair (trip_id, from_user_id, to_user_id),
  KEY idx_trip_settlements_trip_status (trip_id, status, id),
  KEY idx_trip_settlements_from_user (from_user_id),
  KEY idx_trip_settlements_to_user (to_user_id),
  CONSTRAINT fk_trip_settlements_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_settlements_from_user FOREIGN KEY (from_user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_settlements_to_user FOREIGN KEY (to_user_id) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_settlements_marked_sent_by FOREIGN KEY (marked_sent_by) REFERENCES trip_users(id) ON DELETE SET NULL,
  CONSTRAINT fk_trip_settlements_confirmed_by FOREIGN KEY (confirmed_by) REFERENCES trip_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
