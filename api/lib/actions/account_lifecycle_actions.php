<?php
declare(strict_types=1);

function account_action_token_is_well_formed(string $token): bool
{
    return (bool) preg_match('/^[a-f0-9]{64}$/', strtolower(trim($token)));
}

function create_account_action_link_token(PDO $pdo, int $userId, string $action): array
{
    if ($userId <= 0) {
        throw new RuntimeException('Invalid user id for account action token.');
    }
    $action = normalize_account_action($action);
    if ($action === '') {
        throw new RuntimeException('Unsupported account action token type.');
    }

    ensure_account_action_tokens_table_available($pdo);
    $table = table_name('account_action_tokens');
    $ttlSec = account_action_ttl_seconds($action);

    $pdo->prepare(
        'UPDATE ' . $table . '
         SET used_at = COALESCE(used_at, UTC_TIMESTAMP())
         WHERE user_id = :user_id
           AND action = :action
           AND used_at IS NULL
           AND expires_at > UTC_TIMESTAMP()'
    )->execute([
        'user_id' => $userId,
        'action' => $action,
    ]);

    $token = bin2hex(random_bytes(32));
    $tokenHash = hash('sha256', $token);
    $expiresAt = gmdate('Y-m-d H:i:s', time() + $ttlSec);

    $pdo->prepare(
        'INSERT INTO ' . $table . ' (user_id, action, token_hash, expires_at)
         VALUES (:user_id, :action, :token_hash, :expires_at)'
    )->execute([
        'user_id' => $userId,
        'action' => $action,
        'token_hash' => $tokenHash,
        'expires_at' => $expiresAt,
    ]);

    return [
        'token' => $token,
        'expires_at' => $expiresAt,
    ];
}

function deactivate_account_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $password = trim((string) ($body['password'] ?? ''));

    $pdo = db();
    $userId = (int) ($me['id'] ?? 0);
    enforce_rate_limit(
        $pdo,
        'deactivate_account_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'deactivate_account_user',
        (string) $userId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    if (!users_account_status_column_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Account deactivation is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $usersTable = table_name('users');

    $pdo->beginTransaction();
    try {
        $nameSelect = users_name_columns_available($pdo)
            ? 'first_name, '
            : 'NULL AS first_name, ';
        $accountSelect = users_account_status_select_sql($pdo);
        $stmt = $pdo->prepare(
            'SELECT id, email, password_hash, credentials_required, avatar_path, '
            . $nameSelect . $accountSelect . '
             nickname
             FROM ' . $usersTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $stmt->execute(['id' => $userId]);
        $user = $stmt->fetch();
        if (!$user) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'User not found.'], 404);
        }

        if (!user_account_is_active((array) $user)) {
            $pdo->rollBack();
            json_out(user_account_block_error_payload((array) $user), 403);
        }

        $email = trim((string) ($user['email'] ?? ''));
        $hash = (string) ($user['password_hash'] ?? '');
        $requiresCredentials = ((int) ($user['credentials_required'] ?? 1)) === 1;
        $hasSocialIdentity = user_has_social_identity($pdo, $userId);

        if ($email === '') {
            $pdo->rollBack();
            json_out([
                'ok' => false,
                'error' => 'Add email first before deactivating your account.',
            ], 409);
        }
        if (!$hasSocialIdentity) {
            if ($requiresCredentials || $hash === '') {
                $pdo->rollBack();
                json_out([
                    'ok' => false,
                    'error' => 'Add email and password first before deactivating your account.',
                ], 409);
            }
            if ($password === '') {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Password is required.'], 400);
            }
            if (!password_verify($password, $hash)) {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Password is incorrect.'], 401);
            }
        } elseif ($password !== '' && $hash !== '' && !password_verify($password, $hash)) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Password is incorrect.'], 401);
        }

        $setDeletedAt = users_deleted_at_column_available($pdo)
            ? ', deleted_at = NULL'
            : '';
        $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET account_status = "deactivated",
                 deactivated_at = UTC_TIMESTAMP()' . $setDeletedAt . '
             WHERE id = :id'
        )->execute(['id' => $userId]);

        revoke_refresh_tokens_for_user($pdo, $userId);
        deactivate_push_tokens_for_user($pdo, $userId);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    json_out([
        'ok' => true,
        'status' => 'deactivated',
    ]);
}

