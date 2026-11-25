<?php
declare(strict_types=1);

// Admin login, mandatory TOTP 2FA, and the admin's own sessions.
// Loaded by ../admin_panel_actions.php; routes are registered in the router.

// ── Auth ──────────────────────────────────────────────────────────────────────

function admin_panel_login_action(): void
{
    require_post();
    $pdo  = db();
    $body = read_json();

    $clientIp = client_ip_address();
    $username = trim((string) ($body['username'] ?? ''));
    $password = (string) ($body['password'] ?? '');

    enforce_rate_limit(
        $pdo,
        'admin_panel_login_ip',
        $clientIp,
        max(1, RATE_LIMIT_ADMIN_PANEL_LOGIN_IP_MAX),
        max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC),
        true
    );

    if ($username === '' || $password === '') {
        json_out(['ok' => false, 'error' => 'Username and password are required.'], 400);
    }

    $userTable = table_name('admin_users');
    $stmt = $pdo->prepare("SELECT * FROM {$userTable} WHERE username = ? LIMIT 1");
    $stmt->execute([$username]);
    $user = $stmt->fetch();

    // The account limit is keyed on the resolved account (so case or accent
    // variants of a username share one counter) and on the client IP (so
    // nobody can lock a real admin out from elsewhere). Unknown names get the
    // same treatment, keyed on the lower-cased name.
    $accountKey = is_array($user)
        ? 'id:' . (int) $user['id']
        : 'name:' . strtolower($username);
    enforce_rate_limit(
        $pdo,
        'admin_panel_login_account_ip',
        $accountKey . '|' . $clientIp,
        max(1, RATE_LIMIT_ADMIN_PANEL_LOGIN_USERNAME_MAX),
        max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC),
        true
    );

    // Exactly one bcrypt check on every path, at the cost real admin hashes
    // use, so response time does not tell real usernames from unknown ones.
    // There is no account-wide lock: it let anyone lock a real admin out, and
    // the per-account-and-IP limit above plus mandatory 2FA cover guessing.
    $validUser     = is_array($user) && (int) $user['is_active'] === 1;
    $hashToCheck   = $validUser ? (string) $user['password_hash'] : ADMIN_DUMMY_PASSWORD_HASH;
    $passwordValid = password_verify($password, $hashToCheck);

    if (!$validUser || !$passwordValid) {
        if ($validUser) {
            // Counted atomically for the audit trail and the admin list. The
            // column is TINYINT UNSIGNED, so the count stops at 255.
            $pdo->prepare("UPDATE {$userTable} SET failed_login_count = CASE WHEN failed_login_count < 255 THEN failed_login_count + 1 ELSE 255 END, locked_until = NULL WHERE id = ?")
                ->execute([$user['id']]);
            $countStmt = $pdo->prepare("SELECT failed_login_count FROM {$userTable} WHERE id = ?");
            $countStmt->execute([$user['id']]);
            $fails = (int) $countStmt->fetchColumn();

            admin_audit_event(
                $pdo,
                (int) $user['id'],
                (string) $user['username'],
                'admin.auth.login_failed',
                'admin_user',
                (int) $user['id'],
                [
                    'ip' => $clientIp,
                    'failed_login_count' => $fails,
                ]
            );
        } else {
            admin_audit_event(
                $pdo,
                null,
                $username !== '' ? $username : 'unknown',
                'admin.auth.login_failed_unknown_user',
                null,
                null,
                ['ip' => $clientIp]
            );
        }
        json_out(['ok' => false, 'error' => 'Invalid username or password.'], 401);
    }

    // Reset failed counter on success; bring older, cheaper hashes up to the
    // cost the dummy hash uses, so timing stays the same for every account.
    $pdo->prepare("UPDATE {$userTable} SET failed_login_count = 0, locked_until = NULL, last_login_at = UTC_TIMESTAMP() WHERE id = ?")
        ->execute([$user['id']]);
    if (password_needs_rehash((string) $user['password_hash'], PASSWORD_BCRYPT, ['cost' => ADMIN_PASSWORD_BCRYPT_COST])) {
        $pdo->prepare("UPDATE {$userTable} SET password_hash = ? WHERE id = ?")->execute([
            password_hash($password, PASSWORD_BCRYPT, ['cost' => ADMIN_PASSWORD_BCRYPT_COST]),
            $user['id'],
        ]);
    }

    // 2FA is mandatory: a password-only session is never fully authenticated.
    $needs2fa    = (int) $user['totp_enabled'] === 1;
    $sessionToken = admin_create_session($pdo, (int) $user['id'], false);
    admin_set_session_cookie($sessionToken);
    admin_audit_event(
        $pdo,
        (int) $user['id'],
        (string) $user['username'],
        'admin.auth.login_success',
        'admin_user',
        (int) $user['id'],
        [
            'ip' => $clientIp,
            'requires_2fa' => $needs2fa,
        ]
    );

    json_out([
        'ok'          => true,
        'requires_2fa' => $needs2fa,
        'requires_2fa_enrollment' => !$needs2fa,
        'user'         => [
            'id'       => (int) $user['id'],
            'username' => $user['username'],
            'email'    => $user['email'],
            'role'     => $user['role'],
        ],
    ]);
}

