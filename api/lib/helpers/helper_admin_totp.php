<?php
declare(strict_types=1);

// Administrator 2FA lifecycle. Every admin account must use TOTP; there is no
// password-only mode. See docs/security/admin-mfa.md.

const ADMIN_TOTP_PENDING_TTL_SEC = 600;

/** Returns the matching time step for a 6-digit code, or null. Checks every step in the window. */
function admin_totp_matched_counter(string $secret, string $code, int $now, int $window = 1): ?int
{
    $code = trim($code);
    if ($secret === '' || !preg_match('/^\d{6}$/', $code)) {
        return null;
    }
    $counter = intdiv($now, 30);
    $matched = null;
    for ($i = -$window; $i <= $window; $i++) {
        if (hash_equals(admin_totp_code($secret, $counter + $i), $code)) {
            $matched = $counter + $i;
        }
    }
    return $matched;
}

function admin_session_is_fully_verified(array $sess): bool
{
    return (int) ($sess['totp_enabled'] ?? 0) === 1 && (int) ($sess['is_2fa_verified'] ?? 0) === 1;
}

/** Rolls back the open transaction and sends an error response. */
function admin_totp_fail(PDO $pdo, int $status, string $code, string $error): void
{
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    json_out(['ok' => false, 'code' => $code, 'error' => $error], $status);
}