function request_reactivation_link_action(): void
{
    require_post();
    $body = read_json();
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok' => false, 'error' => 'Email is invalid.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'reactivate_link_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'reactivate_link_email',
        $email,
        RATE_LIMIT_LOGIN_EMAIL_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    if (!users_account_status_column_available($pdo) || !account_action_tokens_table_available($pdo)) {
        json_out(['ok' => true]);
    }

    $usersTable = table_name('users');
    $nameSelect = users_name_columns_available($pdo)
        ? 'first_name, '
        : 'NULL AS first_name, ';
    $accountSelect = users_account_status_select_sql($pdo);
    $stmt = $pdo->prepare(
        'SELECT id, email, credentials_required, ' . $nameSelect . $accountSelect . '
         nickname
         FROM ' . $usersTable . '
         WHERE email = :email
         LIMIT 1'
    );
    $stmt->execute(['email' => $email]);
    $user = $stmt->fetch();
    if (!$user) {
        json_out(['ok' => true]);
    }

    $status = user_account_status((array) $user);
    if ($status !== 'deactivated') {
        json_out(['ok' => true]);
    }

    $userId = (int) ($user['id'] ?? 0);
    if ($userId <= 0 || ((int) ($user['credentials_required'] ?? 1)) === 1) {
        json_out(['ok' => true]);
    }

    $tokenMeta = create_account_action_link_token($pdo, $userId, 'reactivate');
    $plainToken = (string) ($tokenMeta['token'] ?? '');
    if ($plainToken === '') {
        json_out(['ok' => true]);
    }

    $firstName = trim((string) ($user['first_name'] ?? ''));
    if ($firstName === '') {
        $firstName = trim((string) ($user['nickname'] ?? 'there'));
    }

    $reactivateUrl = app_base_url() . '/api/reactivate-account.php?token=' . urlencode($plainToken);
    $html = build_account_reactivation_email($reactivateUrl, $firstName);
    send_email_via_resend($email, 'Reactivate your Splyto account', $html);

    json_out(['ok' => true]);
}

function confirm_reactivation_action(): void
{
    require_post();
    $body = read_json();
    $token = strtolower(trim((string) ($body['token'] ?? '')));
    if (!account_action_token_is_well_formed($token)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired reactivation link.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'confirm_reactivation_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    if (!users_account_status_column_available($pdo) || !account_action_tokens_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Account reactivation is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $table = table_name('account_action_tokens');
    $usersTable = table_name('users');
    $tokenHash = hash('sha256', $token);

    $pdo->beginTransaction();
    try {
        $tokenStmt = $pdo->prepare(
            'SELECT id, user_id
             FROM ' . $table . '
             WHERE action = "reactivate"
               AND token_hash = :token_hash
               AND used_at IS NULL
               AND expires_at > UTC_TIMESTAMP()
             LIMIT 1
             FOR UPDATE'
        );
        $tokenStmt->execute(['token_hash' => $tokenHash]);
        $tokenRow = $tokenStmt->fetch();
        if (!$tokenRow) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid or expired reactivation link.'], 400);
        }

        $tokenId = (int) ($tokenRow['id'] ?? 0);
        $userId = (int) ($tokenRow['user_id'] ?? 0);
        if ($tokenId <= 0 || $userId <= 0) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid reactivation token state.'], 400);
        }

        $accountSelect = users_account_status_select_sql($pdo);
        $userStmt = $pdo->prepare(
            'SELECT id, ' . $accountSelect . 'email
             FROM ' . $usersTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $userStmt->execute(['id' => $userId]);
        $user = $userStmt->fetch();
        if (!$user) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'User not found for this link.'], 404);
        }

        $status = user_account_status((array) $user);
        if ($status === 'deleted') {
            $pdo->prepare(
                'UPDATE ' . $table . '
                 SET used_at = UTC_TIMESTAMP()
                 WHERE id = :id'
            )->execute(['id' => $tokenId]);
            $pdo->commit();
            json_out(user_account_block_error_payload((array) $user), 403);
        }

        $setDeletedAt = users_deleted_at_column_available($pdo)
            ? ', deleted_at = NULL'
            : '';
        $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET account_status = "active",
                 deactivated_at = NULL' . $setDeletedAt . '
             WHERE id = :id'
        )->execute(['id' => $userId]);

        $pdo->prepare(
            'UPDATE ' . $table . '
             SET used_at = UTC_TIMESTAMP()
             WHERE id = :id'
        )->execute(['id' => $tokenId]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    json_out(['ok' => true]);
}

