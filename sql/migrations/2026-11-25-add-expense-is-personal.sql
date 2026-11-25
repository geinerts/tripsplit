-- Personal expenses in group trips. See docs/api/personal-expenses.md.
ALTER TABLE trip_expenses
  ADD COLUMN is_personal TINYINT(1) NOT NULL DEFAULT 0;
