<?php
declare(strict_types=1);

function search_users_action(): void
{
    $me = get_me();
    $pdo = db();
    $meId = (int) ($me['id'] ?? 0);
    if ($meId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid session user.'], 401);
    }

    enforce_rate_limit(
        $pdo,
        'search_user_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'search_user_actor',
        (string) $meId,
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    $limit = (int) ($_GET['limit'] ?? 20);
    if ($limit < 1) {
        $limit = 1;
    } elseif ($limit > 50) {
        $limit = 50;
    }

    $qRaw = trim((string) ($_GET['q'] ?? ''));
    if ($qRaw !== '' && str_length($qRaw) > 80) {
        $qRaw = function_exists('mb_substr')
            ? (string) mb_substr($qRaw, 0, 80)
            : substr($qRaw, 0, 80);
    }

    $excludeIds = ids_from_csv((string) ($_GET['exclude_ids'] ?? ''));
    $excludeIds[] = $meId;
    $excludeIds = normalize_user_ids($excludeIds);

    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $tripsTable = table_name('trips');

    $excludeClause = '';
    $excludeParams = [];
    if ($excludeIds) {
        $placeholders = [];
        foreach ($excludeIds as $index => $excludeId) {
            $key = 'exclude_' . $index;
            $placeholders[] = ':' . $key;
            $excludeParams[$key] = (int) $excludeId;
        }
        $excludeClause = ' AND u.id NOT IN (' . implode(',', $placeholders) . ')';
    }

    if ($qRaw === '') {
        $recentParams = array_merge(['me_id' => $meId], $excludeParams);
        $recentSql =
            'SELECT u.id, u.nickname, u.avatar_path, MAX(t.created_at) AS last_shared_at
             FROM ' . $tripMembersTable . ' tm_me
             JOIN ' . $tripMembersTable . ' tm_other
               ON tm_other.trip_id = tm_me.trip_id
              AND tm_other.user_id <> tm_me.user_id
             JOIN ' . $usersTable . ' u ON u.id = tm_other.user_id
             JOIN ' . $tripsTable . ' t ON t.id = tm_me.trip_id
             WHERE tm_me.user_id = :me_id' . $excludeClause . '
             GROUP BY u.id, u.nickname, u.avatar_path
             ORDER BY last_shared_at DESC, u.nickname ASC, u.id ASC
             LIMIT ' . $limit;

        $recentStmt = $pdo->prepare($recentSql);
        $recentStmt->execute($recentParams);
        $rows = $recentStmt->fetchAll();

        if (!$rows) {
            $fallbackSql =
                'SELECT u.id, u.nickname, u.avatar_path
                 FROM ' . $usersTable . ' u
                 WHERE 1=1' . $excludeClause . '
                 ORDER BY u.created_at DESC, u.id DESC
                 LIMIT ' . $limit;
            $fallbackStmt = $pdo->prepare($fallbackSql);
            $fallbackStmt->execute($excludeParams);
            $rows = $fallbackStmt->fetchAll();
        }
    } else {
        $queryLike = '%' . $qRaw . '%';
        $queryPrefix = $qRaw . '%';
        $searchParams = array_merge([
            'q_like_name' => $queryLike,
            'q_like_email' => $queryLike,
            'q_prefix' => $queryPrefix,
            'q_prefix_email' => $queryPrefix,
        ], $excludeParams);

        $searchSql =
            'SELECT
                u.id,
                u.nickname,
                u.avatar_path,
                CASE WHEN u.nickname LIKE :q_prefix THEN 0 ELSE 1 END AS rank_prefix,
                CASE WHEN u.email IS NOT NULL AND u.email LIKE :q_prefix_email THEN 0 ELSE 1 END AS rank_email
             FROM ' . $usersTable . ' u
             WHERE (u.nickname LIKE :q_like_name OR (u.email IS NOT NULL AND u.email LIKE :q_like_email))' . $excludeClause . '
             ORDER BY rank_prefix ASC, rank_email ASC, u.nickname ASC, u.id ASC
             LIMIT ' . $limit;

        $searchStmt = $pdo->prepare($searchSql);
        $searchStmt->execute($searchParams);
        $rows = $searchStmt->fetchAll();
    }

    foreach ($rows as &$row) {
        $row['id'] = (int) ($row['id'] ?? 0);
        $row['nickname'] = trim((string) ($row['nickname'] ?? ''));
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path'], $row['last_shared_at'], $row['rank_prefix'], $row['rank_email']);
    }
    unset($row);

    json_out([
        'ok' => true,
        'query' => $qRaw,
        'users' => $rows,
    ]);
}

function friend_pair_ids(int $leftUserId, int $rightUserId): array
{
    if ($leftUserId <= 0 || $rightUserId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user id.'], 400);
    }
    if ($leftUserId === $rightUserId) {
        json_out(['ok' => false, 'error' => 'You cannot invite yourself.'], 400);
    }
    if ($leftUserId < $rightUserId) {
        return [$leftUserId, $rightUserId];
    }
    return [$rightUserId, $leftUserId];
}

function friend_user_payload_from_row(array $row): array
{
    $userId = (int) ($row['user_id'] ?? $row['id'] ?? 0);
    $nickname = trim((string) ($row['nickname'] ?? ''));
    $avatarPath = trim((string) ($row['avatar_path'] ?? ''));

    return [
        'id' => $userId,
        'nickname' => $nickname,
        'avatar_url' => $avatarPath !== '' ? avatar_public_url($avatarPath) : null,
        'avatar_thumb_url' => $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null,
    ];
}

function find_public_user_by_id(PDO $pdo, int $userId): ?array
{
    if ($userId <= 0) {
        return null;
    }
    $usersTable = table_name('users');
    $stmt = $pdo->prepare(
        'SELECT id, nickname, avatar_path
         FROM ' . $usersTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $stmt->execute(['id' => $userId]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}

function resolve_notification_trip_id(PDO $pdo, int $primaryUserId, int $fallbackUserId = 0): int
{
    $candidateUserIds = normalize_user_ids([$primaryUserId, $fallbackUserId]);
    foreach ($candidateUserIds as $candidateUserId) {
        $trip = find_default_trip_for_user($pdo, (int) $candidateUserId);
        $tripId = (int) ($trip['id'] ?? 0);
        if ($tripId > 0) {
            return $tripId;
        }
    }

    $tripsTable = table_name('trips');
    $stmt = $pdo->query(
        'SELECT id
         FROM ' . $tripsTable . '
         ORDER BY id DESC
         LIMIT 1'
    );
    $tripId = (int) ($stmt->fetchColumn() ?: 0);
    return $tripId > 0 ? $tripId : 0;
}

function actor_display_name(array $me): string
{
    $nickname = trim((string) ($me['nickname'] ?? ''));
    if ($nickname !== '') {
        return $nickname;
    }

    $fullName = trim((string) ($me['full_name'] ?? ''));
    if ($fullName !== '') {
        return $fullName;
    }

    return 'Trip member';
}

function friends_list_action(): void
{
    $me = get_me();
    $pdo = db();
    $meId = (int) ($me['id'] ?? 0);
    if ($meId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid session user.'], 401);
    }

    $section = strtolower(trim((string) ($_GET['section'] ?? '')));
    if ($section === '') {
        friends_list_legacy_action($pdo, $meId);
        return;
    }
    friends_list_paged_action($pdo, $meId, $section);
}

function friends_list_legacy_action(PDO $pdo, int $meId): void
{
    $friendsTable = table_name('friends');
    $usersTable = table_name('users');

    $acceptedStmt = $pdo->prepare(
        'SELECT
            f.id AS request_id,
            f.requested_by,
            f.created_at,
            f.updated_at,
            u.id AS user_id,
            u.nickname,
            u.avatar_path
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id, f.user_b_id, f.user_a_id)
         WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)
           AND f.status = "accepted"
         ORDER BY u.nickname ASC, u.id ASC'
    );
    $acceptedStmt->execute([
        'join_me_id' => $meId,
        'where_me_a' => $meId,
        'where_me_b' => $meId,
    ]);
    $acceptedRows = $acceptedStmt->fetchAll();

    $pendingSentStmt = $pdo->prepare(
        'SELECT
            f.id AS request_id,
            f.requested_by,
            f.created_at,
            u.id AS user_id,
            u.nickname,
            u.avatar_path
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id, f.user_b_id, f.user_a_id)
         WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)
           AND f.status = "pending"
           AND f.requested_by = :requested_by
         ORDER BY f.created_at DESC, f.id DESC'
    );
    $pendingSentStmt->execute([
        'join_me_id' => $meId,
        'where_me_a' => $meId,
        'where_me_b' => $meId,
        'requested_by' => $meId,
    ]);
    $pendingSentRows = $pendingSentStmt->fetchAll();

    $pendingReceivedStmt = $pdo->prepare(
        'SELECT
            f.id AS request_id,
            f.requested_by,
            f.created_at,
            u.id AS user_id,
            u.nickname,
            u.avatar_path
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id, f.user_b_id, f.user_a_id)
         WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)
           AND f.status = "pending"
           AND f.requested_by <> :requested_by
         ORDER BY f.created_at DESC, f.id DESC'
    );
    $pendingReceivedStmt->execute([
        'join_me_id' => $meId,
        'where_me_a' => $meId,
        'where_me_b' => $meId,
        'requested_by' => $meId,
    ]);
    $pendingReceivedRows = $pendingReceivedStmt->fetchAll();

    $friends = [];
    foreach ($acceptedRows as $row) {
        $friends[] = array_merge(friend_user_payload_from_row((array) $row), [
            'since' => $row['created_at'] ?? null,
            'request_id' => (int) ($row['request_id'] ?? 0),
        ]);
    }

    $pendingSent = [];
    foreach ($pendingSentRows as $row) {
        $pendingSent[] = [
            'request_id' => (int) ($row['request_id'] ?? 0),
            'created_at' => $row['created_at'] ?? null,
            'to' => friend_user_payload_from_row((array) $row),
        ];
    }

    $pendingReceived = [];
    foreach ($pendingReceivedRows as $row) {
        $pendingReceived[] = [
            'request_id' => (int) ($row['request_id'] ?? 0),
            'created_at' => $row['created_at'] ?? null,
            'from' => friend_user_payload_from_row((array) $row),
        ];
    }

    json_out([
        'ok' => true,
        'friends' => $friends,
        'pending_sent' => $pendingSent,
        'pending_received' => $pendingReceived,
    ]);
}

