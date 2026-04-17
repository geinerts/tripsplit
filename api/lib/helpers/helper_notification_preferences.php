<?php
declare(strict_types=1);

function notification_preferences_defaults(): array
{
    return [
        'in_app_banner_enabled' => true,
        'in_app_expense_added_enabled' => true,
        'in_app_friend_invites_enabled' => true,
        'in_app_friend_invite_received_enabled' => true,
        'in_app_friend_invite_accepted_enabled' => true,
        'in_app_trip_updates_enabled' => true,
        'in_app_trip_added_enabled' => true,
        'in_app_trip_member_added_enabled' => true,
        'in_app_trip_finished_enabled' => true,
        'in_app_member_ready_to_settle_enabled' => true,
        'in_app_trip_ready_to_settle_enabled' => true,
        'in_app_settlement_updates_enabled' => true,
        'in_app_settlement_reminder_enabled' => true,
        'in_app_settlement_auto_reminder_enabled' => true,
        'in_app_settlement_sent_enabled' => true,
        'in_app_settlement_confirmed_enabled' => true,
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
    $inAppGroupMap = [
        'expense_added' => [
            'group_pref_key' => 'in_app_expense_added_enabled',
            'type_pref_keys' => ['in_app_expense_added_enabled'],
        ],
        'friend_invites' => [
            'group_pref_key' => 'in_app_friend_invites_enabled',
            'type_pref_keys' => [
                'in_app_friend_invite_received_enabled',
                'in_app_friend_invite_accepted_enabled',
            ],
        ],
        'trip_updates' => [
            'group_pref_key' => 'in_app_trip_updates_enabled',
            'type_pref_keys' => [
                'in_app_trip_added_enabled',
                'in_app_trip_member_added_enabled',
                'in_app_trip_finished_enabled',
                'in_app_member_ready_to_settle_enabled',
                'in_app_trip_ready_to_settle_enabled',
            ],
        ],
        'settlement_updates' => [
            'group_pref_key' => 'in_app_settlement_updates_enabled',
            'type_pref_keys' => [
                'in_app_settlement_reminder_enabled',
                'in_app_settlement_auto_reminder_enabled',
                'in_app_settlement_sent_enabled',
                'in_app_settlement_confirmed_enabled',
            ],
        ],
    ];
    $inAppTypeMap = [
        'expense_added' => 'in_app_expense_added_enabled',
        'friend_invite' => 'in_app_friend_invite_received_enabled',
        'friend_invite_received' => 'in_app_friend_invite_received_enabled',
        'friend_invite_accepted' => 'in_app_friend_invite_accepted_enabled',
        'trip_added' => 'in_app_trip_added_enabled',
        'trip_member_added' => 'in_app_trip_member_added_enabled',
        'trip_finished' => 'in_app_trip_finished_enabled',
        'member_ready_to_settle' => 'in_app_member_ready_to_settle_enabled',
        'trip_ready_to_settle' => 'in_app_trip_ready_to_settle_enabled',
        'settlement_reminder' => 'in_app_settlement_reminder_enabled',
        'settlement_auto_reminder' => 'in_app_settlement_auto_reminder_enabled',
        'settlement_sent' => 'in_app_settlement_sent_enabled',
        'settlement_confirmed' => 'in_app_settlement_confirmed_enabled',
    ];
    $flatMap = [
        'in_app_banner_enabled' => 'in_app_banner_enabled',
        'in_app_expense_added_enabled' => 'in_app_expense_added_enabled',
        'in_app_friend_invites_enabled' => 'in_app_friend_invites_enabled',
        'in_app_friend_invite_received_enabled' => 'in_app_friend_invite_received_enabled',
        'in_app_friend_invite_accepted_enabled' => 'in_app_friend_invite_accepted_enabled',
        'in_app_trip_updates_enabled' => 'in_app_trip_updates_enabled',
        'in_app_trip_added_enabled' => 'in_app_trip_added_enabled',
        'in_app_trip_member_added_enabled' => 'in_app_trip_member_added_enabled',
        'in_app_trip_finished_enabled' => 'in_app_trip_finished_enabled',
        'in_app_member_ready_to_settle_enabled' => 'in_app_member_ready_to_settle_enabled',
        'in_app_trip_ready_to_settle_enabled' => 'in_app_trip_ready_to_settle_enabled',
        'in_app_settlement_updates_enabled' => 'in_app_settlement_updates_enabled',
        'in_app_settlement_reminder_enabled' => 'in_app_settlement_reminder_enabled',
        'in_app_settlement_auto_reminder_enabled' => 'in_app_settlement_auto_reminder_enabled',
        'in_app_settlement_sent_enabled' => 'in_app_settlement_sent_enabled',
        'in_app_settlement_confirmed_enabled' => 'in_app_settlement_confirmed_enabled',
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

    $inAppPayload = $input['in_app'] ?? null;
    if (is_array($inAppPayload)) {
        foreach ($inAppGroupMap as $inputKey => $groupConfig) {
            if (!array_key_exists($inputKey, $inAppPayload)) {
                continue;
            }
            $isValid = true;
            $value = normalize_notification_preference_bool($inAppPayload[$inputKey], $isValid);
            if (!$isValid) {
                throw new InvalidArgumentException('Invalid boolean value for "in_app.' . $inputKey . '".');
            }
            $groupKey = (string) ($groupConfig['group_pref_key'] ?? '');
            if ($groupKey !== '') {
                $patch[$groupKey] = $value;
            }
            $typePrefKeys = $groupConfig['type_pref_keys'] ?? [];
            foreach ($typePrefKeys as $typePrefKey) {
                $typePrefKey = (string) $typePrefKey;
                if ($typePrefKey === '') {
                    continue;
                }
                $patch[$typePrefKey] = $value;
            }
        }

        foreach ($inAppTypeMap as $inputKey => $targetKey) {
            if (!array_key_exists($inputKey, $inAppPayload)) {
                continue;
            }
            $isValid = true;
            $value = normalize_notification_preference_bool($inAppPayload[$inputKey], $isValid);
            if (!$isValid) {
                throw new InvalidArgumentException('Invalid boolean value for "in_app.' . $inputKey . '".');
            }
            $patch[$targetKey] = $value;
        }
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
            in_app_expense_added_enabled,
            in_app_friend_invites_enabled,
            in_app_friend_invite_received_enabled,
            in_app_friend_invite_accepted_enabled,
            in_app_trip_updates_enabled,
            in_app_trip_added_enabled,
            in_app_trip_member_added_enabled,
            in_app_trip_finished_enabled,
            in_app_member_ready_to_settle_enabled,
            in_app_trip_ready_to_settle_enabled,
            in_app_settlement_updates_enabled,
            in_app_settlement_reminder_enabled,
            in_app_settlement_auto_reminder_enabled,
            in_app_settlement_sent_enabled,
            in_app_settlement_confirmed_enabled,
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

    $inAppExpenseAddedEnabled = ((int) ($row['in_app_expense_added_enabled'] ?? 1)) === 1;
    $inAppFriendInviteReceivedEnabled = ((int) ($row['in_app_friend_invite_received_enabled'] ?? 1)) === 1;
    $inAppFriendInviteAcceptedEnabled = ((int) ($row['in_app_friend_invite_accepted_enabled'] ?? 1)) === 1;
    $inAppTripAddedEnabled = ((int) ($row['in_app_trip_added_enabled'] ?? 1)) === 1;
    $inAppTripMemberAddedEnabled = ((int) ($row['in_app_trip_member_added_enabled'] ?? 1)) === 1;
    $inAppTripFinishedEnabled = ((int) ($row['in_app_trip_finished_enabled'] ?? 1)) === 1;
    $inAppMemberReadyToSettleEnabled = ((int) ($row['in_app_member_ready_to_settle_enabled'] ?? 1)) === 1;
    $inAppTripReadyToSettleEnabled = ((int) ($row['in_app_trip_ready_to_settle_enabled'] ?? 1)) === 1;
    $inAppSettlementReminderEnabled = ((int) ($row['in_app_settlement_reminder_enabled'] ?? 1)) === 1;
    $inAppSettlementAutoReminderEnabled = ((int) ($row['in_app_settlement_auto_reminder_enabled'] ?? 1)) === 1;
    $inAppSettlementSentEnabled = ((int) ($row['in_app_settlement_sent_enabled'] ?? 1)) === 1;
    $inAppSettlementConfirmedEnabled = ((int) ($row['in_app_settlement_confirmed_enabled'] ?? 1)) === 1;
    $inAppFriendInvitesEnabled =
        ((int) ($row['in_app_friend_invites_enabled'] ?? ($inAppFriendInviteReceivedEnabled || $inAppFriendInviteAcceptedEnabled ? 1 : 0))) === 1;
    $inAppTripUpdatesEnabled =
        ((int) ($row['in_app_trip_updates_enabled'] ?? ($inAppTripAddedEnabled || $inAppTripMemberAddedEnabled || $inAppTripFinishedEnabled || $inAppMemberReadyToSettleEnabled || $inAppTripReadyToSettleEnabled ? 1 : 0))) === 1;
    $inAppSettlementUpdatesEnabled =
        ((int) ($row['in_app_settlement_updates_enabled'] ?? ($inAppSettlementReminderEnabled || $inAppSettlementAutoReminderEnabled || $inAppSettlementSentEnabled || $inAppSettlementConfirmedEnabled ? 1 : 0))) === 1;

    $cache[$userId] = [
        'in_app_banner_enabled' => ((int) ($row['in_app_banner_enabled'] ?? 1)) === 1,
        'in_app_expense_added_enabled' => $inAppExpenseAddedEnabled,
        'in_app_friend_invites_enabled' => $inAppFriendInvitesEnabled,
        'in_app_friend_invite_received_enabled' => $inAppFriendInviteReceivedEnabled,
        'in_app_friend_invite_accepted_enabled' => $inAppFriendInviteAcceptedEnabled,
        'in_app_trip_updates_enabled' => $inAppTripUpdatesEnabled,
        'in_app_trip_added_enabled' => $inAppTripAddedEnabled,
        'in_app_trip_member_added_enabled' => $inAppTripMemberAddedEnabled,
        'in_app_trip_finished_enabled' => $inAppTripFinishedEnabled,
        'in_app_member_ready_to_settle_enabled' => $inAppMemberReadyToSettleEnabled,
        'in_app_trip_ready_to_settle_enabled' => $inAppTripReadyToSettleEnabled,
        'in_app_settlement_updates_enabled' => $inAppSettlementUpdatesEnabled,
        'in_app_settlement_reminder_enabled' => $inAppSettlementReminderEnabled,
        'in_app_settlement_auto_reminder_enabled' => $inAppSettlementAutoReminderEnabled,
        'in_app_settlement_sent_enabled' => $inAppSettlementSentEnabled,
        'in_app_settlement_confirmed_enabled' => $inAppSettlementConfirmedEnabled,
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

    $inAppCategoryTypeMap = [
        'in_app_expense_added_enabled' => [
            'in_app_expense_added_enabled',
        ],
        'in_app_friend_invites_enabled' => [
            'in_app_friend_invite_received_enabled',
            'in_app_friend_invite_accepted_enabled',
        ],
        'in_app_trip_updates_enabled' => [
            'in_app_trip_added_enabled',
            'in_app_trip_member_added_enabled',
            'in_app_trip_finished_enabled',
            'in_app_member_ready_to_settle_enabled',
            'in_app_trip_ready_to_settle_enabled',
        ],
        'in_app_settlement_updates_enabled' => [
            'in_app_settlement_reminder_enabled',
            'in_app_settlement_auto_reminder_enabled',
            'in_app_settlement_sent_enabled',
            'in_app_settlement_confirmed_enabled',
        ],
    ];

    $inAppTypePrefKeys = [];
    foreach ($inAppCategoryTypeMap as $typeKeys) {
        foreach ($typeKeys as $typeKey) {
            $inAppTypePrefKeys[$typeKey] = true;
        }
    }
    $inAppTypePrefKeys = array_keys($inAppTypePrefKeys);
    $inAppCategoryPrefKeys = array_keys($inAppCategoryTypeMap);

    // Backward compatibility: when old clients patch only grouped in-app keys, mirror that to type-level keys.
    foreach ($inAppCategoryTypeMap as $groupKey => $typeKeys) {
        if (!array_key_exists($groupKey, $patch)) {
            continue;
        }
        $groupValue = (bool) $patch[$groupKey];
        foreach ($typeKeys as $typeKey) {
            if (!array_key_exists($typeKey, $patch)) {
                $patch[$typeKey] = $groupValue;
            }
        }
    }

    // If any type-level key is patched, keep grouped keys in sync (OR semantics).
    foreach ($inAppCategoryTypeMap as $groupKey => $typeKeys) {
        $hasCategoryPatch = array_key_exists($groupKey, $patch);
        $hasTypePatch = false;
        foreach ($typeKeys as $typeKey) {
            if (array_key_exists($typeKey, $patch)) {
                $hasTypePatch = true;
                break;
            }
        }
        if (!$hasCategoryPatch && !$hasTypePatch) {
            continue;
        }

        $groupValue = false;
        foreach ($typeKeys as $typeKey) {
            if ((bool) ($patch[$typeKey] ?? $current[$typeKey] ?? true)) {
                $groupValue = true;
                break;
            }
        }
        $patch[$groupKey] = $groupValue;
    }

    $hasAnyInAppPatch = false;
    foreach (array_merge($inAppCategoryPrefKeys, $inAppTypePrefKeys) as $prefKey) {
        if (array_key_exists($prefKey, $patch)) {
            $hasAnyInAppPatch = true;
            break;
        }
    }

    if ($hasAnyInAppPatch && !array_key_exists('in_app_banner_enabled', $patch)) {
        $patch['in_app_banner_enabled'] = false;
        foreach ($inAppCategoryPrefKeys as $prefKey) {
            if ((bool) ($patch[$prefKey] ?? $current[$prefKey] ?? true)) {
                $patch['in_app_banner_enabled'] = true;
                break;
            }
        }
    }
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
            in_app_expense_added_enabled,
            in_app_friend_invites_enabled,
            in_app_friend_invite_received_enabled,
            in_app_friend_invite_accepted_enabled,
            in_app_trip_updates_enabled,
            in_app_trip_added_enabled,
            in_app_trip_member_added_enabled,
            in_app_trip_finished_enabled,
            in_app_member_ready_to_settle_enabled,
            in_app_trip_ready_to_settle_enabled,
            in_app_settlement_updates_enabled,
            in_app_settlement_reminder_enabled,
            in_app_settlement_auto_reminder_enabled,
            in_app_settlement_sent_enabled,
            in_app_settlement_confirmed_enabled,
            push_expense_added_enabled,
            push_friend_invites_enabled,
            push_trip_updates_enabled,
            push_settlement_updates_enabled
         )
         VALUES
         (
            :user_id,
            :in_app_banner_enabled,
            :in_app_expense_added_enabled,
            :in_app_friend_invites_enabled,
            :in_app_friend_invite_received_enabled,
            :in_app_friend_invite_accepted_enabled,
            :in_app_trip_updates_enabled,
            :in_app_trip_added_enabled,
            :in_app_trip_member_added_enabled,
            :in_app_trip_finished_enabled,
            :in_app_member_ready_to_settle_enabled,
            :in_app_trip_ready_to_settle_enabled,
            :in_app_settlement_updates_enabled,
            :in_app_settlement_reminder_enabled,
            :in_app_settlement_auto_reminder_enabled,
            :in_app_settlement_sent_enabled,
            :in_app_settlement_confirmed_enabled,
            :push_expense_added_enabled,
            :push_friend_invites_enabled,
            :push_trip_updates_enabled,
            :push_settlement_updates_enabled
         )
         ON DUPLICATE KEY UPDATE
            in_app_banner_enabled = VALUES(in_app_banner_enabled),
            in_app_expense_added_enabled = VALUES(in_app_expense_added_enabled),
            in_app_friend_invites_enabled = VALUES(in_app_friend_invites_enabled),
            in_app_friend_invite_received_enabled = VALUES(in_app_friend_invite_received_enabled),
            in_app_friend_invite_accepted_enabled = VALUES(in_app_friend_invite_accepted_enabled),
            in_app_trip_updates_enabled = VALUES(in_app_trip_updates_enabled),
            in_app_trip_added_enabled = VALUES(in_app_trip_added_enabled),
            in_app_trip_member_added_enabled = VALUES(in_app_trip_member_added_enabled),
            in_app_trip_finished_enabled = VALUES(in_app_trip_finished_enabled),
            in_app_member_ready_to_settle_enabled = VALUES(in_app_member_ready_to_settle_enabled),
            in_app_trip_ready_to_settle_enabled = VALUES(in_app_trip_ready_to_settle_enabled),
            in_app_settlement_updates_enabled = VALUES(in_app_settlement_updates_enabled),
            in_app_settlement_reminder_enabled = VALUES(in_app_settlement_reminder_enabled),
            in_app_settlement_auto_reminder_enabled = VALUES(in_app_settlement_auto_reminder_enabled),
            in_app_settlement_sent_enabled = VALUES(in_app_settlement_sent_enabled),
            in_app_settlement_confirmed_enabled = VALUES(in_app_settlement_confirmed_enabled),
            push_expense_added_enabled = VALUES(push_expense_added_enabled),
            push_friend_invites_enabled = VALUES(push_friend_invites_enabled),
            push_trip_updates_enabled = VALUES(push_trip_updates_enabled),
            push_settlement_updates_enabled = VALUES(push_settlement_updates_enabled),
            updated_at = CURRENT_TIMESTAMP'
    );
    $stmt->execute([
        'user_id' => $userId,
        'in_app_banner_enabled' => $next['in_app_banner_enabled'] ? 1 : 0,
        'in_app_expense_added_enabled' => $next['in_app_expense_added_enabled'] ? 1 : 0,
        'in_app_friend_invites_enabled' => $next['in_app_friend_invites_enabled'] ? 1 : 0,
        'in_app_friend_invite_received_enabled' => $next['in_app_friend_invite_received_enabled'] ? 1 : 0,
        'in_app_friend_invite_accepted_enabled' => $next['in_app_friend_invite_accepted_enabled'] ? 1 : 0,
        'in_app_trip_updates_enabled' => $next['in_app_trip_updates_enabled'] ? 1 : 0,
        'in_app_trip_added_enabled' => $next['in_app_trip_added_enabled'] ? 1 : 0,
        'in_app_trip_member_added_enabled' => $next['in_app_trip_member_added_enabled'] ? 1 : 0,
        'in_app_trip_finished_enabled' => $next['in_app_trip_finished_enabled'] ? 1 : 0,
        'in_app_member_ready_to_settle_enabled' => $next['in_app_member_ready_to_settle_enabled'] ? 1 : 0,
        'in_app_trip_ready_to_settle_enabled' => $next['in_app_trip_ready_to_settle_enabled'] ? 1 : 0,
        'in_app_settlement_updates_enabled' => $next['in_app_settlement_updates_enabled'] ? 1 : 0,
        'in_app_settlement_reminder_enabled' => $next['in_app_settlement_reminder_enabled'] ? 1 : 0,
        'in_app_settlement_auto_reminder_enabled' => $next['in_app_settlement_auto_reminder_enabled'] ? 1 : 0,
        'in_app_settlement_sent_enabled' => $next['in_app_settlement_sent_enabled'] ? 1 : 0,
        'in_app_settlement_confirmed_enabled' => $next['in_app_settlement_confirmed_enabled'] ? 1 : 0,
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
        'in_app' => [
            'expense_added' => (bool) ($prefs['in_app_expense_added_enabled'] ?? true),
            'friend_invites' => (bool) ($prefs['in_app_friend_invites_enabled'] ?? true),
            'friend_invite_received' => (bool) ($prefs['in_app_friend_invite_received_enabled'] ?? true),
            'friend_invite_accepted' => (bool) ($prefs['in_app_friend_invite_accepted_enabled'] ?? true),
            'trip_updates' => (bool) ($prefs['in_app_trip_updates_enabled'] ?? true),
            'trip_added' => (bool) ($prefs['in_app_trip_added_enabled'] ?? true),
            'trip_member_added' => (bool) ($prefs['in_app_trip_member_added_enabled'] ?? true),
            'trip_finished' => (bool) ($prefs['in_app_trip_finished_enabled'] ?? true),
            'member_ready_to_settle' => (bool) ($prefs['in_app_member_ready_to_settle_enabled'] ?? true),
            'trip_ready_to_settle' => (bool) ($prefs['in_app_trip_ready_to_settle_enabled'] ?? true),
            'settlement_updates' => (bool) ($prefs['in_app_settlement_updates_enabled'] ?? true),
            'settlement_reminder' => (bool) ($prefs['in_app_settlement_reminder_enabled'] ?? true),
            'settlement_auto_reminder' => (bool) ($prefs['in_app_settlement_auto_reminder_enabled'] ?? true),
            'settlement_sent' => (bool) ($prefs['in_app_settlement_sent_enabled'] ?? true),
            'settlement_confirmed' => (bool) ($prefs['in_app_settlement_confirmed_enabled'] ?? true),
        ],
        'push' => [
            'expense_added' => (bool) ($prefs['push_expense_added_enabled'] ?? true),
            'friend_invites' => (bool) ($prefs['push_friend_invites_enabled'] ?? true),
            'trip_updates' => (bool) ($prefs['push_trip_updates_enabled'] ?? true),
            'settlement_updates' => (bool) ($prefs['push_settlement_updates_enabled'] ?? true),
        ],
    ];
}

function notification_in_app_pref_key_for_type(string $type): ?string
{
    $normalized = strtolower(trim($type));
    if ($normalized === '') {
        return null;
    }

    if ($normalized === 'expense_added') {
        return 'in_app_expense_added_enabled';
    }

    if ($normalized === 'friend_invite' || $normalized === 'friend_invite_received') {
        return 'in_app_friend_invite_received_enabled';
    }

    if ($normalized === 'friend_invite_accepted') {
        return 'in_app_friend_invite_accepted_enabled';
    }

    if ($normalized === 'trip_added') {
        return 'in_app_trip_added_enabled';
    }

    if ($normalized === 'trip_member_added') {
        return 'in_app_trip_member_added_enabled';
    }

    if ($normalized === 'trip_finished') {
        return 'in_app_trip_finished_enabled';
    }

    if ($normalized === 'member_ready_to_settle') {
        return 'in_app_member_ready_to_settle_enabled';
    }

    if ($normalized === 'trip_ready_to_settle') {
        return 'in_app_trip_ready_to_settle_enabled';
    }

    if ($normalized === 'settlement_reminder') {
        return 'in_app_settlement_reminder_enabled';
    }

    if ($normalized === 'settlement_auto_reminder') {
        return 'in_app_settlement_auto_reminder_enabled';
    }

    if ($normalized === 'settlement_sent') {
        return 'in_app_settlement_sent_enabled';
    }

    if ($normalized === 'settlement_confirmed') {
        return 'in_app_settlement_confirmed_enabled';
    }

    return null;
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
        ['friend_invite', 'friend_invite_received', 'friend_invite_accepted'],
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
