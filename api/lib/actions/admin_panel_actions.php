<?php
declare(strict_types=1);
require_once __DIR__ . '/../helpers/helper_travel_places.php';
require_once __DIR__ . '/../helpers/helper_account_deletion_feedback.php';
require_once __DIR__ . '/../helpers/helper_feature_usage.php';

// ══════════════════════════════════════════════════════════════════════════════
// Admin Panel v2 Actions
// Auth: cookie-based sessions with mandatory TOTP 2FA, RBAC roles.
// All write actions emit an audit log entry.
// ══════════════════════════════════════════════════════════════════════════════

// ── Auth ──────────────────────────────────────────────────────────────────────

function admin_panel_login_action(): void
{
    require_post();
    $pdo  = db();
    $body = read_json();

    $clientIp = client_ip_address();
    $username = trim((string) ($body['username'] ?? ''));
    $password = (string) ($body['password'] ?? '');
    $usernameForRateLimit = strtolower($username);

    enforce_rate_limit(
        $pdo,
        'admin_panel_login_ip',
        $clientIp,
        max(1, RATE_LIMIT_ADMIN_PANEL_LOGIN_IP_MAX),
        max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC)
    );
    if ($usernameForRateLimit !== '') {
        enforce_rate_limit(
            $pdo,
            'admin_panel_login_username',
            $usernameForRateLimit,
            max(1, RATE_LIMIT_ADMIN_PANEL_LOGIN_USERNAME_MAX),
            max(60, RATE_LIMIT_ADMIN_PANEL_WINDOW_SEC)
        );
    }

    if ($username === '' || $password === '') {
        json_out(['ok' => false, 'error' => 'Username and password are required.'], 400);
    }

    $userTable = table_name('admin_users');
    $stmt = $pdo->prepare("SELECT * FROM {$userTable} WHERE username = ? LIMIT 1");
    $stmt->execute([$username]);
    $user = $stmt->fetch();

    // Rate-limit: check lock first
    if (is_array($user) && $user['locked_until'] !== null) {
        $lockedUntil = strtotime($user['locked_until'] . ' UTC');
        if ($lockedUntil > time()) {
            $remaining = ceil(($lockedUntil - time()) / 60);
            admin_audit_event(
                $pdo,
                (int) $user['id'],
                (string) $user['username'],
                'admin.auth.login_blocked_locked',
                'admin_user',
                (int) $user['id'],
                [
                    'ip' => $clientIp,
                    'remaining_minutes' => $remaining,
                ]
            );
            json_out(['ok' => false, 'error' => "Account locked. Try again in {$remaining} minute(s)."], 429);
        }
        // Lock expired — reset counter
        $pdo->prepare("UPDATE {$userTable} SET failed_login_count = 0, locked_until = NULL WHERE id = ?")
            ->execute([$user['id']]);
        $user['failed_login_count'] = 0;
        $user['locked_until']       = null;
    }

    // Constant-time validation (avoids user enumeration timing)
    $validUser     = is_array($user) && (int) $user['is_active'] === 1;
    $hashToCheck   = $validUser ? (string) $user['password_hash'] : password_hash('dummy', PASSWORD_BCRYPT);
    $passwordValid = password_verify($password, $hashToCheck);

    if (!$validUser || !$passwordValid) {
        if ($validUser) {
            $fails = (int) $user['failed_login_count'] + 1;
            $lockUntil = null;
            if ($fails >= ADMIN_LOCK_THRESHOLD) {
                $lockUntil = date('Y-m-d H:i:s', time() + ADMIN_LOCK_MINUTES * 60);
                $pdo->prepare("UPDATE {$userTable} SET failed_login_count = ?, locked_until = ? WHERE id = ?")
                    ->execute([$fails, $lockUntil, $user['id']]);
            } else {
                $pdo->prepare("UPDATE {$userTable} SET failed_login_count = ? WHERE id = ?")
                    ->execute([$fails, $user['id']]);
            }

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
                    'locked_until_utc' => $lockUntil,
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

    // Reset failed counter on success
    $pdo->prepare("UPDATE {$userTable} SET failed_login_count = 0, locked_until = NULL, last_login_at = UTC_TIMESTAMP() WHERE id = ?")
        ->execute([$user['id']]);

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

// ── Dashboard ─────────────────────────────────────────────────────────────────

function admin_panel_dashboard_action(): void
{
    $sess = require_admin_role(...admin_roles_all());
    $pdo  = db();

    $users   = table_name('users');
    $trips   = table_name('trips');
    $exp     = table_name('expenses');
    $settle  = table_name('settlements');
    $push    = table_name('push_queue');
    $inc     = table_name('admin_incidents');

    $stats = [];

    // User counts
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users} WHERE guest_trip_id IS NULL");
    $stats['total_users'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users} WHERE account_status = 'active' AND guest_trip_id IS NULL");
    $stats['active_users'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users} WHERE created_at >= DATE_SUB(UTC_TIMESTAMP(), INTERVAL 7 DAY)");
    $stats['new_users_7d'] = (int) $stmt->fetchColumn();

    // Trip / expense counts
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$trips}");
    $stats['total_trips'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$exp}");
    $stats['total_expenses'] = (int) $stmt->fetchColumn();

    // Push queue health
    $stmt = $pdo->query("SELECT status, COUNT(*) AS cnt FROM {$push} GROUP BY status");
    $pushRows = $stmt->fetchAll();
    $pushStats = [];
    foreach ($pushRows as $r) {
        $pushStats[(string) $r['status']] = (int) $r['cnt'];
    }
    $stats['push_queue'] = $pushStats;

    // Open incidents
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$inc} WHERE status != 'resolved'");
    $stats['open_incidents'] = (int) $stmt->fetchColumn();

    // Recent open incidents
    $stmt = $pdo->query("
        SELECT id, title, severity, status, created_at, admin_username
        FROM {$inc}
        WHERE status != 'resolved'
        ORDER BY
          FIELD(severity,'critical','high','medium','low'),
          created_at DESC
        LIMIT 5
    ");
    $stats['recent_incidents'] = $stmt->fetchAll();

    $stats['account_deletion_feedback'] = account_deletion_feedback_summary($pdo);
    $stats['feature_usage'] = feature_usage_summary($pdo);
    $stats['growth'] = admin_growth_series($pdo, gmdate('Y-m-d'));

    json_out(['ok' => true, 'stats' => $stats]);
}

