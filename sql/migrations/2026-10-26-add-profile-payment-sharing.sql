ALTER TABLE trip_users
  ADD COLUMN share_payment_details_with_trips TINYINT(1) NOT NULL DEFAULT 0;
