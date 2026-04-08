<?php
declare(strict_types=1);

function sql_alias_prefix(string $alias): string
{
    $alias = trim($alias);
    if ($alias === '') {
        return '';
    }
    if (!preg_match('/^[A-Za-z_][A-Za-z0-9_]*$/', $alias)) {
        throw new RuntimeException('Invalid SQL alias.');
    }
    return $alias . '.';
}

function users_account_status_column_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $usersTable = DB_TABLE_PREFIX . 'users';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $usersTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name = \'account_status\''
        );
        $stmt->execute(['table_name' => $usersTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function users_deactivated_at_column_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $usersTable = DB_TABLE_PREFIX . 'users';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $usersTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name = \'deactivated_at\''
        );
        $stmt->execute(['table_name' => $usersTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function users_deleted_at_column_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $usersTable = DB_TABLE_PREFIX . 'users';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $usersTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name = \'deleted_at\''
        );
        $stmt->execute(['table_name' => $usersTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function users_account_status_select_sql(PDO $pdo, string $alias = ''): string
{
    if (!users_account_status_column_available($pdo)) {
        return '\'active\' AS account_status, NULL AS deactivated_at, NULL AS deleted_at, ';
    }

    $prefix = sql_alias_prefix($alias);
    $deactivated = users_deactivated_at_column_available($pdo)
        ? $prefix . 'deactivated_at'
        : 'NULL';
    $deleted = users_deleted_at_column_available($pdo)
        ? $prefix . 'deleted_at'
        : 'NULL';

    return $prefix . 'account_status AS account_status, '
        . $deactivated . ' AS deactivated_at, '
        . $deleted . ' AS deleted_at, ';
}

function users_active_filter_sql(PDO $pdo, string $alias = 'u'): string
{
    if (!users_account_status_column_available($pdo)) {
        return '';
    }
    $prefix = sql_alias_prefix($alias);
    return ' AND ' . $prefix . 'account_status = "active"';
}

function normalize_user_account_status($raw): string
{
    $status = strtolower(trim((string) ($raw ?? 'active')));
    if ($status === 'deactivated') {
        return 'deactivated';
    }
    if ($status === 'deleted') {
        return 'deleted';
    }
    return 'active';
}

function user_account_status(array $row): string
{
    return normalize_user_account_status($row['account_status'] ?? 'active');
}

function user_account_is_active(array $row): bool
{
    return user_account_status($row) === 'active';
}

function user_account_block_error_payload(array $row): array
{
    $status = user_account_status($row);
    if ($status === 'deleted') {
        return [
            'ok' => false,
            'code' => 'ACCOUNT_DELETED',
            'error' => 'Account is deleted and cannot be restored.',
        ];
    }
    return [
        'ok' => false,
        'code' => 'ACCOUNT_DEACTIVATED',
        'error' => 'Account is deactivated. Request a reactivation link by email.',
    ];
}

function assert_user_account_is_active(array $row): void
{
    if (user_account_is_active($row)) {
        return;
    }
    json_out(user_account_block_error_payload($row), 403);
}

function account_action_tokens_table_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $table = DB_TABLE_PREFIX . 'account_action_tokens';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $table)) {
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
        $stmt->execute(['table_name' => $table]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function ensure_account_action_tokens_table_available(PDO $pdo): void
{
    if (account_action_tokens_table_available($pdo)) {
        return;
    }
    json_out([
        'ok' => false,
        'error' => 'Account action token storage is not initialized. Run migration.',
    ], 503);
}

function account_action_ttl_seconds(string $action): int
{
    $normalized = normalize_account_action($action);
    if ($normalized === 'reactivate') {
        $ttl = (int) ACCOUNT_REACTIVATION_TOKEN_TTL_SEC;
        return $ttl > 300 ? $ttl : 86_400;
    }
    if ($normalized === 'delete') {
        $ttl = (int) ACCOUNT_DELETION_TOKEN_TTL_SEC;
        return $ttl > 300 ? $ttl : 3_600;
    }
    return 3_600;
}

function normalize_account_action(string $action): string
{
    $normalized = strtolower(trim($action));
    if ($normalized === 'reactivate') {
        return 'reactivate';
    }
    if ($normalized === 'delete') {
        return 'delete';
    }
    return '';
}

function app_base_url(): string
{
    $configured = trim((string) APP_BASE_URL);
    if ($configured !== '') {
        return rtrim($configured, '/');
    }
    return 'https://splyto.egm.lv';
}

function revoke_refresh_tokens_for_user(PDO $pdo, int $userId): void
{
    if ($userId <= 0 || !function_exists('refresh_tokens_table_available')) {
        return;
    }
    if (!refresh_tokens_table_available($pdo)) {
        return;
    }

    $stmt = $pdo->prepare(
        'UPDATE ' . table_name('refresh_tokens') . '
         SET revoked_at = COALESCE(revoked_at, UTC_TIMESTAMP())
         WHERE user_id = :user_id'
    );
    $stmt->execute(['user_id' => $userId]);
}

function deactivate_push_tokens_for_user(PDO $pdo, int $userId): void
{
    if ($userId <= 0 || !function_exists('push_tokens_table_available')) {
        return;
    }
    if (!push_tokens_table_available($pdo)) {
        return;
    }

    $stmt = $pdo->prepare(
        'UPDATE ' . table_name('push_tokens') . '
         SET is_active = 0,
             updated_at = CURRENT_TIMESTAMP
         WHERE user_id = :user_id
           AND is_active = 1'
    );
    $stmt->execute(['user_id' => $userId]);
}
