<?php
declare(strict_types=1);

function require_trip_invitation_schema(PDO $pdo): void
{
    $stmt = $pdo->prepare('SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name AND column_name = "target_user_id"');
    $stmt->execute(['table_name' => trim(table_name('trip_invites'), '`')]);
    if (!(int) $stmt->fetchColumn()) {
        json_out(['ok' => false, 'error' => 'Trip invitations require a server update.'], 409);
    }
}

// Caller holds the trip lock. Pending invitations never enter trip_members.
function invite_trip_users(PDO $pdo, int $tripId, int $actorId, string $tripName, array $userIds): int
{
    if (count($userIds) > 100) {
        json_out(['ok' => false, 'error' => 'Invite at most 100 people at a time.'], 400);
    }
    $count = 0;
    foreach ($userIds as $userId) {
        $userId = (int) $userId;
        $member = $pdo->prepare('SELECT user_id FROM ' . table_name('trip_members') . '
            WHERE trip_id = :trip AND user_id = :user FOR UPDATE');
        $member->execute(['trip' => $tripId, 'user' => $userId]);
        if ($member->fetchColumn()) continue;
        $pending = $pdo->prepare('SELECT id FROM ' . table_name('trip_invites') . '
            WHERE trip_id = :trip AND target_user_id = :user
              AND revoked_at IS NULL AND expires_at > UTC_TIMESTAMP() FOR UPDATE');
        $pending->execute(['trip' => $tripId, 'user' => $userId]);
        if ($pending->fetchColumn()) continue;
        $limit = $pdo->prepare('SELECT COUNT(*) FROM ' . table_name('trip_invites') . '
            WHERE trip_id = :trip AND target_user_id IS NOT NULL
              AND revoked_at IS NULL AND expires_at > UTC_TIMESTAMP()');
        $limit->execute(['trip' => $tripId]);
        if ((int) $limit->fetchColumn() >= 100) {
            json_out(['ok' => false, 'error' => 'This trip already has 100 pending invitations.'], 409);
        }
        $code = create_trip_invite_code();
        $pdo->prepare('INSERT INTO ' . table_name('trip_invites') . '
            (trip_id, created_by, target_user_id, invite_code, expires_at)
            VALUES (:trip, :actor, :target, :code, :expires)')->execute([
                'trip' => $tripId, 'actor' => $actorId, 'target' => $userId,
                'code' => $code, 'expires' => gmdate('Y-m-d H:i:s', time() + trip_invite_ttl_seconds()),
            ]);
        create_user_notification($pdo, $tripId, $userId, 'trip_invitation', 'Trip invitation',
            'You have been invited to "' . $tripName . '".',
            ['trip_id' => $tripId, 'invite_token' => $code, 'invited_by_user_id' => $actorId]);
        $count++;
    }
    return $count;
}

function assert_invitation_recipient(array $invite, int $actorId): void
{
    if (isset($invite['target_user_id']) && (int) $invite['target_user_id'] !== $actorId) {
        json_out(['ok' => false, 'error' => 'Invalid invite token.'], 404);
    }
}

function revoke_departing_member_invites(PDO $pdo, int $tripId, int $userId): void
{
    // Old shared links must not let a removed member immediately return. Other
    // recipients keep their personal invitations; owners can issue a fresh link.
    $pdo->prepare('UPDATE ' . table_name('trip_invites') . ' SET revoked_at = UTC_TIMESTAMP()
        WHERE trip_id = :trip AND revoked_at IS NULL
          AND (target_user_id IS NULL OR target_user_id = :user OR created_by = :creator)')
        ->execute(['trip' => $tripId, 'user' => $userId, 'creator' => $userId]);
    $pdo->prepare('UPDATE ' . table_name('trip_invite_preview_tokens') . ' SET used_at = UTC_TIMESTAMP()
        WHERE trip_id = :trip AND user_id = :user AND used_at IS NULL')
        ->execute(['trip' => $tripId, 'user' => $userId]);
}

function decline_trip_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $code = normalize_trip_invite_code((string) ($body['invite_token'] ?? ''));
    $pdo = db();
    require_trip_invitation_schema($pdo);
    enforce_rate_limit($pdo, 'trip_write_user', (string) $me['id'],
        RATE_LIMIT_TRIP_WRITE_USER_MAX, RATE_LIMIT_MUTATION_WINDOW_SEC);
    $locator = $pdo->prepare('SELECT trip_id FROM ' . table_name('trip_invites') . '
        WHERE invite_code = :code AND target_user_id = :user');
    $locator->execute(['code' => $code, 'user' => (int) $me['id']]);
    $tripId = (int) $locator->fetchColumn();
    if (!$tripId) json_out(['ok' => false, 'error' => 'Invalid invite token.'], 404);
    $pdo->beginTransaction();
    try {
        lock_active_trip_membership_scope($pdo, $tripId);
        $stmt = $pdo->prepare('SELECT * FROM ' . table_name('trip_invites') . '
            WHERE invite_code = :code FOR UPDATE');
        $stmt->execute(['code' => $code]);
        $invite = $stmt->fetch();
        if (!$invite || (int) $invite['target_user_id'] !== (int) $me['id']) {
            json_out(['ok' => false, 'error' => 'Invalid invite token.'], 404);
        }
        if ($invite['revoked_at'] !== null || strtotime($invite['expires_at']) <= time()) {
            json_out(['ok' => false, 'error' => 'Invite token expired.'], 409);
        }
        $pdo->prepare('UPDATE ' . table_name('trip_invites') . '
            SET revoked_at = UTC_TIMESTAMP(), response = "declined" WHERE id = :id')
            ->execute(['id' => $invite['id']]);
        app_event($pdo, (int) $me['id'], 'trip.invitation_declined', 'trip', $tripId, $tripId);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
    json_out(['ok' => true]);
}

function list_pending_trip_invitations_action(): void
{
    $me = get_me();
    $pdo = db();
    require_trip_invitation_schema($pdo);
    $trip = get_current_trip($pdo, $me, true);
    require_trip_permission($pdo, $trip, (int) $me['id'], 'manage_members');
    $stmt = $pdo->prepare('SELECT i.id, i.target_user_id AS user_id, u.nickname, i.expires_at
        FROM ' . table_name('trip_invites') . ' i
        JOIN ' . table_name('users') . ' u ON u.id = i.target_user_id
        WHERE i.trip_id = :trip AND i.revoked_at IS NULL AND i.expires_at > UTC_TIMESTAMP()
          AND NOT EXISTS (SELECT 1 FROM ' . table_name('trip_members') . ' m
            WHERE m.trip_id = i.trip_id AND m.user_id = i.target_user_id)
        ORDER BY i.id DESC LIMIT 100');
    $stmt->execute(['trip' => (int) $trip['id']]);
    json_out(['ok' => true, 'invitations' => $stmt->fetchAll()]);
}

function revoke_trip_invitation_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    require_trip_invitation_schema($pdo);
    $trip = get_current_trip($pdo, $me, true);
    enforce_rate_limit($pdo, 'trip_write_user', (string) $me['id'],
        RATE_LIMIT_TRIP_WRITE_USER_MAX, RATE_LIMIT_MUTATION_WINDOW_SEC);
    $tripId = (int) $trip['id'];
    $pdo->beginTransaction();
    try {
        $trip = lock_active_trip_membership_scope($pdo, $tripId);
        require_locked_trip_member($pdo, $tripId, (int) $me['id']);
        require_trip_permission($pdo, $trip, (int) $me['id'], 'manage_members');
        $stmt = $pdo->prepare('UPDATE ' . table_name('trip_invites') . '
            SET revoked_at = UTC_TIMESTAMP()
            WHERE id = :id AND trip_id = :trip AND target_user_id IS NOT NULL
              AND revoked_at IS NULL AND expires_at > UTC_TIMESTAMP()');
        $stmt->execute(['id' => (int) ($body['invitation_id'] ?? 0), 'trip' => $tripId]);
        if (!$stmt->rowCount()) {
            json_out(['ok' => false, 'error' => 'Invitation not found.'], 404);
        }
        app_event($pdo, (int) $me['id'], 'trip.invitation_revoked', 'trip', $tripId, $tripId);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
    json_out(['ok' => true]);
}
