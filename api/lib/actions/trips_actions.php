<?php
declare(strict_types=1);

function trip_invite_secret(): string
{
    return hash('sha256', auth_access_token_secret() . '|trip-invite');
}

function trip_invite_ttl_seconds(): int
{
    // 14 days by default for practical sharing.
    return 1_209_600;
}

function create_trip_invite_token(int $tripId, int $issuedByUserId): string
{
    if ($tripId <= 0 || $issuedByUserId <= 0) {
        throw new RuntimeException('Invalid invite token payload.');
    }

    $issuedAt = time();
    $expiresAt = $issuedAt + trip_invite_ttl_seconds();

    // Compact payload (trip_id, issued_at, expires_at) to keep links short.
    $payload = pack('N3', $tripId, $issuedAt, $expiresAt);
    $encodedPayload = base64url_encode($payload);
    // 128-bit truncated signature is sufficient and makes token shorter.
    $signature = substr(hash_hmac('sha256', $encodedPayload, trip_invite_secret()), 0, 32);
    return $encodedPayload . '.' . $signature;
}

function decode_trip_invite_token(string $token): array
{
    $parts = explode('.', trim($token), 2);
    if (count($parts) !== 2) {
        json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
    }

    $encodedPayload = trim((string) $parts[0]);
    $signature = trim((string) $parts[1]);
    if ($encodedPayload === '' || !preg_match('/^[a-f0-9]{32}$/', $signature)) {
        json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
    }

    $expected = substr(hash_hmac('sha256', $encodedPayload, trip_invite_secret()), 0, 32);
    if (!hash_equals($expected, $signature)) {
        json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
    }

    $decodedPayload = base64url_decode($encodedPayload);
    if (!is_string($decodedPayload) || strlen($decodedPayload) !== 12) {
        json_out(['ok' => false, 'error' => 'Invalid invite token payload.'], 400);
    }

    $unpacked = unpack('Ntrip_id/Niat/Nexp', $decodedPayload);
    if (!is_array($unpacked)) {
        json_out(['ok' => false, 'error' => 'Invalid invite token payload.'], 400);
    }

    $tripId = (int) ($unpacked['trip_id'] ?? 0);
    $issuedAt = (int) ($unpacked['iat'] ?? 0);
    $expiresAt = (int) ($unpacked['exp'] ?? 0);
    $now = time();
    $ttl = trip_invite_ttl_seconds();

    if ($tripId <= 0 || $issuedAt <= 0 || $expiresAt <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid invite token payload.'], 400);
    }
    if ($issuedAt > ($now + 300)) {
        json_out(['ok' => false, 'error' => 'Invite token is not valid yet.'], 400);
    }
    if (($expiresAt - $issuedAt) > $ttl || ($expiresAt - $issuedAt) <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid invite token expiry.'], 400);
    }
    if ($expiresAt < $now) {
        json_out(['ok' => false, 'error' => 'Invite token expired.'], 409);
    }

    return [
        'trip_id' => $tripId,
        'issued_by' => 0,
        'iat' => $issuedAt,
        'exp' => $expiresAt,
    ];
}

function trip_invite_trip_slug(string $tripName): string
{
    $normalized = trim((string) preg_replace('/\s+/u', ' ', $tripName));
    if ($normalized === '') {
        return 'trip';
    }

    $ascii = $normalized;
    if (function_exists('iconv')) {
        $converted = @iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $normalized);
        if (is_string($converted) && trim($converted) !== '') {
            $ascii = $converted;
        }
    }

    $slug = strtolower($ascii);
    $slug = (string) preg_replace('/[^a-z0-9]+/', '-', $slug);
    $slug = trim($slug, '-');
    if ($slug === '') {
        $slug = 'trip';
    }

    if (strlen($slug) > 40) {
        $slug = rtrim(substr($slug, 0, 40), '-');
    }
    return $slug !== '' ? $slug : 'trip';
}

