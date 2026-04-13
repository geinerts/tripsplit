<?php
declare(strict_types=1);

function notification_preferences_defaults(): array
{
    return [
        'in_app_banner_enabled' => true,
        'push_expense_added_enabled' => true,
        'push_friend_invites_enabled' => true,
        'push_trip_updates_enabled' => true,
        'push_settlement_updates_enabled' => true,
    ];
}

function notification_preferences_table_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $rawTable = DB_TABLE_PREFIX . 'user_notification_preferences';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $rawTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $rawTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function &notification_preferences_runtime_cache(): array
{
    static $cache = [];
    return $cache;
}

function normalize_notification_preference_bool($value, bool &$isValid): bool
{
    $isValid = true;
    if (is_bool($value)) {
        return $value;
    }
    if (is_int($value)) {
        if ($value === 0 || $value === 1) {
            return $value === 1;
        }
        $isValid = false;
        return false;
    }
    if (is_string($value)) {
        $normalized = strtolower(trim($value));
        if ($normalized === '1' || $normalized === 'true' || $normalized === 'yes' || $normalized === 'on') {
            return true;
        }
        if ($normalized === '0' || $normalized === 'false' || $normalized === 'no' || $normalized === 'off') {
            return false;
        }
    }
    $isValid = false;
    return false;
}

function normalize_notification_preferences_patch(array $input): array
{
    $patch = [];
    $flatMap = [
        'in_app_banner_enabled' => 'in_app_banner_enabled',
        'push_expense_added_enabled' => 'push_expense_added_enabled',
        'push_friend_invites_enabled' => 'push_friend_invites_enabled',
        'push_trip_updates_enabled' => 'push_trip_updates_enabled',
        'push_settlement_updates_enabled' => 'push_settlement_updates_enabled',
    ];
    foreach ($flatMap as $inputKey => $targetKey) {
        if (!array_key_exists($inputKey, $input)) {
            continue;
        }
        $isValid = true;
        $value = normalize_notification_preference_bool($input[$inputKey], $isValid);
        if (!$isValid) {
            throw new InvalidArgumentException('Invalid boolean value for "' . $inputKey . '".');
        }
        $patch[$targetKey] = $value;
    }

    $pushPayload = $input['push'] ?? null;
    if (is_array($pushPayload)) {
        $nestedMap = [
            'expense_added' => 'push_expense_added_enabled',
            'friend_invites' => 'push_friend_invites_enabled',
            'trip_updates' => 'push_trip_updates_enabled',
            'settlement_updates' => 'push_settlement_updates_enabled',
        ];
        foreach ($nestedMap as $inputKey => $targetKey) {
            if (!array_key_exists($inputKey, $pushPayload)) {
                continue;
            }
            $isValid = true;
            $value = normalize_notification_preference_bool($pushPayload[$inputKey], $isValid);
            if (!$isValid) {
                throw new InvalidArgumentException('Invalid boolean value for "push.' . $inputKey . '".');
            }
            $patch[$targetKey] = $value;
        }
    }

    return $patch;
}

function load_user_notification_preferences(PDO $pdo, int $userId): array
{
    $defaults = notification_preferences_defaults();
    if ($userId <= 0) {
        return $defaults;
    }

    $cache = &notification_preferences_runtime_cache();
    if (array_key_exists($userId, $cache)) {
        return $cache[$userId];
    }

    if (!notification_preferences_table_available($pdo)) {
        $cache[$userId] = $defaults;
        return $cache[$userId];
    }

    $table = table_name('notification_preferences');
    $stmt = $pdo->prepare(
        'SELECT
            in_app_banner_enabled,
            push_expense_added_enabled,
            push_friend_invites_enabled,
            push_trip_updates_enabled,
            push_settlement_updates_enabled
         FROM ' . $table . '
         WHERE user_id = :user_id
         LIMIT 1'
    );
    $stmt->execute(['user_id' => $userId]);
    $row = $stmt->fetch();
    if (!is_array($row)) {
        $cache[$userId] = $defaults;
        return $cache[$userId];
    }

    $cache[$userId] = [
        'in_app_banner_enabled' => ((int) ($row['in_app_banner_enabled'] ?? 1)) === 1,
        'push_expense_added_enabled' => ((int) ($row['push_expense_added_enabled'] ?? 1)) === 1,
        'push_friend_invites_enabled' => ((int) ($row['push_friend_invites_enabled'] ?? 1)) === 1,
        'push_trip_updates_enabled' => ((int) ($row['push_trip_updates_enabled'] ?? 1)) === 1,
        'push_settlement_updates_enabled' => ((int) ($row['push_settlement_updates_enabled'] ?? 1)) === 1,
    ];
    return $cache[$userId];
}

