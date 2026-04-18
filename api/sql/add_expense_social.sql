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
  `body`       VARCHAR(280)    NOT NULL,
  `created_at` TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_ec_expense_id` (`expense_id`),
  CONSTRAINT `fk_ec_expense`
    FOREIGN KEY (`expense_id`) REFERENCES `trip_expenses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
