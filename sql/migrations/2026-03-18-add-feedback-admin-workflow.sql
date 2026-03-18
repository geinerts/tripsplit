SET @trip_feedback_status_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_feedback'
    AND column_name = 'status'
);

SET @trip_feedback_status_sql := IF(
  @trip_feedback_status_exists = 0,
  "ALTER TABLE trip_feedback ADD COLUMN status ENUM('open', 'archived') NOT NULL DEFAULT 'open' AFTER type",
  'SELECT 1'
);

PREPARE stmt_trip_feedback_status FROM @trip_feedback_status_sql;
EXECUTE stmt_trip_feedback_status;
DEALLOCATE PREPARE stmt_trip_feedback_status;

SET @trip_feedback_archived_at_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_feedback'
    AND column_name = 'archived_at'
);

SET @trip_feedback_archived_at_sql := IF(
  @trip_feedback_archived_at_exists = 0,
  'ALTER TABLE trip_feedback ADD COLUMN archived_at TIMESTAMP NULL DEFAULT NULL AFTER context_json',
  'SELECT 1'
);

PREPARE stmt_trip_feedback_archived_at FROM @trip_feedback_archived_at_sql;
EXECUTE stmt_trip_feedback_archived_at;
DEALLOCATE PREPARE stmt_trip_feedback_archived_at;

SET @trip_feedback_archived_comment_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_feedback'
    AND column_name = 'archived_comment'
);

SET @trip_feedback_archived_comment_sql := IF(
  @trip_feedback_archived_comment_exists = 0,
  'ALTER TABLE trip_feedback ADD COLUMN archived_comment VARCHAR(500) NULL AFTER archived_at',
  'SELECT 1'
);

PREPARE stmt_trip_feedback_archived_comment FROM @trip_feedback_archived_comment_sql;
EXECUTE stmt_trip_feedback_archived_comment;
DEALLOCATE PREPARE stmt_trip_feedback_archived_comment;

SET @trip_feedback_archived_by_admin_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_feedback'
    AND column_name = 'archived_by_admin'
);

SET @trip_feedback_archived_by_admin_sql := IF(
  @trip_feedback_archived_by_admin_exists = 0,
  'ALTER TABLE trip_feedback ADD COLUMN archived_by_admin VARCHAR(80) NULL AFTER archived_comment',
  'SELECT 1'
);

PREPARE stmt_trip_feedback_archived_by_admin FROM @trip_feedback_archived_by_admin_sql;
EXECUTE stmt_trip_feedback_archived_by_admin;
DEALLOCATE PREPARE stmt_trip_feedback_archived_by_admin;

SET @trip_feedback_updated_at_exists := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_feedback'
    AND column_name = 'updated_at'
);

SET @trip_feedback_updated_at_sql := IF(
  @trip_feedback_updated_at_exists = 0,
  'ALTER TABLE trip_feedback ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER archived_by_admin',
  'SELECT 1'
);

PREPARE stmt_trip_feedback_updated_at FROM @trip_feedback_updated_at_sql;
EXECUTE stmt_trip_feedback_updated_at;
DEALLOCATE PREPARE stmt_trip_feedback_updated_at;

SET @trip_feedback_status_index_exists := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_feedback'
    AND index_name = 'idx_trip_feedback_status_created'
);

SET @trip_feedback_status_index_sql := IF(
  @trip_feedback_status_index_exists = 0,
  'ALTER TABLE trip_feedback ADD INDEX idx_trip_feedback_status_created (status, created_at, id)',
  'SELECT 1'
);

PREPARE stmt_trip_feedback_status_index FROM @trip_feedback_status_index_sql;
EXECUTE stmt_trip_feedback_status_index;
DEALLOCATE PREPARE stmt_trip_feedback_status_index;

UPDATE trip_feedback
SET status = 'archived'
WHERE archived_at IS NOT NULL;

UPDATE trip_feedback
SET status = 'open'
WHERE status IS NULL OR status = '';

CREATE TABLE IF NOT EXISTS trip_feedback_status_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  feedback_id BIGINT UNSIGNED NOT NULL,
  action ENUM('created', 'archived', 'deleted') NOT NULL,
  from_status ENUM('open', 'archived') NULL,
  to_status ENUM('open', 'archived') NULL,
  comment VARCHAR(500) NULL,
  actor VARCHAR(80) NOT NULL DEFAULT 'system',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_feedback_status_history_feedback (feedback_id, id),
  KEY idx_trip_feedback_status_history_created (created_at, id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO trip_feedback_status_history
  (feedback_id, action, from_status, to_status, comment, actor, created_at)
SELECT
  f.id,
  'created',
  NULL,
  'open',
  NULL,
  'system',
  f.created_at
FROM trip_feedback f
LEFT JOIN trip_feedback_status_history h
  ON h.feedback_id = f.id
 AND h.action = 'created'
WHERE h.id IS NULL;

INSERT INTO trip_feedback_status_history
  (feedback_id, action, from_status, to_status, comment, actor, created_at)
SELECT
  f.id,
  'archived',
  'open',
  'archived',
  f.archived_comment,
  COALESCE(NULLIF(TRIM(f.archived_by_admin), ''), 'admin'),
  COALESCE(f.archived_at, f.updated_at, f.created_at)
FROM trip_feedback f
LEFT JOIN trip_feedback_status_history h
  ON h.feedback_id = f.id
 AND h.action = 'archived'
WHERE f.status = 'archived'
  AND h.id IS NULL;
