-- Quick split share links: a page anyone with the link can open. See docs/api/quick-split-share-links.md.
-- The token is derived from token_salt with a server key, so the database alone can't rebuild
-- a link; lookups use the token's SHA-256 (token_hash).

CREATE TABLE IF NOT EXISTS trip_quick_split_shares (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  quick_split_id BIGINT UNSIGNED NOT NULL,
  token_salt CHAR(32) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  token_hash CHAR(64) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  show_receipt TINYINT(1) NOT NULL DEFAULT 0,
  created_by INT UNSIGNED NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NOT NULL,
  revoked_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_trip_quick_split_shares_token (token_hash),
  KEY idx_trip_quick_split_shares_split (quick_split_id, revoked_at, expires_at),
  CONSTRAINT fk_trip_quick_split_shares_split FOREIGN KEY (quick_split_id) REFERENCES trip_quick_splits(id) ON DELETE CASCADE,
  CONSTRAINT fk_trip_quick_split_shares_creator FOREIGN KEY (created_by) REFERENCES trip_users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
