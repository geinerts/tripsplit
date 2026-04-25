CREATE TABLE IF NOT EXISTS `trip_app_events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `trip_id` INT UNSIGNED NULL,
  `user_id` INT UNSIGNED NULL,
  `event_type` VARCHAR(64) NOT NULL,
  `entity_type` VARCHAR(32) NULL,
  `entity_id` BIGINT UNSIGNED NULL,
  `payload_json` JSON NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_app_events_trip_id` (`trip_id`, `id`),
  KEY `idx_app_events_trip_created` (`trip_id`, `created_at`, `id`),
  KEY `idx_app_events_type_created` (`event_type`, `created_at`),
  KEY `idx_app_events_user` (`user_id`, `created_at`),
  KEY `idx_app_events_created` (`created_at`),
  CONSTRAINT `fk_app_events_trip`
    FOREIGN KEY (`trip_id`) REFERENCES `trip_trips` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_app_events_user`
    FOREIGN KEY (`user_id`) REFERENCES `trip_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @trip_app_events_trip_id_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_app_events'
    AND column_name = 'trip_id'
);

SET @trip_app_events_add_trip_id_sql := IF(
  @trip_app_events_trip_id_exists = 0,
  'ALTER TABLE trip_app_events ADD COLUMN trip_id INT UNSIGNED NULL AFTER id',
  'SELECT 1'
);

PREPARE stmt_trip_app_events_add_trip_id FROM @trip_app_events_add_trip_id_sql;
EXECUTE stmt_trip_app_events_add_trip_id;
DEALLOCATE PREPARE stmt_trip_app_events_add_trip_id;

SET @trip_app_events_payload_json_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_app_events'
    AND column_name = 'payload_json'
);

SET @trip_app_events_add_payload_json_sql := IF(
  @trip_app_events_payload_json_exists = 0,
  'ALTER TABLE trip_app_events ADD COLUMN payload_json JSON NULL AFTER entity_id',
  'SELECT 1'
);

PREPARE stmt_trip_app_events_add_payload_json FROM @trip_app_events_add_payload_json_sql;
EXECUTE stmt_trip_app_events_add_payload_json;
DEALLOCATE PREPARE stmt_trip_app_events_add_payload_json;

SET @trip_app_events_trip_id_index_exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_app_events'
    AND index_name = 'idx_app_events_trip_id'
);

SET @trip_app_events_add_trip_id_index_sql := IF(
  @trip_app_events_trip_id_index_exists = 0,
  'ALTER TABLE trip_app_events ADD INDEX idx_app_events_trip_id (trip_id, id)',
  'SELECT 1'
);

PREPARE stmt_trip_app_events_add_trip_id_index FROM @trip_app_events_add_trip_id_index_sql;
EXECUTE stmt_trip_app_events_add_trip_id_index;
DEALLOCATE PREPARE stmt_trip_app_events_add_trip_id_index;

SET @trip_app_events_trip_created_index_exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_app_events'
    AND index_name = 'idx_app_events_trip_created'
);

SET @trip_app_events_add_trip_created_index_sql := IF(
  @trip_app_events_trip_created_index_exists = 0,
  'ALTER TABLE trip_app_events ADD INDEX idx_app_events_trip_created (trip_id, created_at, id)',
  'SELECT 1'
);

PREPARE stmt_trip_app_events_add_trip_created_index FROM @trip_app_events_add_trip_created_index_sql;
EXECUTE stmt_trip_app_events_add_trip_created_index;
DEALLOCATE PREPARE stmt_trip_app_events_add_trip_created_index;

SET @trip_app_events_trip_fk_exists := (
  SELECT COUNT(*)
  FROM information_schema.table_constraints
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_app_events'
    AND constraint_name = 'fk_app_events_trip'
    AND constraint_type = 'FOREIGN KEY'
);

SET @trip_app_events_add_trip_fk_sql := IF(
  @trip_app_events_trip_fk_exists = 0,
  'ALTER TABLE trip_app_events
     ADD CONSTRAINT fk_app_events_trip
       FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE',
  'SELECT 1'
);

PREPARE stmt_trip_app_events_add_trip_fk FROM @trip_app_events_add_trip_fk_sql;
EXECUTE stmt_trip_app_events_add_trip_fk;
DEALLOCATE PREPARE stmt_trip_app_events_add_trip_fk;