function friends_list_counts(PDO $pdo, int $meId): array
{
    $friendsTable = table_name('friends');
    $baseWhere = '(f.user_a_id = :user_a_id OR f.user_b_id = :user_b_id)';

    $friendsCountStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $friendsTable . ' f
         WHERE ' . $baseWhere . '
           AND f.status = "accepted"'
    );
    $friendsCountStmt->execute([
        'user_a_id' => $meId,
        'user_b_id' => $meId,
    ]);
    $friendsCount = (int) ($friendsCountStmt->fetchColumn() ?: 0);

    $pendingSentStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $friendsTable . ' f
         WHERE ' . $baseWhere . '
           AND f.status = "pending"
           AND f.requested_by = :requested_by'
    );
    $pendingSentStmt->execute([
        'user_a_id' => $meId,
        'user_b_id' => $meId,
        'requested_by' => $meId,
    ]);
    $pendingSentCount = (int) ($pendingSentStmt->fetchColumn() ?: 0);

    $pendingReceivedStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $friendsTable . ' f
         WHERE ' . $baseWhere . '
           AND f.status = "pending"
           AND f.requested_by <> :requested_by'
    );
    $pendingReceivedStmt->execute([
        'user_a_id' => $meId,
        'user_b_id' => $meId,
        'requested_by' => $meId,
    ]);
    $pendingReceivedCount = (int) ($pendingReceivedStmt->fetchColumn() ?: 0);

    return [
        'friends' => $friendsCount,
        'pending_sent' => $pendingSentCount,
        'pending_received' => $pendingReceivedCount,
    ];
}