/**
 * Daily counts for the last $days days, ending with $today (UTC, Y-m-d):
 * sign-ups (guests excluded), active users (anyone with an app event that day)
 * and new trips. Days without data are zero.
 */
function admin_growth_series(PDO $pdo, string $today, int $days = 30): array
{
    $end = new DateTimeImmutable($today . ' 00:00:00', new DateTimeZone('UTC'));
    $start = $end->modify('-' . ($days - 1) . ' days');
    $from = $start->format('Y-m-d H:i:s');
    $series = [];
    for ($day = $start; $day <= $end; $day = $day->modify('+1 day')) {
        $series[$day->format('Y-m-d')] = ['date' => $day->format('Y-m-d'), 'signups' => 0, 'active' => 0, 'trips' => 0];
    }
    $queries = [
        'signups' => 'SELECT DATE(created_at) AS d, COUNT(*) AS n FROM ' . table_name('users')
            . ' WHERE created_at >= ? AND guest_trip_id IS NULL GROUP BY DATE(created_at)',
        'active' => 'SELECT DATE(created_at) AS d, COUNT(DISTINCT user_id) AS n FROM ' . table_name('app_events')
            . ' WHERE created_at >= ? AND user_id IS NOT NULL GROUP BY DATE(created_at)',
        'trips' => 'SELECT DATE(created_at) AS d, COUNT(*) AS n FROM ' . table_name('trips')
            . ' WHERE created_at >= ? GROUP BY DATE(created_at)',
    ];
    foreach ($queries as $key => $sql) {
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$from]);
        foreach ($stmt->fetchAll(PDO::FETCH_ASSOC) as $row) {
            $date = substr((string) $row['d'], 0, 10);
            if (isset($series[$date])) {
                $series[$date][$key] = (int) $row['n'];
            }
        }
    }
    return array_values($series);
}

// ── System health ────────────────────────────────────────────────────────────

function admin_panel_system_health_action(): void
{
    require_admin_role(...admin_roles_ops());
    $pdo = db();
    $now = time();
    json_out(['ok' => true, 'jobs' => ops_status_read($now),
        'system' => ops_system_snapshot($pdo, dirname(__DIR__, 3)),
        'push' => admin_push_queue_health($pdo, gmdate('Y-m-d H:i:s', $now))]);
}

