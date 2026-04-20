<?php
declare(strict_types=1);

// ══════════════════════════════════════════════════════════════════════════════
// Admin Panel v2 Actions
// Auth: cookie-based sessions with optional TOTP 2FA, RBAC roles.
// All write actions emit an audit log entry.
// ══════════════════════════════════════════════════════════════════════════════

// ── Auth ──────────────────────────────────────────────────────────────────────

function admin_panel_login_action(): void
{
    require_post();
    $pdo  = db();
    $body = read_json();

    $username = trim((string) ($body['username'] ?? ''));
    $password = (string) ($body['password'] ?? '');

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
            if ($fails >= ADMIN_LOCK_THRESHOLD) {
                $lockUntil = date('Y-m-d H:i:s', time() + ADMIN_LOCK_MINUTES * 60);
                $pdo->prepare("UPDATE {$userTable} SET failed_login_count = ?, locked_until = ? WHERE id = ?")
                    ->execute([$fails, $lockUntil, $user['id']]);
            } else {
                $pdo->prepare("UPDATE {$userTable} SET failed_login_count = ? WHERE id = ?")
                    ->execute([$fails, $user['id']]);
            }
        }
        json_out(['ok' => false, 'error' => 'Invalid username or password.'], 401);
    }

    // Reset failed counter on success
    $pdo->prepare("UPDATE {$userTable} SET failed_login_count = 0, locked_until = NULL, last_login_at = UTC_TIMESTAMP() WHERE id = ?")
        ->execute([$user['id']]);

    $needs2fa    = (int) $user['totp_enabled'] === 1;
    $sessionToken = admin_create_session($pdo, (int) $user['id'], !$needs2fa);
    admin_set_session_cookie($sessionToken);

    json_out([
        'ok'          => true,
        'requires_2fa' => $needs2fa,
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

    // Accept a partial session (not yet 2FA-verified)
    $token = admin_session_token_from_cookie();
    if ($token === '') {
        json_out(['ok' => false, 'error' => 'Not authenticated.'], 401);
    }
    $sessTable = table_name('admin_sessions');
    $userTable = table_name('admin_users');

    $stmt = $pdo->prepare("
        SELECT s.token, s.admin_user_id, s.is_2fa_verified,
               u.totp_secret, u.totp_enabled, u.username, u.email, u.role
        FROM {$sessTable} s
        JOIN {$userTable} u ON u.id = s.admin_user_id
        WHERE s.token = ? AND s.expires_at > UTC_TIMESTAMP() AND u.is_active = 1
    ");
    $stmt->execute([$token]);
    $sess = $stmt->fetch();

    if (!is_array($sess)) {
        json_out(['ok' => false, 'error' => 'Session not found or expired.'], 401);
    }
    if ((int) $sess['totp_enabled'] !== 1) {
        json_out(['ok' => false, 'error' => '2FA is not enabled on this account.'], 400);
    }
    if (!admin_totp_verify((string) $sess['totp_secret'], $code)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired 2FA code.'], 401);
    }

    $pdo->prepare("UPDATE {$sessTable} SET is_2fa_verified = 1 WHERE token = ?")
        ->execute([$token]);

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
    $token = admin_session_token_from_cookie();
    if ($token !== '') {
        $sessTable = table_name('admin_sessions');
        db()->prepare("DELETE FROM {$sessTable} WHERE token = ?")->execute([$token]);
    }
    admin_clear_session_cookie();
    json_out(['ok' => true]);
}

function admin_panel_session_check_action(): void
{
    require_get();
    $token = admin_session_token_from_cookie();
    $sess  = admin_resolve_session(db(), $token);

    if ($sess === null) {
        json_out(['ok' => false, 'authenticated' => false]);
    }

    $needs2fa  = (int) $sess['totp_enabled'] === 1;
    $verified  = (bool) $sess['is_2fa_verified'];
    $fullAuth  = !$needs2fa || $verified;

    json_out([
        'ok'            => true,
        'authenticated' => true,
        'full_auth'     => $fullAuth,
        'requires_2fa'  => $needs2fa && !$verified,
        'user'          => [
            'id'           => (int) $sess['admin_user_id'],
            'username'     => $sess['username'],
            'email'        => $sess['email'],
            'role'         => $sess['role'],
            'totp_enabled' => $needs2fa,
        ],
    ]);
}

// ── TOTP Setup ────────────────────────────────────────────────────────────────

function admin_panel_setup_totp_action(): void
{
    require_get();
    $sess      = require_admin_session();
    $secret    = admin_totp_generate_secret();
    $uri       = admin_totp_uri($secret, (string) $sess['username']);
    $qrUrl     = 'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=' . rawurlencode($uri);

    // Persist the pending secret (enabled=0 until confirmed)
    $userTable = table_name('admin_users');
    db()->prepare("UPDATE {$userTable} SET totp_secret = ? WHERE id = ?")
       ->execute([$secret, (int) $sess['admin_user_id']]);

    json_out(['ok' => true, 'secret' => $secret, 'qr_url' => $qrUrl, 'uri' => $uri]);
}

function admin_panel_confirm_totp_action(): void
{
    require_post();
    $sess      = require_admin_session();
    $pdo       = db();
    $body      = read_json();
    $code      = trim((string) ($body['code'] ?? ''));

    $userTable = table_name('admin_users');
    $stmt      = $pdo->prepare("SELECT totp_secret FROM {$userTable} WHERE id = ?");
    $stmt->execute([(int) $sess['admin_user_id']]);
    $secret = (string) ($stmt->fetchColumn() ?: '');

    if ($secret === '' || !admin_totp_verify($secret, $code)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired 2FA code.'], 400);
    }

    $pdo->prepare("UPDATE {$userTable} SET totp_enabled = 1 WHERE id = ?")
       ->execute([(int) $sess['admin_user_id']]);

    admin_audit($pdo, $sess, 'admin.totp.enable');
    json_out(['ok' => true]);
}

function admin_panel_disable_totp_action(): void
{
    require_post();
    $sess      = require_admin_session();
    $pdo       = db();
    $body      = read_json();
    $password  = (string) ($body['password'] ?? '');

    $userTable = table_name('admin_users');
    $stmt      = $pdo->prepare("SELECT password_hash FROM {$userTable} WHERE id = ?");
    $stmt->execute([(int) $sess['admin_user_id']]);
    $hash = (string) ($stmt->fetchColumn() ?: '');

    if (!password_verify($password, $hash)) {
        json_out(['ok' => false, 'error' => 'Incorrect password.'], 403);
    }

    $pdo->prepare("UPDATE {$userTable} SET totp_enabled = 0, totp_secret = NULL WHERE id = ?")
       ->execute([(int) $sess['admin_user_id']]);

    admin_audit($pdo, $sess, 'admin.totp.disable');
    json_out(['ok' => true]);
}

// ── Active Sessions ───────────────────────────────────────────────────────────

function admin_panel_active_sessions_action(): void
{
    require_get();
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
    $current  = admin_session_token_from_cookie();
    $sessions = array_map(function (array $row) use ($current): array {
        return [
            'token'           => substr($row['token'], 0, 8) . '…', // mask
            'token_full'      => $row['token'],                       // for revoke
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
    $target    = trim((string) ($body['token'] ?? ''));

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
    require_get();
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
    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users}");
    $stats['total_users'] = (int) $stmt->fetchColumn();

    $stmt = $pdo->query("SELECT COUNT(*) FROM {$users} WHERE account_status = 'active'");
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

    json_out(['ok' => true, 'stats' => $stats]);
}

// ── User support tools ────────────────────────────────────────────────────────

function admin_panel_user_search_action(): void
{
    require_get();
    $sess = require_admin_role(...admin_roles_support());
    $pdo  = db();

    $q      = trim((string) ($_GET['q']      ?? ''));
    $status = trim((string) ($_GET['status'] ?? 'all'));
    $limit  = max(1, min(100, (int) ($_GET['limit']  ?? 40)));
    $offset = max(0,          (int) ($_GET['offset'] ?? 0));

    $userTable = table_name('users');

    $conditions = [];
    $params     = [];

    if ($q !== '') {
        $conditions[] = '(nickname LIKE ? OR email LIKE ?)';
        $like = '%' . str_replace(['%', '_'], ['\\%', '\\_'], $q) . '%';
        $params[] = $like;
        $params[] = $like;
    }

    if ($status !== 'all' && in_array($status, ['active', 'suspended', 'deleted'], true)) {
        $conditions[] = 'account_status = ?';
        $params[]     = $status;
    }

    $where = $conditions ? ('WHERE ' . implode(' AND ', $conditions)) : '';

    $stmt = $pdo->prepare("
        SELECT id, nickname, email, account_status, created_at, last_active_at
        FROM {$userTable}
        {$where}
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ");
    $params[] = $limit;
    $params[] = $offset;
    $stmt->execute($params);
    $users = $stmt->fetchAll();

    // Total count
    $cntStmt = $pdo->prepare("SELECT COUNT(*) FROM {$userTable} {$where}");
    $cntStmt->execute(array_slice($params, 0, count($params) - 2));
    $total = (int) $cntStmt->fetchColumn();

    json_out(['ok' => true, 'users' => $users, 'total' => $total, 'limit' => $limit, 'offset' => $offset]);
}

function admin_panel_user_detail_action(): void
{
    require_get();
    $sess   = require_admin_role(...admin_roles_support());
    $pdo    = db();
    $userId = (int) ($_GET['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid user_id.'], 400);
    }

    $userTable   = table_name('users');
    $tripsTable  = table_name('trips');
    $membTable   = table_name('trip_members');
    $expTable    = table_name('expenses');
    $pushTable   = table_name('push_tokens');
    $notifTable  = table_name('notifications');

    $stmt = $pdo->prepare("SELECT * FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!is_array($user)) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    // Remove sensitive fields
    unset($user['password_hash']);

    // Recent trips
    $stmt = $pdo->prepare("
        SELECT t.id, t.name, t.status, t.base_currency, t.created_at, tm.role AS member_role
        FROM {$tripsTable} t
        JOIN {$membTable} tm ON tm.trip_id = t.id AND tm.user_id = ?
        ORDER BY t.created_at DESC LIMIT 10
    ");
    $stmt->execute([$userId]);
    $trips = $stmt->fetchAll();

    // Recent expenses
    $stmt = $pdo->prepare("
        SELECT id, trip_id, description, amount_cents, currency, created_at
        FROM {$expTable}
        WHERE paid_by_user_id = ?
        ORDER BY created_at DESC LIMIT 10
    ");
    $stmt->execute([$userId]);
    $expenses = $stmt->fetchAll();

    // Push tokens
    $stmt = $pdo->prepare("
        SELECT platform, token_preview, created_at, last_used_at
        FROM {$pushTable}
        WHERE user_id = ?
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
        'expenses'       => $expenses,
        'push_tokens'    => $pushTokens,
        'unread_notifs'  => $unreadNotifs,
    ]);
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
    if ($user['account_status'] === 'suspended') {
        json_out(['ok' => false, 'error' => 'User is already suspended.'], 409);
    }

    $pdo->prepare("UPDATE {$userTable} SET account_status = 'suspended' WHERE id = ?")->execute([$userId]);
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

    $userTable = table_name('users');
    $stmt = $pdo->prepare("SELECT id, nickname, email FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!is_array($user)) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    admin_audit($pdo, $sess, 'user.delete', 'user', $userId, [
        'nickname' => $user['nickname'],
        'email'    => $user['email'],
        'reason'   => $reason,
    ]);

    // Cascade delete via existing admin helper (reuses admin_delete_user logic)
    // Soft-delete: mark as deleted rather than hard-delete to preserve financial history
    $pdo->prepare("UPDATE {$userTable} SET account_status = 'deleted', email = CONCAT('deleted_', id, '_', email) WHERE id = ?")
        ->execute([$userId]);

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
    require_get();
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
        SELECT id, user_id, platform, title, body, status, attempts, last_error, created_at, sent_at
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
    require_get();
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
    require_get();
    $sess         = require_admin_role(...admin_roles_ops());
    $pdo          = db();
    $actionFilter = trim((string) ($_GET['action']  ?? ''));
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

// ── Admin user management (superadmin only) ───────────────────────────────────

function admin_panel_admin_users_action(): void
{
    require_get();
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

    if (empty($changes)) {
        json_out(['ok' => false, 'error' => 'Nothing to update.'], 400);
    }

    $setClauses = implode(', ', array_map(fn(string $k) => "{$k} = ?", array_keys($changes)));
    $pdo->prepare("UPDATE {$userTable} SET {$setClauses} WHERE id = ?")
        ->execute([...array_values($changes), $targetId]);

    $logDetails = array_diff_key($changes, ['password_hash' => null]); // Don't log hash
    admin_audit($pdo, $sess, 'admin_user.update', 'admin_user', $targetId, $logDetails);
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
    require_get();
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