function friends_list_paged_action(PDO $pdo, int $meId, string $section): void
{
    if (
        $section !== 'friends' &&
        $section !== 'pending_sent' &&
        $section !== 'pending_received'
    ) {
        json_out(['ok' => false, 'error' => 'Unsupported friends section.'], 400);
    }

    $query = $_GET;
    $hasCursor = trim((string) ($query['cursor'] ?? '')) !== '';
    $cursorPayload = $hasCursor
        ? pagination_decode_cursor((string) $query['cursor'])
        : null;
    $hasOffset = array_key_exists('offset', $query);
    $offset = (!$hasCursor && $hasOffset)
        ? pagination_offset($query['offset'])
        : 0;
    $limit = pagination_limit($query['limit'] ?? 25, 25, 100);
    $limitPlusOne = $limit + 1;

    $friendsTable = table_name('friends');
    $usersTable = table_name('users');
    $params = [
        'join_me_id' => $meId,
        'where_me_a' => $meId,
        'where_me_b' => $meId,
    ];
    $where =
        'WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)';

    if ($section === 'friends') {
        $where .= ' AND f.status = "accepted"';
        $orderBy = 'ORDER BY u.nickname ASC, u.id ASC';
        if ($cursorPayload !== null) {
            $cursorNickname = trim((string) ($cursorPayload['nickname'] ?? ''));
            $cursorUserId = (int) ($cursorPayload['id'] ?? 0);
            if ($cursorUserId <= 0) {
                json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
            }
            $where .= '
               AND (
                    u.nickname > :cursor_nickname
                    OR (u.nickname = :cursor_nickname AND u.id > :cursor_user_id)
               )';
            $params['cursor_nickname'] = $cursorNickname;
            $params['cursor_user_id'] = $cursorUserId;
        }
    } else {
        $params['requested_by'] = $meId;
        if ($section === 'pending_sent') {
            $where .= '
               AND f.status = "pending"
               AND f.requested_by = :requested_by';
        } else {
            $where .= '
               AND f.status = "pending"
               AND f.requested_by <> :requested_by';
        }

        $orderBy = 'ORDER BY f.created_at DESC, f.id DESC';
        if ($cursorPayload !== null) {
            $cursorCreatedAt = trim((string) ($cursorPayload['created_at'] ?? ''));
            $cursorRequestId = (int) ($cursorPayload['id'] ?? 0);
            if ($cursorCreatedAt === '' || $cursorRequestId <= 0) {
                json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
            }
            $where .= '
               AND (
                    f.created_at < :cursor_created_at
                    OR (f.created_at = :cursor_created_at AND f.id < :cursor_request_id)
               )';
            $params['cursor_created_at'] = $cursorCreatedAt;
            $params['cursor_request_id'] = $cursorRequestId;
        }
    }

    $sql =
        'SELECT
            f.id AS request_id,
            f.requested_by,
            f.created_at,
            f.updated_at,
            u.id AS user_id,
            u.nickname,
            u.avatar_path
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id, f.user_b_id, f.user_a_id)
         ' . $where . '
         ' . $orderBy;

    if ($hasCursor) {
        $sql .= '
         LIMIT ' . $limitPlusOne;
    } else {
        $sql .= '
         LIMIT ' . $offset . ', ' . $limitPlusOne;
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();
    $hasMore = count($rows) > $limit;
    if ($hasMore) {
        $rows = array_slice($rows, 0, $limit);
    }

    $items = [];
    foreach ($rows as $row) {
        if ($section === 'friends') {
            $items[] = array_merge(friend_user_payload_from_row((array) $row), [
                'since' => $row['created_at'] ?? null,
                'request_id' => (int) ($row['request_id'] ?? 0),
            ]);
            continue;
        }
        $items[] = [
            'request_id' => (int) ($row['request_id'] ?? 0),
            'created_at' => $row['created_at'] ?? null,
            $section === 'pending_sent' ? 'to' : 'from' => friend_user_payload_from_row((array) $row),
        ];
    }

    $nextCursor = null;
    if ($hasMore && count($rows) > 0) {
        $last = $rows[count($rows) - 1];
        if ($section === 'friends') {
            $nextCursor = pagination_encode_cursor([
                'nickname' => (string) ($last['nickname'] ?? ''),
                'id' => (int) ($last['user_id'] ?? 0),
            ]);
        } else {
            $nextCursor = pagination_encode_cursor([
                'created_at' => (string) ($last['created_at'] ?? ''),
                'id' => (int) ($last['request_id'] ?? 0),
            ]);
        }
    }

    json_out([
        'ok' => true,
        'section' => $section,
        'items' => $items,
        'counts' => friends_list_counts($pdo, $meId),
        'pagination' => [
            'mode' => $hasCursor ? 'cursor' : 'offset',
            'limit' => $limit,
            'offset' => $hasCursor ? null : $offset,
            'has_more' => $hasMore,
            'next_cursor' => $nextCursor !== '' ? $nextCursor : null,
            'next_offset' => (!$hasCursor && $hasMore) ? ($offset + $limit) : null,
        ],
    ]);
}

