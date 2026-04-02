<?php
declare(strict_types=1);

function normalize_settlement_status($value): string
{
    $raw = strtolower(trim((string) $value));
    if ($raw === 'sent' || $raw === 'confirmed') {
        return $raw;
    }
    return 'pending';
}

function parse_request_bool($value, bool $fallback = false): bool
{
    if (is_bool($value)) {
        return $value;
    }
    if (is_numeric($value)) {
        return ((int) $value) === 1;
    }
    if (is_string($value)) {
        $normalized = strtolower(trim($value));
        if ($normalized === '1' || $normalized === 'true' || $normalized === 'yes' || $normalized === 'y') {
            return true;
        }
        if ($normalized === '0' || $normalized === 'false' || $normalized === 'no' || $normalized === 'n') {
            return false;
        }
    }
    return $fallback;
}

function settlement_manual_reminder_cooldown_minutes(): int
{
    $minutes = (int) SETTLEMENT_MANUAL_REMINDER_COOLDOWN_MIN;
    if ($minutes < 0) {
        return 0;
    }
    if ($minutes > 1_440) {
        return 1_440;
    }
    return $minutes;
}

function load_trip_ready_to_settle_state(PDO $pdo, int $tripId, int $currentUserId): array
{
    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $readyColumnsAvailable = trip_members_ready_columns_available($pdo);
    $readySelect = $readyColumnsAvailable
        ? 'tm.ready_to_settle, tm.ready_to_settle_at, '
        : '1 AS ready_to_settle, NULL AS ready_to_settle_at, ';

    $stmt = $pdo->prepare(
        'SELECT
            tm.user_id,
            ' . $readySelect . '
            u.nickname
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => $tripId]);
    $rows = $stmt->fetchAll();

    $members = [];
    $readyMembers = 0;
    $currentUserReady = false;
    foreach ($rows as $row) {
        $userId = (int) ($row['user_id'] ?? 0);
        $isReady = ((int) ($row['ready_to_settle'] ?? 0)) === 1;
        if ($isReady) {
            $readyMembers++;
        }
        if ($userId > 0 && $userId === $currentUserId) {
            $currentUserReady = $isReady;
        }
        $members[] = [
            'user_id' => $userId,
            'nickname' => (string) ($row['nickname'] ?? ''),
            'is_ready' => $isReady,
            'ready_at' => $row['ready_to_settle_at'] ?: null,
        ];
    }

    $membersTotal = count($members);
    return [
        'enabled' => $readyColumnsAvailable,
        'members_total' => $membersTotal,
        'ready_members' => $readyMembers,
        'all_ready' => $membersTotal > 0 && $readyMembers === $membersTotal,
        'current_user_ready' => $currentUserReady,
        'members' => $members,
    ];
}
