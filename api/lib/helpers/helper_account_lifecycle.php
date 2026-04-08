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

function users_email_verified_at_column_available(PDO $pdo): bool
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
               AND column_name = \'email_verified_at\''
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
        return '\'active\' AS account_status, NULL AS deactivated_at, NULL AS deleted_at, NULL AS email_verified_at, ';
    }

    $prefix = sql_alias_prefix($alias);
    $deactivated = users_deactivated_at_column_available($pdo)
        ? $prefix . 'deactivated_at'
        : 'NULL';
    $deleted = users_deleted_at_column_available($pdo)
        ? $prefix . 'deleted_at'
        : 'NULL';
    $emailVerifiedAt = users_email_verified_at_column_available($pdo)
        ? $prefix . 'email_verified_at'
        : 'NULL';

    return $prefix . 'account_status AS account_status, '
        . $deactivated . ' AS deactivated_at, '
        . $deleted . ' AS deleted_at, '
        . $emailVerifiedAt . ' AS email_verified_at, ';
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

function email_verification_required(): bool
{
    return (bool) EMAIL_VERIFICATION_REQUIRED;
}

function email_verification_token_ttl_seconds(): int
{
    $ttl = (int) EMAIL_VERIFICATION_TOKEN_TTL_SEC;
    return $ttl > 300 ? $ttl : 86_400;
}

function email_verification_grace_days(): int
{
    $days = (int) EMAIL_VERIFICATION_GRACE_DAYS;
    if ($days < 1) {
        return 7;
    }
    if ($days > 365) {
        return 365;
    }
    return $days;
}

function email_verification_cleanup_batch_limit(): int
{
    $limit = (int) EMAIL_VERIFICATION_CLEANUP_BATCH_LIMIT;
    if ($limit < 1) {
        return 300;
    }
    if ($limit > 2000) {
        return 2000;
    }
    return $limit;
}

function user_has_email_credentials(array $row): bool
{
    $credentialsRequired = ((int) ($row['credentials_required'] ?? 1)) === 1;
    $email = strtolower(trim((string) ($row['email'] ?? '')));
    return !$credentialsRequired && $email !== '';
}

function user_email_is_verified(array $row): bool
{
    if (!email_verification_required()) {
        return true;
    }
    if (!user_has_email_credentials($row)) {
        return true;
    }
    $verifiedAt = trim((string) ($row['email_verified_at'] ?? ''));
    return $verifiedAt !== '';
}

function user_requires_email_verification(array $row): bool
{
    return !user_email_is_verified($row);
}

function user_email_verification_block_error_payload(array $row): array
{
    $status = user_account_status($row);
    if ($status === 'deactivated') {
        return [
            'ok' => false,
            'code' => 'EMAIL_NOT_VERIFIED',
            'error' => 'Email is not verified. Account is deactivated until verification.',
        ];
    }
    return [
        'ok' => false,
        'code' => 'EMAIL_NOT_VERIFIED',
        'error' => 'Email is not verified. Check your inbox for the verification link.',
    ];
}

function assert_user_email_verified(array $row): void
{
    if (user_email_is_verified($row)) {
        return;
    }
    json_out(user_email_verification_block_error_payload($row), 403);
}

function assert_user_account_is_active(array $row): void
{
    if (user_account_is_active($row)) {
        return;
    }
    json_out(user_account_block_error_payload($row), 403);
}

function email_verification_tokens_table_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $table = DB_TABLE_PREFIX . 'email_verification_tokens';
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

function ensure_email_verification_tokens_table_available(PDO $pdo): void
{
    if (email_verification_tokens_table_available($pdo)) {
        return;
    }
    json_out([
        'ok' => false,
        'error' => 'Email verification token storage is not initialized. Run migration.',
    ], 503);
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

function process_unverified_account_deactivation(PDO $pdo, array $options = []): array
{
    $enabled = email_verification_required();
    $hasAccountStatus = users_account_status_column_available($pdo);
    $hasEmailVerified = users_email_verified_at_column_available($pdo);
    $limit = (int) ($options['limit'] ?? email_verification_cleanup_batch_limit());
    $limit = max(1, min(2000, $limit));
    $dryRun = !empty($options['dry_run']);
    $graceDays = email_verification_grace_days();

    $result = [
        'enabled' => $enabled,
        'table_ready' => $hasAccountStatus && $hasEmailVerified,
        'dry_run' => $dryRun,
        'limit' => $limit,
        'grace_days' => $graceDays,
        'picked' => 0,
        'deactivated' => 0,
        'user_ids' => [],
    ];

    if (!$enabled || !$hasAccountStatus || !$hasEmailVerified) {
        return $result;
    }

    $usersTable = table_name('users');
    $select = $pdo->query(
        'SELECT id
         FROM ' . $usersTable . '
         WHERE account_status = "active"
           AND credentials_required = 0
           AND email IS NOT NULL
           AND email <> ""
           AND email_verified_at IS NULL
           AND created_at <= (UTC_TIMESTAMP() - INTERVAL ' . $graceDays . ' DAY)
         ORDER BY created_at ASC, id ASC
         LIMIT ' . $limit
    );
    $rows = $select ? $select->fetchAll() : [];
    $userIds = array_map(
        static fn(array $row): int => (int) ($row['id'] ?? 0),
        is_array($rows) ? $rows : []
    );
    $userIds = array_values(array_filter($userIds, static fn(int $id): bool => $id > 0));

    $result['picked'] = count($userIds);
    $result['user_ids'] = $userIds;

    if ($dryRun || !$userIds) {
        return $result;
    }

    $setDeactivatedAt = users_deactivated_at_column_available($pdo)
        ? ', deactivated_at = UTC_TIMESTAMP()'
        : '';
    $setDeletedAt = users_deleted_at_column_available($pdo)
        ? ', deleted_at = NULL'
        : '';
    $placeholders = implode(',', array_fill(0, count($userIds), '?'));

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET account_status = "deactivated"' . $setDeactivatedAt . $setDeletedAt . '
             WHERE id IN (' . $placeholders . ')
               AND account_status = "active"
               AND credentials_required = 0
               AND email IS NOT NULL
               AND email <> ""
               AND email_verified_at IS NULL'
        );
        $stmt->execute($userIds);
        $result['deactivated'] = (int) $stmt->rowCount();
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    foreach ($userIds as $userId) {
        revoke_refresh_tokens_for_user($pdo, $userId);
        deactivate_push_tokens_for_user($pdo, $userId);
    }

    return $result;
}
