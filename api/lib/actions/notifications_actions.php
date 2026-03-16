<?php
declare(strict_types=1);

function list_notifications_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, false);
    if (!$trip) {
        json_out([
            'ok' => true,
            'trip' => null,
            'unread_count' => 0,
            'notifications' => [],
        ]);
    }
    $tripId = (int) $trip['id'];
    $notificationsTable = table_name('notifications');
    $query = $_GET;
    $hasCursor = trim((string) ($query['cursor'] ?? '')) !== '';
    $cursorId = 0;
    if ($hasCursor) {
        $cursorPayload = pagination_decode_cursor((string) $query['cursor']);
        $cursorId = (int) ($cursorPayload['id'] ?? 0);
        if ($cursorId <= 0) {
            json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
        }
    }
    $offset = (!$hasCursor && array_key_exists('offset', $query))
        ? pagination_offset($query['offset'])
        : 0;
    $defaultLimit = pagination_requested($query) ? 30 : 50;
    $limit = pagination_limit($query['limit'] ?? $defaultLimit, $defaultLimit, 200);
    $limitPlusOne = $limit + 1;

    $sql =
        'SELECT id, trip_id, user_id, type, title, body, payload_json, is_read, read_at, created_at
         FROM ' . $notificationsTable . '
         WHERE user_id = :user_id
           AND trip_id = :trip_id';
    $params = [
        'user_id' => (int) $me['id'],
        'trip_id' => $tripId,
    ];
    if ($hasCursor) {
        $sql .= '
           AND id < :cursor_id';
        $params['cursor_id'] = $cursorId;
    }
    $sql .= '
         ORDER BY id DESC';
    if ($hasCursor) {
        $sql .= '
         LIMIT ' . $limitPlusOne;
    } else {
        $sql .= '
         LIMIT ' . $offset . ', ' . $limitPlusOne;
    }

    $rowsStmt = $pdo->prepare($sql);
    $rowsStmt->execute($params);
    $rows = $rowsStmt->fetchAll();
    $hasMore = count($rows) > $limit;
    if ($hasMore) {
        $rows = array_slice($rows, 0, $limit);
    }

    $unreadStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $notificationsTable . '
         WHERE user_id = :user_id
           AND trip_id = :trip_id
           AND is_read = 0'
    );
    $unreadStmt->execute([
        'user_id' => (int) $me['id'],
        'trip_id' => $tripId,
    ]);
    $unreadCount = (int) ($unreadStmt->fetchColumn() ?: 0);

    $notifications = [];
    foreach ($rows as $row) {
        $payload = null;
        $rawPayload = (string) ($row['payload_json'] ?? '');
        if ($rawPayload !== '') {
            $decoded = json_decode($rawPayload, true);
            if (is_array($decoded)) {
                $payload = $decoded;
            }
        }

        $notifications[] = [
            'id' => (int) ($row['id'] ?? 0),
            'trip_id' => (int) ($row['trip_id'] ?? 0),
            'type' => (string) ($row['type'] ?? 'info'),
            'title' => (string) ($row['title'] ?? ''),
            'body' => (string) ($row['body'] ?? ''),
            'payload' => $payload,
            'is_read' => ((int) ($row['is_read'] ?? 0)) === 1,
            'read_at' => $row['read_at'] ?? null,
            'created_at' => $row['created_at'] ?? null,
        ];
    }

    $nextCursor = null;
    if ($hasMore && count($rows) > 0) {
        $last = $rows[count($rows) - 1];
        $nextCursor = pagination_encode_cursor([
            'id' => (int) ($last['id'] ?? 0),
        ]);
    }

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'unread_count' => $unreadCount,
        'notifications' => $notifications,
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

function count_pending_friend_invites(PDO $pdo, int $userId): int
{
    if ($userId <= 0) {
        return 0;
    }

    $friendsTable = table_name('friends');
    $stmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $friendsTable . ' f
         WHERE (f.user_a_id = :user_id_a OR f.user_b_id = :user_id_b)
           AND f.status = "pending"
           AND f.requested_by <> :user_id_sender'
    );
    $stmt->execute([
        'user_id_a' => $userId,
        'user_id_b' => $userId,
        'user_id_sender' => $userId,
    ]);

    return (int) ($stmt->fetchColumn() ?: 0);
}

