<?php
declare(strict_types=1);

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
    $firstName = normalize_me_name_value($row['first_name'] ?? null);
    $lastName = normalize_me_name_value($row['last_name'] ?? null);
    $displayName = combine_full_name($firstName, $lastName);
    $avatarPath = trim((string) ($row['avatar_path'] ?? ''));

    return [
        'id' => $userId,
        'nickname' => $nickname,
        'first_name' => $firstName,
        'last_name' => $lastName,
        'display_name' => $displayName !== null ? $displayName : $nickname,
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
    $nameSelect = users_name_columns_available($pdo)
        ? 'first_name, last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . 'nickname, avatar_path
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
