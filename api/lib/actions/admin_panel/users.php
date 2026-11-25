<?php
declare(strict_types=1);

// User support tools: search, detail and account actions.
// Loaded by ../admin_panel_actions.php; routes are registered in the router.

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
        . admin_has_password_login_sql($pdo) . ',
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

/**
 * has_password_login: 1 = the user chose a password, 0 = no password login,
 * 2 = legacy account with a stored hash but unknown origin. Apple/Google sign-ups
 * store a random placeholder hash, so the hash alone does not mean email login.
 * The hash itself is never selected.
 */
function admin_has_password_login_sql(PDO $pdo): string
{
    $legacy = "CASE WHEN password_hash IS NOT NULL AND password_hash <> '' THEN 2 ELSE 0 END";
    if (!users_password_capability_available($pdo)) {
        return "{$legacy} AS has_password_login";
    }
    return "CASE WHEN has_password = 1 THEN 1 WHEN has_password = 0 THEN 0 ELSE {$legacy} END AS has_password_login";
}

/**
 * Adds how each user signs in, which app platforms they use and whether the
 * email is verified, so support can spot test or bot accounts at a glance.
 * Rows must contain has_password_login (see admin_has_password_login_sql). A legacy
 * hash counts as email sign-in only when no Apple/Google identity is linked.
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
        $linked = $providers[$id] ?? [];
        $passwordFlag = (int) ($user['has_password_login'] ?? 0);
        $email = $passwordFlag === 1 || ($passwordFlag === 2 && $linked === []);
        $user['sign_in_methods'] = array_merge($email ? ['email'] : [], $linked);
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

    $hasPassword = admin_has_password_login_sql($pdo);
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
        'features'       => admin_user_features($pdo, $userId),
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
    revoke_sessions_and_push_for_user($pdo, $userId);
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
    $reactivationSelect = email_verification_reactivation_select_sql($pdo);
    $stmt = $pdo->prepare("SELECT id, nickname, {$reactivationSelect} account_status FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!is_array($user)) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }
    if ($user['account_status'] === 'deactivated'
        && (int) ($user['email_verification_can_reactivate'] ?? 0) !== 1) {
        json_out(['ok' => false, 'error' => 'User is already deactivated/suspended.'], 409);
    }

    $clearReactivation = users_email_reactivation_column_available($pdo)
        ? ', email_verification_can_reactivate = 0' : '';
    $pdo->prepare("UPDATE {$userTable} SET account_status = 'deactivated'{$clearReactivation} WHERE id = ?")->execute([$userId]);
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
    $reactivationSelect = email_verification_reactivation_select_sql($pdo);
    $stmt = $pdo->prepare("SELECT id, nickname, {$reactivationSelect} account_status FROM {$userTable} WHERE id = ? LIMIT 1");
    $stmt->execute([$userId]);
    $user = $stmt->fetch();
    if (!is_array($user)) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    $clearReactivation = users_email_reactivation_column_available($pdo)
        ? ', email_verification_can_reactivate = 0' : '';
    $pdo->prepare("UPDATE {$userTable} SET account_status = 'active'{$clearReactivation} WHERE id = ?")->execute([$userId]);
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