/** Backlog and recent failures of the push queue. */
function admin_push_queue_health(PDO $pdo, string $now): array
{
    $queue = table_name('push_queue');
    $stmt = $pdo->prepare("SELECT
            SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
            MIN(CASE WHEN status = 'pending' THEN created_at END) AS oldest_pending_at,
            SUM(CASE WHEN status IN ('failed', 'dead') AND updated_at >= ? THEN 1 ELSE 0 END) AS failed_24h,
            MAX(sent_at) AS last_sent_at
        FROM {$queue}");
    $stmt->execute([(new DateTimeImmutable($now . ' UTC'))->modify('-1 day')->format('Y-m-d H:i:s')]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC) ?: [];
    return ['pending' => (int) ($row['pending'] ?? 0), 'oldest_pending_at' => $row['oldest_pending_at'] ?? null,
        'failed_24h' => (int) ($row['failed_24h'] ?? 0), 'last_sent_at' => $row['last_sent_at'] ?? null];
}

// ── Security overview ────────────────────────────────────────────────────────

function admin_panel_security_overview_action(): void
{
    require_admin_role('superadmin', 'admin');
    json_out(['ok' => true] + admin_security_overview(db(), time()));
}

/**
 * Admin sign-in, 2FA and session events from the audit log, plus rate-limit
 * pressure per scope in the last 24 hours (subjects stay hashed).
 */
function admin_security_overview(PDO $pdo, int $now): array
{
    $since = gmdate('Y-m-d H:i:s', $now - 7 * 86400);
    $stmt = $pdo->prepare("SELECT admin_username, action, ip_address, created_at FROM " . table_name('admin_audit_log') . "
        WHERE created_at >= ? AND (action LIKE 'admin.auth.%' OR action LIKE 'admin.totp.%'
            OR action LIKE 'admin_user.%' OR action LIKE 'admin.session.%' OR action = 'user.sessions.revoke_all')
        ORDER BY created_at DESC, id DESC LIMIT 100");
    $stmt->execute([$since]);
    $events = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $counts = ['failed_logins' => 0, 'failed_2fa' => 0, 'locked' => 0, 'successful_logins' => 0];
    foreach ($events as $event) {
        $action = (string) $event['action'];
        if (str_starts_with($action, 'admin.auth.login_failed')) $counts['failed_logins']++;
        elseif ($action === 'admin.auth.2fa_failed') $counts['failed_2fa']++;
        elseif ($action === 'admin.auth.login_blocked_locked') $counts['locked']++;
        elseif ($action === 'admin.auth.2fa_success') $counts['successful_logins']++;
    }

    $limits = $pdo->prepare('SELECT scope, COUNT(*) AS windows, SUM(hits) AS requests, MAX(hits) AS peak
        FROM ' . table_name('request_limits') . ' WHERE window_start >= ? GROUP BY scope ORDER BY peak DESC, scope LIMIT 30');
    $limits->execute([$now - 86400]);
    $rateLimits = array_map(static fn(array $row): array => ['scope' => (string) $row['scope'],
        'windows' => (int) $row['windows'], 'requests' => (int) $row['requests'], 'peak' => (int) $row['peak']],
        $limits->fetchAll(PDO::FETCH_ASSOC));

    $sessions = $pdo->prepare('SELECT COUNT(*) FROM ' . table_name('admin_sessions') . ' WHERE expires_at > ?');
    $sessions->execute([gmdate('Y-m-d H:i:s', $now)]);

    return ['counts_7d' => $counts, 'events' => $events, 'rate_limits_24h' => $rateLimits,
        'active_admin_sessions' => (int) $sessions->fetchColumn()];
}

// ── User support tools ────────────────────────────────────────────────────────

function admin_panel_user_search_action(): void
{
    require_admin_role(...admin_roles_support());
    $pdo = db();
    $result = admin_user_search($pdo, $_GET, gmdate('Y-m-d H:i:s'));
    $result['premium_for_everyone'] = premium_for_everyone_window(premium_for_everyone_config(), time()) !== null;
    json_out(['ok' => true] + $result);
}

/**
 * Users list for the admin panel: search, filters, sorting and per-user summary
 * (trip count, last activity, Premium grant). Guests are never listed.
 */
function admin_user_search(PDO $pdo, array $query, string $now): array
{
    $q      = trim((string) ($query['q'] ?? ''));
    $status = trim((string) ($query['status'] ?? 'all'));
    $limit  = max(1, min(100, (int) ($query['limit'] ?? 40)));
    $offset = max(0, (int) ($query['offset'] ?? 0));
    $sort   = (string) ($query['sort'] ?? 'newest');

    $users = table_name('users');
    $hasIdentities = social_auth_identity_table_available($pdo);
    $hasPush = push_tokens_table_available($pdo);
    $conditions = ['u.guest_trip_id IS NULL'];
    $params = [];

    if ($q !== '') {
        $conditions[] = "(u.nickname LIKE ? ESCAPE '!' OR u.email LIKE ? ESCAPE '!')";
        $like = '%' . str_replace(['!', '%', '_'], ['!!', '!%', '!_'], $q) . '%';
        array_push($params, $like, $like);
    }
    if (in_array($status, ['active', 'deactivated', 'deleted'], true)) {
        $conditions[] = 'u.account_status = ?';
        $params[] = $status;
    }
    $platform = (string) ($query['platform'] ?? '');
    if (in_array($platform, ['ios', 'android'], true)) {
        $conditions[] = $hasPush
            ? 'EXISTS (SELECT 1 FROM ' . table_name('push_tokens') . ' p WHERE p.user_id = u.id AND LOWER(p.platform) = ?)'
            : '1 = 0';
        if ($hasPush) {
            $params[] = $platform;
        }
    }
    $signIn = (string) ($query['sign_in'] ?? '');
    if ($signIn === 'email') {
        $conditions[] = "(u.password_hash IS NOT NULL AND u.password_hash <> '')";
    } elseif (in_array($signIn, ['apple', 'google'], true)) {
        $conditions[] = $hasIdentities
            ? 'EXISTS (SELECT 1 FROM ' . table_name('user_identities') . ' i WHERE i.user_id = u.id AND i.provider = ?)'
            : '1 = 0';
        if ($hasIdentities) {
            $params[] = $signIn;
        }
    }
    $premiumSql = 'EXISTS (SELECT 1 FROM ' . table_name('premium_grants') . ' g WHERE g.user_id = u.id'
        . ' AND g.revoked_at IS NULL AND g.starts_at <= ? AND g.ends_at > ?)';
    if (!empty($query['premium'])) {
        $conditions[] = $premiumSql;
        array_push($params, $now, $now);
    }
    if (!empty($query['unverified'])) {
        $conditions[] = "u.email IS NOT NULL AND u.email <> '' AND u.email_verified_at IS NULL";
    }

    $where = 'WHERE ' . implode(' AND ', $conditions);
    $order = match ($sort) {
        'last_active' => 'last_active_at IS NULL, last_active_at DESC, u.id DESC',
        'trips' => 'trips_count DESC, u.id DESC',
        'oldest' => 'u.created_at ASC, u.id ASC',
        default => 'u.created_at DESC, u.id DESC',
    };

    $stmt = $pdo->prepare('SELECT u.id, u.nickname, u.email, u.account_status, u.created_at, '
        . admin_has_password_login_sql() . ',
            (SELECT COUNT(*) FROM ' . table_name('trip_members') . ' m WHERE m.user_id = u.id) AS trips_count,
            (SELECT MAX(r.last_used_at) FROM ' . table_name('refresh_tokens') . ' r WHERE r.user_id = u.id) AS last_active_at,
            ' . $premiumSql . ' AS premium_grant
        FROM ' . $users . ' u ' . $where . ' ORDER BY ' . $order . ' LIMIT ? OFFSET ?');
    $stmt->execute([$now, $now, ...$params, $limit, $offset]);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $count = $pdo->prepare('SELECT COUNT(*) FROM ' . $users . ' u ' . $where);
    $count->execute($params);

    $rows = array_map(static function (array $row): array {
        $row['trips_count'] = (int) $row['trips_count'];
        $row['premium_grant'] = (bool) (int) $row['premium_grant'];
        return $row;
    }, $rows);

    return [
        'users' => admin_users_with_account_signals($pdo, $rows),
        'total' => (int) $count->fetchColumn(),
        'limit' => $limit,
        'offset' => $offset,
    ];
}

/** A boolean column: the user can sign in with email and password. The hash itself is never selected. */
function admin_has_password_login_sql(): string
{
    return "(password_hash IS NOT NULL AND password_hash <> '') AS has_password_login";
}

/**
 * Adds how each user signs in, which app platforms they use and whether the
 * email is verified, so support can spot test or bot accounts at a glance.
 * Rows must contain has_password_login; it becomes the "email" sign-in method.
 */
function admin_users_with_account_signals(PDO $pdo, array $users): array
{
    $ids = array_values(array_unique(array_map(static fn(array $u): int => (int) $u['id'], $users)));
    $providers = [];
    $platforms = [];
    $verified = [];
    if ($ids !== []) {
        $marks = implode(',', array_fill(0, count($ids), '?'));
        if (social_auth_identity_table_available($pdo)) {
            $stmt = $pdo->prepare('SELECT user_id, provider FROM ' . table_name('user_identities')
                . " WHERE user_id IN ({$marks}) ORDER BY provider");
            $stmt->execute($ids);
            foreach ($stmt->fetchAll() as $row) {
                $providers[(int) $row['user_id']][] = (string) $row['provider'];
            }
        }
        if (push_tokens_table_available($pdo)) {
            $stmt = $pdo->prepare('SELECT DISTINCT user_id, platform FROM ' . table_name('push_tokens')
                . " WHERE user_id IN ({$marks}) ORDER BY platform");
            $stmt->execute($ids);
            foreach ($stmt->fetchAll() as $row) {
                $platforms[(int) $row['user_id']][] = strtolower((string) $row['platform']);
            }
        }
        if (users_email_verified_at_column_available($pdo)) {
            $stmt = $pdo->prepare('SELECT id, email_verified_at FROM ' . table_name('users') . " WHERE id IN ({$marks})");
            $stmt->execute($ids);
            foreach ($stmt->fetchAll() as $row) {
                $verified[(int) $row['id']] = !empty($row['email_verified_at']);
            }
        }
    }
    return array_map(static function (array $user) use ($providers, $platforms, $verified): array {
        $id = (int) $user['id'];
        $methods = !empty($user['has_password_login']) ? ['email'] : [];
        $user['sign_in_methods'] = array_merge($methods, $providers[$id] ?? []);
        $user['platforms'] = array_values(array_unique($platforms[$id] ?? []));
        $user['email_verified'] = $verified[$id] ?? null;
        unset($user['has_password_login']);
        return $user;
    }, $users);
}

function admin_panel_user_detail_action(): void
{
    $sess   = require_admin_role(...admin_roles_support());
    $pdo    = db();
    $userId = (int) ($_GET['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }

    $userTable   = table_name('users');
    $tripsTable  = table_name('trips');
    $membTable   = table_name('trip_members');
    $pushTable   = table_name('push_tokens');
    $notifTable  = table_name('notifications');

    $hasPassword = admin_has_password_login_sql();
    $stmt = $pdo->prepare("SELECT id, nickname, email, account_status, created_at, {$hasPassword} FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!is_array($user)) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }
    $user = admin_users_with_account_signals($pdo, [$user])[0];

    // Recent trips
    $stmt = $pdo->prepare("
        SELECT t.id, t.name, t.status, t.created_at,
               (SELECT COUNT(*) FROM {$membTable} c WHERE c.trip_id = t.id) AS members_count
        FROM {$tripsTable} t
        JOIN {$membTable} tm ON tm.trip_id = t.id AND tm.user_id = ?
        ORDER BY t.created_at DESC LIMIT 10
    ");
    $stmt->execute([$userId]);
    $trips = $stmt->fetchAll();

    // Push tokens
    $stmt = $pdo->prepare("
        SELECT platform, provider, app_bundle, is_active, last_seen_at
        FROM {$pushTable}
        WHERE user_id = ?
        ORDER BY last_seen_at DESC
    ");
    $stmt->execute([$userId]);
    $pushTokens = $stmt->fetchAll();

    // Unread notifications
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM {$notifTable} WHERE user_id = ? AND is_read = 0");
    $stmt->execute([$userId]);
    $unreadNotifs = (int) $stmt->fetchColumn();

    json_out([
        'ok'             => true,
        'user'           => $user,
        'trips'          => $trips,
        'premium'        => premium_user_detail($pdo, $userId, $sess),
        'push_tokens'    => $pushTokens,
        'unread_notifs'  => $unreadNotifs,
        'sessions'       => admin_user_sessions($pdo, $userId, gmdate('Y-m-d H:i:s')),
        'timeline'       => admin_user_timeline($pdo, $userId),
    ]);
}

/** Signed-in devices: active refresh sessions. Token hashes and IP addresses are not returned. */
function admin_user_sessions(PDO $pdo, int $userId, string $now): array
{
    $stmt = $pdo->prepare('SELECT id, created_at, last_used_at, user_agent FROM ' . table_name('refresh_tokens')
        . ' WHERE user_id = ? AND revoked_at IS NULL AND expires_at > ? ORDER BY COALESCE(last_used_at, created_at) DESC LIMIT 20');
    $stmt->execute([$userId, $now]);
    return array_map(static fn(array $row): array => [
        'id' => (int) $row['id'],
        'created_at' => $row['created_at'],
        'last_used_at' => $row['last_used_at'],
        'user_agent' => mb_substr(trim((string) ($row['user_agent'] ?? '')), 0, 120),
    ], $stmt->fetchAll(PDO::FETCH_ASSOC));
}

/** The user's most recent app events, newest first, with the trip name when there is one. */
function admin_user_timeline(PDO $pdo, int $userId, int $limit = 25): array
{
    $stmt = $pdo->prepare('SELECT e.event_type, e.entity_type, e.entity_id, e.trip_id, t.name AS trip_name, e.created_at
        FROM ' . table_name('app_events') . ' e
        LEFT JOIN ' . table_name('trips') . ' t ON t.id = e.trip_id
        WHERE e.user_id = ? ORDER BY e.created_at DESC, e.id DESC LIMIT ' . max(1, min(100, $limit)));
    $stmt->execute([$userId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/** Support action: ends every app session of the user; they must sign in again on each device. */
function admin_panel_user_sign_out_everywhere_action(): void
{
    require_post();
    $sess   = require_admin_role(...admin_roles_support());
    $pdo    = db();
    $body   = read_json();
    $userId = (int) ($body['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }
    $count = $pdo->prepare('SELECT COUNT(*) FROM ' . table_name('refresh_tokens')
        . ' WHERE user_id = ? AND revoked_at IS NULL AND expires_at > ?');
    $count->execute([$userId, gmdate('Y-m-d H:i:s')]);
    $active = (int) $count->fetchColumn();
    revoke_refresh_tokens_for_user($pdo, $userId);
    admin_audit($pdo, $sess, 'user.sessions.revoke_all', 'user', $userId, ['sessions' => $active]);
    json_out(['ok' => true, 'revoked' => $active]);
}

function admin_panel_user_suspend_action(): void
{
    require_post();
    $sess   = require_admin_role(...admin_roles_support());
    $pdo    = db();
    $body   = read_json();
    $userId = (int) ($body['user_id'] ?? 0);
    $reason = trim((string) ($body['reason'] ?? ''));

    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }

    $userTable = table_name('users');
    $stmt = $pdo->prepare("SELECT id, nickname, account_status FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!is_array($user)) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }
    if ($user['account_status'] === 'deactivated') {
        json_out(['ok' => false, 'error' => 'User is already deactivated/suspended.'], 409);
    }

    $pdo->prepare("UPDATE {$userTable} SET account_status = 'deactivated' WHERE id = ?")->execute([$userId]);
    admin_audit($pdo, $sess, 'user.suspend', 'user', $userId, [
        'nickname' => $user['nickname'],
        'reason'   => $reason,
    ]);
    json_out(['ok' => true]);
}

function admin_panel_user_reactivate_action(): void
{
    require_post();
    $sess   = require_admin_role(...admin_roles_support());
    $pdo    = db();
    $body   = read_json();
    $userId = (int) ($body['user_id'] ?? 0);
    $reason = trim((string) ($body['reason'] ?? ''));

    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }

    $userTable = table_name('users');
    $stmt = $pdo->prepare("SELECT id, nickname, account_status FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!is_array($user)) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    $pdo->prepare("UPDATE {$userTable} SET account_status = 'active' WHERE id = ?")->execute([$userId]);
    admin_audit($pdo, $sess, 'user.reactivate', 'user', $userId, [
        'nickname' => $user['nickname'],
        'reason'   => $reason,
    ]);
    json_out(['ok' => true]);
}

function admin_panel_user_delete_action(): void
{
    require_post();
    $sess   = require_admin_role(...admin_roles_write());
    $pdo    = db();
    $body   = read_json();
    $userId = (int) ($body['user_id'] ?? 0);
    $reason = trim((string) ($body['reason'] ?? ''));

    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }
    if ($reason === '') {
        json_out(['ok' => false, 'error' => 'A reason is required to delete a user.'], 400);
    }

    // Same erasure as a self-service deletion: sessions, push tokens, social links,
    // friends, payment details and avatar are removed; shared trip history stays.
    ensure_account_action_proof_schema($pdo);
    ensure_refresh_tokens_table_available($pdo);
    $cleanup = null;
    $pdo->beginTransaction();
    try {
        $user = lock_account_action_user($pdo, $userId);
        if (!is_array($user)) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'User not found.'], 404);
        }
        if ((string) ($user['account_status'] ?? '') === 'deleted') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'This user is already deleted.'], 409);
        }
        // The audit entry keeps no email, so an erased account leaves no contact data behind.
        admin_audit($pdo, $sess, 'user.delete', 'user', $userId, [
            'nickname' => $user['nickname'],
            'reason'   => $reason,
        ]);
        $cleanup = erase_account_for_deletion($pdo, $user);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $error;
    }
    finish_account_deletion_cleanup($cleanup);

    json_out(['ok' => true]);
}

function admin_panel_clear_push_tokens_action(): void
{
    require_post();
    $sess   = require_admin_role(...admin_roles_support());
    $pdo    = db();
    $body   = read_json();
    $userId = (int) ($body['user_id'] ?? 0);

    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }

    $pushTable = table_name('push_tokens');
    $stmt = $pdo->prepare("DELETE FROM {$pushTable} WHERE user_id = ?");
    $stmt->execute([$userId]);
    $count = $stmt->rowCount();

    admin_audit($pdo, $sess, 'user.push_tokens.clear', 'user', $userId, ['removed' => $count]);
    json_out(['ok' => true, 'removed' => $count]);
}

// ── Push queue ────────────────────────────────────────────────────────────────

function admin_panel_push_queue_action(): void
{
    $sess   = require_admin_role(...admin_roles_ops());
    $pdo    = db();
    $status = trim((string) ($_GET['status'] ?? 'all'));
    $limit  = max(1, min(100, (int) ($_GET['limit']  ?? 50)));
    $offset = max(0,          (int) ($_GET['offset'] ?? 0));

    $queueTable = table_name('push_queue');

    // Health summary
    $stmt  = $pdo->query("SELECT status, COUNT(*) AS cnt, MAX(created_at) AS latest FROM {$queueTable} GROUP BY status");
    $health = [];
    foreach ($stmt->fetchAll() as $row) {
        $health[(string) $row['status']] = ['count' => (int) $row['cnt'], 'latest' => $row['latest']];
    }

    // Filtered rows
    $where  = ($status !== 'all') ? 'WHERE status = ?' : '';
    $params = ($status !== 'all') ? [$status, $limit, $offset] : [$limit, $offset];
    $stmt   = $pdo->prepare("
        SELECT id, user_id, type, title, body, status, attempts, last_error, created_at, sent_at
        FROM {$queueTable}
        {$where}
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    json_out(['ok' => true, 'health' => $health, 'rows' => $rows, 'limit' => $limit, 'offset' => $offset]);
}

function admin_panel_push_retry_action(): void
{
    require_post();
    $sess    = require_admin_role(...admin_roles_ops());
    $pdo     = db();
    $body    = read_json();
    $queueId = (int) ($body['queue_id'] ?? 0);

    if ($queueId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid queue_id.'], 400);
    }

    $queueTable = table_name('push_queue');
    $stmt = $pdo->prepare("SELECT id, status FROM {$queueTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$queueId]);
    $item = $stmt->fetch();
    if (!is_array($item)) {
        json_out(['ok' => false, 'error' => 'Queue item not found.'], 404);
    }
    if ($item['status'] === 'sent') {
        json_out(['ok' => false, 'error' => 'Item already sent.'], 409);
    }

    // Reset attempts so the background worker picks it up again
    $pdo->prepare("UPDATE {$queueTable} SET status = 'pending', attempts = 0, last_error = NULL WHERE id = ?")
        ->execute([$queueId]);

    admin_audit($pdo, $sess, 'push.retry', 'push_queue', $queueId);
    json_out(['ok' => true]);
}

// ── Incidents ─────────────────────────────────────────────────────────────────

function admin_panel_incidents_action(): void
{
    $sess   = require_admin_role(...admin_roles_all());
    $pdo    = db();
    $status = trim((string) ($_GET['status'] ?? 'all'));
    $limit  = max(1, min(100, (int) ($_GET['limit']  ?? 25)));
    $offset = max(0,          (int) ($_GET['offset'] ?? 0));

    $incTable = table_name('admin_incidents');

    $where  = ($status !== 'all') ? 'WHERE status = ?' : '';
    $params = ($status !== 'all') ? [$status, $limit, $offset] : [$limit, $offset];

    $stmt = $pdo->prepare("
        SELECT id, admin_username, title, body, severity, status,
               resolved_at, resolved_by_username, created_at, updated_at
        FROM {$incTable}
        {$where}
        ORDER BY
          FIELD(status,'open','investigating','resolved'),
          FIELD(severity,'critical','high','medium','low'),
          created_at DESC
        LIMIT ? OFFSET ?
    ");
    $stmt->execute($params);
    $incidents = $stmt->fetchAll();

    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$incTable} {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    json_out(['ok' => true, 'incidents' => $incidents, 'total' => $total]);
}

function admin_panel_create_incident_action(): void
{
    require_post();
    $sess  = require_admin_role(...admin_roles_ops());
    $pdo   = db();
    $body  = read_json();

    $title    = trim((string) ($body['title']    ?? ''));
    $bodyText = trim((string) ($body['body']     ?? ''));
    $severity = trim((string) ($body['severity'] ?? 'medium'));

    if ($title === '') {
        json_out(['ok' => false, 'error' => 'Title is required.'], 400);
    }
    if (!in_array($severity, ['low', 'medium', 'high', 'critical'], true)) {
        json_out(['ok' => false, 'error' => 'Invalid severity.'], 400);
    }

    $incTable = table_name('admin_incidents');
    $stmt = $pdo->prepare("
        INSERT INTO {$incTable} (admin_user_id, admin_username, title, body, severity)
        VALUES (?, ?, ?, ?, ?)
    ");
    $stmt->execute([
        (int) $sess['admin_user_id'],
        (string) $sess['username'],
        $title,
        $bodyText,
        $severity,
    ]);
    $incidentId = (int) $pdo->lastInsertId();

    admin_audit($pdo, $sess, 'incident.create', 'incident', $incidentId, [
        'title'    => $title,
        'severity' => $severity,
    ]);

    json_out(['ok' => true, 'id' => $incidentId]);
}

function admin_panel_update_incident_action(): void
{
    require_post();
    $sess       = require_admin_role(...admin_roles_ops());
    $pdo        = db();
    $body       = read_json();
    $incidentId = (int) ($body['id']     ?? 0);
    $newStatus  = trim((string) ($body['status'] ?? ''));

    if ($incidentId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid incident id.'], 400);
    }
    if (!in_array($newStatus, ['open', 'investigating', 'resolved'], true)) {
        json_out(['ok' => false, 'error' => 'Invalid status.'], 400);
    }

    $incTable = table_name('admin_incidents');
    $stmt = $pdo->prepare("SELECT id, status FROM {$incTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$incidentId]);
    $incident = $stmt->fetch();
    if (!is_array($incident)) {
        json_out(['ok' => false, 'error' => 'Incident not found.'], 404);
    }

    $resolvedAt = ($newStatus === 'resolved') ? date('Y-m-d H:i:s') : null;
    $resolvedBy = ($newStatus === 'resolved') ? $sess['username'] : null;

    $pdo->prepare("
        UPDATE {$incTable}
        SET status = ?, resolved_at = ?, resolved_by_username = ?
        WHERE id = ?
    ")->execute([$newStatus, $resolvedAt, $resolvedBy, $incidentId]);

    admin_audit($pdo, $sess, 'incident.update', 'incident', $incidentId, [
        'old_status' => $incident['status'],
        'new_status' => $newStatus,
    ]);

    json_out(['ok' => true]);
}

// ── Audit log ─────────────────────────────────────────────────────────────────

function admin_panel_audit_log_action(): void
{
    $sess         = require_admin_role(...admin_roles_ops());
    $pdo          = db();
    $actionFilter = trim((string) ($_GET['action_filter'] ?? ''));
    $targetFilter = trim((string) ($_GET['target']  ?? ''));
    $limit        = max(1, min(200, (int) ($_GET['limit']  ?? 50)));
    $offset       = max(0,          (int) ($_GET['offset'] ?? 0));

    $logTable = table_name('admin_audit_log');

    $conditions = [];
    $params     = [];

    if ($actionFilter !== '') {
        $conditions[] = 'action LIKE ?';
        $params[]     = '%' . str_replace(['%', '_'], ['\\%', '\\_'], $actionFilter) . '%';
    }
    if ($targetFilter !== '') {
        $conditions[] = 'target_type = ?';
        $params[]     = $targetFilter;
    }

    $where = $conditions ? 'WHERE ' . implode(' AND ', $conditions) : '';

    $stmt = $pdo->prepare("
        SELECT id, admin_username, action, target_type, target_id, details, ip_address, created_at
        FROM {$logTable}
        {$where}
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    // Decode JSON details for response
    foreach ($rows as &$row) {
        if ($row['details'] !== null) {
            $row['details'] = json_decode((string) $row['details'], true);
        }
    }
    unset($row);

    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$logTable} {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    json_out(['ok' => true, 'log' => $rows, 'total' => $total, 'limit' => $limit, 'offset' => $offset]);
}

// ── App events feed ───────────────────────────────────────────────────────────

function admin_panel_app_events_action(): void
{
    require_admin_role(...admin_roles_ops());
    $pdo        = db();
    $typeFilter = trim((string) ($_GET['event_type'] ?? ''));
    $limit      = max(1, min(200, (int) ($_GET['limit']  ?? 50)));
    $offset     = max(0,          (int) ($_GET['offset'] ?? 0));

    $eventsTable = table_name('app_events');
    $usersTable  = table_name('users');

    $conditions = [];
    $params     = [];

    if ($typeFilter !== '') {
        $conditions[] = 'e.event_type LIKE ?';
        $params[]     = '%' . str_replace(['%', '_'], ['\\%', '\\_'], $typeFilter) . '%';
    }

    $where = $conditions ? 'WHERE ' . implode(' AND ', $conditions) : '';

    $stmt = $pdo->prepare("
        SELECT e.id, e.user_id, u.nickname AS username, e.event_type, e.entity_type, e.entity_id, e.created_at
        FROM {$eventsTable} e
        LEFT JOIN {$usersTable} u ON u.id = e.user_id
        {$where}
        ORDER BY e.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$eventsTable} e {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    json_out(['ok' => true, 'events' => $rows, 'total' => $total, 'limit' => $limit, 'offset' => $offset]);
}

// ── Admin user management (superadmin only) ───────────────────────────────────

function admin_panel_admin_users_action(): void
{
    $sess      = require_admin_role('superadmin');
    $pdo       = db();
    $userTable = table_name('admin_users');
    $sessTable = table_name('admin_sessions');

    $stmt = $pdo->query("
        SELECT u.id, u.username, u.email, u.role, u.is_active,
               u.totp_enabled, u.last_login_at, u.locked_until, u.created_at,
               COUNT(s.token) AS active_sessions
        FROM {$userTable} u
        LEFT JOIN {$sessTable} s ON s.admin_user_id = u.id AND s.expires_at > UTC_TIMESTAMP()
        GROUP BY u.id
        ORDER BY u.created_at ASC
    ");
    $users = $stmt->fetchAll();

    json_out(['ok' => true, 'users' => $users]);
}

function admin_panel_create_admin_user_action(): void
{
    require_post();
    $sess      = require_admin_role('superadmin');
    $pdo       = db();
    $body      = read_json();

    $username = trim((string) ($body['username'] ?? ''));
    $email    = trim((string) ($body['email']    ?? ''));
    $password = (string) ($body['password']      ?? '');
    $role     = trim((string) ($body['role']     ?? 'readonly'));

    if ($username === '' || $email === '' || $password === '') {
        json_out(['ok' => false, 'error' => 'Username, email and password are required.'], 400);
    }
    if (!in_array($role, ['superadmin', 'admin', 'support', 'ops', 'readonly'], true)) {
        json_out(['ok' => false, 'error' => 'Invalid role.'], 400);
    }
    if (strlen($password) < 12) {
        json_out(['ok' => false, 'error' => 'Password must be at least 12 characters.'], 400);
    }

    $hash      = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);
    $userTable = table_name('admin_users');

    try {
        $pdo->prepare("
            INSERT INTO {$userTable} (username, email, password_hash, role)
            VALUES (?, ?, ?, ?)
        ")->execute([$username, $email, $hash, $role]);
    } catch (PDOException $e) {
        if (str_contains($e->getMessage(), 'Duplicate entry')) {
            json_out(['ok' => false, 'error' => 'Username or email already exists.'], 409);
        }
        throw $e;
    }

    $newId = (int) $pdo->lastInsertId();
    admin_audit($pdo, $sess, 'admin_user.create', 'admin_user', $newId, [
        'username' => $username,
        'role'     => $role,
    ]);
    json_out(['ok' => true, 'id' => $newId]);
}

function admin_panel_update_admin_user_action(): void
{
    require_post();
    $sess      = require_admin_role('superadmin');
    $pdo       = db();
    $body      = read_json();
    $targetId  = (int) ($body['id'] ?? 0);

    if ($targetId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid id.'], 400);
    }

    $userTable = table_name('admin_users');
    $stmt = $pdo->prepare("SELECT * FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$targetId]);
    $existing = $stmt->fetch();
    if (!is_array($existing)) {
        json_out(['ok' => false, 'error' => 'Admin user not found.'], 404);
    }

    $changes = [];

    if (isset($body['role'])) {
        $role = trim((string) $body['role']);
        if (!in_array($role, ['superadmin', 'admin', 'support', 'ops', 'readonly'], true)) {
            json_out(['ok' => false, 'error' => 'Invalid role.'], 400);
        }
        $changes['role'] = $role;
    }

    if (isset($body['is_active'])) {
        $changes['is_active'] = (int) (bool) $body['is_active'];
    }

    if (isset($body['password'])) {
        $pw = (string) $body['password'];
        if (strlen($pw) < 12) {
            json_out(['ok' => false, 'error' => 'Password must be at least 12 characters.'], 400);
        }
        $changes['password_hash'] = password_hash($pw, PASSWORD_BCRYPT, ['cost' => 12]);
    }

    $resetTotp = !empty($body['reset_totp']);
    $isSelf = $targetId === (int) $sess['admin_user_id'];
    if ($resetTotp && $isSelf) {
        json_out(['ok' => false, 'error' => 'Replace your own authenticator from My Account.'], 400);
    }

    if (empty($changes) && !$resetTotp) {
        json_out(['ok' => false, 'error' => 'Nothing to update.'], 400);
    }

    $pdo->beginTransaction();
    try {
        if ($changes) {
            $setClauses = implode(', ', array_map(fn(string $k) => "{$k} = ?", array_keys($changes)));
            $pdo->prepare("UPDATE {$userTable} SET {$setClauses} WHERE id = ?")
                ->execute([...array_values($changes), $targetId]);
        }
        $revoked = 0;
        if ($resetTotp) {
            $revoked = admin_totp_reset_user($pdo, $targetId);
        } elseif (!$isSelf && (isset($changes['password_hash']) || ($changes['is_active'] ?? 1) === 0)) {
            // A new password or deactivation signs the other admin out everywhere.
            $revoke = $pdo->prepare('DELETE FROM ' . table_name('admin_sessions') . ' WHERE admin_user_id = ?');
            $revoke->execute([$targetId]);
            $revoked = $revoke->rowCount();
        }
        $logDetails = array_diff_key($changes, ['password_hash' => null]); // Don't log hash
        if (isset($changes['password_hash'])) {
            $logDetails['password_changed'] = true;
        }
        if ($resetTotp) {
            $logDetails['totp_reset'] = true;
        }
        $logDetails['revoked_sessions'] = $revoked;
        admin_audit($pdo, $sess, 'admin_user.update', 'admin_user', $targetId, $logDetails, true);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    json_out(['ok' => true]);
}

function admin_panel_delete_admin_user_action(): void
{
    require_post();
    $sess     = require_admin_role('superadmin');
    $pdo      = db();
    $body     = read_json();
    $targetId = (int) ($body['id'] ?? 0);

    if ($targetId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid id.'], 400);
    }
    if ($targetId === (int) $sess['admin_user_id']) {
        json_out(['ok' => false, 'error' => 'You cannot delete your own account.'], 400);
    }

    $userTable = table_name('admin_users');
    $stmt = $pdo->prepare("SELECT username FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$targetId]);
    $row = $stmt->fetch();
    if (!is_array($row)) {
        json_out(['ok' => false, 'error' => 'Admin user not found.'], 404);
    }

    admin_audit($pdo, $sess, 'admin_user.delete', 'admin_user', $targetId, [
        'username' => $row['username'],
    ]);

    $pdo->prepare("DELETE FROM {$userTable} WHERE id = ?")->execute([$targetId]);
    json_out(['ok' => true]);
}

// ── Feedback (proxy via new auth) ─────────────────────────────────────────────

function admin_panel_feedback_action(): void
{
    require_admin_role(...admin_roles_support());
    // Delegate to the existing feedback feed action but with new auth already validated
    admin_feedback_feed_action_inner();
}

/**
 * Inner implementation split out from admin_feedback_feed_action so we can
 * call it without re-running require_admin().
 */
function admin_feedback_feed_action_inner(): void
{
    $pdo            = db();
    $feedbackTable  = table_name('feedback');
    $statusHistTable = table_name('feedback_status_history');
    $usersTable     = table_name('users');
    $tripsTable     = table_name('trips');

    $limit  = max(1, min(120, (int) ($_GET['limit']  ?? 40)));
    $offset = max(0,           (int) ($_GET['offset'] ?? 0));
    $type   = strtolower(trim((string) ($_GET['type'] ?? 'all')));
    if (!in_array($type, ['all', 'bug', 'suggestion'], true)) {
        json_out(['ok' => false, 'error' => 'Invalid type.'], 400);
    }
    $statusFilter = normalize_admin_feedback_status_filter((string) ($_GET['status'] ?? 'all'));
    $hasScreenshot = strtolower(trim((string) ($_GET['has_screenshot'] ?? 'all')));
    $search = trim((string) ($_GET['search'] ?? ''));

    $conditions = [];
    $params     = [];

    if ($type !== 'all') {
        $conditions[] = 'f.type = ?';
        $params[]     = $type;
    }
    if ($statusFilter !== 'all') {
        $conditions[] = 'f.status = ?';
        $params[]     = $statusFilter;
    }
    if ($hasScreenshot === 'yes') {
        $conditions[] = 'f.screenshot_path IS NOT NULL';
    } elseif ($hasScreenshot === 'no') {
        $conditions[] = 'f.screenshot_path IS NULL';
    }
    if ($search !== '') {
        $conditions[] = 'f.message LIKE ?';
        $like = '%' . str_replace(['%', '_'], ['\\%', '\\_'], $search) . '%';
        $params[] = $like;
    }

    $where = $conditions ? ('WHERE ' . implode(' AND ', $conditions)) : '';

    $stmt = $pdo->prepare("
        SELECT f.*, u.nickname AS user_nickname, u.email AS user_email,
               t.name AS trip_name
        FROM {$feedbackTable} f
        LEFT JOIN {$usersTable} u ON u.id = f.user_id
        LEFT JOIN {$tripsTable} t ON t.id = f.trip_id
        {$where}
        ORDER BY f.created_at DESC
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $feedback = $stmt->fetchAll();

    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$feedbackTable} f {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    // Stats
    $statsStmt = $pdo->query("
        SELECT
          COUNT(*) AS total,
          SUM(type = 'bug') AS bugs,
          SUM(type = 'suggestion') AS suggestions,
          SUM(screenshot_path IS NOT NULL) AS with_screenshot,
          SUM(status = 'open') AS open_count,
          SUM(status = 'archived') AS archived_count
        FROM {$feedbackTable}
    ");
    $stats = $statsStmt->fetch();

    json_out([
        'ok'       => true,
        'feedback' => $feedback,
        'total'    => $total,
        'stats'    => $stats,
        'limit'    => $limit,
        'offset'   => $offset,
    ]);
}

function admin_panel_archive_feedback_action(): void
{
    require_post();
    $sess = require_admin_role(...admin_roles_support());
    $pdo  = db();
    $body = read_json();
    $id   = (int) ($body['id'] ?? 0);

    if ($id <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid feedback id.'], 400);
    }

    $feedbackTable = table_name('feedback');
    $pdo->prepare("UPDATE {$feedbackTable} SET status = 'archived' WHERE id = ?")->execute([$id]);
    admin_audit($pdo, $sess, 'feedback.archive', 'feedback', $id);
    json_out(['ok' => true]);
}

function admin_panel_delete_feedback_action(): void
{
    require_post();
    $sess = require_admin_role(...admin_roles_write());
    $pdo  = db();
    $body = read_json();
    $id   = (int) ($body['id'] ?? 0);

    if ($id <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid feedback id.'], 400);
    }

    $feedbackTable = table_name('feedback');
    $pdo->prepare("DELETE FROM {$feedbackTable} WHERE id = ?")->execute([$id]);
    admin_audit($pdo, $sess, 'feedback.delete', 'feedback', $id);
    json_out(['ok' => true]);
}
