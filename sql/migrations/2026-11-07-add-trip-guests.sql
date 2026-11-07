-- Set only for people added to a trip by name, who have no account.
ALTER TABLE trip_users
  ADD COLUMN guest_trip_id INT UNSIGNED NULL DEFAULT NULL AFTER locale,
  ADD KEY idx_trip_users_guest_trip (guest_trip_id);
