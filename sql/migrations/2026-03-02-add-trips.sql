CREATE TABLE IF NOT EXISTS trip_trips (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  created_by INT UNSIGNED NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_trip_trips_created_at (created_at, id),
  KEY idx_trip_trips_created_by (created_by),
  CONSTRAINT fk_trip_trips_created_by FOREIGN KEY (created_by) REFERENCES trip_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_trip_members (
  trip_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  joined_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (trip_id, user_id),
  KEY idx_trip_trip_members_user (user_id),
  CONSTRAINT fk_trip_trip_members_trip FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_trip_members_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE trip_expenses
  ADD COLUMN IF NOT EXISTS trip_id INT UNSIGNED NULL AFTER id;

ALTER TABLE trip_random_orders
  ADD COLUMN IF NOT EXISTS trip_id INT UNSIGNED NULL AFTER id;

ALTER TABLE trip_random_draw_state
  ADD COLUMN IF NOT EXISTS trip_id INT UNSIGNED NULL AFTER id;

INSERT INTO trip_trips (name, created_by)
SELECT 'Main Trip', (
  SELECT id FROM trip_users ORDER BY created_at ASC, id ASC LIMIT 1
)
WHERE NOT EXISTS (SELECT 1 FROM trip_trips LIMIT 1);

SET @default_trip_id := (
  SELECT id
  FROM trip_trips
  ORDER BY created_at ASC, id ASC
  LIMIT 1
);

INSERT IGNORE INTO trip_trip_members (trip_id, user_id)
SELECT @default_trip_id, u.id
FROM trip_users u
WHERE @default_trip_id IS NOT NULL;

UPDATE trip_expenses
SET trip_id = @default_trip_id
WHERE trip_id IS NULL AND @default_trip_id IS NOT NULL;

UPDATE trip_random_orders
SET trip_id = @default_trip_id
WHERE trip_id IS NULL AND @default_trip_id IS NOT NULL;

UPDATE trip_random_draw_state
SET trip_id = @default_trip_id
WHERE trip_id IS NULL AND @default_trip_id IS NOT NULL;

ALTER TABLE trip_expenses
  MODIFY COLUMN trip_id INT UNSIGNED NOT NULL;

ALTER TABLE trip_random_orders
  MODIFY COLUMN trip_id INT UNSIGNED NOT NULL;

ALTER TABLE trip_random_draw_state
  MODIFY COLUMN trip_id INT UNSIGNED NOT NULL;

SET @trip_expenses_trip_idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_expenses'
    AND index_name = 'idx_trip_expenses_trip_id'
);

SET @trip_expenses_trip_idx_sql := IF(
  @trip_expenses_trip_idx_exists = 0,
  'CREATE INDEX idx_trip_expenses_trip_id ON trip_expenses(trip_id)',
  'SELECT 1'
);

PREPARE stmt_trip_expenses_trip_idx FROM @trip_expenses_trip_idx_sql;
EXECUTE stmt_trip_expenses_trip_idx;
DEALLOCATE PREPARE stmt_trip_expenses_trip_idx;

SET @trip_random_orders_trip_idx_exists := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_random_orders'
    AND index_name = 'idx_trip_random_orders_trip_id'
);

SET @trip_random_orders_trip_idx_sql := IF(
  @trip_random_orders_trip_idx_exists = 0,
  'CREATE INDEX idx_trip_random_orders_trip_id ON trip_random_orders(trip_id)',
  'SELECT 1'
);

PREPARE stmt_trip_random_orders_trip_idx FROM @trip_random_orders_trip_idx_sql;
EXECUTE stmt_trip_random_orders_trip_idx;
DEALLOCATE PREPARE stmt_trip_random_orders_trip_idx;

SET @trip_random_draw_state_has_legacy_id := (
  SELECT COUNT(1)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_random_draw_state'
    AND column_name = 'id'
);

SET @trip_random_draw_state_drop_legacy_id_sql := IF(
  @trip_random_draw_state_has_legacy_id = 1,
  'ALTER TABLE trip_random_draw_state DROP PRIMARY KEY, DROP COLUMN id',
  'SELECT 1'
);

PREPARE stmt_trip_random_draw_state_drop_legacy_id FROM @trip_random_draw_state_drop_legacy_id_sql;
EXECUTE stmt_trip_random_draw_state_drop_legacy_id;
DEALLOCATE PREPARE stmt_trip_random_draw_state_drop_legacy_id;

SET @trip_random_draw_state_pk_exists := (
  SELECT COUNT(1)
  FROM information_schema.table_constraints
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_random_draw_state'
    AND constraint_type = 'PRIMARY KEY'
);

SET @trip_random_draw_state_pk_sql := IF(
  @trip_random_draw_state_pk_exists = 0,
  'ALTER TABLE trip_random_draw_state ADD PRIMARY KEY (trip_id)',
  'SELECT 1'
);

PREPARE stmt_trip_random_draw_state_pk FROM @trip_random_draw_state_pk_sql;
EXECUTE stmt_trip_random_draw_state_pk;
DEALLOCATE PREPARE stmt_trip_random_draw_state_pk;

SET @fk_trip_expenses_trip_exists := (
  SELECT COUNT(1)
  FROM information_schema.referential_constraints
  WHERE constraint_schema = DATABASE()
    AND table_name = 'trip_expenses'
    AND constraint_name = 'fk_trip_expenses_trip_id'
);

SET @fk_trip_expenses_trip_sql := IF(
  @fk_trip_expenses_trip_exists = 0,
  'ALTER TABLE trip_expenses ADD CONSTRAINT fk_trip_expenses_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE',
  'SELECT 1'
);

PREPARE stmt_fk_trip_expenses_trip FROM @fk_trip_expenses_trip_sql;
EXECUTE stmt_fk_trip_expenses_trip;
DEALLOCATE PREPARE stmt_fk_trip_expenses_trip;

SET @fk_trip_random_orders_trip_exists := (
  SELECT COUNT(1)
  FROM information_schema.referential_constraints
  WHERE constraint_schema = DATABASE()
    AND table_name = 'trip_random_orders'
    AND constraint_name = 'fk_trip_random_orders_trip_id'
);

SET @fk_trip_random_orders_trip_sql := IF(
  @fk_trip_random_orders_trip_exists = 0,
  'ALTER TABLE trip_random_orders ADD CONSTRAINT fk_trip_random_orders_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE',
  'SELECT 1'
);

PREPARE stmt_fk_trip_random_orders_trip FROM @fk_trip_random_orders_trip_sql;
EXECUTE stmt_fk_trip_random_orders_trip;
DEALLOCATE PREPARE stmt_fk_trip_random_orders_trip;

SET @fk_trip_random_draw_state_trip_exists := (
  SELECT COUNT(1)
  FROM information_schema.referential_constraints
  WHERE constraint_schema = DATABASE()
    AND table_name = 'trip_random_draw_state'
    AND constraint_name = 'fk_trip_random_draw_state_trip_id'
);

SET @fk_trip_random_draw_state_trip_sql := IF(
  @fk_trip_random_draw_state_trip_exists = 0,
  'ALTER TABLE trip_random_draw_state ADD CONSTRAINT fk_trip_random_draw_state_trip_id FOREIGN KEY (trip_id) REFERENCES trip_trips(id) ON DELETE CASCADE',
  'SELECT 1'
);

PREPARE stmt_fk_trip_random_draw_state_trip FROM @fk_trip_random_draw_state_trip_sql;
EXECUTE stmt_fk_trip_random_draw_state_trip;
DEALLOCATE PREPARE stmt_fk_trip_random_draw_state_trip;
