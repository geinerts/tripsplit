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
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $nameGroupBy = users_name_columns_available($pdo)
        ? ', u.first_name, u.last_name'
        : '';

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
            'SELECT u.id, ' . $nameSelect . 'u.nickname, u.avatar_path, MAX(t.created_at) AS last_shared_at
             FROM ' . $tripMembersTable . ' tm_me
             JOIN ' . $tripMembersTable . ' tm_other
               ON tm_other.trip_id = tm_me.trip_id
              AND tm_other.user_id <> tm_me.user_id
             JOIN ' . $usersTable . ' u ON u.id = tm_other.user_id
             JOIN ' . $tripsTable . ' t ON t.id = tm_me.trip_id
             WHERE tm_me.user_id = :me_id' . $excludeClause . '
             GROUP BY u.id' . $nameGroupBy . ', u.nickname, u.avatar_path
             ORDER BY last_shared_at DESC, u.nickname ASC, u.id ASC
             LIMIT ' . $limit;

        $recentStmt = $pdo->prepare($recentSql);
        $recentStmt->execute($recentParams);
        $rows = $recentStmt->fetchAll();

        if (!$rows) {
            $fallbackSql =
                'SELECT u.id, ' . $nameSelect . 'u.nickname, u.avatar_path
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
                ' . $nameSelect . '
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
        $firstName = normalize_me_name_value($row['first_name'] ?? null);
        $lastName = normalize_me_name_value($row['last_name'] ?? null);
        $displayName = combine_full_name($firstName, $lastName);
        $row['first_name'] = $firstName;
        $row['last_name'] = $lastName;
        $row['display_name'] = $displayName !== null
            ? $displayName
            : $row['nickname'];
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
