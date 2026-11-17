-- Quick splits: one bill shared between people without a trip. See docs/api/quick-splits.md.

CREATE TABLE IF NOT EXISTS trip_quick_splits (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  created_by INT UNSIGNED NOT NULL,
  amount_cents BIGINT UNSIGNED NOT NULL,
  currency_code CHAR(3) NOT NULL DEFAULT 'EUR',
  category VARCHAR(64) NOT NULL DEFAULT 'other',
  subcategory VARCHAR(40) NULL DEFAULT NULL,
  note VARCHAR(255) NOT NULL DEFAULT '',
  split_mode ENUM('equal', 'exact', 'percent', 'shares', 'adjustment', 'itemized') NOT NULL DEFAULT 'equal',
  split_date DATE NOT NULL,
  receipt_path VARCHAR(255) NULL DEFAULT NULL,
  client_mutation_id VARCHAR(96) CHARACTER SET ascii COLLATE ascii_general_ci NULL DEFAULT NULL,
  moved_trip_id INT UNSIGNED NULL DEFAULT NULL,
  moved_expense_id BIGINT UNSIGNED NULL DEFAULT NULL,
  moved_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_quick_splits_mutation (created_by, client_mutation_id),
  KEY idx_trip_quick_splits_creator (created_by, moved_at, split_date, id),
  CONSTRAINT fk_trip_quick_splits_creator FOREIGN KEY (created_by) REFERENCES trip_users(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_quick_splits_moved_trip FOREIGN KEY (moved_trip_id) REFERENCES trip_trips(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- user_id is set for Splyto accounts; name is saved for everyone and shown when the account is gone.
CREATE TABLE IF NOT EXISTS trip_quick_split_people (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  quick_split_id BIGINT UNSIGNED NOT NULL,
  position SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  user_id INT UNSIGNED NULL DEFAULT NULL,
  name VARCHAR(32) NOT NULL DEFAULT '',
  is_payer TINYINT(1) NOT NULL DEFAULT 0,
  owed_cents BIGINT UNSIGNED NOT NULL DEFAULT 0,
  split_value BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_trip_quick_split_people_split (quick_split_id, position),
  KEY idx_trip_quick_split_people_user (user_id, quick_split_id),
  CONSTRAINT fk_trip_quick_split_people_split FOREIGN KEY (quick_split_id) REFERENCES trip_quick_splits(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_quick_split_people_user FOREIGN KEY (user_id) REFERENCES trip_users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_quick_split_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  quick_split_id BIGINT UNSIGNED NOT NULL,
  position SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  name VARCHAR(80) NOT NULL DEFAULT '',
  amount_cents BIGINT UNSIGNED NOT NULL,
  is_extra TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_trip_quick_split_items_split (quick_split_id, position),
  CONSTRAINT fk_trip_quick_split_items_split FOREIGN KEY (quick_split_id) REFERENCES trip_quick_splits(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS trip_quick_split_item_people (
  item_id BIGINT UNSIGNED NOT NULL,
  person_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (item_id, person_id),
  KEY idx_trip_quick_split_item_people_person (person_id),
  CONSTRAINT fk_trip_quick_split_item_people_item FOREIGN KEY (item_id) REFERENCES trip_quick_split_items(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_quick_split_item_people_person FOREIGN KEY (person_id) REFERENCES trip_quick_split_people(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
