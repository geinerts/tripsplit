ALTER TABLE trip_expenses
  ADD COLUMN IF NOT EXISTS receipt_path VARCHAR(255) NULL AFTER expense_date;
