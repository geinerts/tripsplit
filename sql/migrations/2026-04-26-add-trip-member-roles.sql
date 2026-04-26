SET @trip_trip_members_role_exists := (
  SELECT COUNT(*)
  FROM information_schema.columns
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trip_members'
    AND column_name = 'role'
);

SET @trip_trip_members_add_role_sql := IF(
  @trip_trip_members_role_exists = 0,
  "ALTER TABLE trip_trip_members ADD COLUMN role VARCHAR(16) NOT NULL DEFAULT 'member' AFTER user_id",
  "SELECT 'trip_trip_members.role already exists' AS info"
);

PREPARE stmt_trip_trip_members_add_role FROM @trip_trip_members_add_role_sql;
EXECUTE stmt_trip_trip_members_add_role;
DEALLOCATE PREPARE stmt_trip_trip_members_add_role;

UPDATE trip_trip_members
SET role = 'member'
WHERE role IS NULL
   OR TRIM(role) = ''
   OR LOWER(TRIM(role)) NOT IN ('owner', 'admin', 'member');

UPDATE trip_trip_members tm
JOIN trip_trips t
  ON t.id = tm.trip_id
 AND t.created_by = tm.user_id
SET tm.role = 'owner'
WHERE t.created_by IS NOT NULL
  AND tm.role <> 'owner';

UPDATE trip_trip_members tm
JOIN (
  SELECT tm_pick.trip_id, MIN(tm_pick.user_id) AS fallback_owner_user_id
  FROM trip_trip_members tm_pick
  LEFT JOIN trip_trip_members tm_owner
    ON tm_owner.trip_id = tm_pick.trip_id
   AND tm_owner.role = 'owner'
  WHERE tm_owner.user_id IS NULL
  GROUP BY tm_pick.trip_id
) fallback
  ON fallback.trip_id = tm.trip_id
 AND fallback.fallback_owner_user_id = tm.user_id
SET tm.role = 'owner'
WHERE tm.role <> 'owner';

SET @trip_trip_members_trip_role_idx_exists := (
  SELECT COUNT(*)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'trip_trip_members'
    AND index_name = 'idx_trip_trip_members_trip_role'
);

SET @trip_trip_members_add_trip_role_idx_sql := IF(
  @trip_trip_members_trip_role_idx_exists = 0,
  "CREATE INDEX idx_trip_trip_members_trip_role ON trip_trip_members(trip_id, role)",
  "SELECT 'idx_trip_trip_members_trip_role already exists' AS info"
);

PREPARE stmt_trip_trip_members_add_trip_role_idx FROM @trip_trip_members_add_trip_role_idx_sql;
EXECUTE stmt_trip_trip_members_add_trip_role_idx;
DEALLOCATE PREPARE stmt_trip_trip_members_add_trip_role_idx;
