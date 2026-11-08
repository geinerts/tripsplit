<?php
declare(strict_types=1);

/**
 * First members of each trip for the trips list, so the home screen can show
 * avatars without loading the workspace. See docs/api/trip-members-preview.md.
 *
 * @param int[] $tripIds
 * @return array<int, array<int, array{id:int, display_name:string, avatar_url:?string, avatar_thumb_url:?string}>>
 */
function trip_members_preview(PDO $pdo, array $tripIds, int $limit = 3): array
{
    $tripIds = array_values(array_unique(array_filter(
        array_map('intval', $tripIds),
        static fn(int $id): bool => $id > 0
    )));
    if ($tripIds === [] || $limit <= 0) {
        return [];
    }

    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $order = (trip_members_preview_column_available($pdo, $tripMembersTable, 'joined_at') ? 'tm.joined_at ASC, ' : '')
        . (trip_members_preview_column_available($pdo, $usersTable, 'created_at') ? 'u.created_at ASC, ' : '');
    $placeholders = implode(',', array_fill(0, count($tripIds), '?'));
    $stmt = $pdo->prepare(
        'SELECT tm.trip_id, u.id, ' . $nameSelect . 'u.nickname, u.avatar_path
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id IN (' . $placeholders . ')
         ORDER BY tm.trip_id ASC, ' . $order . 'u.id ASC'
    );
    $stmt->execute($tripIds);

    $preview = [];
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $tripId = (int) $row['trip_id'];
        if (count($preview[$tripId] ?? []) >= $limit) {
            continue;
        }
        $fullName = combine_full_name(
            normalize_me_name_value($row['first_name'] ?? null),
            normalize_me_name_value($row['last_name'] ?? null)
        );
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $preview[$tripId][] = [
            'id' => (int) $row['id'],
            'display_name' => $fullName ?? trim((string) ($row['nickname'] ?? '')),
            'avatar_url' => $avatarPath !== '' ? avatar_public_url($avatarPath) : null,
            'avatar_thumb_url' => $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null,
        ];
    }

    return $preview;
}

/** Older installs and test harnesses may lack the ordering columns. */
function trip_members_preview_column_available(PDO $pdo, string $table, string $column): bool
{
    static $cache = [];
    $key = $table . '.' . $column;
    if (isset($cache[$key])) {
        return $cache[$key];
    }
    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name = :column_name'
        );
        $stmt->execute(['table_name' => $table, 'column_name' => $column]);
        $cache[$key] = ((int) ($stmt->fetchColumn() ?: 0)) > 0;
    } catch (Throwable $error) {
        $cache[$key] = false;
    }

    return $cache[$key];
}
