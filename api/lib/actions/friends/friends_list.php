<?php
declare(strict_types=1);

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
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $revolutMeLinkSelect = users_revolut_me_link_column_available($pdo)
        ? 'u.revolut_me_link, '
        : 'NULL AS revolut_me_link, ';
    $paymentSelect = users_payment_columns_available($pdo)
        ? 'u.bank_account_holder, u.bank_iban, u.bank_bic, u.revolut_handle, ' . $revolutMeLinkSelect . 'u.paypal_me_link, '
        : 'NULL AS bank_account_holder, NULL AS bank_iban, NULL AS bank_bic, NULL AS revolut_handle, NULL AS revolut_me_link, NULL AS paypal_me_link, ';
    $activeFilter = users_active_filter_sql($pdo, 'u');

    $acceptedStmt = $pdo->prepare(
        'SELECT
            f.id AS request_id,
            f.requested_by,
            f.created_at,
            f.updated_at,
            ' . $nameSelect . $paymentSelect . '
            u.id AS user_id,
            u.nickname,
            u.avatar_path
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id, f.user_b_id, f.user_a_id)
         WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)
           AND f.status = "accepted"
           ' . $activeFilter . '
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
            ' . $nameSelect . $paymentSelect . '
            u.id AS user_id,
            u.nickname,
            u.avatar_path
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id, f.user_b_id, f.user_a_id)
         WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)
           AND f.status = "pending"
           AND f.requested_by = :requested_by
           ' . $activeFilter . '
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
            ' . $nameSelect . $paymentSelect . '
            u.id AS user_id,
            u.nickname,
            u.avatar_path
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id, f.user_b_id, f.user_a_id)
         WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)
           AND f.status = "pending"
           AND f.requested_by <> :requested_by
           ' . $activeFilter . '
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
        $friends[] = array_merge(friend_user_payload_from_row((array) $row, true), [
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
    $usersTable = table_name('users');
    $activeFilter = users_active_filter_sql($pdo, 'u');
    $baseWhere = '(f.user_a_id = :user_a_id OR f.user_b_id = :user_b_id)';

    $friendsCountStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id_a, f.user_b_id, f.user_a_id)
         WHERE ' . $baseWhere . '
           AND f.status = "accepted"
           ' . $activeFilter
    );
    $friendsCountStmt->execute([
        'join_me_id_a' => $meId,
        'user_a_id' => $meId,
        'user_b_id' => $meId,
    ]);
    $friendsCount = (int) ($friendsCountStmt->fetchColumn() ?: 0);

    $pendingSentStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id_b, f.user_b_id, f.user_a_id)
         WHERE ' . $baseWhere . '
           AND f.status = "pending"
           AND f.requested_by = :requested_by
           ' . $activeFilter
    );
    $pendingSentStmt->execute([
        'join_me_id_b' => $meId,
        'user_a_id' => $meId,
        'user_b_id' => $meId,
        'requested_by' => $meId,
    ]);
    $pendingSentCount = (int) ($pendingSentStmt->fetchColumn() ?: 0);

    $pendingReceivedStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $friendsTable . ' f
         JOIN ' . $usersTable . ' u
           ON u.id = IF(f.user_a_id = :join_me_id_c, f.user_b_id, f.user_a_id)
         WHERE ' . $baseWhere . '
           AND f.status = "pending"
           AND f.requested_by <> :requested_by
           ' . $activeFilter
    );
    $pendingReceivedStmt->execute([
        'join_me_id_c' => $meId,
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
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $revolutMeLinkSelect = users_revolut_me_link_column_available($pdo)
        ? 'u.revolut_me_link, '
        : 'NULL AS revolut_me_link, ';
    $paymentSelect = users_payment_columns_available($pdo)
        ? 'u.bank_account_holder, u.bank_iban, u.bank_bic, u.revolut_handle, ' . $revolutMeLinkSelect . 'u.paypal_me_link, '
        : 'NULL AS bank_account_holder, NULL AS bank_iban, NULL AS bank_bic, NULL AS revolut_handle, NULL AS revolut_me_link, NULL AS paypal_me_link, ';
    $activeFilter = users_active_filter_sql($pdo, 'u');
    $params = [
        'join_me_id' => $meId,
        'where_me_a' => $meId,
        'where_me_b' => $meId,
    ];
    $where =
        'WHERE (f.user_a_id = :where_me_a OR f.user_b_id = :where_me_b)';
    $where .= $activeFilter;

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
            ' . $nameSelect . $paymentSelect . '
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
            $items[] = array_merge(friend_user_payload_from_row((array) $row, true), [
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
