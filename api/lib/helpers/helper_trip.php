<?php
declare(strict_types=1);

function trips_image_column_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $tripsTable = DB_TABLE_PREFIX . 'trips';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $tripsTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name = \'image_path\''
        );
        $stmt->execute(['table_name' => $tripsTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function trips_date_range_columns_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $tripsTable = DB_TABLE_PREFIX . 'trips';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $tripsTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name IN (\'date_from\', \'date_to\')'
        );
        $stmt->execute(['table_name' => $tripsTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 2;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function trip_members_ready_columns_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $tripMembersTable = DB_TABLE_PREFIX . 'trip_members';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $tripMembersTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name IN (\'ready_to_settle\', \'ready_to_settle_at\')'
        );
        $stmt->execute(['table_name' => $tripMembersTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 2;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function normalize_trip_status($value): string
{
    $raw = strtolower(trim((string) $value));
    if ($raw === 'settling' || $raw === 'archived') {
        return $raw;
    }
    return 'active';
}

function build_trip_payload(array $trip): array
{
    $imagePath = trim((string) ($trip['image_path'] ?? ''));
    $currencyCode = normalize_currency_code($trip['currency_code'] ?? default_trip_currency_code());
    return [
        'id' => (int) ($trip['id'] ?? 0),
        'name' => (string) ($trip['name'] ?? ''),
        'currency_code' => $currencyCode,
        'status' => normalize_trip_status($trip['status'] ?? 'active'),
        'created_by' => array_key_exists('created_by', $trip) && $trip['created_by'] !== null
            ? (int) $trip['created_by']
            : null,
        'date_from' => array_key_exists('date_from', $trip) ? ($trip['date_from'] ?: null) : null,
        'date_to' => array_key_exists('date_to', $trip) ? ($trip['date_to'] ?: null) : null,
        'ended_at' => array_key_exists('ended_at', $trip) ? ($trip['ended_at'] ?: null) : null,
        'archived_at' => array_key_exists('archived_at', $trip) ? ($trip['archived_at'] ?: null) : null,
        'image_url' => $imagePath !== '' ? trip_image_public_url($imagePath) : null,
        'image_thumb_url' => $imagePath !== '' ? trip_image_thumb_public_url($imagePath) : null,
    ];
}

function normalize_trip_row(array $trip): array
{
    $trip['id'] = (int) ($trip['id'] ?? 0);
    $trip['name'] = (string) ($trip['name'] ?? '');
    $trip['currency_code'] = normalize_currency_code(
        $trip['currency_code'] ?? default_trip_currency_code()
    );
    $trip['status'] = normalize_trip_status($trip['status'] ?? 'active');
    $trip['created_by'] = array_key_exists('created_by', $trip) && $trip['created_by'] !== null
        ? (int) $trip['created_by']
        : null;
    $trip['date_from'] = array_key_exists('date_from', $trip) ? ($trip['date_from'] ?: null) : null;
    $trip['date_to'] = array_key_exists('date_to', $trip) ? ($trip['date_to'] ?: null) : null;
    $trip['ended_at'] = array_key_exists('ended_at', $trip) ? ($trip['ended_at'] ?: null) : null;
    $trip['archived_at'] = array_key_exists('archived_at', $trip) ? ($trip['archived_at'] ?: null) : null;
    $trip['image_path'] = trim((string) ($trip['image_path'] ?? ''));
    return $trip;
}

function assert_trip_is_active(array $trip): void
{
    $status = normalize_trip_status($trip['status'] ?? 'active');
    if ($status !== 'active') {
        json_out([
            'ok' => false,
            'error' => 'Trip is closed for editing.',
            'trip' => build_trip_payload($trip),
        ], 409);
    }
}

function create_user_notification(
    PDO $pdo,
    int $tripId,
    int $userId,
    string $type,
    string $title,
    string $body,
    array $payload = []
): void {
    if ($tripId <= 0 || $userId <= 0) {
        return;
    }

    $notificationsTable = table_name('notifications');
    $normalizedType = trim($type) !== '' ? trim($type) : 'info';
    $normalizedTitle = trim($title) !== '' ? trim($title) : 'Notification';
    $normalizedBody = trim($body);
    $payloadJson = null;
    if ($payload) {
        $encoded = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if (is_string($encoded) && $encoded !== '') {
            $payloadJson = $encoded;
        }
    }

    $insert = $pdo->prepare(
        'INSERT INTO ' . $notificationsTable . '
         (trip_id, user_id, type, title, body, payload_json, is_read)
         VALUES (:trip_id, :user_id, :type, :title, :body, :payload_json, 0)'
    );
    $insert->execute([
        'trip_id' => $tripId,
        'user_id' => $userId,
        'type' => $normalizedType,
        'title' => $normalizedTitle,
        'body' => $normalizedBody,
        'payload_json' => $payloadJson,
    ]);

    if (!push_should_queue_notification_type($normalizedType)) {
        return;
    }

    if (!user_allows_push_notification($pdo, $userId, $normalizedType)) {
        return;
    }

    try {
        queue_push_notification(
            $pdo,
            $userId,
            $tripId,
            $normalizedType,
            $normalizedTitle,
            $normalizedBody,
            $payload,
            (int) $pdo->lastInsertId()
        );
    } catch (Throwable $error) {
        log_api_exception($error, 'queue_push_notification');
    }
}

function parse_trip_id_from_request(): int
{
    $raw = $_SERVER['HTTP_X_TRIP_ID'] ?? ($_GET['trip_id'] ?? '');
    if (!is_scalar($raw)) {
        return 0;
    }
    $tripId = (int) trim((string) $raw);
    return $tripId > 0 ? $tripId : 0;
}

function find_trip_for_user(PDO $pdo, int $userId, int $tripId): ?array
{
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 't.image_path'
        : 'NULL AS image_path';
    $tripCurrencySelect = trips_currency_column_available($pdo)
        ? 't.currency_code'
        : '"' . default_trip_currency_code() . '" AS currency_code';
    $tripDateFromSelect = trips_date_range_columns_available($pdo)
        ? 't.date_from'
        : 'NULL AS date_from';
    $tripDateToSelect = trips_date_range_columns_available($pdo)
        ? 't.date_to'
        : 'NULL AS date_to';
    $stmt = $pdo->prepare(
        'SELECT t.id, t.name, ' . $tripCurrencySelect . ', t.status, t.created_by, ' . $tripDateFromSelect . ', ' . $tripDateToSelect . ', t.ended_at, t.archived_at, ' . $tripImageSelect . '
         FROM ' . $tripsTable . ' t
         JOIN ' . $tripMembersTable . ' tm ON tm.trip_id = t.id
         WHERE t.id = :trip_id AND tm.user_id = :user_id
         LIMIT 1'
    );
    $stmt->execute([
        'trip_id' => $tripId,
        'user_id' => $userId,
    ]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}

function find_default_trip_for_user(PDO $pdo, int $userId): ?array
{
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 't.image_path'
        : 'NULL AS image_path';
    $tripCurrencySelect = trips_currency_column_available($pdo)
        ? 't.currency_code'
        : '"' . default_trip_currency_code() . '" AS currency_code';
    $tripDateFromSelect = trips_date_range_columns_available($pdo)
        ? 't.date_from'
        : 'NULL AS date_from';
    $tripDateToSelect = trips_date_range_columns_available($pdo)
        ? 't.date_to'
        : 'NULL AS date_to';
    $stmt = $pdo->prepare(
        'SELECT t.id, t.name, ' . $tripCurrencySelect . ', t.status, t.created_by, ' . $tripDateFromSelect . ', ' . $tripDateToSelect . ', t.ended_at, t.archived_at, ' . $tripImageSelect . '
         FROM ' . $tripsTable . ' t
         JOIN ' . $tripMembersTable . ' tm ON tm.trip_id = t.id
         WHERE tm.user_id = :user_id
         ORDER BY t.created_at DESC, t.id DESC
         LIMIT 1'
    );
    $stmt->execute(['user_id' => $userId]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}

function get_current_trip(PDO $pdo, array $me, bool $require = true): ?array
{
    $userId = (int) ($me['id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid session user.'], 401);
    }

    $tripId = parse_trip_id_from_request();
    if ($tripId > 0) {
        $trip = find_trip_for_user($pdo, $userId, $tripId);
        if ($trip) {
            return normalize_trip_row($trip);
        }
        json_out(['ok' => false, 'error' => 'Trip not found or access denied.'], 403);
    }

    $trip = find_default_trip_for_user($pdo, $userId);
    if ($trip) {
        return normalize_trip_row($trip);
    }

    if ($require) {
        json_out(['ok' => false, 'error' => 'No trip found. Create a trip first.'], 400);
    }
    return null;
}

function require_valid_trip_member_ids(PDO $pdo, int $tripId, array $ids, bool $requireAtLeastOne = true): array
{
    $ids = normalize_user_ids($ids);
    if ($requireAtLeastOne && count($ids) < 1) {
        json_out(['ok' => false, 'error' => 'Pick at least one user.'], 400);
    }
    if (!$ids) {
        return [];
    }

    $tripMembersTable = table_name('trip_members');
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $sql = 'SELECT user_id AS id
            FROM ' . $tripMembersTable . '
            WHERE trip_id = ? AND user_id IN (' . $placeholders . ')';
    $stmt = $pdo->prepare($sql);
    $stmt->execute(array_merge([$tripId], $ids));
    $existing = array_map('intval', array_column($stmt->fetchAll(), 'id'));
    sort($existing);

    $copy = $ids;
    sort($copy);
    if ($existing !== $copy) {
        json_out(['ok' => false, 'error' => 'Some selected users are not in this trip.'], 400);
    }

    return $ids;
}

function all_trip_member_ids(PDO $pdo, int $tripId): array
{
    $tripMembersTable = table_name('trip_members');
    $stmt = $pdo->prepare(
        'SELECT user_id
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id
         ORDER BY joined_at ASC, user_id ASC'
    );
    $stmt->execute(['trip_id' => $tripId]);
    $ids = array_map(static fn(array $row): int => (int) $row['user_id'], $stmt->fetchAll());
    $ids = normalize_user_ids($ids);
    if (count($ids) < 1) {
        json_out(['ok' => false, 'error' => 'Trip has no members.'], 400);
    }
    return $ids;
}