function admin_totp_lock_user(PDO $pdo, int $adminUserId): array
{
    $stmt = $pdo->prepare('SELECT id, username, password_hash, is_active, totp_enabled, totp_secret,
            totp_pending_secret, totp_pending_created_at, totp_last_counter
        FROM ' . table_name('admin_users') . ' WHERE id = ? FOR UPDATE');
    $stmt->execute([$adminUserId]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);
    if (!is_array($user) || (int) $user['is_active'] !== 1) {
        admin_totp_fail($pdo, 401, 'unauthenticated', 'Not authenticated.');
    }
    return $user;
}

/** Accepts a code for the active secret once; a code that was already used is refused. */
function admin_totp_consume_code(PDO $pdo, array $user, string $code, int $now): bool
{
    $secret = admin_totp_decrypt_secret((string) ($user['totp_secret'] ?? ''));
    $counter = admin_totp_matched_counter($secret, $code, $now);
    $last = $user['totp_last_counter'] === null ? null : (int) $user['totp_last_counter'];
    if ($counter === null || ($last !== null && $counter <= $last)) {
        return false;
    }
    $pdo->prepare('UPDATE ' . table_name('admin_users') . ' SET totp_last_counter = ? WHERE id = ?')
        ->execute([$counter, (int) $user['id']]);
    return true;
}

/**
 * Second login step: marks the session verified after a fresh, unused code.
 * Returns 'ok', 'invalid' or 'enrollment_required'; the caller audits and responds.
 */
function admin_totp_verify_login(PDO $pdo, array $sess, string $code, int $now): string
{
    $pdo->beginTransaction();
    try {
        $user = admin_totp_lock_user($pdo, (int) $sess['admin_user_id']);
        if ((int) $user['totp_enabled'] !== 1) {
            $pdo->rollBack();
            return 'enrollment_required';
        }
        if (!admin_totp_consume_code($pdo, $user, $code, $now)) {
            $pdo->rollBack();
            return 'invalid';
        }
        $pdo->prepare('UPDATE ' . table_name('admin_sessions') . ' SET is_2fa_verified = 1 WHERE token = ?')
            ->execute([(string) $sess['token']]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    return 'ok';
}

/**
 * Starts enrolment or replacement. The new secret is stored as pending only;
 * the working secret stays active until admin_totp_confirm_setup succeeds.
 * Always needs the password. Replacement also needs a verified session and a
 * current code from the existing authenticator.
 */
function admin_totp_begin_setup(PDO $pdo, array $sess, array $body, int $now): array
{
    $password = (string) ($body['password'] ?? '');
    $currentCode = trim((string) ($body['current_code'] ?? ''));
    if ($password === '' || strlen($password) > 4096) {
        json_out(['ok' => false, 'code' => 'reauthentication_required', 'error' => 'Enter your password.'], 400);
    }

    $pdo->beginTransaction();
    try {
        $user = admin_totp_lock_user($pdo, (int) $sess['admin_user_id']);
        $replacing = (int) $user['totp_enabled'] === 1;
        if ($replacing && (int) ($sess['is_2fa_verified'] ?? 0) !== 1) {
            admin_totp_fail($pdo, 401, '2fa_required', 'Two-factor authentication required.');
        }
        if (!password_verify($password, (string) $user['password_hash'])) {
            admin_totp_fail($pdo, 403, 'reauthentication_required', 'Incorrect password.');
        }
        if ($replacing && !admin_totp_consume_code($pdo, $user, $currentCode, $now)) {
            admin_totp_fail($pdo, 403, 'current_2fa_required',
                'Enter a current code from your existing authenticator app.');
        }

        $secret = admin_totp_generate_secret();
        $pdo->prepare('UPDATE ' . table_name('admin_users')
            . ' SET totp_pending_secret = ?, totp_pending_created_at = ? WHERE id = ?')
            ->execute([admin_totp_encrypt_secret($secret), gmdate('Y-m-d H:i:s', $now), (int) $user['id']]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    return [
        'secret' => $secret,
        'uri' => admin_totp_uri($secret, (string) $user['username']),
        'replacing' => $replacing,
        'expires_in' => ADMIN_TOTP_PENDING_TTL_SEC,
    ];
}

/**
 * Confirms the pending secret with a code from the new authenticator, switches
 * to it, signs out every other session of this admin and verifies this one.
 */
function admin_totp_confirm_setup(PDO $pdo, array $sess, array $body, int $now): array
{
    $code = trim((string) ($body['code'] ?? ''));
    $pdo->beginTransaction();
    try {
        $user = admin_totp_lock_user($pdo, (int) $sess['admin_user_id']);
        $replacing = (int) $user['totp_enabled'] === 1;
        if ($replacing && (int) ($sess['is_2fa_verified'] ?? 0) !== 1) {
            admin_totp_fail($pdo, 401, '2fa_required', 'Two-factor authentication required.');
        }
        $pending = admin_totp_decrypt_secret((string) ($user['totp_pending_secret'] ?? ''));
        $createdAt = strtotime((string) ($user['totp_pending_created_at'] ?? '') . ' UTC');
        if ($pending === '' || $createdAt === false
            || $now - $createdAt > ADMIN_TOTP_PENDING_TTL_SEC || $createdAt - $now > 60) {
            admin_totp_fail($pdo, 409, 'totp_setup_expired', 'The setup key expired. Start again.');
        }
        $counter = admin_totp_matched_counter($pending, $code, $now);
        if ($counter === null) {
            admin_totp_fail($pdo, 400, '2fa_invalid', 'Invalid or expired 2FA code.');
        }

        $adminId = (int) $user['id'];
        $pdo->prepare('UPDATE ' . table_name('admin_users') . '
            SET totp_secret = ?, totp_enabled = 1, totp_pending_secret = NULL,
                totp_pending_created_at = NULL, totp_last_counter = ?
            WHERE id = ?')
            ->execute([admin_totp_encrypt_secret($pending), $counter, $adminId]);
        $sessions = table_name('admin_sessions');
        $revoke = $pdo->prepare("DELETE FROM {$sessions} WHERE admin_user_id = ? AND token <> ?");
        $revoke->execute([$adminId, (string) $sess['token']]);
        $revoked = $revoke->rowCount();
        $pdo->prepare("UPDATE {$sessions} SET is_2fa_verified = 1 WHERE token = ?")
            ->execute([(string) $sess['token']]);
        admin_audit($pdo, $sess, $replacing ? 'admin.totp.replace' : 'admin.totp.enable',
            'admin_user', $adminId, ['revoked_sessions' => $revoked], true);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    return ['replaced' => $replacing, 'revoked_sessions' => $revoked];
}

/**
 * Recovery: removes 2FA from an account and signs out all its sessions. The next
 * login must enrol a new authenticator. Used by a superadmin for another admin,
 * and by the operator CLI (scripts/admin_totp.php).
 */
function admin_totp_reset_user(PDO $pdo, int $adminUserId): int
{
    $pdo->prepare('UPDATE ' . table_name('admin_users') . '
        SET totp_enabled = 0, totp_secret = NULL, totp_pending_secret = NULL,
            totp_pending_created_at = NULL, totp_last_counter = NULL
        WHERE id = ?')->execute([$adminUserId]);
    $revoke = $pdo->prepare('DELETE FROM ' . table_name('admin_sessions') . ' WHERE admin_user_id = ?');
    $revoke->execute([$adminUserId]);
    return $revoke->rowCount();
}

/**
 * Re-encrypts every stored secret with the current key. Reads with the current
 * or previous key. Refuses to change anything if a secret cannot be read.
 */
function admin_totp_reencrypt_all(PDO $pdo, bool $apply): array
{
    $pdo->beginTransaction();
    try {
        $rows = $pdo->query('SELECT id, username, totp_secret, totp_pending_secret FROM '
            . table_name('admin_users') . ' ORDER BY id FOR UPDATE')->fetchAll(PDO::FETCH_ASSOC);
        $updates = [];
        $unreadable = [];
        foreach ($rows as $row) {
            $next = ['totp_secret' => null, 'totp_pending_secret' => null];
            foreach (array_keys($next) as $column) {
                $stored = trim((string) ($row[$column] ?? ''));
                if ($stored === '') {
                    continue;
                }
                $plain = admin_totp_decrypt_secret($stored);
                if ($plain === '') {
                    $unreadable[] = (string) $row['username'] . ':' . $column;
                    continue;
                }
                $next[$column] = admin_totp_encrypt_secret($plain);
            }
            if ($next['totp_secret'] !== null || $next['totp_pending_secret'] !== null) {
                $updates[(int) $row['id']] = $next;
            }
        }
        if ($unreadable !== [] || !$apply) {
            $pdo->rollBack();
            return ['applied' => false, 'accounts' => count($updates), 'unreadable' => $unreadable];
        }
        $stmt = $pdo->prepare('UPDATE ' . table_name('admin_users')
            . ' SET totp_secret = COALESCE(?, totp_secret), totp_pending_secret = COALESCE(?, totp_pending_secret) WHERE id = ?');
        foreach ($updates as $id => $next) {
            $stmt->execute([$next['totp_secret'], $next['totp_pending_secret'], $id]);
        }
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    return ['applied' => true, 'accounts' => count($updates), 'unreadable' => []];
}
