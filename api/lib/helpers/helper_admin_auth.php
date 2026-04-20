<?php
declare(strict_types=1);

// ── Config constants ───────────────────────────────────────────────────────────

define('ADMIN_SESSION_COOKIE',   'splyto_admin_sess');
define('ADMIN_SESSION_TTL',      28800);  // 8 h sliding
define('ADMIN_MAX_SESSIONS',     5);      // concurrent sessions per admin user
define('ADMIN_LOCK_THRESHOLD',   5);      // failed logins before lock
define('ADMIN_LOCK_MINUTES',     15);     // lock duration

// ── Role helpers ───────────────────────────────────────────────────────────────

/** All roles that have any access. */
function admin_roles_all(): array   { return ['superadmin', 'admin', 'support', 'ops', 'readonly']; }

/** Roles that can perform generic write/delete actions on app data. */
function admin_roles_write(): array { return ['superadmin', 'admin']; }

/** Roles with access to support tools (user lookup, account actions, push logs). */
function admin_roles_support(): array { return ['superadmin', 'admin', 'support']; }

/** Roles with access to ops tools (queue, incidents, retry). */
function admin_roles_ops(): array   { return ['superadmin', 'admin', 'ops']; }

function admin_can(array $sess, string ...$roles): bool
{
    return in_array($sess['role'], $roles, true);
}

// ── Session cookie ────────────────────────────────────────────────────────────

function admin_session_token_from_cookie(): string
{
    $raw = trim((string) ($_COOKIE[ADMIN_SESSION_COOKIE] ?? ''));
    return preg_match('/^[a-f0-9]{64}$/', $raw) ? $raw : '';
}

