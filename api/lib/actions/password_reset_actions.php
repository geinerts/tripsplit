<?php
declare(strict_types=1);

function ensure_password_reset_security_schema(PDO $pdo): void
{
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name
        AND column_name = 'credential_state_hash'");
    $stmt->execute(['table_name' => trim(table_name('password_resets'), '`')]);
    if (!(bool) $stmt->fetchColumn() || !users_email_verified_at_column_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Password recovery is temporarily unavailable.'], 503);
    }
}

function password_reset_credential_state(array $user): string
{
    return hash('sha256', json_encode([
        (int) $user['id'], strtolower(trim((string) $user['email'])),
        (string) $user['password_hash'], (string) $user['email_verified_at'],
        (int) $user['credentials_required'],
    ], JSON_THROW_ON_ERROR));
}

function password_reset_user_is_eligible(array $user): bool
{
    return user_account_is_active($user) && (int) $user['credentials_required'] === 0
        && !empty($user['email_verified_at']) && !empty($user['email']);
}

function forgot_password_action(): void
{
    require_post();
    $body = read_json();
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok' => false, 'error' => 'Email is invalid.'], 400);
    }
    $pdo = db();
    // Apply identical limits before account lookup, including unknown email addresses.
    enforce_rate_limit($pdo, 'password_reset_request_ip', client_ip_address(), 10, 900, true);
    enforce_rate_limit($pdo, 'password_reset_request_email', $email, 3, 3600, true);
    enforce_rate_limit($pdo, 'password_reset_request_global', 'all', 100, 3600, true);
    ensure_password_reset_security_schema($pdo);
    $users = table_name('users');
    $resets = table_name('password_resets');
    $token = null;
    $tokenId = 0;
    $firstName = '';
    $deliveryEmail = '';
    $pdo->beginTransaction();
    try {
        $nameSelect = users_name_columns_available($pdo) ? 'first_name' : 'nickname AS first_name';
        $stmt = $pdo->prepare('SELECT id, email, password_hash, credentials_required,
            ' . users_account_status_select_sql($pdo) . $nameSelect . '
            FROM ' . $users . ' WHERE email = :email LIMIT 1 FOR UPDATE');
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();
        if ($user && password_reset_user_is_eligible($user)) {
            // Rolling per-account limits remain effective across fixed-window boundaries.
            $recent = $pdo->prepare('SELECT created_at FROM ' . $resets . '
                WHERE user_id = :user_id AND created_at > :cutoff ORDER BY created_at DESC FOR UPDATE');
            $recent->execute(['user_id' => $user['id'], 'cutoff' => gmdate('Y-m-d H:i:s', time() - 3600)]);
            $attempts = $recent->fetchAll(PDO::FETCH_COLUMN);
            if (count($attempts) < 3 && ($attempts === []
                || $attempts[0] <= gmdate('Y-m-d H:i:s', time() - 60))) {
                $token = bin2hex(random_bytes(32));
                $pdo->prepare('INSERT INTO ' . $resets . '
                    (user_id, token_hash, credential_state_hash, expires_at)
                    VALUES (:user_id, :token_hash, :state, :expires_at)')->execute([
                        'user_id' => $user['id'], 'token_hash' => hash('sha256', $token),
                        'state' => password_reset_credential_state($user),
                        'expires_at' => gmdate('Y-m-d H:i:s', time() + 3600),
                    ]);
                $tokenId = (int) $pdo->lastInsertId();
                $firstName = (string) ($user['first_name'] ?? 'there');
                $deliveryEmail = (string) $user['email'];
            }
        }
        // A new request does not invalidate an earlier delivered link.
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $error;
    }
    if ($token !== null) {
        $url = rtrim((string) APP_BASE_URL, '/') . '/reset-password.php?token=' . urlencode($token);
        try {
            $sent = send_email_via_resend($deliveryEmail, 'Reset your Splyto password',
                build_password_reset_email($url, $firstName));
        } catch (Throwable $error) {
            // Do not expose delivery/account existence or provider error details to callers.
            $sent = false;
        }
        if (!$sent) {
            $pdo->prepare('UPDATE ' . $resets . ' SET used_at = UTC_TIMESTAMP() WHERE id = :id')
                ->execute(['id' => $tokenId]);
        }
    }
    json_out(['ok' => true]);
}

function reset_password_action(): void
{
    require_post();
    $body = read_json();
    $token = trim((string) ($body['token'] ?? ''));
    if (!preg_match('/^[a-f0-9]{64}$/D', $token)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired reset link.'], 400);
    }
    $pdo = db();
    enforce_rate_limit($pdo, 'password_reset_confirm_ip', client_ip_address(), 20, 900, true);
    enforce_rate_limit($pdo, 'password_reset_confirm_token', hash('sha256', $token), 5, 900, true);
    ensure_password_reset_security_schema($pdo);
    $password = validate_password_plain((string) ($body['password'] ?? ''));
    ensure_refresh_tokens_table_available($pdo);
    $resets = table_name('password_resets');
    $users = table_name('users');
    $tokenHash = hash('sha256', $token);
    $lookup = $pdo->prepare('SELECT user_id FROM ' . $resets . ' WHERE token_hash = :hash LIMIT 1');
    $lookup->execute(['hash' => $tokenHash]);
    $userId = (int) $lookup->fetchColumn();
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid or expired reset link.'], 400);
    }
    $pdo->beginTransaction();
    try {
        // Same user-first lock order as password change and enrollment.
        $userStmt = $pdo->prepare('SELECT id, email, password_hash, credentials_required, '
            . users_account_status_select_sql($pdo) . 'nickname FROM ' . $users . '
            WHERE id = :id FOR UPDATE');
        $userStmt->execute(['id' => $userId]);
        $user = $userStmt->fetch();
        $stmt = $pdo->prepare('SELECT id, credential_state_hash FROM ' . $resets . '
            WHERE token_hash = :hash AND user_id = :user_id AND used_at IS NULL
              AND expires_at > UTC_TIMESTAMP() LIMIT 1 FOR UPDATE');
        $stmt->execute(['hash' => $tokenHash, 'user_id' => $userId]);
        $reset = $stmt->fetch();
        if (!$user || !password_reset_user_is_eligible($user) || !$reset
            || !hash_equals(password_reset_credential_state($user), (string) $reset['credential_state_hash'])) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid or expired reset link.'], 400);
        }
        $hash = password_hash($password, credential_password_algo());
        if (!is_string($hash) || $hash === '') { throw new RuntimeException('Failed to hash password.'); }
        $pdo->prepare('UPDATE ' . $users . ' SET password_hash = :hash WHERE id = :id')
            ->execute(['hash' => $hash, 'id' => $userId]);
        $pdo->prepare('UPDATE ' . $resets . ' SET used_at = UTC_TIMESTAMP()
            WHERE user_id = :id AND used_at IS NULL')->execute(['id' => $userId]);
        revoke_refresh_tokens_for_user($pdo, $userId);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $error;
    }
    json_out(['ok' => true]);
}
