-- Older links have no state binding and are deliberately rejected after rollout.
ALTER TABLE trip_password_resets
  ADD COLUMN credential_state_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL AFTER token_hash;
