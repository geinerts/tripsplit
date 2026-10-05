<?php
declare(strict_types=1);

function ensure_account_action_proof_schema(PDO $pdo): void
{
    $stmt = $pdo->prepare("SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name
        AND column_name = 'credential_state_hash'");
    $stmt->execute(['table_name' => trim(table_name('account_action_tokens'), '`')]);
    if (!(bool) $stmt->fetchColumn() || !users_account_status_column_available($pdo)
        || !users_email_verified_at_column_available($pdo) || !users_deactivated_at_column_available($pdo)
        || !users_deleted_at_column_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Account confirmation is temporarily unavailable.'], 503);
    }
}

function account_action_proof_state(array $user, string $action): string
{
    return hash('sha256', json_encode([
        'account-action-v1', $action, (int) $user['id'], (string) $user['email'],
        (string) $user['password_hash'], (int) $user['credentials_required'],
        (string) $user['email_verified_at'], (string) $user['account_status'],
        (string) ($user['deactivated_at'] ?? ''), (string) ($user['deleted_at'] ?? ''),
    ], JSON_THROW_ON_ERROR));
}

function account_action_user_is_eligible(array $user, string $action): bool
{
    return in_array($action, ['delete', 'reactivate'], true)
        && (string) ($user['account_status'] ?? '') === ($action === 'delete' ? 'active' : 'deactivated')
        && (int) ($user['credentials_required'] ?? 1) === 0
        && !empty($user['email_verified_at']) && !empty($user['email'])
        && empty($user['deleted_at']);
}

function lock_account_action_user(PDO $pdo, int $id): ?array
{
    $stmt = $pdo->prepare('SELECT id, email, password_hash, credentials_required, nickname, avatar_path, '
        . users_account_status_select_sql($pdo) . 'device_token FROM ' . table_name('users')
        . ' WHERE id = :id FOR UPDATE');
    $stmt->execute(['id' => $id]);
    return $stmt->fetch() ?: null;
}

// The caller holds the user lock for both cooldown evaluation and proof creation.
function create_account_action_link_token(PDO $pdo, array $user, string $action): ?array
{
    if (!$pdo->inTransaction() || !account_action_user_is_eligible($user, $action)) {
        throw new RuntimeException('Account proof requires a locked eligible user.');
    }
    $table = table_name('account_action_tokens');
    $stmt = $pdo->prepare('SELECT created_at FROM ' . $table . '
        WHERE user_id = :id AND action = :action AND created_at > :cutoff
        ORDER BY created_at DESC FOR UPDATE');
    $stmt->execute(['id' => $user['id'], 'action' => $action, 'cutoff' => gmdate('Y-m-d H:i:s', time() - 3600)]);
    $recent = $stmt->fetchAll(PDO::FETCH_COLUMN);
    if (count($recent) >= 3 || ($recent !== [] && $recent[0] > gmdate('Y-m-d H:i:s', time() - 60))) {
        return null;
    }
    $token = bin2hex(random_bytes(32));
    $ttl = min(account_action_ttl_seconds($action), $action === 'delete' ? 3600 : 86400);
    $expires = gmdate('Y-m-d H:i:s', time() + $ttl);
    $pdo->prepare('INSERT INTO ' . $table . '
        (user_id, action, token_hash, credential_state_hash, expires_at)
        VALUES (:id, :action, :hash, :state, :expires)')->execute([
            'id' => $user['id'], 'action' => $action, 'hash' => hash('sha256', $token),
            'state' => account_action_proof_state($user, $action), 'expires' => $expires,
        ]);
    return ['id' => (int) $pdo->lastInsertId(), 'token' => $token, 'expires_at' => $expires];
}

function consume_account_action_proofs(PDO $pdo, int $userId): void
{
    $pdo->prepare('UPDATE ' . table_name('account_action_tokens')
        . ' SET used_at = UTC_TIMESTAMP() WHERE user_id = :id AND used_at IS NULL')
        ->execute(['id' => $userId]);
}

function deleted_account_payment_assignments(PDO $pdo): string
{
    $stmt = $pdo->prepare('SELECT column_name FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = :table_name');
    $stmt->execute(['table_name' => trim(table_name('users'), '`')]);
    $available = $stmt->fetchAll(PDO::FETCH_COLUMN);
    $fields = ['bank_country_code', 'bank_account_holder', 'bank_account_number', 'bank_iban',
        'bank_bic', 'bank_sort_code', 'bank_routing_number', 'revolut_handle',
        'revolut_me_link', 'paypal_me_link', 'wise_pay_link'];
    $sql = '';
    foreach (array_intersect($fields, $available) as $field) { $sql .= '`' . $field . '` = NULL, '; }
    return $sql;
}