function build_trip_invite_url(string $token, string $tripName = ''): string
{
    $base = trim((string) PUBLIC_BASE_URL);
    if ($base === '') {
        $base = 'https://splyto.egm.lv';
    }
    $base = rtrim($base, '/');
    $base = preg_replace('#/api$#', '', $base) ?: $base;

    $parts = explode('.', $token, 2);
    $signature = strtolower(trim((string) ($parts[1] ?? '')));
    $suffix = substr((string) preg_replace('/[^a-z0-9]/', '', $signature), 0, 6);
    if ($suffix === '') {
        $suffix = substr(hash('crc32b', $token), 0, 6);
    }
    $tripTag = trip_invite_trip_slug($tripName) . '-' . $suffix;

    $separator = strpos($base, '?') === false ? '?' : '&';
    return $base
        . $separator
        . 'trip=' . rawurlencode($tripTag)
        . '&i=' . rawurlencode($token);
}

function trips_action(): void
{
    $me = get_me();
    $pdo = db();
    $currentUserId = (int) ($me['id'] ?? 0);
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $settlementsTable = table_name('settlements');
    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 't.image_path'
        : 'NULL AS image_path';
    $tripCurrencySelect = trips_currency_column_available($pdo)
        ? 't.currency_code'
        : '\'' . default_trip_currency_code() . '\' AS currency_code';
    $tripImageGroupBy = trips_image_column_available($pdo)
        ? ', t.image_path'
        : '';
    $tripCurrencyGroupBy = trips_currency_column_available($pdo)
        ? ', t.currency_code'
        : '';

    $stmt = $pdo->prepare(
        'SELECT
            t.id,
            t.name,
            ' . $tripCurrencySelect . ',
            t.status,
            t.created_by,
            ' . $tripImageSelect . ',
            t.created_at,
            t.ended_at,
            t.archived_at,
            (
              SELECT COUNT(*)
              FROM ' . $settlementsTable . ' s
              WHERE s.trip_id = t.id
            ) AS settlements_total,
            (
              SELECT COUNT(*)
              FROM ' . $settlementsTable . ' s
              WHERE s.trip_id = t.id
                AND s.status = "confirmed"
            ) AS settlements_confirmed,
            (
              SELECT COALESCE(SUM(CAST(ROUND(e.amount * 100) AS SIGNED)), 0)
              FROM ' . $expensesTable . ' e
              WHERE e.trip_id = t.id
            ) AS total_amount_cents,
            (
              SELECT COALESCE(SUM(CAST(ROUND(e2.amount * 100) AS SIGNED)), 0)
              FROM ' . $expensesTable . ' e2
              WHERE e2.trip_id = t.id
                AND e2.paid_by = tm.user_id
            ) AS my_paid_cents,
            (
              SELECT COALESCE(SUM(ep.owed_cents), 0)
              FROM ' . $participantsTable . ' ep
              JOIN ' . $expensesTable . ' e3 ON e3.id = ep.expense_id
              WHERE e3.trip_id = t.id
                AND ep.user_id = tm.user_id
            ) AS my_owed_cents,
            COUNT(tm2.user_id) AS members_count
         FROM ' . $tripsTable . ' t
         JOIN ' . $tripMembersTable . ' tm ON tm.trip_id = t.id
         LEFT JOIN ' . $tripMembersTable . ' tm2 ON tm2.trip_id = t.id
         WHERE tm.user_id = :user_id
         GROUP BY
            t.id,
            tm.user_id,
            t.name,
            t.status,
            t.created_by,
            t.created_at,
            t.ended_at,
            t.archived_at' . $tripImageGroupBy . $tripCurrencyGroupBy . '
         ORDER BY t.created_at DESC, t.id DESC'
    );
    $stmt->execute(['user_id' => $currentUserId]);
    $rows = $stmt->fetchAll();

    $activeTripId = null;
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $row['currency_code'] = normalize_currency_code(
            $row['currency_code'] ?? default_trip_currency_code()
        );
        $row['status'] = normalize_trip_status($row['status'] ?? 'active');
        $row['created_by'] = $row['created_by'] !== null ? (int) $row['created_by'] : null;
        $imagePath = trim((string) ($row['image_path'] ?? ''));
        $row['image_url'] = $imagePath !== '' ? trip_image_public_url($imagePath) : null;
        $row['image_thumb_url'] = $imagePath !== '' ? trip_image_thumb_public_url($imagePath) : null;
        unset($row['image_path']);
        $row['members_count'] = (int) $row['members_count'];
        $row['ended_at'] = $row['ended_at'] ?: null;
        $row['archived_at'] = $row['archived_at'] ?: null;
        $row['settlements_total'] = (int) ($row['settlements_total'] ?? 0);
        $row['settlements_confirmed'] = (int) ($row['settlements_confirmed'] ?? 0);
        $row['total_amount_cents'] = (int) ($row['total_amount_cents'] ?? 0);
        $row['my_paid_cents'] = (int) ($row['my_paid_cents'] ?? 0);
        $row['my_owed_cents'] = (int) ($row['my_owed_cents'] ?? 0);
        $row['settlements_pending'] = max(
            0,
            $row['settlements_total'] - $row['settlements_confirmed']
        );

        // Keep trips list math consistent with workspace balances math.
        $computed = compute_trip_balance_data($pdo, (int) $row['id']);
        $stats = $computed['stats'] ?? [];
        if (is_array($stats) && isset($stats[$currentUserId]) && is_array($stats[$currentUserId])) {
            $myStats = $stats[$currentUserId];
            $row['my_paid_cents'] = (int) ($myStats['paid_cents'] ?? 0);
            $row['my_owed_cents'] = (int) ($myStats['owed_cents'] ?? 0);
        }
        $row['my_balance_cents'] = $row['my_owed_cents'] - $row['my_paid_cents'];
        $row['all_settled'] = $row['settlements_total'] > 0 && $row['settlements_total'] === $row['settlements_confirmed'];
        $row['ready_to_settle'] = $row['status'] === 'settling' && $row['settlements_pending'] > 0;
        if ($activeTripId === null && $row['status'] === 'active') {
            $activeTripId = (int) $row['id'];
        }
    }
    unset($row);

    $activeTrip = get_current_trip($pdo, $me, false);
    json_out([
        'ok' => true,
        'trips' => $rows,
        'active_trip_id' => $activeTripId ?? ($activeTrip ? (int) $activeTrip['id'] : null),
    ]);
}

