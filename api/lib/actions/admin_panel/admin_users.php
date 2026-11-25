<?php
declare(strict_types=1);

// Admin user management (superadmin only).
// Loaded by ../admin_panel_actions.php; routes are registered in the router.

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
