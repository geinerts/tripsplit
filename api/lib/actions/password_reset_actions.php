<?php
declare(strict_types=1);

/**
 * forgot_password — accepts email, sends reset link via Resend.
 *
 * Always returns {"ok":true} to prevent email enumeration attacks.
 */
function forgot_password_action(): void
{
    require_post();

    $body  = read_json();
    $email = strtolower(trim((string) ($body['email'] ?? '')));

    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok' => false, 'error' => 'Email is invalid.'], 400);
    }

    $pdo        = db();
    $usersTable = table_name('users');
    $resetsTable = table_name('password_resets');
    $activeFilter = users_active_filter_sql($pdo, '');

    // Look up user — silent success if not found (anti-enumeration)
    $stmt = $pdo->prepare(
        'SELECT id, first_name, email
         FROM ' . $usersTable . '
         WHERE email = :email
           AND credentials_required = 0
           ' . $activeFilter . '
         LIMIT 1'
    );
    $stmt->execute(['email' => $email]);
    $user = $stmt->fetch();

    if (!$user) {
        // Don't reveal whether email exists
        json_out(['ok' => true]);
    }

    $userId    = (int) $user['id'];
    $firstName = (string) ($user['first_name'] ?? 'there');

    // Invalidate existing unused tokens for this user
    $pdo->prepare(
        'UPDATE ' . $resetsTable . ' SET used_at = NOW()
         WHERE user_id = :user_id AND used_at IS NULL AND expires_at > NOW()'
    )->execute(['user_id' => $userId]);

    // Generate secure token
    $token     = bin2hex(random_bytes(32)); // 64 hex chars
    $tokenHash = hash('sha256', $token);
    $expiresAt = date('Y-m-d H:i:s', time() + 3600); // 1 hour

    $pdo->prepare(
        'INSERT INTO ' . $resetsTable . ' (user_id, token_hash, expires_at)
         VALUES (:user_id, :token_hash, :expires_at)'
    )->execute([
        'user_id'    => $userId,
        'token_hash' => $tokenHash,
        'expires_at' => $expiresAt,
    ]);

    // Build reset URL
    $appBaseUrl = rtrim((string) (defined('APP_BASE_URL') ? APP_BASE_URL : 'https://splyto.egm.lv'), '/');
    $resetUrl   = $appBaseUrl . '/reset-password.php?token=' . urlencode($token);

    // Send email
    $html = build_password_reset_email($resetUrl, $firstName);
    send_email_via_resend($email, 'Reset your Splyto password', $html);

    json_out(['ok' => true]);
}

/**
 * reset_password — validates token, sets new password.
 */
function reset_password_action(): void
{
    require_post();

    $body     = read_json();
    $token    = trim((string) ($body['token'] ?? ''));
    $password = (string) ($body['password'] ?? '');

    if ($token === '') {
        json_out(['ok' => false, 'error' => 'Invalid or expired reset link.'], 400);
    }

    $password = validate_password_plain($password);

    $pdo         = db();
    $resetsTable = table_name('password_resets');
    $usersTable  = table_name('users');

    $tokenHash = hash('sha256', $token);

    $stmt = $pdo->prepare(
        'SELECT id, user_id FROM ' . $resetsTable . '
         WHERE token_hash = :token_hash
           AND used_at IS NULL
           AND expires_at > NOW()
         LIMIT 1'
    );
    $stmt->execute(['token_hash' => $tokenHash]);
    $reset = $stmt->fetch();

    if (!$reset) {
        json_out(['ok' => false, 'error' => 'Invalid or expired reset link.'], 400);
    }

    $resetId = (int) $reset['id'];
    $userId  = (int) $reset['user_id'];

    $accountSelect = users_account_status_select_sql($pdo);
    $userStmt = $pdo->prepare(
        'SELECT id, ' . $accountSelect . 'email
         FROM ' . $usersTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $userStmt->execute(['id' => $userId]);
    $user = $userStmt->fetch();
    if (!$user || !user_account_is_active((array) $user)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired reset link.'], 400);
    }

    // Update password
    $passwordHash = password_hash($password, credential_password_algo());
    $pdo->prepare(
        'UPDATE ' . $usersTable . ' SET password_hash = :hash WHERE id = :id'
    )->execute(['hash' => $passwordHash, 'id' => $userId]);

    // Mark token as used
    $pdo->prepare(
        'UPDATE ' . $resetsTable . ' SET used_at = NOW() WHERE id = :id'
    )->execute(['id' => $resetId]);

    // Revoke all existing sessions for security
    $pdo->prepare(
        'UPDATE ' . table_name('refresh_tokens') . '
         SET revoked_at = NOW() WHERE user_id = :user_id AND revoked_at IS NULL'
    )->execute(['user_id' => $userId]);

    json_out(['ok' => true]);
}