function admin_panel_verify_2fa_action(): void
{
    require_post();
    $pdo  = db();
    $body = read_json();
    $code = trim((string) ($body['code'] ?? ''));
    $clientIp = client_ip_address();

    // Accept a partial session (not yet 2FA-verified)
    $token = admin_session_token_from_cookie();
    if ($token === '') {
        json_out(['ok' => false, 'error' => 'Not authenticated.'], 401);
    }
    $tokenHash = admin_session_token_hash($token);

    enforce_rate_limit(
        $pdo,
        'admin_panel_2fa_ip',
        $clientIp,
        max(1, RATE_LIMIT_ADMIN_PANEL_2FA_IP_MAX),
        max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC)
    );
    enforce_rate_limit(
        $pdo,
        'admin_panel_2fa_token',
        $token,
        max(1, RATE_LIMIT_ADMIN_PANEL_2FA_TOKEN_MAX),
        max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC)
    );

    $sess = admin_resolve_session($pdo, $token);
    if (!is_array($sess)) {
        json_out(['ok' => false, 'error' => 'Session not found or expired.'], 401);
    }
    // Per account, across sessions and IPs: a new password login gives a new
    // session token, so the per-token limit alone allowed endless guessing.
    $adminKey = (string) (int) $sess['admin_user_id'];
    enforce_rate_limit(
        $pdo,
        'admin_panel_2fa_account',
        $adminKey,
        ADMIN_2FA_ACCOUNT_MAX_PER_WINDOW,
        max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC),
        true
    );
    enforce_rate_limit($pdo, 'admin_panel_2fa_account_day', $adminKey, ADMIN_2FA_ACCOUNT_MAX_PER_DAY, 86400, true);
    $result = admin_totp_verify_login($pdo, $sess, $code, time());
    if ($result === 'enrollment_required') {
        json_out(['ok' => false, 'code' => '2fa_enrollment_required',
            'error' => 'Set up two-factor authentication to continue.'], 403);
    }
    if ($result !== 'ok') {
        admin_audit_event(
            $pdo,
            (int) $sess['admin_user_id'],
            (string) $sess['username'],
            'admin.auth.2fa_failed',
            'admin_user',
            (int) $sess['admin_user_id'],
            ['ip' => $clientIp]
        );
        json_out(['ok' => false, 'error' => 'Invalid or expired 2FA code.'], 401);
    }
    admin_audit_event(
        $pdo,
        (int) $sess['admin_user_id'],
        (string) $sess['username'],
        'admin.auth.2fa_success',
        'admin_user',
        (int) $sess['admin_user_id'],
        ['ip' => $clientIp]
    );

    json_out([
        'ok'   => true,
        'user' => [
            'username' => $sess['username'],
            'email'    => $sess['email'],
            'role'     => $sess['role'],
        ],
    ]);
}

function admin_panel_logout_action(): void
{
    require_post();
    $pdo = db();
    $token = admin_session_token_from_cookie();
    $sess = null;
    if ($token !== '') {
        $sessTable = table_name('admin_sessions');
        $sess = admin_resolve_session($pdo, $token);
        $pdo->prepare("DELETE FROM {$sessTable} WHERE token = ?")
            ->execute([admin_session_token_hash($token)]);
    }
    if (is_array($sess)) {
        admin_audit($pdo, $sess, 'admin.auth.logout');
    }
    admin_clear_session_cookie();
    json_out(['ok' => true]);
}

function admin_panel_session_check_action(): void
{
    $token = admin_session_token_from_cookie();
    $sess  = admin_resolve_session(db(), $token);

    if ($sess === null) {
        json_out(['ok' => false, 'authenticated' => false]);
    }

    $enrolled = (int) $sess['totp_enabled'] === 1;
    $verified = (int) $sess['is_2fa_verified'] === 1;

    json_out([
        'ok'            => true,
        'authenticated' => true,
        'full_auth'     => $enrolled && $verified,
        'requires_2fa'  => $enrolled && !$verified,
        'requires_2fa_enrollment' => !$enrolled,
        'user'          => [
            'id'           => (int) $sess['admin_user_id'],
            'username'     => $sess['username'],
            'email'        => $sess['email'],
            'role'         => $sess['role'],
            'totp_enabled' => $enrolled,
        ],
    ]);
}

