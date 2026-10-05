ALTER TABLE trip_payments
  ADD COLUMN share_payment_details TINYINT(1) NOT NULL DEFAULT 0 AFTER requester_user_id;
