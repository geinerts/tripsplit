ALTER TABLE trip_expenses
  MODIFY COLUMN split_mode ENUM('equal', 'exact', 'percent', 'shares', 'adjustment', 'itemized') NOT NULL DEFAULT 'equal';

-- Adjustments can be negative.
ALTER TABLE trip_expense_participants
  MODIFY COLUMN split_value BIGINT NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS trip_expense_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  expense_id BIGINT UNSIGNED NOT NULL,
  position SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  name VARCHAR(80) NOT NULL DEFAULT '',
  amount_cents BIGINT UNSIGNED NOT NULL,
  is_extra TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_trip_expense_items_expense (expense_id, position),
  CONSTRAINT fk_trip_expense_items_expense FOREIGN KEY (expense_id) REFERENCES trip_expenses(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_expense_item_participants (
  item_id BIGINT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  PRIMARY KEY (item_id, user_id),
  KEY idx_trip_expense_item_participants_user (user_id),
  CONSTRAINT fk_trip_expense_item_participants_item FOREIGN KEY (item_id) REFERENCES trip_expense_items(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_expense_item_participants_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