function list_pending_friend_invite_notifications(PDO $pdo, int $userId, int $limit = 80): array
{
    if ($userId <= 0) {
        return [];
    }

    if ($limit < 1) {
        $limit = 1;
    } elseif ($limit > 200) {
        $limit = 200;
    }

    $friendsTable = table_name('friends');
    $usersTable = table_name('users');
    $stmt = $pdo->prepare(
        'SELECT
            f.id AS request_id,
            f.created_at,
            u.id AS from_user_id,
            u.nickname AS from_nickname
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u ON u.id = f.requested_by
         WHERE (f.user_a_id = :user_id_a OR f.user_b_id = :user_id_b)
           AND f.status = "pending"
           AND f.requested_by <> :user_id_sender
         ORDER BY f.created_at DESC, f.id DESC
         LIMIT ' . $limit
    );
    $stmt->execute([
        'user_id_a' => $userId,
        'user_id_b' => $userId,
        'user_id_sender' => $userId,
    ]);

    $rows = $stmt->fetchAll();
    $notifications = [];
    foreach ($rows as $row) {
        $requestId = (int) ($row['request_id'] ?? 0);
        if ($requestId <= 0) {
            continue;
        }
        $fromUserId = (int) ($row['from_user_id'] ?? 0);
        $fromName = trim((string) ($row['from_nickname'] ?? ''));
        if ($fromName === '') {
            $fromName = 'Trip member';
        }

        $notifications[] = [
            'id' => -$requestId,
            'trip_id' => 0,
            'trip_name' => null,
            'type' => 'friend_invite',
            'title' => 'Friend invite',
            'body' => $fromName . ' sent you a friend invite.',
            'payload' => [
                'request_id' => $requestId,
                'from_user_id' => $fromUserId,
            ],
            'is_read' => false,
            'read_at' => null,
            'created_at' => $row['created_at'] ?? null,
        ];
    }

    return $notifications;
}

function list_notifications_global_action(): void
{
    $me = get_me();
    $pdo = db();
    $userId = (int) ($me['id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid session user.'], 401);
    }

    $pagedRaw = strtolower(trim((string) ($_GET['paged'] ?? '0')));
    $isPaged = $pagedRaw === '1' || $pagedRaw === 'true' || $pagedRaw === 'yes';
    if ($isPaged) {
        list_notifications_global_paged_action($pdo, $userId);
        return;
    }
    list_notifications_global_legacy_action($pdo, $userId);
}

function list_notifications_global_legacy_action(PDO $pdo, int $userId): void
{
    $limit = pagination_limit($_GET['limit'] ?? 80, 80, 200);
    $notifications = load_global_notifications_page(
        $pdo,
        $userId,
        $limit,
        null,
        0
    );
    $pendingFriendInvites = count_pending_friend_invites($pdo, $userId);
    $friendNotifications = list_pending_friend_invite_notifications($pdo, $userId, $limit);
    $merged = array_merge($notifications['items'], $friendNotifications);
    usort(
        $merged,
        static function (array $a, array $b): int {
            $aTime = strtotime((string) ($a['created_at'] ?? '')) ?: 0;
            $bTime = strtotime((string) ($b['created_at'] ?? '')) ?: 0;
            if ($aTime !== $bTime) {
                return $bTime <=> $aTime;
            }
            $aId = (int) ($a['id'] ?? 0);
            $bId = (int) ($b['id'] ?? 0);
            return $bId <=> $aId;
        }
    );
    if (count($merged) > $limit) {
        $merged = array_slice($merged, 0, $limit);
    }

    json_out([
        'ok' => true,
        'unread_count' => $notifications['unread_notifications_count'] + $pendingFriendInvites,
        'unread_notifications_count' => $notifications['unread_notifications_count'],
        'pending_friend_invites_count' => $pendingFriendInvites,
        'notifications' => $merged,
    ]);
}