// ── TOTP Setup ────────────────────────────────────────────────────────────────
// Enrolment (no 2FA yet) works from the password-only login session. Replacing an
// authenticator needs a verified session, the password and a current code.
// There is no way to turn 2FA off from the panel; recovery is scripts/admin_totp.php.

function admin_panel_totp_rate_limit(PDO $pdo, array $sess): void
{
    enforce_rate_limit($pdo, 'admin_panel_totp_setup_ip', client_ip_address(),
        max(1, RATE_LIMIT_ADMIN_PANEL_2FA_IP_MAX), max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC));
    enforce_rate_limit($pdo, 'admin_panel_totp_setup_admin', (string) (int) $sess['admin_user_id'],
        max(1, RATE_LIMIT_ADMIN_PANEL_2FA_TOKEN_MAX), max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC));
}

function admin_panel_setup_totp_action(): void
{
    require_post();
    $sess = resolve_admin_session_any();
    $pdo  = db();
    admin_panel_totp_rate_limit($pdo, $sess);
    $setup = admin_totp_begin_setup($pdo, $sess, read_json(), time());
    admin_audit($pdo, $sess, $setup['replacing'] ? 'admin.totp.replace_started' : 'admin.totp.enroll_started');
    json_out(['ok' => true] + $setup);
}

function admin_panel_confirm_totp_action(): void
{
    require_post();
    $sess = resolve_admin_session_any();
    $pdo  = db();
    admin_panel_totp_rate_limit($pdo, $sess);
    $result = admin_totp_confirm_setup($pdo, $sess, read_json(), time());
    json_out(['ok' => true] + $result);
}

// ── Active Sessions ───────────────────────────────────────────────────────────

function admin_panel_active_sessions_action(): void
{
    $sess      = require_admin_session();
    $pdo       = db();
    $sessTable = table_name('admin_sessions');
    $myId      = (int) $sess['admin_user_id'];

    // Superadmin/admin sees all sessions; others see only their own
    if (admin_can($sess, 'superadmin', 'admin')) {
        $userTable = table_name('admin_users');
        $stmt = $pdo->prepare("
            SELECT s.token, s.ip_address, s.user_agent, s.is_2fa_verified,
                   s.expires_at, s.last_active_at, s.created_at,
                   u.username, u.role
            FROM {$sessTable} s
            JOIN {$userTable} u ON u.id = s.admin_user_id
            WHERE s.expires_at > UTC_TIMESTAMP()
            ORDER BY s.last_active_at DESC
        ");
        $stmt->execute();
    } else {
        $stmt = $pdo->prepare("
            SELECT token, ip_address, user_agent, is_2fa_verified,
                   expires_at, last_active_at, created_at
            FROM {$sessTable}
            WHERE admin_user_id = ? AND expires_at > UTC_TIMESTAMP()
            ORDER BY last_active_at DESC
        ");
        $stmt->execute([$myId]);
    }

    $rows     = $stmt->fetchAll();
    $current  = admin_session_token_hash(admin_session_token_from_cookie());
    $sessions = array_map(function (array $row) use ($current): array {
        return [
            'token'           => substr($row['token'], 0, 8) . '…', // mask
            'session_id'      => $row['token'],
            'is_current'      => $row['token'] === $current,
            'username'        => $row['username'] ?? null,
            'role'            => $row['role'] ?? null,
            'ip_address'      => $row['ip_address'],
            'user_agent'      => $row['user_agent'],
            'is_2fa_verified' => (bool) $row['is_2fa_verified'],
            'expires_at'      => $row['expires_at'],
            'last_active_at'  => $row['last_active_at'],
            'created_at'      => $row['created_at'],
        ];
    }, $rows);

    json_out(['ok' => true, 'sessions' => $sessions]);
}

function admin_panel_revoke_session_action(): void
{
    require_post();
    $sess      = require_admin_session();
    $pdo       = db();
    $body      = read_json();
    $target    = trim((string) ($body['session_id'] ?? ''));

    if (!preg_match('/^[a-f0-9]{64}$/', $target)) {
        json_out(['ok' => false, 'error' => 'Invalid session token.'], 400);
    }

    $sessTable = table_name('admin_sessions');

    // Non-superadmins can only revoke their own sessions
    if (!admin_can($sess, 'superadmin', 'admin')) {
        $stmt = $pdo->prepare("SELECT admin_user_id FROM {$sessTable} WHERE token = ?");
        $stmt->execute([$target]);
        $ownerId = (int) $stmt->fetchColumn();
        if ($ownerId !== (int) $sess['admin_user_id']) {
            json_out(['ok' => false, 'error' => 'You can only revoke your own sessions.'], 403);
        }
    }

    $pdo->prepare("DELETE FROM {$sessTable} WHERE token = ?")->execute([$target]);
    admin_audit($pdo, $sess, 'admin.session.revoke', 'session', null, ['token_prefix' => substr($target, 0, 8)]);
    json_out(['ok' => true]);
}