function all_users_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, false);
    if (!$trip) {
        json_out([
            'ok' => true,
            'trip' => null,
            'users' => [[
                'id' => (int) $me['id'],
                'nickname' => (string) ($me['nickname'] ?? ''),
            ]],
        ]);
    }

    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $readySelect = trip_members_ready_columns_available($pdo)
        ? 'tm.ready_to_settle, tm.ready_to_settle_at, '
        : '1 AS ready_to_settle, NULL AS ready_to_settle_at, ';
    $stmt = $pdo->prepare(
        'SELECT u.id, ' . $readySelect . 'u.nickname, u.avatar_path
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => (int) $trip['id']]);
    $rows = $stmt->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $row['is_ready_to_settle'] = ((int) ($row['ready_to_settle'] ?? 0)) === 1;
        $row['ready_to_settle_at'] = $row['ready_to_settle_at'] ?: null;
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path'], $row['ready_to_settle']);
    }
    unset($row);
    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'users' => $rows,
    ]);
}


function create_trip_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripCurrencyColumnAvailable = trips_currency_column_available($pdo);

    $name = trim((string) ($body['name'] ?? ''));
    if (str_length($name) < 2 || str_length($name) > 120) {
        json_out(['ok' => false, 'error' => 'Trip name must be 2-120 chars.'], 400);
    }
    ensure_text_has_no_links($name, 'Trip name');
    $currencyCode = normalize_currency_code($body['currency_code'] ?? default_trip_currency_code());
    if (!$tripCurrencyColumnAvailable && $currencyCode !== default_trip_currency_code()) {
        json_out([
            'ok' => false,
            'error' => 'Trip currency support is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $meId = (int) ($me['id'] ?? 0);
    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) $meId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $memberIds = require_valid_user_ids($pdo, (array) ($body['member_ids'] ?? []), false);
    $memberIds[] = $meId;
    $memberIds = normalize_user_ids($memberIds);
    if (count($memberIds) < 1) {
        json_out(['ok' => false, 'error' => 'Trip must include at least one member.'], 400);
    }
    $creatorId = (int) ($me['id'] ?? 0);
    $creatorName = trim((string) ($me['nickname'] ?? ''));
    if ($creatorName === '') {
        $creatorName = 'Trip member';
    }

    $pdo->beginTransaction();
    try {
        if ($tripCurrencyColumnAvailable) {
            $insertTrip = $pdo->prepare(
                'INSERT INTO ' . $tripsTable . ' (name, currency_code, created_by)
                 VALUES (:name, :currency_code, :created_by)'
            );
            $insertTrip->execute([
                'name' => $name,
                'currency_code' => $currencyCode,
                'created_by' => $meId,
            ]);
        } else {
            $insertTrip = $pdo->prepare(
                'INSERT INTO ' . $tripsTable . ' (name, created_by)
                 VALUES (:name, :created_by)'
            );
            $insertTrip->execute([
                'name' => $name,
                'created_by' => $meId,
            ]);
        }
        $tripId = (int) $pdo->lastInsertId();

        $insertMember = $pdo->prepare(
            'INSERT INTO ' . $tripMembersTable . ' (trip_id, user_id)
             VALUES (:trip_id, :user_id)'
        );
        $notifyUserIds = [];
        foreach ($memberIds as $userId) {
            $insertMember->execute([
                'trip_id' => $tripId,
                'user_id' => (int) $userId,
            ]);
            if ((int) $userId !== $creatorId) {
                $notifyUserIds[] = (int) $userId;
            }
        }

        foreach ($notifyUserIds as $userId) {
            create_user_notification(
                $pdo,
                $tripId,
                $userId,
                'trip_added',
                'Added to trip',
                $creatorName . ' added you to trip "' . $name . '".',
                [
                    'trip_id' => $tripId,
                    'added_by_user_id' => $creatorId,
                ]
            );
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    json_out([
        'ok' => true,
        'trip' => [
            'id' => $tripId,
            'name' => $name,
            'currency_code' => $currencyCode,
            'status' => 'active',
            'created_by' => $meId,
            'ended_at' => null,
            'archived_at' => null,
            'image_url' => null,
            'image_thumb_url' => null,
            'members_count' => count($memberIds),
        ],
    ]);
}

function update_trip_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripImageColumnAvailable = trips_image_column_available($pdo);
    $tripCurrencyColumnAvailable = trips_currency_column_available($pdo);

    $tripId = (int) ($body['id'] ?? 0);
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Trip id is required.'], 400);
    }

    $trip = find_trip_for_user($pdo, (int) $me['id'], $tripId);
    if (!$trip) {
        json_out(['ok' => false, 'error' => 'Trip not found or access denied.'], 403);
    }
    $trip = normalize_trip_row($trip);

    $creatorId = (int) ($trip['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== (int) $me['id']) {
        json_out(['ok' => false, 'error' => 'Only trip creator can edit this trip.'], 403);
    }

    $hasName = array_key_exists('name', $body);
    $hasCurrencyCode = array_key_exists('currency_code', $body);
    $hasImagePath = array_key_exists('image_path', $body);
    $removeImage = (bool) ($body['remove_image'] ?? false);
    if (($hasImagePath || $removeImage) && !$tripImageColumnAvailable) {
        json_out(['ok' => false, 'error' => 'Trip image support is not enabled on server yet. Run migration first.'], 409);
    }
    if ($hasCurrencyCode && !$tripCurrencyColumnAvailable) {
        json_out(['ok' => false, 'error' => 'Trip currency support is not enabled on server yet. Run migration first.'], 409);
    }
    if (!$hasName && !$hasCurrencyCode && !$hasImagePath && !$removeImage) {
        json_out(['ok' => false, 'error' => 'No trip changes provided.'], 400);
    }

    $nextName = (string) ($trip['name'] ?? '');
    if ($hasName) {
        $name = trim((string) ($body['name'] ?? ''));
        if (str_length($name) < 2 || str_length($name) > 120) {
            json_out(['ok' => false, 'error' => 'Trip name must be 2-120 chars.'], 400);
        }
        ensure_text_has_no_links($name, 'Trip name');
        $nextName = $name;
    }
    $nextCurrencyCode = normalize_currency_code(
        $trip['currency_code'] ?? default_trip_currency_code()
    );
    if ($hasCurrencyCode) {
        $nextCurrencyCode = normalize_currency_code($body['currency_code'] ?? '');
    }

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) ((int) $me['id']),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $oldImagePath = trim((string) ($trip['image_path'] ?? ''));
    $nextImagePath = $oldImagePath;
    if ($hasImagePath) {
        $incomingImagePath = normalize_trip_image_path((string) ($body['image_path'] ?? ''), true);
        if ($incomingImagePath !== '') {
            $nextImagePath = $incomingImagePath;
        }
    }
    if ($removeImage) {
        $nextImagePath = '';
    }

    if ($tripImageColumnAvailable && $tripCurrencyColumnAvailable) {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name,
                 currency_code = :currency_code,
                 image_path = :image_path
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'currency_code' => $nextCurrencyCode,
            'image_path' => $nextImagePath !== '' ? $nextImagePath : null,
            'id' => $tripId,
        ]);
    } elseif ($tripCurrencyColumnAvailable) {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name,
                 currency_code = :currency_code
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'currency_code' => $nextCurrencyCode,
            'id' => $tripId,
        ]);
    } elseif ($tripImageColumnAvailable) {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name,
                 image_path = :image_path
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'image_path' => $nextImagePath !== '' ? $nextImagePath : null,
            'id' => $tripId,
        ]);
    } else {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'id' => $tripId,
        ]);
    }

    if ($tripImageColumnAvailable && $oldImagePath !== '' && $oldImagePath !== $nextImagePath) {
        delete_trip_image_file($oldImagePath);
    }

    $fresh = find_trip_for_user($pdo, (int) $me['id'], $tripId);
    if (!$fresh) {
        json_out(['ok' => false, 'error' => 'Trip not found after update.'], 404);
    }
    $fresh = normalize_trip_row($fresh);

    $countStmt = $pdo->prepare(
        'SELECT COUNT(*) AS c
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id'
    );
    $countStmt->execute(['trip_id' => $tripId]);
    $membersCount = (int) ($countStmt->fetchColumn() ?: 0);

    json_out([
        'ok' => true,
        'trip' => [
            'id' => (int) ($fresh['id'] ?? 0),
            'name' => (string) ($fresh['name'] ?? ''),
            'currency_code' => normalize_currency_code(
                $fresh['currency_code'] ?? default_trip_currency_code()
            ),
            'status' => normalize_trip_status($fresh['status'] ?? 'active'),
            'created_by' => array_key_exists('created_by', $fresh) && $fresh['created_by'] !== null
                ? (int) $fresh['created_by']
                : null,
            'ended_at' => array_key_exists('ended_at', $fresh) ? ($fresh['ended_at'] ?: null) : null,
            'archived_at' => array_key_exists('archived_at', $fresh) ? ($fresh['archived_at'] ?: null) : null,
            'image_url' => trim((string) ($fresh['image_path'] ?? '')) !== ''
                ? trip_image_public_url((string) $fresh['image_path'])
                : null,
            'image_thumb_url' => trim((string) ($fresh['image_path'] ?? '')) !== ''
                ? trip_image_thumb_public_url((string) $fresh['image_path'])
                : null,
            'members_count' => $membersCount,
        ],
    ]);
}