function list_notifications_global_paged_action(PDO $pdo, int $userId): void
{
    $query = $_GET;
    $hasCursor = trim((string) ($query['cursor'] ?? '')) !== '';
    $cursorId = null;
    if ($hasCursor) {
        $cursorPayload = pagination_decode_cursor((string) $query['cursor']);
        $cursorId = (int) ($cursorPayload['id'] ?? 0);
        if ($cursorId <= 0) {
            json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
        }
    }
    $offset = (!$hasCursor && array_key_exists('offset', $query))
        ? pagination_offset($query['offset'])
        : 0;
    $limit = pagination_limit($query['limit'] ?? 50, 50, 200);
    $includeFriendInvites = !$hasCursor && $offset === 0;
    $friendNotifications = $includeFriendInvites
        ? list_pending_friend_invite_notifications($pdo, $userId, min(20, $limit))
        : [];
    $friendCount = count($friendNotifications);

    $dbLimit = $limit;
    if ($includeFriendInvites) {
        $dbLimit = max(0, $limit - $friendCount);
    }

    $result = [
        'items' => [],
        'has_more' => false,
        'next_cursor' => null,
        'unread_notifications_count' => 0,
    ];
    if ($dbLimit > 0) {
        $result = load_global_notifications_page(
            $pdo,
            $userId,
            $dbLimit,
            $cursorId,
            $offset
        );
    } else {
        $probe = load_global_notifications_page(
            $pdo,
            $userId,
            1,
            null,
            0
        );
        $probeFirstId = 0;
        if (!empty($probe['items'])) {
            $probeFirstId = (int) (($probe['items'][0]['id'] ?? 0));
        }
        $result = [
            'items' => [],
            'has_more' => $probeFirstId > 0,
            'next_cursor' => $probeFirstId > 0
                ? pagination_encode_cursor(['id' => $probeFirstId + 1])
                : null,
            'unread_notifications_count' => (int) ($probe['unread_notifications_count'] ?? 0),
        ];
    }

    $pendingFriendInvites = count_pending_friend_invites($pdo, $userId);
    $items = $includeFriendInvites
        ? array_merge($friendNotifications, $result['items'])
        : $result['items'];
    if (count($items) > $limit) {
        $items = array_slice($items, 0, $limit);
    }

    json_out([
        'ok' => true,
        'unread_count' => $result['unread_notifications_count'] + $pendingFriendInvites,
        'unread_notifications_count' => $result['unread_notifications_count'],
        'pending_friend_invites_count' => $pendingFriendInvites,
        'notifications' => $items,
        'pagination' => [
            'mode' => $hasCursor ? 'cursor' : 'offset',
            'limit' => $limit,
            'offset' => $hasCursor ? null : $offset,
            'has_more' => $result['has_more'],
            'next_cursor' => $result['next_cursor'],
            'next_offset' => (!$hasCursor && $result['has_more'])
                ? ($offset + $limit)
                : null,
        ],
    ]);
}

function load_global_notifications_page(
    PDO $pdo,
    int $userId,
    int $limit,
    ?int $cursorId,
    int $offset
): array {
    $notificationsTable = table_name('notifications');
    $tripsTable = table_name('trips');
    $limit = pagination_limit($limit, 50, 200);
    $limitPlusOne = $limit + 1;

    $sql =
        'SELECT
            n.id,
            n.trip_id,
            n.user_id,
            n.type,
            n.title,
            n.body,
            n.payload_json,
            n.is_read,
            n.read_at,
            n.created_at,
            t.name AS trip_name
         FROM ' . $notificationsTable . ' n
         LEFT JOIN ' . $tripsTable . ' t ON t.id = n.trip_id
         WHERE n.user_id = :user_id';
    $params = ['user_id' => $userId];
    if ($cursorId !== null && $cursorId > 0) {
        $sql .= '
           AND n.id < :cursor_id';
        $params['cursor_id'] = $cursorId;
    }
    $sql .= '
         ORDER BY n.id DESC';
    if ($cursorId !== null && $cursorId > 0) {
        $sql .= '
         LIMIT ' . $limitPlusOne;
    } else {
        $sql .= '
         LIMIT ' . $offset . ', ' . $limitPlusOne;
    }

    $rowsStmt = $pdo->prepare($sql);
    $rowsStmt->execute($params);
    $rows = $rowsStmt->fetchAll();
    $hasMore = count($rows) > $limit;
    if ($hasMore) {
        $rows = array_slice($rows, 0, $limit);
    }

    $items = [];
    foreach ($rows as $row) {
        $payload = null;
        $rawPayload = (string) ($row['payload_json'] ?? '');
        if ($rawPayload !== '') {
            $decoded = json_decode($rawPayload, true);
            if (is_array($decoded)) {
                $payload = $decoded;
            }
        }

        $items[] = [
            'id' => (int) ($row['id'] ?? 0),
            'trip_id' => (int) ($row['trip_id'] ?? 0),
            'trip_name' => trim((string) ($row['trip_name'] ?? '')) ?: null,
            'type' => (string) ($row['type'] ?? 'info'),
            'title' => (string) ($row['title'] ?? ''),
            'body' => (string) ($row['body'] ?? ''),
            'payload' => $payload,
            'is_read' => ((int) ($row['is_read'] ?? 0)) === 1,
            'read_at' => $row['read_at'] ?? null,
            'created_at' => $row['created_at'] ?? null,
        ];
    }

    $unreadStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $notificationsTable . '
         WHERE user_id = :user_id
           AND is_read = 0'
    );
    $unreadStmt->execute(['user_id' => $userId]);
    $unreadNotificationsCount = (int) ($unreadStmt->fetchColumn() ?: 0);

    $nextCursor = null;
    if ($hasMore && count($rows) > 0) {
        $last = $rows[count($rows) - 1];
        $nextCursor = pagination_encode_cursor([
            'id' => (int) ($last['id'] ?? 0),
        ]);
    }

    return [
        'items' => $items,
        'has_more' => $hasMore,
        'next_cursor' => $nextCursor !== '' ? $nextCursor : null,
        'unread_notifications_count' => $unreadNotificationsCount,
    ];
}

