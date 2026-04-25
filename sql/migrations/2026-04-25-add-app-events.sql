CREATE TABLE IF NOT EXISTS `trip_app_events` (
  `id`          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     BIGINT UNSIGNED NULL,
  `event_type`  VARCHAR(64)     NOT NULL,
  `entity_type` VARCHAR(32)     NULL,
  `entity_id`   BIGINT UNSIGNED NULL,
  `created_at`  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_app_events_type_created` (`event_type`, `created_at`),
  KEY `idx_app_events_user`         (`user_id`, `created_at`),
  KEY `idx_app_events_created`      (`created_at`),
  CONSTRAINT `fk_app_events_user`
    FOREIGN KEY (`user_id`) REFERENCES `trip_users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