function request_account_deletion_link_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $password = trim((string) ($body['password'] ?? ''));

    $pdo = db();
    $userId = (int) ($me['id'] ?? 0);
    enforce_rate_limit(
        $pdo,
        'delete_link_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'delete_link_user',
        (string) $userId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    if (!users_account_status_column_available($pdo) || !account_action_tokens_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Account deletion is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $usersTable = table_name('users');

    $nameSelect = users_name_columns_available($pdo)
        ? 'first_name, '
        : 'NULL AS first_name, ';
    $accountSelect = users_account_status_select_sql($pdo);
    $stmt = $pdo->prepare(
        'SELECT id, email, password_hash, credentials_required, ' . $nameSelect . $accountSelect . '
         nickname
         FROM ' . $usersTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $stmt->execute(['id' => $userId]);
    $user = $stmt->fetch();
    if (!$user) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }
    if (!user_account_is_active((array) $user)) {
        json_out(user_account_block_error_payload((array) $user), 403);
    }

    $email = strtolower(trim((string) ($user['email'] ?? '')));
    $hash = (string) ($user['password_hash'] ?? '');
    $requiresCredentials = ((int) ($user['credentials_required'] ?? 1)) === 1;
    $hasSocialIdentity = user_has_social_identity($pdo, $userId);

    if ($email === '') {
        json_out([
            'ok' => false,
            'error' => 'Add email first before requesting account deletion.',
        ], 409);
    }
    if (!$hasSocialIdentity) {
        if ($requiresCredentials || $hash === '') {
            json_out([
                'ok' => false,
                'error' => 'Add email and password first before requesting account deletion.',
            ], 409);
        }
        if ($password === '') {
            json_out(['ok' => false, 'error' => 'Password is required.'], 400);
        }
        if (!password_verify($password, $hash)) {
            json_out(['ok' => false, 'error' => 'Password is incorrect.'], 401);
        }
    } elseif ($password !== '' && $hash !== '' && !password_verify($password, $hash)) {
        json_out(['ok' => false, 'error' => 'Password is incorrect.'], 401);
    }

    $tokenMeta = create_account_action_link_token($pdo, $userId, 'delete');
    $plainToken = (string) ($tokenMeta['token'] ?? '');
    if ($plainToken === '') {
        json_out(['ok' => false, 'error' => 'Could not create deletion link.'], 500);
    }

    $firstName = trim((string) ($user['first_name'] ?? ''));
    if ($firstName === '') {
        $firstName = trim((string) ($user['nickname'] ?? 'there'));
    }

    $deleteUrl = app_base_url() . '/api/delete-account.php?token=' . urlencode($plainToken);
    $html = build_account_delete_email($deleteUrl, $firstName);
    $sent = send_email_via_resend($email, 'Confirm permanent account deletion', $html);
    if (!$sent) {
        json_out([
            'ok' => false,
            'error' => 'Could not send deletion email right now. Please try again later.',
        ], 503);
    }

    json_out(['ok' => true]);
}

function confirm_account_deletion_action(): void
{
    require_post();
    $body = read_json();
    $token = strtolower(trim((string) ($body['token'] ?? '')));
    if (!account_action_token_is_well_formed($token)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired deletion link.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'confirm_deletion_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    if (!users_account_status_column_available($pdo) || !account_action_tokens_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Account deletion is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $tokenHash = hash('sha256', $token);
    $tokensTable = table_name('account_action_tokens');
    $usersTable = table_name('users');
    $friendsTable = table_name('friends');
    $userId = 0;
    $avatarPath = '';

    $pdo->beginTransaction();
    try {
        $tokenStmt = $pdo->prepare(
            'SELECT id, user_id
             FROM ' . $tokensTable . '
             WHERE action = "delete"
               AND token_hash = :token_hash
               AND used_at IS NULL
               AND expires_at > UTC_TIMESTAMP()
             LIMIT 1
             FOR UPDATE'
        );
        $tokenStmt->execute(['token_hash' => $tokenHash]);
        $tokenRow = $tokenStmt->fetch();
        if (!$tokenRow) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid or expired deletion link.'], 400);
        }

        $tokenId = (int) ($tokenRow['id'] ?? 0);
        $userId = (int) ($tokenRow['user_id'] ?? 0);
        if ($tokenId <= 0 || $userId <= 0) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid deletion token state.'], 400);
        }

        $nameSelect = users_name_columns_available($pdo)
            ? 'first_name, last_name, '
            : 'NULL AS first_name, NULL AS last_name, ';
        $accountSelect = users_account_status_select_sql($pdo);
        $userStmt = $pdo->prepare(
            'SELECT id, ' . $nameSelect . $accountSelect . '
                nickname, avatar_path
             FROM ' . $usersTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $userStmt->execute(['id' => $userId]);
        $user = $userStmt->fetch();
        if (!$user) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'User not found for this link.'], 404);
        }

        $status = user_account_status((array) $user);
        if ($status === 'deleted') {
            $pdo->prepare(
                'UPDATE ' . $tokensTable . '
                 SET used_at = UTC_TIMESTAMP()
                 WHERE id = :id'
            )->execute(['id' => $tokenId]);
            $pdo->commit();
            json_out(['ok' => true, 'status' => 'deleted']);
        }

        $avatarPath = trim((string) ($user['avatar_path'] ?? ''));

        $pdo->prepare(
            'DELETE FROM ' . $friendsTable . '
             WHERE user_a_id = :user_a_id OR user_b_id = :user_b_id'
        )->execute([
            'user_a_id' => $userId,
            'user_b_id' => $userId,
        ]);

        if (social_auth_identity_table_available($pdo)) {
            $pdo->prepare(
                'DELETE FROM ' . table_name('user_identities') . '
                 WHERE user_id = :user_id'
            )->execute(['user_id' => $userId]);
        }

        revoke_refresh_tokens_for_user($pdo, $userId);
        deactivate_push_tokens_for_user($pdo, $userId);

        $setNames = '';
        if (users_name_columns_available($pdo)) {
            $setNames = 'first_name = "Deleted", last_name = "User", ';
        }
        $setDeletedAt = users_deleted_at_column_available($pdo)
            ? ', deleted_at = UTC_TIMESTAMP()'
            : '';
        $setDeactivatedAt = users_deactivated_at_column_available($pdo)
            ? ', deactivated_at = UTC_TIMESTAMP()'
            : '';
        $randomDeviceToken = bin2hex(random_bytes(32));

        $updateSql =
            'UPDATE ' . $usersTable . '
             SET ' . $setNames . '
                 nickname = "Deleted User",
                 email = NULL,
                 password_hash = NULL,
                 credentials_required = 1,
                 email_verified_at = NULL,
                 avatar_path = NULL,
                 device_token = :device_token,
                 account_status = "deleted"' . $setDeactivatedAt . $setDeletedAt . '
             WHERE id = :id';
        $pdo->prepare($updateSql)->execute([
            'device_token' => $randomDeviceToken,
            'id' => $userId,
        ]);

        $pdo->prepare(
            'UPDATE ' . $tokensTable . '
             SET used_at = UTC_TIMESTAMP()
             WHERE id = :id'
        )->execute(['id' => $tokenId]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if ($avatarPath !== '') {
        delete_avatar_file($avatarPath);
    }

    json_out(['ok' => true, 'status' => 'deleted', 'user_id' => $userId]);
}
