-- Expense reactions: one emoji per user per expense (toggle).
-- Default prefix is "trip_" — adjust if your TRIP_DB_TABLE_PREFIX differs.
CREATE TABLE IF NOT EXISTS `trip_expense_reactions` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `expense_id` BIGINT UNSIGNED NOT NULL,
  `trip_id`    INT UNSIGNED    NOT NULL,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `emoji`      VARCHAR(16)     NOT NULL,
  `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_expense_user` (`expense_id`, `user_id`),
  INDEX `idx_er_expense_id` (`expense_id`),
  CONSTRAINT `fk_er_expense`
    FOREIGN KEY (`expense_id`) REFERENCES `trip_expenses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Expense comments: free-text comment per expense (max 280 chars).
CREATE TABLE IF NOT EXISTS `trip_expense_comments` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `expense_id` BIGINT UNSIGNED NOT NULL,
  `trip_id`    INT UNSIGNED    NOT NULL,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `parent_comment_id` BIGINT UNSIGNED NULL,
  `body`       VARCHAR(280)    NOT NULL,
  `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_ec_expense_id` (`expense_id`),
  INDEX `idx_ec_parent_comment_id` (`parent_comment_id`),
  CONSTRAINT `fk_ec_expense`
    FOREIGN KEY (`expense_id`) REFERENCES `trip_expenses` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ec_parent_comment`
    FOREIGN KEY (`parent_comment_id`) REFERENCES `trip_expense_comments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Expense comment reactions: one emoji per user per comment (toggle).
CREATE TABLE IF NOT EXISTS `trip_expense_comment_reactions` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `comment_id` BIGINT UNSIGNED NOT NULL,
  `expense_id` BIGINT UNSIGNED NOT NULL,
  `trip_id`    INT UNSIGNED    NOT NULL,
  `user_id`    BIGINT UNSIGNED NOT NULL,
  `emoji`      VARCHAR(16)     NOT NULL,
  `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_ecr_comment_user` (`comment_id`, `user_id`),
  INDEX `idx_ecr_expense_id` (`expense_id`),
  INDEX `idx_ecr_comment_id` (`comment_id`),
  CONSTRAINT `fk_ecr_comment`
    FOREIGN KEY (`comment_id`) REFERENCES `trip_expense_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ecr_expense`
    FOREIGN KEY (`expense_id`) REFERENCES `trip_expenses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Expense comment mentions: one row per mentioned user per comment.
CREATE TABLE IF NOT EXISTS `trip_expense_comment_mentions` (
  `comment_id`   BIGINT UNSIGNED NOT NULL,
  `user_id`      INT UNSIGNED    NOT NULL,
  `mention_text` VARCHAR(191)    NOT NULL,
  `is_active`    TINYINT(1)      NOT NULL DEFAULT 1,
  `created_at`   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`, `user_id`),
  INDEX `idx_ecm_user` (`user_id`),
  CONSTRAINT `fk_ecm_comment`
    FOREIGN KEY (`comment_id`) REFERENCES `trip_expense_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_ecm_user`
    FOREIGN KEY (`user_id`) REFERENCES `trip_users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
