-- ── Admin Panel v2 Tables ─────────────────────────────────────────────────────
-- Idempotent: CREATE TABLE IF NOT EXISTS throughout.
-- Run once on the VPS after deploying the code.

-- Admin user accounts (separate from app users)
CREATE TABLE IF NOT EXISTS `trip_admin_users` (
  `id`                 INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `username`           VARCHAR(64)   NOT NULL,
  `email`              VARCHAR(255)  NOT NULL,
  `password_hash`      VARCHAR(255)  NOT NULL,
  `role`               ENUM('superadmin','admin','support','ops','readonly') NOT NULL DEFAULT 'readonly',
  `is_active`          TINYINT(1)    NOT NULL DEFAULT 1,
  `totp_secret`        VARCHAR(128)  NULL DEFAULT NULL,
  `totp_enabled`       TINYINT(1)    NOT NULL DEFAULT 0,
  `last_login_at`      DATETIME      NULL DEFAULT NULL,
  `failed_login_count` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `locked_until`       DATETIME      NULL DEFAULT NULL,
  `created_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`         DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_username` (`username`),
  UNIQUE KEY `uq_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Admin sessions (configurable sliding window, default 2 hours, max 5 concurrent per user)
CREATE TABLE IF NOT EXISTS `trip_admin_sessions` (
  `token`            CHAR(64)     NOT NULL,
  `admin_user_id`    INT UNSIGNED NOT NULL,
  `ip_address`       VARCHAR(45)  NOT NULL DEFAULT '',
  `user_agent`       VARCHAR(512) NOT NULL DEFAULT '',
  `is_2fa_verified`  TINYINT(1)   NOT NULL DEFAULT 0,
  `expires_at`       DATETIME     NOT NULL,
  `last_active_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`token`),
  KEY `idx_admin_user_id` (`admin_user_id`),
  KEY `idx_expires_at`    (`expires_at`),
  CONSTRAINT `fk_admin_sessions_user`
    FOREIGN KEY (`admin_user_id`) REFERENCES `trip_admin_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Immutable audit trail for every write action
CREATE TABLE IF NOT EXISTS `trip_admin_audit_log` (
  `id`               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_user_id`    INT UNSIGNED    NULL DEFAULT NULL,
  `admin_username`   VARCHAR(64)     NOT NULL DEFAULT '',
  `action`           VARCHAR(128)    NOT NULL,
  `target_type`      VARCHAR(64)     NULL DEFAULT NULL,
  `target_id`        BIGINT          NULL DEFAULT NULL,
  `details`          JSON            NULL DEFAULT NULL,
  `ip_address`       VARCHAR(45)     NOT NULL DEFAULT '',
  `created_at`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_created_at`  (`created_at`),
  KEY `idx_admin_user`  (`admin_user_id`),
  KEY `idx_target`      (`target_type`, `target_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Incident / on-call notes
CREATE TABLE IF NOT EXISTS `trip_admin_incidents` (
  `id`                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `admin_user_id`        INT UNSIGNED NOT NULL,
  `admin_username`       VARCHAR(64)  NOT NULL DEFAULT '',
  `title`                VARCHAR(255) NOT NULL,
  `body`                 TEXT         NOT NULL,
  `severity`             ENUM('low','medium','high','critical') NOT NULL DEFAULT 'medium',
  `status`               ENUM('open','investigating','resolved') NOT NULL DEFAULT 'open',
  `resolved_at`          DATETIME     NULL DEFAULT NULL,
  `resolved_by_username` VARCHAR(64)  NULL DEFAULT NULL,
  `created_at`           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`           DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status`     (`status`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_admin_incidents_user`
    FOREIGN KEY (`admin_user_id`) REFERENCES `trip_admin_users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
