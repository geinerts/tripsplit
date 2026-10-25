-- Friend invitations belong to an account, even when it has no trips.
ALTER TABLE trip_notifications MODIFY COLUMN trip_id INT UNSIGNED NULL;

-- Recover invitations still represented by a friendship row. Accepted invites
-- are historical, so they must not appear as new after this migration.
-- Do not queue push messages when restoring history.
INSERT INTO trip_notifications
    (trip_id, user_id, type, title, body, payload_json, is_read, read_at, created_at)
SELECT NULL,
    IF(f.requested_by = f.user_a_id, f.user_b_id, f.user_a_id),
    'friend_invite_received', 'Friend invite',
    CONCAT(COALESCE(NULLIF(TRIM(u.nickname), ''), 'Trip member'), ' sent you a friend invite.'),
    JSON_OBJECT('request_id', f.id, 'from_user_id', f.requested_by, 'status', f.status),
    IF(f.status = 'pending', 0, 1),
    IF(f.status = 'pending', NULL, COALESCE(f.responded_at, f.created_at)),
    f.created_at
FROM trip_friends f
JOIN trip_users u ON u.id = f.requested_by
WHERE f.status IN ('pending', 'accepted')
  AND NOT EXISTS (
    SELECT 1 FROM trip_notifications n
    WHERE n.user_id = IF(f.requested_by = f.user_a_id, f.user_b_id, f.user_a_id)
      AND n.type = 'friend_invite_received'
      AND JSON_EXTRACT(n.payload_json, '$.request_id') = f.id
  );