function delete_trip_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $tripsTable = table_name('trips');
    $expensesTable = table_name('expenses');

    $tripId = (int) ($body['id'] ?? 0);
    if ($tripId <= 0) {
        $tripId = parse_trip_id_from_request();
    }
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Trip id is required.'], 400);
    }

    $actorId = (int) ($me['id'] ?? 0);
    $trip = find_trip_for_user($pdo, $actorId, $tripId);
    if (!$trip) {
        json_out(['ok' => false, 'error' => 'Trip not found or access denied.'], 403);
    }
    $trip = normalize_trip_row($trip);

    $creatorId = (int) ($trip['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== $actorId) {
        json_out(['ok' => false, 'error' => 'Only trip creator can delete this trip.'], 403);
    }

    if (normalize_trip_status($trip['status'] ?? 'active') !== 'active') {
        json_out([
            'ok' => false,
            'error' => 'Only active trips can be deleted.',
        ], 409);
    }

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) $actorId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expensesCountStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $expensesTable . '
         WHERE trip_id = :trip_id'
    );
    $expensesCountStmt->execute(['trip_id' => $tripId]);
    $expensesCount = (int) ($expensesCountStmt->fetchColumn() ?: 0);
    if ($expensesCount > 0) {
        json_out([
            'ok' => false,
            'error' => 'Trip cannot be deleted because it already has expenses.',
        ], 409);
    }

    $delete = $pdo->prepare(
        'DELETE FROM ' . $tripsTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $delete->execute(['id' => $tripId]);
    if ((int) $delete->rowCount() < 1) {
        json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
    }

    $imagePath = trim((string) ($trip['image_path'] ?? ''));
    if ($imagePath !== '') {
        delete_trip_image_file($imagePath);
    }

    json_out([
        'ok' => true,
        'deleted' => true,
        'trip_id' => $tripId,
    ]);
}

