<?php
declare(strict_types=1);

// Admin actions for feature flags. Contract: docs/api/feature-flags.md.
// Reading needs superadmin or admin; every change needs superadmin, a reason,
// and writes its audit entry in the same transaction.

require_once __DIR__ . '/../helpers/helper_feature_flags.php';

function feature_admin_require_tables(PDO $pdo): void
{
    if (!feature_flags_tables_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Feature flags need the 2026-11-20 migration.'], 503);
    }
}

function feature_admin_reason(array $body): string
{
    $reason = trim((string) ($body['reason'] ?? ''));
    if ($reason === '' || mb_strlen($reason) > 200) {
        json_out(['ok' => false, 'error' => 'Give a reason (up to 200 characters).'], 400);
    }
    return $reason;
}

function feature_admin_key(array $body): string
{
    $key = trim((string) ($body['key'] ?? ''));
    if (!feature_flag_key_is_known($key)) {
        json_out(['ok' => false, 'error' => 'Unknown feature.'], 400);
    }
    return $key;
}

/** Flags with their mode and who changed them last. */
function feature_admin_flags(PDO $pdo): array
{
    $rows = [];
    $stmt = $pdo->query('SELECT f.flag_key, f.mode, f.updated_at, a.username AS updated_by
        FROM ' . table_name('feature_flags') . ' f
        LEFT JOIN ' . table_name('admin_users') . ' a ON a.id = f.updated_by_admin_id');
    foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $rows[(string) $row['flag_key']] = $row;
    }
    $flags = [];
    foreach (feature_flag_catalog() as $key => $meta) {
        $row = $rows[$key] ?? null;
        $mode = (string) ($row['mode'] ?? 'off');
        $flags[] = [
            'key' => $key,
            'label' => $meta['label'],
            'description' => $meta['description'],
            'mode' => in_array($mode, feature_flag_modes(), true) ? $mode : 'off',
            'updated_at' => $row['updated_at'] ?? null,
            'updated_by' => $row['updated_by'] ?? null,
        ];
    }
    return $flags;
}

function admin_panel_features_action(): void
{
    require_admin_role('superadmin', 'admin');
    $pdo = db();
    feature_admin_require_tables($pdo);
    $stmt = $pdo->query('SELECT g.flag_key AS `key`, g.user_id, u.nickname, u.email,
            ' . users_account_status_select_sql($pdo, 'u') . 'g.granted_at, a.username AS granted_by
        FROM ' . table_name('user_features') . ' g
        JOIN ' . table_name('users') . ' u ON u.id = g.user_id
        LEFT JOIN ' . table_name('admin_users') . ' a ON a.id = g.granted_by_admin_id
        ORDER BY g.granted_at DESC, g.user_id DESC');
    $grants = array_map(static function (array $row): array {
        $row['user_id'] = (int) $row['user_id'];
        return $row;
    }, array_values(array_filter($stmt->fetchAll(PDO::FETCH_ASSOC),
        static fn (array $row): bool => feature_flag_key_is_known((string) $row['key']))));
    json_out(['ok' => true, 'flags' => feature_admin_flags($pdo), 'grants' => $grants]);
}

function admin_panel_feature_set_mode_action(): void
{
    require_post();
    $sess = require_admin_role('superadmin');
    $pdo = db();
    feature_admin_require_tables($pdo);
    $body = read_json();
    $key = feature_admin_key($body);
    $mode = trim((string) ($body['mode'] ?? ''));
    if (!in_array($mode, feature_flag_modes(), true)) {
        json_out(['ok' => false, 'error' => 'Unknown mode.'], 400);
    }
    $reason = feature_admin_reason($body);
    $table = table_name('feature_flags');

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare('SELECT mode FROM ' . $table . ' WHERE flag_key = ? FOR UPDATE');
        $stmt->execute([$key]);
        $from = (string) ($stmt->fetchColumn() ?: 'off');
        $pdo->prepare('INSERT INTO ' . $table . ' (flag_key, mode, updated_by_admin_id) VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE mode = VALUES(mode), updated_by_admin_id = VALUES(updated_by_admin_id),
            updated_at = CURRENT_TIMESTAMP')->execute([$key, $mode, (int) $sess['admin_user_id']]);
        admin_audit($pdo, $sess, 'feature.mode_set', 'feature', null,
            ['key' => $key, 'from' => $from, 'to' => $mode, 'reason' => $reason], true);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    $flag = array_values(array_filter(feature_admin_flags($pdo), static fn (array $f): bool => $f['key'] === $key))[0];
    json_out(['ok' => true, 'flag' => $flag]);
}

function admin_panel_user_feature_set_action(): void
{
    require_post();
    $sess = require_admin_role('superadmin');
    $pdo = db();
    feature_admin_require_tables($pdo);
    $body = read_json();
    $userId = (int) ($body['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }
    $key = feature_admin_key($body);
    $enabled = ($body['enabled'] ?? null) === true;
    if (!is_bool($body['enabled'] ?? null)) {
        json_out(['ok' => false, 'error' => 'enabled must be true or false.'], 400);
    }
    $reason = feature_admin_reason($body);
    $grants = table_name('user_features');

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare('SELECT id FROM ' . table_name('users') . ' WHERE id = ? FOR UPDATE');
        $stmt->execute([$userId]);
        if (!$stmt->fetchColumn()) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'User not found.'], 404);
        }
        if ($enabled && !feature_user_is_eligible($pdo, $userId)) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Only active accounts that are not trip guests can get features.'], 409);
        }
        if ($enabled) {
            $pdo->prepare('INSERT IGNORE INTO ' . $grants . ' (user_id, flag_key, granted_by_admin_id) VALUES (?, ?, ?)')
                ->execute([$userId, $key, (int) $sess['admin_user_id']]);
        } else {
            $pdo->prepare('DELETE FROM ' . $grants . ' WHERE user_id = ? AND flag_key = ?')->execute([$userId, $key]);
        }
        admin_audit($pdo, $sess, $enabled ? 'feature.user_grant' : 'feature.user_revoke', 'user', $userId,
            ['key' => $key, 'reason' => $reason], true);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    json_out(['ok' => true, 'enabled' => $enabled,
        'effective' => feature_enabled_for_user($pdo, $userId, $key)]);
}

/** For the admin user detail: each flag, whether granted and whether on right now. */
function admin_user_features(PDO $pdo, int $userId): array
{
    $grants = feature_user_grants($pdo, $userId);
    $effective = feature_flags_for_user($pdo, $userId);
    $out = [];
    foreach (feature_flag_catalog() as $key => $meta) {
        $out[] = ['key' => $key, 'label' => $meta['label'],
            'granted' => in_array($key, $grants, true), 'effective' => (bool) ($effective[$key] ?? false)];
    }
    return $out;
}
