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
