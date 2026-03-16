<?php
declare(strict_types=1);

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
    $tripImageGroupBy = trips_image_column_available($pdo)
        ? ', t.image_path'
        : '';

    $stmt = $pdo->prepare(
        'SELECT
            t.id,
            t.name,
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
            t.name,
            t.status,
            t.created_by,
            t.created_at,
            t.ended_at,
            t.archived_at' . $tripImageGroupBy . '
         ORDER BY t.created_at DESC, t.id DESC'
    );
    $stmt->execute(['user_id' => $currentUserId]);
    $rows = $stmt->fetchAll();

    $activeTripId = null;
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
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
    $stmt = $pdo->prepare(
        'SELECT u.id, u.nickname, u.avatar_path
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => (int) $trip['id']]);
    $rows = $stmt->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path']);
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

    $name = trim((string) ($body['name'] ?? ''));
    if (str_length($name) < 2 || str_length($name) > 120) {
        json_out(['ok' => false, 'error' => 'Trip name must be 2-120 chars.'], 400);
    }
    ensure_text_has_no_links($name, 'Trip name');

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
        $insertTrip = $pdo->prepare(
            'INSERT INTO ' . $tripsTable . ' (name, created_by)
             VALUES (:name, :created_by)'
        );
        $insertTrip->execute([
            'name' => $name,
            'created_by' => $meId,
        ]);
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
    $hasImagePath = array_key_exists('image_path', $body);
    $removeImage = (bool) ($body['remove_image'] ?? false);
    if (($hasImagePath || $removeImage) && !$tripImageColumnAvailable) {
        json_out(['ok' => false, 'error' => 'Trip image support is not enabled on server yet. Run migration first.'], 409);
    }
    if (!$hasName && !$hasImagePath && !$removeImage) {
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

    if ($tripImageColumnAvailable) {
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

    $metaStmt = $pdo->prepare(
        'SELECT id, name, status, created_by, ended_at, archived_at, ' . $tripImageSelect . '
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

    $stmt = $pdo->prepare(
        'SELECT u.id, ' . $nameSelect . 'u.nickname, u.avatar_path
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
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path']);
    }
    unset($row);

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'users' => $rows,
    ]);
}
