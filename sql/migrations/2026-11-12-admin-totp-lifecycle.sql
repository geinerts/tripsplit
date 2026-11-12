-- Administrator 2FA lifecycle (F05, 2026-10-04 audit).
-- A new authenticator is kept as a pending secret until it is confirmed, so the
-- working secret is never overwritten early. totp_last_counter rejects reuse of a
-- code that was already accepted. Additive only; existing secrets are unchanged.
ALTER TABLE trip_admin_users
  ADD COLUMN totp_pending_secret VARCHAR(255) NULL DEFAULT NULL AFTER totp_enabled,
  ADD COLUMN totp_pending_created_at DATETIME NULL DEFAULT NULL AFTER totp_pending_secret,
  ADD COLUMN totp_last_counter BIGINT UNSIGNED NULL DEFAULT NULL AFTER totp_pending_created_at;