function add_trip_members_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) $trip['id'];

    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 'image_path'
        : 'NULL AS image_path';
    $tripCurrencySelect = trips_currency_column_available($pdo)
        ? 'currency_code'
        : '\'' . default_trip_currency_code() . '\' AS currency_code';

    $metaStmt = $pdo->prepare(
        'SELECT id, name, ' . $tripCurrencySelect . ', status, created_by, ended_at, archived_at, ' . $tripImageSelect . '
         FROM ' . $tripsTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $metaStmt->execute(['id' => $tripId]);
    $tripMeta = $metaStmt->fetch();
    if (!$tripMeta) {
        json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
    }
    $tripMeta['status'] = normalize_trip_status($tripMeta['status'] ?? 'active');
    assert_trip_is_active($tripMeta);

    $creatorId = (int) ($tripMeta['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== (int) $me['id']) {
        json_out(['ok' => false, 'error' => 'Only trip creator can edit members.'], 403);
    }

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) ((int) $me['id']),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $memberIds = require_valid_user_ids($pdo, (array) ($body['member_ids'] ?? []), true);
    $memberIds = normalize_user_ids($memberIds);
    if (count($memberIds) < 1) {
        json_out(['ok' => false, 'error' => 'Pick at least one user.'], 400);
    }
    $actorId = (int) ($me['id'] ?? 0);
    $actorName = trim((string) ($me['nickname'] ?? ''));
    if ($actorName === '') {
        $actorName = 'Trip member';
    }
    $tripName = trim((string) ($tripMeta['name'] ?? ''));

    $pdo->beginTransaction();
    $addedCount = 0;
    try {
        $insert = $pdo->prepare(
            'INSERT IGNORE INTO ' . $tripMembersTable . ' (trip_id, user_id)
             VALUES (:trip_id, :user_id)'
        );
        $addedUserIds = [];
        foreach ($memberIds as $userId) {
            $insert->execute([
                'trip_id' => $tripId,
                'user_id' => (int) $userId,
            ]);
            $rowCount = (int) $insert->rowCount();
            $addedCount += $rowCount;
            if ($rowCount > 0 && (int) $userId !== $actorId) {
                $addedUserIds[] = (int) $userId;
            }
        }

        $tripLabel = $tripName !== '' ? $tripName : ('Trip #' . $tripId);
        foreach ($addedUserIds as $userId) {
            create_user_notification(
                $pdo,
                $tripId,
                $userId,
                'trip_member_added',
                'Added to trip',
                $actorName . ' added you to trip "' . $tripLabel . '".',
                [
                    'trip_id' => $tripId,
                    'added_by_user_id' => $actorId,
                ]
            );
        }
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $countStmt = $pdo->prepare(
        'SELECT COUNT(*) AS c
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id'
    );
    $countStmt->execute(['trip_id' => $tripId]);
    $membersCount = (int) ($countStmt->fetchColumn() ?: 0);

    json_out([
        'ok' => true,
        'trip' => [
            'id' => $tripId,
            'name' => (string) ($tripMeta['name'] ?? ''),
            'currency_code' => normalize_currency_code(
                $tripMeta['currency_code'] ?? default_trip_currency_code()
            ),
            'status' => (string) ($tripMeta['status'] ?? 'active'),
            'created_by' => $creatorId,
            'ended_at' => $tripMeta['ended_at'] ?: null,
            'archived_at' => $tripMeta['archived_at'] ?: null,
            'image_url' => trim((string) ($tripMeta['image_path'] ?? '')) !== ''
                ? trip_image_public_url((string) $tripMeta['image_path'])
                : null,
            'image_thumb_url' => trim((string) ($tripMeta['image_path'] ?? '')) !== ''
                ? trip_image_thumb_public_url((string) $tripMeta['image_path'])
                : null,
            'members_count' => $membersCount,
        ],
        'added_count' => $addedCount,
    ]);
}

function create_trip_invite_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
    }

    $status = normalize_trip_status($trip['status'] ?? 'active');
    if ($status !== 'active') {
        json_out(['ok' => false, 'error' => 'Invite links are available only for active trips.'], 409);
    }

    $creatorId = (int) ($trip['created_by'] ?? 0);
    $actorId = (int) ($me['id'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== $actorId) {
        json_out(['ok' => false, 'error' => 'Only trip creator can generate invite links.'], 403);
    }

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) $actorId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $token = create_trip_invite_token($tripId, $actorId);
    $expiresAt = time() + trip_invite_ttl_seconds();

    json_out([
        'ok' => true,
        'trip_id' => $tripId,
        'invite_token' => $token,
        'invite_url' => build_trip_invite_url($token, (string) ($trip['name'] ?? '')),
        'expires_in_sec' => trip_invite_ttl_seconds(),
        'expires_at' => gmdate('Y-m-d H:i:s', $expiresAt),
    ]);
}

