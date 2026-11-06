-- Currencies like the Vietnamese dong need amounts above the 42.9 million units that
-- INT UNSIGNED holds in hundredths. Widening keeps every existing value.
ALTER TABLE trip_expense_participants
  MODIFY COLUMN owed_cents BIGINT UNSIGNED NOT NULL DEFAULT 0,
  MODIFY COLUMN split_value BIGINT UNSIGNED NOT NULL DEFAULT 0;

ALTER TABLE trip_settlements
  MODIFY COLUMN amount_cents BIGINT UNSIGNED NOT NULL;

ALTER TABLE trip_payments
  MODIFY COLUMN amount_cents BIGINT UNSIGNED NOT NULL;
