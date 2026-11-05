SET @trip_expense_comments_exists := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expense_comments'
);

SET @trip_expense_comment_mentions_sql := IF(
  @trip_expense_comments_exists = 1,
  'CREATE TABLE IF NOT EXISTS trip_expense_comment_mentions (
     comment_id BIGINT UNSIGNED NOT NULL,
     user_id INT UNSIGNED NOT NULL,
     mention_text VARCHAR(191) NOT NULL,
     is_active TINYINT(1) NOT NULL DEFAULT 1,
     created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
     PRIMARY KEY (comment_id, user_id),
     KEY idx_ecm_user (user_id),
     CONSTRAINT fk_ecm_comment FOREIGN KEY (comment_id)
       REFERENCES trip_expense_comments(id) ON DELETE CASCADE,
     CONSTRAINT fk_ecm_user FOREIGN KEY (user_id)
       REFERENCES trip_users(id) ON DELETE CASCADE
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci',
  'SELECT 1'
);

PREPARE stmt_trip_expense_comment_mentions FROM @trip_expense_comment_mentions_sql;
EXECUTE stmt_trip_expense_comment_mentions;
DEALLOCATE PREPARE stmt_trip_expense_comment_mentions;
