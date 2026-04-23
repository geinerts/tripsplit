SET @trip_expense_comments_exists := (
  SELECT COUNT(*)
  FROM information_schema.tables
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expense_comments'
);

SET @trip_expense_comments_parent_column_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expense_comments'
    AND column_name = 'parent_comment_id'
);

SET @trip_expense_comments_add_parent_column_sql := IF(
  @trip_expense_comments_exists = 1 AND @trip_expense_comments_parent_column_exists = 0,
  'ALTER TABLE trip_expense_comments ADD COLUMN parent_comment_id BIGINT UNSIGNED NULL AFTER user_id',
  'SELECT 1'
);

PREPARE stmt_trip_expense_comments_add_parent_column FROM @trip_expense_comments_add_parent_column_sql;
EXECUTE stmt_trip_expense_comments_add_parent_column;
DEALLOCATE PREPARE stmt_trip_expense_comments_add_parent_column;

SET @trip_expense_comments_parent_index_exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expense_comments'
    AND index_name = 'idx_ec_parent_comment_id'
);

SET @trip_expense_comments_add_parent_index_sql := IF(
  @trip_expense_comments_exists = 1 AND @trip_expense_comments_parent_index_exists = 0,
  'ALTER TABLE trip_expense_comments ADD INDEX idx_ec_parent_comment_id (parent_comment_id)',
  'SELECT 1'
);

PREPARE stmt_trip_expense_comments_add_parent_index FROM @trip_expense_comments_add_parent_index_sql;
EXECUTE stmt_trip_expense_comments_add_parent_index;
DEALLOCATE PREPARE stmt_trip_expense_comments_add_parent_index;

SET @trip_expense_comments_parent_fk_exists := (
  SELECT COUNT(*)
  FROM information_schema.table_constraints
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expense_comments'
    AND constraint_name = 'fk_ec_parent_comment'
    AND constraint_type = 'FOREIGN KEY'
);

SET @trip_expense_comments_add_parent_fk_sql := IF(
  @trip_expense_comments_exists = 1 AND @trip_expense_comments_parent_fk_exists = 0,
  'ALTER TABLE trip_expense_comments
     ADD CONSTRAINT fk_ec_parent_comment
       FOREIGN KEY (parent_comment_id) REFERENCES trip_expense_comments(id) ON DELETE SET NULL',
  'SELECT 1'
);

PREPARE stmt_trip_expense_comments_add_parent_fk FROM @trip_expense_comments_add_parent_fk_sql;
EXECUTE stmt_trip_expense_comments_add_parent_fk;
DEALLOCATE PREPARE stmt_trip_expense_comments_add_parent_fk;
