<?php
declare(strict_types=1);

/**
 * Guests of the trip the actor can act for: all of them for its owner, none for anyone else.
 *
 * @return array<int, int>
 */
function trip_guest_ids_for_actor(PDO $pdo, int $tripId, int $actorId): array
{
    static $cache = [];
    $key = $tripId . ':' . $actorId;
    if (isset($cache[$key])) {
        return $cache[$key];
    }
    try {
        if ($tripId <= 0 || $actorId <= 0 || trip_member_role_for_user($pdo, $tripId, $actorId) !== 'owner') {
            return $cache[$key] = [];
        }
        $stmt = $pdo->prepare(
            'SELECT u.id FROM ' . table_name('users') . ' u
             JOIN ' . table_name('trip_members') . ' tm ON tm.user_id = u.id AND tm.trip_id = :member_trip
             WHERE u.guest_trip_id = :guest_trip'
        );
        $stmt->execute(['member_trip' => $tripId, 'guest_trip' => $tripId]);
        return $cache[$key] = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));
    } catch (PDOException $error) {
        return [];
    }
}

/** True when the actor may act as this person in the trip. */
function trip_actor_acts_for(int $actorId, int $userId, array $guestIds): bool
{
    return $userId > 0 && ($userId === $actorId || in_array($userId, $guestIds, true));
}

function user_is_guest(PDO $pdo, int $userId): bool
{
    try {
        $stmt = $pdo->prepare(
            'SELECT 1 FROM ' . table_name('users') . ' WHERE id = :id AND guest_trip_id IS NOT NULL LIMIT 1'
        );
        $stmt->execute(['id' => $userId]);
        return (bool) $stmt->fetchColumn();
    } catch (PDOException $error) {
        return false;
    }
}

function normalize_trip_guest_name($value): string
{
    $name = trim(preg_replace('/\s+/u', ' ', (string) $value) ?? '');
    if ($name === '') {
        json_out(['ok' => false, 'error' => 'Name is required.'], 400);
    }
    if (str_length($name) > 32) {
        json_out(['ok' => false, 'error' => 'Name is too long.'], 400);
    }
    ensure_text_has_no_links($name, 'Name');
    return $name;
}

/** The payer of an expense: the actor, or a guest when the trip owner names one. */
function resolve_expense_payer_id(PDO $pdo, int $tripId, int $actorId, array $body, int $current): int
{
    if (!array_key_exists('paid_by', $body) || $body['paid_by'] === null) {
        return $current;
    }
    $payerId = (int) $body['paid_by'];
    if ($payerId !== $actorId && !in_array($payerId, trip_guest_ids_for_actor($pdo, $tripId, $actorId), true)) {
        json_out(['ok' => false, 'error' => 'Only the trip owner can enter expenses for a guest.'], 403);
    }
    return $payerId;
}

/** @return array{0: PDO, 1: array, 2: int, 3: array} */
function trip_guest_request(): array
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    require_group_trip($trip);
    assert_trip_is_active($trip);
    $actorId = (int) $me['id'];
    if (trip_member_role_for_user($pdo, (int) $trip['id'], $actorId, $trip) !== 'owner') {
        json_out(['ok' => false, 'error' => 'Only the trip owner can manage guests.'], 403);
    }
    enforce_rate_limit($pdo, 'trip_write_user', (string) $actorId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX, RATE_LIMIT_MUTATION_WINDOW_SEC);
    return [$pdo, $trip, $actorId, $body];
}

function add_trip_guest_action(): void
{
    [$pdo, $trip, $actorId, $body] = trip_guest_request();
    $tripId = (int) $trip['id'];
    $name = normalize_trip_guest_name($body['name'] ?? '');

    $pdo->beginTransaction();
    try {
        lock_active_trip_membership_scope($pdo, $tripId);
        require_locked_trip_member($pdo, $tripId, $actorId);
        $pdo->prepare(
            'INSERT INTO ' . table_name('users') . ' (nickname, credentials_required, device_token, guest_trip_id)
             VALUES (:nickname, 0, :device_token, :trip_id)'
        )->execute(['nickname' => $name, 'device_token' => bin2hex(random_bytes(32)), 'trip_id' => $tripId]);
        $guestId = (int) $pdo->lastInsertId();
        // A guest never holds up settling, since nobody can mark them ready.
        $pdo->prepare(
            'INSERT INTO ' . table_name('trip_members') . ' (trip_id, user_id, ready_to_settle, ready_to_settle_at)
             VALUES (:trip_id, :user_id, 1, UTC_TIMESTAMP())'
        )->execute(['trip_id' => $tripId, 'user_id' => $guestId]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    app_event($pdo, $actorId, 'trip.guest_added', 'trip', $tripId, $tripId, ['guest_id' => $guestId]);
    json_out(['ok' => true, 'guest' => ['id' => $guestId, 'nickname' => $name, 'is_guest' => true]]);
}

function rename_trip_guest_action(): void
{
    [$pdo, $trip, $actorId, $body] = trip_guest_request();
    $tripId = (int) $trip['id'];
    $guestId = (int) ($body['user_id'] ?? 0);
    $name = normalize_trip_guest_name($body['name'] ?? '');

    $stmt = $pdo->prepare(
        'UPDATE ' . table_name('users') . ' SET nickname = :nickname WHERE id = :id AND guest_trip_id = :trip_id'
    );
    $stmt->execute(['nickname' => $name, 'id' => $guestId, 'trip_id' => $tripId]);
    $found = $pdo->prepare('SELECT 1 FROM ' . table_name('users') . ' WHERE id = :id AND guest_trip_id = :trip_id');
    $found->execute(['id' => $guestId, 'trip_id' => $tripId]);
    if (!$found->fetchColumn()) {
        json_out(['ok' => false, 'error' => 'Guest not found.'], 404);
    }

    app_event($pdo, $actorId, 'trip.guest_renamed', 'trip', $tripId, $tripId, ['guest_id' => $guestId]);
    json_out(['ok' => true, 'guest' => ['id' => $guestId, 'nickname' => $name, 'is_guest' => true]]);
}