function join_trip_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $token = trim((string) ($body['invite_token'] ?? ''));
    if ($token === '') {
        json_out(['ok' => false, 'error' => 'invite_token is required.'], 400);
    }

    $decoded = decode_trip_invite_token($token);
    $tripId = (int) ($decoded['trip_id'] ?? 0);
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
    }

    $pdo = db();
    $actorId = (int) ($me['id'] ?? 0);
    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) $actorId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 't.image_path'
        : 'NULL AS image_path';

    $pdo->beginTransaction();
    try {
        $tripStmt = $pdo->prepare(
            'SELECT
                t.id,
                t.name,
                t.status,
                t.created_by,
                t.ended_at,
                t.archived_at,
                ' . $tripImageSelect . '
             FROM ' . $tripsTable . ' t
             WHERE t.id = :trip_id
             LIMIT 1
             FOR UPDATE'
        );
        $tripStmt->execute(['trip_id' => $tripId]);
        $trip = $tripStmt->fetch();
        if (!$trip) {
            json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
        }

        $status = normalize_trip_status($trip['status'] ?? 'active');
        if ($status !== 'active') {
            json_out(['ok' => false, 'error' => 'Trip is closed.'], 409);
        }

        $memberStmt = $pdo->prepare(
            'SELECT user_id
             FROM ' . $tripMembersTable . '
             WHERE trip_id = :trip_id
               AND user_id = :user_id
             LIMIT 1'
        );
        $memberStmt->execute([
            'trip_id' => $tripId,
            'user_id' => $actorId,
        ]);
        $alreadyMember = (bool) $memberStmt->fetch();

        if (!$alreadyMember) {
            $insertMember = $pdo->prepare(
                'INSERT INTO ' . $tripMembersTable . ' (trip_id, user_id)
                 VALUES (:trip_id, :user_id)'
            );
            $insertMember->execute([
                'trip_id' => $tripId,
                'user_id' => $actorId,
            ]);
        }

        $pdo->commit();

        $freshTrip = find_trip_for_user($pdo, $actorId, $tripId);
        if (!$freshTrip) {
            json_out(['ok' => false, 'error' => 'Trip not found after join.'], 404);
        }

        json_out([
            'ok' => true,
            'already_member' => $alreadyMember,
            'trip' => build_trip_payload(normalize_trip_row($freshTrip)),
        ]);
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
}

function users_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $readySelect = trip_members_ready_columns_available($pdo)
        ? 'tm.ready_to_settle, tm.ready_to_settle_at, '
        : '1 AS ready_to_settle, NULL AS ready_to_settle_at, ';

    $stmt = $pdo->prepare(
        'SELECT u.id, ' . $nameSelect . $readySelect . 'u.nickname, u.avatar_path
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => (int) $trip['id']]);
    $rows = $stmt->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $firstName = normalize_me_name_value($row['first_name'] ?? null);
        $lastName = normalize_me_name_value($row['last_name'] ?? null);
        $displayName = combine_full_name($firstName, $lastName);
        $row['first_name'] = $firstName;
        $row['last_name'] = $lastName;
        $row['display_name'] = $displayName !== null
            ? $displayName
            : trim((string) ($row['nickname'] ?? ''));
        $row['is_ready_to_settle'] = ((int) ($row['ready_to_settle'] ?? 0)) === 1;
        $row['ready_to_settle_at'] = $row['ready_to_settle_at'] ?: null;
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path'], $row['ready_to_settle']);
    }
    unset($row);

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'users' => $rows,
    ]);
}
