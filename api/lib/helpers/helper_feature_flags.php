<?php
declare(strict_types=1);

// Feature flags: a global mode per flag plus per-account grants.
// Contract: docs/api/feature-flags.md. Everything fails closed: a missing
// table or a failed read means the feature is off.

/** The only flags that exist. Keys are fixed here, never created from input. */
function feature_flag_catalog(): array
{
    return [
        'receipt_ai' => [
            'label' => 'AI receipt reading',
            'description' => 'Reads receipt photos with AI in Quick split. Test phase: allowlist only.',
        ],
    ];
}

function feature_flag_modes(): array
{
    return ['off', 'allowlist', 'everyone'];
}

function feature_flag_key_is_known(string $key): bool
{
    return array_key_exists($key, feature_flag_catalog());
}

function feature_flags_tables_available(PDO $pdo): bool
{
    static $cache = null;
    if (is_bool($cache)) {
        return $cache;
    }
    try {
        // A query that reads no rows: works on MySQL and SQLite alike.
        $pdo->query('SELECT 1 FROM ' . table_name('feature_flags') . ' WHERE 1 = 0');
        $pdo->query('SELECT 1 FROM ' . table_name('user_features') . ' WHERE 1 = 0');
        $cache = true;
    } catch (Throwable $error) {
        $cache = false;
    }
    return $cache;
}

/** Mode of every catalog flag; a flag without a row, or any failure, is "off". */
function feature_flag_modes_read(PDO $pdo): array
{
    $modes = array_fill_keys(array_keys(feature_flag_catalog()), 'off');
    if (!feature_flags_tables_available($pdo)) {
        return $modes;
    }
    try {
        $rows = $pdo->query('SELECT flag_key, mode FROM ' . table_name('feature_flags'))->fetchAll(PDO::FETCH_ASSOC);
    } catch (Throwable $error) {
        return $modes;
    }
    foreach ($rows as $row) {
        $key = (string) $row['flag_key'];
        $mode = (string) $row['mode'];
        if (array_key_exists($key, $modes) && in_array($mode, feature_flag_modes(), true)) {
            $modes[$key] = $mode;
        }
    }
    return $modes;
}

/** Active, non-guest accounts only; deleted, deactivated and trip guests never get a feature. */
function feature_user_is_eligible(PDO $pdo, int $userId): bool
{
    if ($userId <= 0) {
        return false;
    }
    try {
        $stmt = $pdo->prepare('SELECT ' . users_account_status_select_sql($pdo) . 'guest_trip_id
            FROM ' . table_name('users') . ' WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => $userId]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
    } catch (Throwable $error) {
        return false;
    }
    return is_array($user) && user_account_status($user) === 'active' && $user['guest_trip_id'] === null;
}

/** Keys of the flags granted to this account (whatever the current mode). */
function feature_user_grants(PDO $pdo, int $userId): array
{
    if ($userId <= 0 || !feature_flags_tables_available($pdo)) {
        return [];
    }
    try {
        $stmt = $pdo->prepare('SELECT flag_key FROM ' . table_name('user_features') . ' WHERE user_id = :id');
        $stmt->execute(['id' => $userId]);
        return array_values(array_filter(array_map('strval', $stmt->fetchAll(PDO::FETCH_COLUMN)),
            'feature_flag_key_is_known'));
    } catch (Throwable $error) {
        return [];
    }
}

/** Map of every catalog key to whether this account has the feature now. */
function feature_flags_for_user(PDO $pdo, int $userId): array
{
    $result = array_fill_keys(array_keys(feature_flag_catalog()), false);
    $modes = feature_flag_modes_read($pdo);
    if (!in_array('allowlist', $modes, true) && !in_array('everyone', $modes, true)) {
        return $result;
    }
    if (!feature_user_is_eligible($pdo, $userId)) {
        return $result;
    }
    $grants = in_array('allowlist', $modes, true) ? feature_user_grants($pdo, $userId) : [];
    foreach ($modes as $key => $mode) {
        $result[$key] = $mode === 'everyone' || ($mode === 'allowlist' && in_array($key, $grants, true));
    }
    return $result;
}

/**
 * The check a feature's own request makes before doing any work or spending
 * money. Always reads the database (no cache), so "off" applies at once.
 */
function feature_enabled_for_user(PDO $pdo, int $userId, string $key): bool
{
    if (!feature_flag_key_is_known($key)) {
        return false;
    }
    return feature_flags_for_user($pdo, $userId)[$key] ?? false;
}

/** Removes an account's grants; part of account deletion. */
function delete_user_feature_grants(PDO $pdo, int $userId): void
{
    if ($userId > 0 && feature_flags_tables_available($pdo)) {
        $pdo->prepare('DELETE FROM ' . table_name('user_features') . ' WHERE user_id = :id')
            ->execute(['id' => $userId]);
    }
}