function upsert_user_notification_preferences(PDO $pdo, int $userId, array $patch): array
{
    if ($userId <= 0) {
        throw new InvalidArgumentException('Invalid user id.');
    }

    $current = load_user_notification_preferences($pdo, $userId);
    if (!$patch) {
        return $current;
    }

    $next = array_merge($current, $patch);
    $table = table_name('notification_preferences');
    $stmt = $pdo->prepare(
        'INSERT INTO ' . $table . '
         (
            user_id,
            in_app_banner_enabled,
            push_expense_added_enabled,
            push_friend_invites_enabled,
            push_trip_updates_enabled,
            push_settlement_updates_enabled
         )
         VALUES
         (
            :user_id,
            :in_app_banner_enabled,
            :push_expense_added_enabled,
            :push_friend_invites_enabled,
            :push_trip_updates_enabled,
            :push_settlement_updates_enabled
         )
         ON DUPLICATE KEY UPDATE
            in_app_banner_enabled = VALUES(in_app_banner_enabled),
            push_expense_added_enabled = VALUES(push_expense_added_enabled),
            push_friend_invites_enabled = VALUES(push_friend_invites_enabled),
            push_trip_updates_enabled = VALUES(push_trip_updates_enabled),
            push_settlement_updates_enabled = VALUES(push_settlement_updates_enabled),
            updated_at = CURRENT_TIMESTAMP'
    );
    $stmt->execute([
        'user_id' => $userId,
        'in_app_banner_enabled' => $next['in_app_banner_enabled'] ? 1 : 0,
        'push_expense_added_enabled' => $next['push_expense_added_enabled'] ? 1 : 0,
        'push_friend_invites_enabled' => $next['push_friend_invites_enabled'] ? 1 : 0,
        'push_trip_updates_enabled' => $next['push_trip_updates_enabled'] ? 1 : 0,
        'push_settlement_updates_enabled' => $next['push_settlement_updates_enabled'] ? 1 : 0,
    ]);

    $cache = &notification_preferences_runtime_cache();
    $cache[$userId] = $next;
    return $next;
}

function build_notification_preferences_payload(array $prefs): array
{
    return [
        'in_app_banner_enabled' => (bool) ($prefs['in_app_banner_enabled'] ?? true),
        'push' => [
            'expense_added' => (bool) ($prefs['push_expense_added_enabled'] ?? true),
            'friend_invites' => (bool) ($prefs['push_friend_invites_enabled'] ?? true),
            'trip_updates' => (bool) ($prefs['push_trip_updates_enabled'] ?? true),
            'settlement_updates' => (bool) ($prefs['push_settlement_updates_enabled'] ?? true),
        ],
    ];
}

function notification_push_pref_key_for_type(string $type): ?string
{
    $normalized = strtolower(trim($type));
    if ($normalized === '') {
        return null;
    }

    if ($normalized === 'expense_added') {
        return 'push_expense_added_enabled';
    }

    if (in_array(
        $normalized,
        ['friend_invite', 'friend_invite_received', 'friend_invite_accepted', 'friend_invite_rejected'],
        true
    )) {
        return 'push_friend_invites_enabled';
    }

    if (in_array(
        $normalized,
        ['trip_added', 'trip_member_added', 'trip_finished', 'trip_ready_to_settle', 'member_ready_to_settle'],
        true
    )) {
        return 'push_trip_updates_enabled';
    }

    if (in_array($normalized, ['settlement_sent', 'settlement_confirmed'], true)) {
        return 'push_settlement_updates_enabled';
    }

    if ($normalized === 'settlement_reminder' || $normalized === 'settlement_auto_reminder') {
        return '__disabled__';
    }

    return null;
}

function user_allows_push_notification(PDO $pdo, int $userId, string $type): bool
{
    if ($userId <= 0) {
        return false;
    }

    $prefKey = notification_push_pref_key_for_type($type);
    if ($prefKey === '__disabled__') {
        return false;
    }
    if ($prefKey === null) {
        return true;
    }

    $prefs = load_user_notification_preferences($pdo, $userId);
    return (bool) ($prefs[$prefKey] ?? true);
}
