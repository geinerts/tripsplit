<?php
declare(strict_types=1);

require_once __DIR__ . '/../helpers/helper_account_action_proofs.php';

function account_action_token_is_well_formed(string $token): bool
{
    return (bool) preg_match('/^[a-f0-9]{64}$/D', $token);
}

function deactivate_account_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $password = (string) ($body['password'] ?? '');

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
        if (resolve_user_id_from_access_token(bearer_access_token_from_header(), $pdo) !== $userId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Please sign in again.'], 401);
        }

        $email = trim((string) ($user['email'] ?? ''));
        $hash = (string) ($user['password_hash'] ?? '');
        $requiresCredentials = ((int) ($user['credentials_required'] ?? 1)) === 1;
        if ($email === '' || $requiresCredentials || $hash === ''
            || $password === '' || !password_verify($password, $hash)) {
            $pdo->rollBack();
            json_out(['ok' => false, 'code' => 'REAUTHENTICATION_REQUIRED',
                'error' => 'Confirm with your current password or request a deactivation email.'], 403);
        }
        ensure_refresh_tokens_table_available($pdo);

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
        if (account_action_tokens_table_available($pdo)) {
            $pdo->prepare('UPDATE ' . table_name('account_action_tokens')
                . ' SET used_at = UTC_TIMESTAMP() WHERE user_id = :id AND used_at IS NULL')
                ->execute(['id' => $userId]);
        }

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
    request_account_lifecycle_link('reactivate');
}

function request_account_deletion_link_action(): void
{
    request_account_lifecycle_link('delete');
}

