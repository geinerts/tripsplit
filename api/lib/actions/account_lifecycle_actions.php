<?php
declare(strict_types=1);

require_once __DIR__ . '/../helpers/helper_account_deletion_feedback.php';
require_once __DIR__ . '/../helpers/helper_travel_places.php';

require_once __DIR__ . '/../helpers/helper_account_action_proofs.php';
require_once __DIR__ . '/../helpers/helper_social_tokens.php';

function account_action_token_is_well_formed(string $token): bool
{
    return (bool) preg_match('/^[a-f0-9]{64}$/D', $token);
}

/**
 * Erases a locked user's personal data and access inside the caller's transaction.
 * Shared by self-service and admin deletion so both remove the same data.
 * Returns the work that must run after commit (see finish_account_deletion_cleanup).
 */
function erase_account_for_deletion(PDO $pdo, array $user): array
{
    if (!$pdo->inTransaction()) {
        throw new RuntimeException('Account deletion requires a transaction.');
    }
    $userId = (int) $user['id'];
    $avatarPath = trim((string) ($user['avatar_path'] ?? ''));
    $providerTokens = [];
    delete_user_travel_places($pdo, $userId);
    $pdo->prepare('DELETE FROM ' . table_name('friends')
        . ' WHERE user_a_id = :a OR user_b_id = :b')->execute(['a' => $userId, 'b' => $userId]);
    if (social_auth_identity_table_available($pdo)) {
        $providerTokens = social_tokens_for_user($pdo, $userId);
        $pdo->prepare('DELETE FROM ' . table_name('user_identities') . ' WHERE user_id = :id')
            ->execute(['id' => $userId]);
    }
    $names = users_name_columns_available($pdo) ? 'first_name = "Deleted", last_name = "User", ' : '';
    $paymentFields = deleted_account_payment_assignments($pdo);
    $pdo->prepare('UPDATE ' . table_name('users') . ' SET ' . $names . $paymentFields . '
        nickname = "Deleted User", email = NULL, password_hash = NULL, credentials_required = 1,
        email_verified_at = NULL, avatar_path = NULL, device_token = :device,
        account_status = "deleted", deactivated_at = UTC_TIMESTAMP(), deleted_at = UTC_TIMESTAMP()
        WHERE id = :id')->execute(['device' => bin2hex(random_bytes(32)), 'id' => $userId]);
    revoke_refresh_tokens_for_user($pdo, $userId);
    deactivate_push_tokens_for_user($pdo, $userId);
    consume_account_action_proofs($pdo, $userId);
    return ['avatar_path' => $avatarPath, 'provider_tokens' => $providerTokens];
}

/** Revokes Apple/Google tokens and removes the avatar once the deletion has committed. */
function finish_account_deletion_cleanup(?array $cleanup): void
{
    if ($cleanup === null) {
        return;
    }
    social_tokens_revoke($cleanup['provider_tokens'] ?? []);
    $avatarPath = (string) ($cleanup['avatar_path'] ?? '');
    if ($avatarPath !== '') {
        try { delete_avatar_file($avatarPath); }
        catch (Throwable $error) { error_log('Account deletion avatar cleanup failed.'); }
    }
}

function request_account_deletion_link_action(): void
{
    require_post();
    $body = read_json();
    $me = get_me();
    $pdo = db();
    enforce_rate_limit($pdo, 'delete_link_ip', client_ip_address(), 10, 900, true);
    enforce_rate_limit($pdo, 'delete_link_user', (string) $me['id'], 3, 3600, true);
    enforce_rate_limit($pdo, 'delete_link_global', 'all', 100, 3600, true);
    ensure_account_action_proof_schema($pdo);
    $userId = (int) $me['id'];
    $proof = null;
    $pdo->beginTransaction();
    try {
        $user = lock_account_action_user($pdo, $userId);
        if (!$user || !account_action_user_is_eligible($user)) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'A verified active account is required.'], 403);
        }
        if (resolve_user_id_from_access_token(bearer_access_token_from_header(), $pdo) !== $userId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Please sign in again.'], 401);
        }
        $password = (string) ($body['password'] ?? '');
        $hasSocialIdentity = user_has_social_identity($pdo, $userId);
        // Email confirmation is always required; keep the existing local-password request check.
        if ((!$hasSocialIdentity || $password !== '')
            && ($password === '' || !password_verify($password, (string) $user['password_hash']))) {
            $pdo->rollBack();
            json_out(['ok' => false, 'code' => 'REAUTHENTICATION_REQUIRED',
                'error' => 'Confirm your current password to request the deletion email.'], 403);
        }
        $proof = create_account_action_link_token($pdo, $user);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $error;
    }
    if ($proof !== null) {
        $url = app_base_url() . '/api/delete-account.php?token=' . urlencode($proof['token']);
        try {
            $sent = send_email_via_resend((string) $user['email'], 'Confirm permanent account deletion',
                build_account_delete_email($url, (string) $user['nickname']));
        } catch (Throwable $error) { $sent = false; }
        if (!$sent) {
            $pdo->prepare('UPDATE ' . table_name('account_action_tokens')
                . ' SET used_at = UTC_TIMESTAMP() WHERE id = :id AND used_at IS NULL')
                ->execute(['id' => $proof['id']]);
            json_out(['ok' => false, 'error' => 'Could not send the confirmation email. Try again later.'], 503);
        }
        record_account_deletion_feedback($pdo, account_deletion_reason_codes($body['reason_codes'] ?? []));
    }
    json_out(['ok' => true]);
}

function confirm_account_deletion_action(): void
{
    require_post();
    $body = read_json();
    $token = is_string($body['token'] ?? null) ? $body['token'] : '';
    $invalid = ['ok' => false, 'error' => 'Invalid or expired account confirmation link.'];
    if (!account_action_token_is_well_formed($token)) { json_out($invalid, 400); }
    $pdo = db();
    enforce_rate_limit($pdo, 'confirm_deletion_ip', client_ip_address(), 20, 900, true);
    enforce_rate_limit($pdo, 'confirm_deletion_token', hash('sha256', $token), 5, 900, true);
    ensure_account_action_proof_schema($pdo);
    ensure_refresh_tokens_table_available($pdo);
    $table = table_name('account_action_tokens');
    $hash = hash('sha256', $token);
    $lookup = $pdo->prepare('SELECT user_id FROM ' . $table . ' WHERE token_hash = :hash AND action = :action');
    $lookup->execute(['hash' => $hash, 'action' => 'delete']);
    $userId = (int) $lookup->fetchColumn();
    $cleanup = null;
    $pdo->beginTransaction();
    try {
        // Lock the user first, then the proof, avoiding opposite lock ordering.
        $user = lock_account_action_user($pdo, $userId);
        $stmt = $pdo->prepare('SELECT credential_state_hash FROM ' . $table . '
            WHERE token_hash = :hash AND action = :action AND user_id = :user
              AND used_at IS NULL AND expires_at > UTC_TIMESTAMP() LIMIT 1 FOR UPDATE');
        $stmt->execute(['hash' => $hash, 'action' => 'delete', 'user' => $userId]);
        $proof = $stmt->fetch();
        if (!$user || !account_action_user_is_eligible($user) || !$proof
            || !hash_equals(account_action_proof_state($user), (string) $proof['credential_state_hash'])) {
            $pdo->rollBack();
            json_out($invalid, 400);
        }
        $cleanup = erase_account_for_deletion($pdo, $user);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) { $pdo->rollBack(); }
        throw $error;
    }
    finish_account_deletion_cleanup($cleanup);
    json_out(['ok' => true, 'status' => 'deleted', 'user_id' => $userId]);
}
