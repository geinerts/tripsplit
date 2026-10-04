<?php
declare(strict_types=1);

/**
 * Implementations must fetch/verify authoritative store state on the server.
 * A client purchase reference is only a lookup hint, never proof of entitlement.
 */
interface SubscriptionSandboxVerifier
{
    public function verify(string $accountToken, string $purchaseReference): array;
}

function subscription_account_token(): string
{
    $bytes = random_bytes(16);
    $bytes[6] = chr((ord($bytes[6]) & 0x0f) | 0x40);
    $bytes[8] = chr((ord($bytes[8]) & 0x3f) | 0x80);
    $hex = bin2hex($bytes);
    return substr($hex, 0, 8) . '-' . substr($hex, 8, 4) . '-'
        . substr($hex, 12, 4) . '-' . substr($hex, 16, 4) . '-' . substr($hex, 20);
}

function subscription_sandbox_identity(PDO $pdo, int $userId): array
{
    if ($userId <= 0 || $pdo->inTransaction()) {
        throw new InvalidArgumentException('Invalid billing identity context.');
    }
    $pdo->beginTransaction();
    try {
        // Serialize first identity creation for the account; never accept a client ID.
        $user = $pdo->prepare('SELECT id, account_status FROM ' . table_name('users')
            . ' WHERE id = :id FOR UPDATE');
        $user->execute(['id' => $userId]);
        $row = $user->fetch(PDO::FETCH_ASSOC);
        if (!$row || ($row['account_status'] ?? '') !== 'active') {
            throw new DomainException('Billing requires an active account.');
        }
        $table = table_name('subscription_accounts');
        $find = $pdo->prepare('SELECT account_token, verification_sequence FROM ' . $table
            . ' WHERE user_id = :user_id');
        $find->execute(['user_id' => $userId]);
        $identity = $find->fetch(PDO::FETCH_ASSOC);
        if (!$identity) {
            $identity = ['account_token' => subscription_account_token(), 'verification_sequence' => 0];
            $insert = $pdo->prepare('INSERT INTO ' . $table
                . ' (user_id, account_token) VALUES (:user_id, :account_token)');
            $insert->execute(['user_id' => $userId, 'account_token' => $identity['account_token']]);
        }
        $pdo->commit();
        return $identity;
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
}

/** Normalize only output from a server verifier, never an HTTP request body. */
function subscription_sandbox_observation(
    array $verified,
    string $accountToken,
    array $allowedProducts,
    int $nowMs
): array {
    if (($verified['environment'] ?? '') !== 'sandbox'
        || ($verified['account_token'] ?? '') !== $accountToken
        || !preg_match('/^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/D', $accountToken)) {
        throw new DomainException('Purchase environment or account binding is invalid.');
    }
    $store = $verified['store'] ?? null;
    $product = $verified['product_id'] ?? null;
    $originalId = $verified['original_purchase_id'] ?? null;
    if (!in_array($store, ['app_store', 'play_store'], true)
        || !is_string($product) || strlen($product) > 191
        || !in_array($product, $allowedProducts[$store] ?? [], true)
        || !is_string($originalId) || trim($originalId) === '' || strlen($originalId) > 4096) {
        throw new DomainException('Purchase product or original identifier is invalid.');
    }
    if (!array_key_exists('expires_at_ms', $verified)
        || ($verified['expires_at_ms'] !== null && (!is_int($verified['expires_at_ms'])
            || $verified['expires_at_ms'] <= 0 || $verified['expires_at_ms'] > 253402300799999))) {
        throw new DomainException('Purchase timestamps are invalid.');
    }
    if ($nowMs <= 0 || !is_bool($verified['access_allowed'] ?? null)
        || !is_bool($verified['auto_renew'] ?? null)
        || !in_array($verified['provider_status'] ?? '', ['trialing', 'active', 'expired',
            'in_grace_period', 'in_billing_retry', 'paused', 'unknown', 'incomplete'], true)) {
        throw new DomainException('Subscription expiry or renewal state is missing.');
    }
    // Namespaced fingerprint only. Never persist receipts or Google purchase tokens.
    return [
        'purchase_hash' => hash('sha256', json_encode(['sandbox', $store, $originalId], JSON_THROW_ON_ERROR)),
        'store' => $store,
        'product_id' => $product,
        'expires_at_ms' => $verified['expires_at_ms'],
        'access_allowed' => $verified['access_allowed'] ? 1 : 0,
        'provider_status' => $verified['provider_status'],
        'auto_renew' => $verified['auto_renew'] ? 1 : 0,
        'verified_at_ms' => $nowMs,
    ];
}

/** Test-state projection only; never use this as a production entitlement. */
function subscription_sandbox_state(array $purchase, int $nowMs): string
{
    $verifiedAt = (int) ($purchase['verified_at_ms'] ?? 0);
    if ($nowMs <= 0 || $verifiedAt <= 0 || $verifiedAt > $nowMs || $nowMs - $verifiedAt >= 300000) {
        return 'needs_verification';
    }
    if ((int) ($purchase['access_allowed'] ?? 0) !== 1) {
        return 'inactive';
    }
    if (($purchase['provider_status'] ?? '') === 'in_grace_period') {
        return 'grace_period';
    }
    return (int) ($purchase['expires_at_ms'] ?? 0) > $nowMs ? 'active' : 'needs_verification';
}

/**
 * Internal sandbox orchestration, called only after tester authentication.
 * requestId is an idempotency key, not a signed store event. Webhook authentication
 * and reconciliation belong in the selected provider adapter before calling here.
 */
function subscription_sandbox_verify(
    PDO $pdo,
    int $userId,
    SubscriptionSandboxVerifier $verifier,
    string $purchaseReference,
    string $requestId,
    array $allowedProducts
): array {
    if (!preg_match('/^[A-Za-z0-9._:-]{8,96}$/D', $requestId)
        || $purchaseReference === '' || strlen($purchaseReference) > 16384) {
        throw new InvalidArgumentException('Invalid verification request.');
    }
    $identity = subscription_sandbox_identity($pdo, $userId);
    $token = $identity['account_token'];
    $accounts = table_name('subscription_accounts');
    $attempts = table_name('subscription_sandbox_attempts');
    $requestHash = hash('sha256', $requestId);
    $referenceHash = hash('sha256', $purchaseReference);
    $pdo->beginTransaction();
    try {
        $lock = $pdo->prepare('SELECT verification_sequence FROM ' . $accounts
            . ' WHERE user_id = :user_id FOR UPDATE');
        $lock->execute(['user_id' => $userId]);
        $sequence = (int) $lock->fetchColumn() + 1;
        $find = $pdo->prepare('SELECT reference_hash, status FROM ' . $attempts
            . ' WHERE account_token = :account_token AND request_hash = :request_hash');
        $find->execute(['account_token' => $token, 'request_hash' => $requestHash]);
        $existing = $find->fetch(PDO::FETCH_ASSOC);
        if ($existing) {
            if (!hash_equals($existing['reference_hash'], $referenceHash)) {
                throw new DomainException('Verification request was reused with another purchase.');
            }
            // A stuck attempt is retried with a fresh request key after provider recovery.
            $pdo->commit();
            return ['status' => $existing['status'], 'duplicate' => true];
        }
        $pdo->prepare('UPDATE ' . $accounts . ' SET verification_sequence = :sequence WHERE user_id = :user_id')
            ->execute(['sequence' => $sequence, 'user_id' => $userId]);
        $pdo->prepare('INSERT INTO ' . $attempts
            . ' (account_token, request_hash, reference_hash, verification_sequence, status)'
            . ' VALUES (:account_token, :request_hash, :reference_hash, :sequence, :status)')
            ->execute(['account_token' => $token, 'request_hash' => $requestHash,
                'reference_hash' => $referenceHash, 'sequence' => $sequence, 'status' => 'pending']);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }

    try {
        // Do not hold database locks while contacting a store/provider.
        $observation = subscription_sandbox_observation(
            $verifier->verify($token, $purchaseReference), $token, $allowedProducts,
            (int) floor(microtime(true) * 1000)
        );
        $pdo->beginTransaction();
        $user = $pdo->prepare('SELECT account_status FROM ' . table_name('users') . ' WHERE id = :id FOR UPDATE');
        $user->execute(['id' => $userId]);
        if ($user->fetchColumn() !== 'active') {
            throw new DomainException('Account changed during verification.');
        }
        $lock->execute(['user_id' => $userId]);
        $lock->fetchColumn();
        $status = subscription_sandbox_store_observation($pdo, $token, $observation, $sequence)
            ? 'applied' : 'superseded';
        $pdo->prepare('UPDATE ' . $attempts . ' SET status = :status'
            . ' WHERE account_token = :account_token AND request_hash = :request_hash')
            ->execute(['status' => $status, 'account_token' => $token, 'request_hash' => $requestHash]);
        $pdo->commit();
        return ['status' => $status, 'duplicate' => false];
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        $pdo->prepare('UPDATE ' . $attempts . ' SET status = :status'
            . ' WHERE account_token = :account_token AND request_hash = :request_hash')
            ->execute(['status' => 'failed', 'account_token' => $token, 'request_hash' => $requestHash]);
        throw $error;
    }
}

function subscription_sandbox_store_observation(PDO $pdo, string $accountToken, array $observation, int $sequence): bool
{
    if (!$pdo->inTransaction()) {
        throw new LogicException('Purchase persistence requires a transaction.');
    }
    $table = table_name('subscription_sandbox_purchases');
    $observation['verification_sequence'] = $sequence;
    // The unique fingerprint locks the purchase even if two different owners race.
    $pdo->prepare('INSERT INTO ' . $table . ' (purchase_hash, account_token, store, product_id,'
        . ' expires_at_ms, access_allowed, provider_status, auto_renew, verified_at_ms, verification_sequence)'
        . ' VALUES (:purchase_hash, :account_token, :store, :product_id,'
        . ' :expires_at_ms, :access_allowed, :provider_status, :auto_renew, :verified_at_ms, :verification_sequence)'
        . ' ON DUPLICATE KEY UPDATE purchase_hash = purchase_hash')
        ->execute($observation + ['account_token' => $accountToken]);
    $find = $pdo->prepare('SELECT account_token, verification_sequence FROM ' . $table . ' WHERE purchase_hash = :hash FOR UPDATE');
    $find->execute(['hash' => $observation['purchase_hash']]);
    $existing = $find->fetch(PDO::FETCH_ASSOC);
    if (!$existing || $existing['account_token'] !== $accountToken) {
        throw new DomainException('Purchase is already bound to another account.');
    }
    if ((int) $existing['verification_sequence'] > $sequence) return false;
    $pdo->prepare('UPDATE ' . $table . ' SET product_id = :product_id, store = :store,'
        . ' expires_at_ms = :expires_at_ms, access_allowed = :access_allowed,'
        . ' provider_status = :provider_status, auto_renew = :auto_renew, verified_at_ms = :verified_at_ms,'
        . ' verification_sequence = :verification_sequence'
        . ' WHERE purchase_hash = :purchase_hash')->execute($observation);
    return true;
}
