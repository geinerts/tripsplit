ALTER TABLE trip_account_action_tokens
  MODIFY action ENUM('reactivate', 'delete', 'deactivate') NOT NULL,
  ADD COLUMN credential_state_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NULL AFTER token_hash;
