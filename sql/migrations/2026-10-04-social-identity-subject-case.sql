-- Provider subjects are opaque, case-sensitive identifiers. No identities are relinked.
-- The runtime exact-match check also protects servers awaiting this migration.
ALTER TABLE trip_user_identities
  MODIFY provider_subject VARCHAR(191) CHARACTER SET ascii COLLATE ascii_bin NOT NULL;
