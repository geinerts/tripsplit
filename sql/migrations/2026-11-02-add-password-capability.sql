-- Keep legacy accounts unknown: a social identity or hash is not proof of a chosen password.
ALTER TABLE trip_users ADD COLUMN has_password TINYINT(1) NULL DEFAULT NULL AFTER password_hash;
