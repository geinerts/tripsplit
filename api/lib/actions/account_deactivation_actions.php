<?php
declare(strict_types=1);

function deactivation_credential_state(array $user): string
{
    return hash('sha256', json_encode([(int) $user['id'], (string) $user['email'],
        (string) $user['password_hash'], (string) $user['email_verified_at'],
        (int) $user['credentials_required'], (string) ($user['deactivated_at'] ?? '')], JSON_THROW_ON_ERROR));
}

function ensure_deactivation_link_schema(PDO $pdo): void
{
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name
        AND column_name = 'credential_state_hash'");
    $stmt->execute(['table_name' => trim(table_name('account_action_tokens'), '`')]);
    if (!(bool) $stmt->fetchColumn() || !users_deactivated_at_column_available($pdo)
        || !users_account_status_column_available($pdo) || !users_email_verified_at_column_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Deactivation by email is temporarily unavailable.'], 503);
    }
}

function lock_deactivation_user(PDO $pdo, int $id): ?array
{
    $stmt = $pdo->prepare('SELECT id, email, password_hash, credentials_required, '
        . users_account_status_select_sql($pdo) . 'nickname FROM ' . table_name('users')
        . ' WHERE id = :id FOR UPDATE');
    $stmt->execute(['id' => $id]);
    return $stmt->fetch() ?: null;
}

function request_deactivation_link_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $userId = (int) $me['id'];
    enforce_rate_limit($pdo, 'deactivation_link_ip', client_ip_address(), 10, 900, true);
    enforce_rate_limit($pdo, 'deactivation_link_user', (string) $userId, 3, 3600, true);
    enforce_rate_limit($pdo, 'deactivation_link_global', 'all', 100, 3600, true);
    ensure_deactivation_link_schema($pdo);
    $table = table_name('account_action_tokens');
    $token = null;
    $tokenId = 0;
    $pdo->beginTransaction();
    try {
        $user = lock_deactivation_user($pdo, $userId);
        if (!$user || !user_account_is_active($user) || empty($user['email_verified_at'])
            || empty($user['email']) || (int) $user['credentials_required'] !== 0) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'A verified active account is required.'], 403);
        }
        $stmt = $pdo->prepare('SELECT created_at FROM ' . $table . '
            WHERE user_id = :id AND action = :action AND created_at > :cutoff
            ORDER BY created_at DESC FOR UPDATE');
        $stmt->execute(['id' => $userId, 'action' => 'deactivate', 'cutoff' => gmdate('Y-m-d H:i:s', time() - 3600)]);
        $recent = $stmt->fetchAll(PDO::FETCH_COLUMN);
        if (count($recent) < 3 && ($recent === [] || $recent[0] <= gmdate('Y-m-d H:i:s', time() - 60))) {
            $token = bin2hex(random_bytes(32));
            $pdo->prepare('INSERT INTO ' . $table . '
                (user_id, action, token_hash, credential_state_hash, expires_at)
                VALUES (:id, :action, :hash, :state, :expiry)')->execute([
                    'id' => $userId, 'action' => 'deactivate', 'hash' => hash('sha256', $token),
                    'state' => deactivation_credential_state($user),
                    'expiry' => gmdate('Y-m-d H:i:s', time() + 900),
                ]);
            $tokenId = (int) $pdo->lastInsertId();
        }
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $e;
    }
    if ($token !== null) {
        $url = app_base_url() . '/api/deactivate-account.php?token=' . urlencode($token);
        try {
            $sent = send_email_via_resend((string) $user['email'], 'Confirm Splyto account deactivation',
                build_account_deactivation_email($url, (string) $user['nickname']));
        } catch (Throwable $error) {
            $sent = false;
        }
        if (!$sent) {
            $pdo->prepare('UPDATE ' . $table . ' SET used_at = UTC_TIMESTAMP() WHERE id = :id')
                ->execute(['id' => $tokenId]);
            json_out(['ok' => false, 'error' => 'Could not send the confirmation email. Try again later.'], 503);
        }
    }
    json_out(['ok' => true]);
}

function confirm_deactivation_action(): void
{
    require_post();
    $body = read_json();
    $token = (string) ($body['token'] ?? '');
    if (!preg_match('/^[a-f0-9]{64}$/D', $token)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired deactivation link.'], 400);
    }
    $pdo = db();
    enforce_rate_limit($pdo, 'deactivation_confirm_ip', client_ip_address(), 20, 900, true);
    enforce_rate_limit($pdo, 'deactivation_confirm_token', hash('sha256', $token), 5, 900, true);
    ensure_deactivation_link_schema($pdo);
    ensure_refresh_tokens_table_available($pdo);
    $table = table_name('account_action_tokens');
    $hash = hash('sha256', $token);
    $lookup = $pdo->prepare('SELECT user_id FROM ' . $table . ' WHERE token_hash = :hash AND action = :action');
    $lookup->execute(['hash' => $hash, 'action' => 'deactivate']);
    $userId = (int) $lookup->fetchColumn();
    $pdo->beginTransaction();
    try {
        $user = lock_deactivation_user($pdo, $userId);
        $stmt = $pdo->prepare('SELECT id, credential_state_hash FROM ' . $table . '
            WHERE token_hash = :hash AND action = :action AND used_at IS NULL
              AND expires_at > UTC_TIMESTAMP() LIMIT 1 FOR UPDATE');
        $stmt->execute(['hash' => $hash, 'action' => 'deactivate']);
        $proof = $stmt->fetch();
        if (!$user || !user_account_is_active($user) || empty($user['email_verified_at'])
            || (int) $user['credentials_required'] !== 0 || !$proof
            || !hash_equals(deactivation_credential_state($user), (string) $proof['credential_state_hash'])) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid or expired deactivation link.'], 400);
        }
        $pdo->prepare('UPDATE ' . table_name('users') . '
            SET account_status = :status, deactivated_at = UTC_TIMESTAMP() WHERE id = :id')
            ->execute(['status' => 'deactivated', 'id' => $userId]);
        revoke_refresh_tokens_for_user($pdo, $userId);
        deactivate_push_tokens_for_user($pdo, $userId);
        $pdo->prepare('UPDATE ' . $table . ' SET used_at = UTC_TIMESTAMP()
            WHERE user_id = :id AND used_at IS NULL')->execute(['id' => $userId]);
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $e;
    }
    json_out(['ok' => true]);
}