function send_friend_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $targetUserId = (int) ($body['user_id'] ?? 0);
    if ($targetUserId <= 0) {
        json_out(['ok' => false, 'error' => 'user_id is required.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_invite_ip',
        client_ip_address(),
        RATE_LIMIT_FRIENDS_INVITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_invite_actor',
        (string) $meId,
        RATE_LIMIT_FRIENDS_INVITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    [$userAId, $userBId] = friend_pair_ids($meId, $targetUserId);
    $targetUser = find_public_user_by_id($pdo, $targetUserId);
    if (!$targetUser) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    $friendsTable = table_name('friends');
    $requestId = 0;
    $status = 'pending';
    $created = false;
    $autoAccepted = false;

    $pdo->beginTransaction();
    try {
        $existingStmt = $pdo->prepare(
            'SELECT id, requested_by, status
             FROM ' . $friendsTable . '
             WHERE user_a_id = :user_a_id
               AND user_b_id = :user_b_id
             LIMIT 1
             FOR UPDATE'
        );
        $existingStmt->execute([
            'user_a_id' => $userAId,
            'user_b_id' => $userBId,
        ]);
        $existing = $existingStmt->fetch();

        if (!$existing) {
            $insert = $pdo->prepare(
                'INSERT INTO ' . $friendsTable . '
                 (user_a_id, user_b_id, requested_by, status, responded_at)
                 VALUES (:user_a_id, :user_b_id, :requested_by, "pending", NULL)'
            );
            $insert->execute([
                'user_a_id' => $userAId,
                'user_b_id' => $userBId,
                'requested_by' => $meId,
            ]);
            $requestId = (int) $pdo->lastInsertId();
            $status = 'pending';
            $created = true;
        } else {
            $requestId = (int) ($existing['id'] ?? 0);
            $existingStatus = strtolower(trim((string) ($existing['status'] ?? '')));
            $existingRequestedBy = (int) ($existing['requested_by'] ?? 0);

            if ($existingStatus === 'accepted') {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Already friends.'], 409);
            }

            if ($existingStatus === 'pending' && $existingRequestedBy === $meId) {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Invite already sent.'], 409);
            }

            if ($existingStatus === 'pending' && $existingRequestedBy !== $meId) {
                $update = $pdo->prepare(
                    'UPDATE ' . $friendsTable . '
                     SET status = "accepted",
                         responded_at = UTC_TIMESTAMP()
                     WHERE id = :id'
                );
                $update->execute(['id' => $requestId]);
                $status = 'accepted';
                $autoAccepted = true;
            } else {
                $update = $pdo->prepare(
                    'UPDATE ' . $friendsTable . '
                     SET requested_by = :requested_by,
                         status = "pending",
                         responded_at = NULL
                     WHERE id = :id'
                );
                $update->execute([
                    'requested_by' => $meId,
                    'id' => $requestId,
                ]);
                $status = 'pending';
            }
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if ($autoAccepted && $requestId > 0) {
        $tripIdForNotification = resolve_notification_trip_id($pdo, $targetUserId, $meId);
        if ($tripIdForNotification > 0) {
            create_user_notification(
                $pdo,
                $tripIdForNotification,
                $targetUserId,
                'friend_invite_accepted',
                'Invite accepted',
                actor_display_name($me) . ' accepted your friend invite.',
                [
                    'request_id' => $requestId,
                    'from_user_id' => $meId,
                    'status' => 'accepted',
                ]
            );
        }
    }

    json_out([
        'ok' => true,
        'request_id' => $requestId,
        'status' => $status,
        'created' => $created,
        'auto_accepted' => $autoAccepted,
        'user' => friend_user_payload_from_row($targetUser),
    ]);
}

function respond_friend_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $requestId = (int) ($body['request_id'] ?? 0);
    if ($requestId <= 0) {
        json_out(['ok' => false, 'error' => 'request_id is required.'], 400);
    }
    $accept = (bool) ($body['accept'] ?? false);

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_respond_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_respond_actor',
        (string) $meId,
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    $friendsTable = table_name('friends');
    $request = null;
    $otherUserId = 0;
    $nextStatus = $accept ? 'accepted' : 'rejected';

    $pdo->beginTransaction();
    try {
        $select = $pdo->prepare(
            'SELECT id, user_a_id, user_b_id, requested_by, status
             FROM ' . $friendsTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $select->execute(['id' => $requestId]);
        $request = $select->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Request not found.'], 404);
        }

        $currentStatus = strtolower(trim((string) ($request['status'] ?? '')));
        if ($currentStatus !== 'pending') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Request is no longer pending.'], 409);
        }

        $userAId = (int) ($request['user_a_id'] ?? 0);
        $userBId = (int) ($request['user_b_id'] ?? 0);
        $requestedBy = (int) ($request['requested_by'] ?? 0);
        if ($meId !== $userAId && $meId !== $userBId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Access denied for this request.'], 403);
        }
        if ($requestedBy === $meId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Cannot respond to your own invite.'], 403);
        }

        $otherUserId = $requestedBy;
        $update = $pdo->prepare(
            'UPDATE ' . $friendsTable . '
             SET status = :status,
                 responded_at = UTC_TIMESTAMP()
             WHERE id = :id'
        );
        $update->execute([
            'status' => $nextStatus,
            'id' => $requestId,
        ]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if ($otherUserId > 0 && $requestId > 0) {
        $tripIdForNotification = resolve_notification_trip_id($pdo, $otherUserId, $meId);
        if ($tripIdForNotification > 0) {
            $type = $accept ? 'friend_invite_accepted' : 'friend_invite_rejected';
            $title = $accept ? 'Invite accepted' : 'Invite declined';
            $bodyText = $accept
                ? actor_display_name($me) . ' accepted your friend invite.'
                : actor_display_name($me) . ' declined your friend invite.';
            create_user_notification(
                $pdo,
                $tripIdForNotification,
                $otherUserId,
                $type,
                $title,
                $bodyText,
                [
                    'request_id' => $requestId,
                    'from_user_id' => $meId,
                    'status' => $nextStatus,
                ]
            );
        }
    }

    $otherUser = find_public_user_by_id($pdo, $otherUserId);
    json_out([
        'ok' => true,
        'request_id' => $requestId,
        'status' => $nextStatus,
        'user' => $otherUser ? friend_user_payload_from_row($otherUser) : null,
    ]);
}

function cancel_friend_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $requestId = (int) ($body['request_id'] ?? 0);
    if ($requestId <= 0) {
        json_out(['ok' => false, 'error' => 'request_id is required.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_cancel_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_cancel_actor',
        (string) $meId,
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    $friendsTable = table_name('friends');
    $otherUserId = 0;

    $pdo->beginTransaction();
    try {
        $select = $pdo->prepare(
            'SELECT id, user_a_id, user_b_id, requested_by, status
             FROM ' . $friendsTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $select->execute(['id' => $requestId]);
        $request = $select->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Request not found.'], 404);
        }

        $userAId = (int) ($request['user_a_id'] ?? 0);
        $userBId = (int) ($request['user_b_id'] ?? 0);
        $requestedBy = (int) ($request['requested_by'] ?? 0);
        if ($meId !== $userAId && $meId !== $userBId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Access denied for this request.'], 403);
        }
        if ($requestedBy !== $meId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Only sender can cancel this invite.'], 403);
        }

        $currentStatus = strtolower(trim((string) ($request['status'] ?? '')));
        if ($currentStatus !== 'pending') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Only pending invites can be cancelled.'], 409);
        }

        $otherUserId = $userAId === $meId ? $userBId : $userAId;
        $update = $pdo->prepare(
            'UPDATE ' . $friendsTable . '
             SET status = "rejected",
                 responded_at = UTC_TIMESTAMP()
             WHERE id = :id'
        );
        $update->execute(['id' => $requestId]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $otherUser = find_public_user_by_id($pdo, $otherUserId);
    json_out([
        'ok' => true,
        'request_id' => $requestId,
        'status' => 'rejected',
        'user' => $otherUser ? friend_user_payload_from_row($otherUser) : null,
    ]);
}

function remove_friend_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $targetUserId = (int) ($body['user_id'] ?? 0);
    if ($targetUserId <= 0) {
        json_out(['ok' => false, 'error' => 'user_id is required.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_remove_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_remove_actor',
        (string) $meId,
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    [$userAId, $userBId] = friend_pair_ids($meId, $targetUserId);
    $friendsTable = table_name('friends');

    $pdo->beginTransaction();
    try {
        $select = $pdo->prepare(
            'SELECT id, status
             FROM ' . $friendsTable . '
             WHERE user_a_id = :user_a_id
               AND user_b_id = :user_b_id
             LIMIT 1
             FOR UPDATE'
        );
        $select->execute([
            'user_a_id' => $userAId,
            'user_b_id' => $userBId,
        ]);
        $request = $select->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Friendship not found.'], 404);
        }

        $currentStatus = strtolower(trim((string) ($request['status'] ?? '')));
        if ($currentStatus !== 'accepted') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Only accepted friends can be removed.'], 409);
        }

        $update = $pdo->prepare(
            'UPDATE ' . $friendsTable . '
             SET requested_by = :requested_by,
                 status = "rejected",
                 responded_at = UTC_TIMESTAMP()
             WHERE id = :id'
        );
        $update->execute([
            'requested_by' => $meId,
            'id' => (int) ($request['id'] ?? 0),
        ]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $targetUser = find_public_user_by_id($pdo, $targetUserId);
    json_out([
        'ok' => true,
        'user' => $targetUser ? friend_user_payload_from_row($targetUser) : null,
    ]);
}