function request_account_lifecycle_link(string $action): void
{
    require_post();
    $body = read_json();
    $me = $action === 'delete' ? get_me() : null;
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    if ($action === 'reactivate' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok' => false, 'error' => 'Email is invalid.'], 400);
    }
    $pdo = db();
    $scope = $action === 'delete' ? 'delete_link' : 'reactivate_link';
    enforce_rate_limit($pdo, $scope . '_ip', client_ip_address(), 10, 900, true);
    enforce_rate_limit($pdo, $scope . ($me ? '_user' : '_email'),
        $me ? (string) $me['id'] : $email, 3, 3600, true);
    enforce_rate_limit($pdo, $scope . '_global', 'all', 100, 3600, true);
    ensure_account_action_proof_schema($pdo);
    $userId = (int) ($me['id'] ?? 0);
    if ($action === 'reactivate') {
        $stmt = $pdo->prepare('SELECT id FROM ' . table_name('users') . ' WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);
        $userId = (int) $stmt->fetchColumn();
    }
    $proof = null;
    $pdo->beginTransaction();
    try {
        $user = lock_account_action_user($pdo, $userId);
        if (!$user || !account_action_user_is_eligible($user, $action)
            || ($action === 'reactivate' && strtolower(trim((string) $user['email'])) !== $email)) {
            $pdo->rollBack();
            if ($action === 'reactivate') { json_out(['ok' => true]); }
            json_out(['ok' => false, 'error' => 'A verified active account is required.'], 403);
        }
        if ($action === 'delete') {
            if (resolve_user_id_from_access_token(bearer_access_token_from_header(), $pdo) !== $userId) {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Please sign in again.'], 401);
            }
            $password = (string) ($body['password'] ?? '');
            $hasSocialIdentity = user_has_social_identity($pdo, $userId);
            // Email confirmation is always required; keep the existing local-password request check.
            if ((!$hasSocialIdentity || $password !== '')
                && ($password === '' || !password_verify($password, (string) $user['password_hash']))) {
                $pdo->rollBack();
                json_out(['ok' => false, 'code' => 'REAUTHENTICATION_REQUIRED',
                    'error' => 'Confirm your current password to request the deletion email.'], 403);
            }
        }
        $proof = create_account_action_link_token($pdo, $user, $action);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $error;
    }
    if ($proof !== null) {
        $path = $action === 'delete' ? 'delete-account.php' : 'reactivate-account.php';
        $url = app_base_url() . '/api/' . $path . '?token=' . urlencode($proof['token']);
        try {
            $html = $action === 'delete'
                ? build_account_delete_email($url, (string) $user['nickname'])
                : build_account_reactivation_email($url, (string) $user['nickname']);
            $sent = send_email_via_resend((string) $user['email'],
                $action === 'delete' ? 'Confirm permanent account deletion' : 'Reactivate your Splyto account', $html);
        } catch (Throwable $error) { $sent = false; }
        if (!$sent) {
            $pdo->prepare('UPDATE ' . table_name('account_action_tokens')
                . ' SET used_at = UTC_TIMESTAMP() WHERE id = :id AND used_at IS NULL')
                ->execute(['id' => $proof['id']]);
            if ($action === 'delete') {
                json_out(['ok' => false, 'error' => 'Could not send the confirmation email. Try again later.'], 503);
            }
        }
    }
    json_out(['ok' => true]);
}

function confirm_reactivation_action(): void
{
    confirm_account_lifecycle_link('reactivate');
}

function confirm_account_deletion_action(): void
{
    confirm_account_lifecycle_link('delete');
}

function confirm_account_lifecycle_link(string $action): void
{
    require_post();
    $body = read_json();
    $token = is_string($body['token'] ?? null) ? $body['token'] : '';
    $invalid = ['ok' => false, 'error' => 'Invalid or expired account confirmation link.'];
    if (!account_action_token_is_well_formed($token)) { json_out($invalid, 400); }
    $pdo = db();
    $scope = $action === 'delete' ? 'confirm_deletion' : 'confirm_reactivation';
    enforce_rate_limit($pdo, $scope . '_ip', client_ip_address(), 20, 900, true);
    enforce_rate_limit($pdo, $scope . '_token', hash('sha256', $token), 5, 900, true);
    ensure_account_action_proof_schema($pdo);
    ensure_refresh_tokens_table_available($pdo);
    $table = table_name('account_action_tokens');
    $hash = hash('sha256', $token);
    $lookup = $pdo->prepare('SELECT user_id FROM ' . $table . ' WHERE token_hash = :hash AND action = :action');
    $lookup->execute(['hash' => $hash, 'action' => $action]);
    $userId = (int) $lookup->fetchColumn();
    $avatarPath = '';
    $pdo->beginTransaction();
    try {
        // All lifecycle flows lock the user first, then the proof, avoiding opposite lock ordering.
        $user = lock_account_action_user($pdo, $userId);
        $stmt = $pdo->prepare('SELECT credential_state_hash FROM ' . $table . '
            WHERE token_hash = :hash AND action = :action AND user_id = :user
              AND used_at IS NULL AND expires_at > UTC_TIMESTAMP() LIMIT 1 FOR UPDATE');
        $stmt->execute(['hash' => $hash, 'action' => $action, 'user' => $userId]);
        $proof = $stmt->fetch();
        if (!$user || !account_action_user_is_eligible($user, $action) || !$proof
            || !hash_equals(account_action_proof_state($user, $action), (string) $proof['credential_state_hash'])) {
            $pdo->rollBack();
            json_out($invalid, 400);
        }
        if ($action === 'reactivate') {
            $pdo->prepare('UPDATE ' . table_name('users') . '
                SET account_status = "active", deactivated_at = NULL, deleted_at = NULL WHERE id = :id')
                ->execute(['id' => $userId]);
        } else {
            $avatarPath = trim((string) ($user['avatar_path'] ?? ''));
            $pdo->prepare('DELETE FROM ' . table_name('friends')
                . ' WHERE user_a_id = :a OR user_b_id = :b')->execute(['a' => $userId, 'b' => $userId]);
            if (social_auth_identity_table_available($pdo)) {
                $pdo->prepare('DELETE FROM ' . table_name('user_identities') . ' WHERE user_id = :id')
                    ->execute(['id' => $userId]);
            }
            $names = users_name_columns_available($pdo) ? 'first_name = "Deleted", last_name = "User", ' : '';
            $paymentFields = deleted_account_payment_assignments($pdo);
            $pdo->prepare('UPDATE ' . table_name('users') . ' SET ' . $names . $paymentFields . '
                nickname = "Deleted User", email = NULL, password_hash = NULL, credentials_required = 1,
                email_verified_at = NULL, avatar_path = NULL, device_token = :device,
                account_status = "deleted", deactivated_at = UTC_TIMESTAMP(), deleted_at = UTC_TIMESTAMP()
                WHERE id = :id')->execute(['device' => bin2hex(random_bytes(32)), 'id' => $userId]);
        }
        revoke_refresh_tokens_for_user($pdo, $userId);
        deactivate_push_tokens_for_user($pdo, $userId);
        consume_account_action_proofs($pdo, $userId);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $error;
    }
    if ($avatarPath !== '') {
        try { delete_avatar_file($avatarPath); }
        catch (Throwable $error) { error_log('Account deletion avatar cleanup failed.'); }
    }
    json_out($action === 'delete'
        ? ['ok' => true, 'status' => 'deleted', 'user_id' => $userId]
        : ['ok' => true]);
}