function admin_set_session_cookie(string $token): void
{
    $isHttps = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off')
        || (strtolower((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')) === 'https');

    setcookie(ADMIN_SESSION_COOKIE, $token, [
        'expires'  => time() + ADMIN_SESSION_TTL,
        'path'     => '/',
        'secure'   => $isHttps,
        'httponly' => true,
        'samesite' => 'Strict',
    ]);
}

function admin_clear_session_cookie(): void
{
    setcookie(ADMIN_SESSION_COOKIE, '', [
        'expires'  => time() - 3600,
        'path'     => '/',
        'secure'   => true,
        'httponly' => true,
        'samesite' => 'Strict',
    ]);
}

// ── Session CRUD ──────────────────────────────────────────────────────────────

function admin_create_session(PDO $pdo, int $adminUserId, bool $is2faVerified): string
{
    $token     = bin2hex(random_bytes(32)); // 64-char hex
    $ip        = client_ip_address();
    $ua        = substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 512);
    $expiresAt = date('Y-m-d H:i:s', time() + ADMIN_SESSION_TTL);
    $sessTable = table_name('admin_sessions');

    // Remove expired sessions for this user
    $pdo->prepare("DELETE FROM {$sessTable} WHERE admin_user_id = ? AND expires_at < UTC_TIMESTAMP()")
        ->execute([$adminUserId]);

    // Enforce max concurrent sessions — evict oldest
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM {$sessTable} WHERE admin_user_id = ?");
    $stmt->execute([$adminUserId]);
    if ((int) $stmt->fetchColumn() >= ADMIN_MAX_SESSIONS) {
        $pdo->prepare("DELETE FROM {$sessTable} WHERE admin_user_id = ? ORDER BY last_active_at ASC LIMIT 1")
            ->execute([$adminUserId]);
    }

    $pdo->prepare("
        INSERT INTO {$sessTable} (token, admin_user_id, ip_address, user_agent, is_2fa_verified, expires_at)
        VALUES (?, ?, ?, ?, ?, ?)
    ")->execute([$token, $adminUserId, $ip, $ua, $is2faVerified ? 1 : 0, $expiresAt]);

    return $token;
}

function admin_resolve_session(PDO $pdo, string $token): ?array
{
    if ($token === '') {
        return null;
    }

    $sessTable = table_name('admin_sessions');
    $userTable = table_name('admin_users');

    $stmt = $pdo->prepare("
        SELECT s.token, s.admin_user_id, s.ip_address, s.is_2fa_verified,
               u.username, u.email, u.role, u.is_active, u.totp_enabled
        FROM {$sessTable} s
        JOIN {$userTable} u ON u.id = s.admin_user_id
        WHERE s.token = ?
          AND s.expires_at > UTC_TIMESTAMP()
          AND u.is_active = 1
    ");
    $stmt->execute([$token]);
    $row = $stmt->fetch();
    if (!is_array($row)) {
        return null;
    }

    // Slide the expiry window
    $newExpiry = date('Y-m-d H:i:s', time() + ADMIN_SESSION_TTL);
    $pdo->prepare("UPDATE {$sessTable} SET last_active_at = UTC_TIMESTAMP(), expires_at = ? WHERE token = ?")
        ->execute([$newExpiry, $token]);

    return $row;
}

// ── Auth guards ───────────────────────────────────────────────────────────────

/**
 * Resolve the current admin session from the cookie.
 * Returns the session+user row. Exits with 401 if invalid.
 * Does NOT enforce 2FA — use require_admin_session() for fully-verified sessions.
 */
function resolve_admin_session_any(): array
{
    $token = admin_session_token_from_cookie();
    $sess  = admin_resolve_session(db(), $token);
    if ($sess === null) {
        json_out(['ok' => false, 'error' => 'Not authenticated.', 'code' => 'unauthenticated'], 401);
    }
    return $sess;
}

/**
 * Require a fully-authenticated admin session (password + 2FA if enabled).
 * Returns the session row. Exits with 401/403 on failure.
 */
function require_admin_session(): array
{
    $sess = resolve_admin_session_any();
    if ((int) $sess['totp_enabled'] === 1 && !(bool) $sess['is_2fa_verified']) {
        json_out(['ok' => false, 'error' => 'Two-factor authentication required.', 'code' => '2fa_required'], 401);
    }
    return $sess;
}

/**
 * Require a fully-authenticated session AND one of the given roles.
 * Returns the session row.
 */
function require_admin_role(string ...$roles): array
{
    $sess = require_admin_session();
    if (!in_array($sess['role'], $roles, true)) {
        json_out(['ok' => false, 'error' => 'Insufficient permissions.', 'code' => 'forbidden'], 403);
    }
    return $sess;
}

// ── Audit logging ─────────────────────────────────────────────────────────────

function admin_audit(
    PDO    $pdo,
    array  $sess,
    string $action,
    ?string $targetType = null,
    ?int    $targetId   = null,
    ?array  $details    = null
): void {
    try {
        $tbl     = table_name('admin_audit_log');
        $details = $details !== null
            ? json_encode($details, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)
            : null;
        $pdo->prepare("
            INSERT INTO {$tbl}
                (admin_user_id, admin_username, action, target_type, target_id, details, ip_address)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ")->execute([
            (int)    $sess['admin_user_id'],
            (string) $sess['username'],
            $action,
            $targetType,
            $targetId,
            $details,
            client_ip_address(),
        ]);
    } catch (Throwable) {
        // Non-fatal — don't break the actual action if audit log fails
    }
}

// ── TOTP (RFC 6238) ───────────────────────────────────────────────────────────

function _admin_b32_alpha(): string
{
    return 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
}

function admin_base32_encode(string $bytes): string
{
    $alpha = _admin_b32_alpha();
    $bits  = '';
    $len   = strlen($bytes);
    for ($i = 0; $i < $len; $i++) {
        $bits .= str_pad(decbin(ord($bytes[$i])), 8, '0', STR_PAD_LEFT);
    }
    $out  = '';
    $blen = strlen($bits);
    for ($i = 0; $i + 5 <= $blen; $i += 5) {
        $out .= $alpha[(int) bindec(substr($bits, $i, 5))];
    }
    return $out;
}

function admin_base32_decode(string $encoded): string
{
    $alpha   = _admin_b32_alpha();
    $encoded = strtoupper(preg_replace('/[^A-Z2-7]/', '', $encoded));
    $bits    = '';
    $len     = strlen($encoded);
    for ($i = 0; $i < $len; $i++) {
        $pos = strpos($alpha, $encoded[$i]);
        if ($pos === false) {
            continue;
        }
        $bits .= str_pad(decbin($pos), 5, '0', STR_PAD_LEFT);
    }
    $out  = '';
    $blen = strlen($bits);
    for ($i = 0; $i + 8 <= $blen; $i += 8) {
        $out .= chr((int) bindec(substr($bits, $i, 8)));
    }
    return $out;
}

function admin_totp_generate_secret(): string
{
    return admin_base32_encode(random_bytes(20));
}

function admin_totp_code(string $secret, int $counter): string
{
    $key    = admin_base32_decode($secret);
    $msg    = pack('J', $counter);                   // 8-byte big-endian unsigned
    $hash   = hash_hmac('sha1', $msg, $key, true);   // 20-byte raw HMAC-SHA1
    $offset = ord($hash[19]) & 0x0F;
    $otp    = (
        ((ord($hash[$offset])     & 0x7F) << 24) |
        ((ord($hash[$offset + 1]) & 0xFF) << 16) |
        ((ord($hash[$offset + 2]) & 0xFF) << 8)  |
         (ord($hash[$offset + 3]) & 0xFF)
    ) % 1_000_000;
    return str_pad((string) $otp, 6, '0', STR_PAD_LEFT);
}

function admin_totp_verify(string $secret, string $code, int $window = 1): bool
{
    $code = trim($code);
    if (!preg_match('/^\d{6}$/', $code)) {
        return false;
    }
    $counter = (int) floor(time() / 30);
    for ($i = -$window; $i <= $window; $i++) {
        if (hash_equals(admin_totp_code($secret, $counter + $i), $code)) {
            return true;
        }
    }
    return false;
}

function admin_totp_uri(string $secret, string $username, string $issuer = 'Splyto Admin'): string
{
    return sprintf(
        'otpauth://totp/%s:%s?secret=%s&issuer=%s&algorithm=SHA1&digits=6&period=30',
        rawurlencode($issuer),
        rawurlencode($username),
        rawurlencode($secret),
        rawurlencode($issuer)
    );
}
