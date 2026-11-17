ALTER TABLE trip_expense_comment_mentions
  ADD COLUMN start_offset SMALLINT UNSIGNED NULL DEFAULT NULL;
ALTER TABLE trip_expense_comment_mentions
  ADD COLUMN end_offset SMALLINT UNSIGNED NULL DEFAULT NULL;
