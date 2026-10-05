ALTER TABLE trip_trip_invites
  ADD COLUMN target_user_id INT UNSIGNED NULL,
  ADD COLUMN response ENUM('accepted', 'declined') NULL,
  ADD KEY idx_trip_invites_target (trip_id, target_user_id, revoked_at, expires_at),
  ADD CONSTRAINT fk_trip_invites_target FOREIGN KEY (target_user_id)
    REFERENCES trip_users(id) ON DELETE CASCADE;