function mark_notifications_read_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, false);
    $tripId = $trip ? (int) $trip['id'] : 0;
    $notificationsTable = table_name('notifications');

    $ids = normalize_user_ids((array) ($body['notification_ids'] ?? []));
    $updated = 0;

    if ($ids) {
        $baseSql = 'UPDATE ' . $notificationsTable . '
                    SET is_read = 1,
                        read_at = COALESCE(read_at, CURRENT_TIMESTAMP)
                    WHERE user_id = ?';
        $params = [(int) $me['id']];
        if ($tripId > 0) {
            $baseSql .= ' AND trip_id = ?';
            $params[] = $tripId;
        }
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $baseSql .= ' AND id IN (' . $placeholders . ')
                      AND is_read = 0';
        $params = array_merge($params, $ids);

        $update = $pdo->prepare($baseSql);
        $update->execute($params);
        $updated = (int) $update->rowCount();
    } else {
        $baseSql = 'UPDATE ' . $notificationsTable . '
                    SET is_read = 1,
                        read_at = COALESCE(read_at, CURRENT_TIMESTAMP)
                    WHERE user_id = :user_id
                      AND is_read = 0';
        $params = ['user_id' => (int) $me['id']];
        if ($tripId > 0) {
            $baseSql .= ' AND trip_id = :trip_id';
            $params['trip_id'] = $tripId;
        }

        $update = $pdo->prepare($baseSql);
        $update->execute($params);
        $updated = (int) $update->rowCount();
    }

    $countSql = 'SELECT COUNT(*)
                 FROM ' . $notificationsTable . '
                 WHERE user_id = :user_id
                   AND is_read = 0';
    $countParams = ['user_id' => (int) $me['id']];
    if ($tripId > 0) {
        $countSql .= ' AND trip_id = :trip_id';
        $countParams['trip_id'] = $tripId;
    }
    $countStmt = $pdo->prepare($countSql);
    $countStmt->execute($countParams);
    $unreadCount = (int) ($countStmt->fetchColumn() ?: 0);

    json_out([
        'ok' => true,
        'updated_count' => $updated,
        'unread_count' => $unreadCount,
        'trip' => $trip ? build_trip_payload($trip) : null,
    ]);
}

function mark_notifications_read_global_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $notificationsTable = table_name('notifications');
    $userId = (int) ($me['id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid session user.'], 401);
    }

    $ids = normalize_user_ids((array) ($body['notification_ids'] ?? []));
    $updated = 0;
    if ($ids) {
        $baseSql = 'UPDATE ' . $notificationsTable . '
                    SET is_read = 1,
                        read_at = COALESCE(read_at, CURRENT_TIMESTAMP)
                    WHERE user_id = ?';
        $params = [$userId];
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $baseSql .= ' AND id IN (' . $placeholders . ')
                      AND is_read = 0';
        $params = array_merge($params, $ids);

        $update = $pdo->prepare($baseSql);
        $update->execute($params);
        $updated = (int) $update->rowCount();
    } else {
        $update = $pdo->prepare(
            'UPDATE ' . $notificationsTable . '
             SET is_read = 1,
                 read_at = COALESCE(read_at, CURRENT_TIMESTAMP)
             WHERE user_id = :user_id
               AND is_read = 0'
        );
        $update->execute(['user_id' => $userId]);
        $updated = (int) $update->rowCount();
    }

    $countStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $notificationsTable . '
         WHERE user_id = :user_id
           AND is_read = 0'
    );
    $countStmt->execute(['user_id' => $userId]);
    $unreadNotificationsCount = (int) ($countStmt->fetchColumn() ?: 0);
    $pendingFriendInvitesCount = count_pending_friend_invites($pdo, $userId);

    json_out([
        'ok' => true,
        'updated_count' => $updated,
        'unread_count' => $unreadNotificationsCount + $pendingFriendInvitesCount,
        'unread_notifications_count' => $unreadNotificationsCount,
        'pending_friend_invites_count' => $pendingFriendInvitesCount,
    ]);
}
