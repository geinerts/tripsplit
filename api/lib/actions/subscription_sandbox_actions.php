<?php
declare(strict_types=1);

require_once __DIR__ . '/../helpers/helper_revenuecat_sandbox.php';

function revenuecat_sandbox_config(): ?array
{
    if (!env_bool('TRIP_RC_SANDBOX_ENABLED', false)) return null;
    $project = env_string('TRIP_RC_PROJECT_ID');
    $key = env_string('TRIP_RC_SECRET_KEY');
    $entitlement = env_string('TRIP_RC_ENTITLEMENT', 'splyto_pro');
    $testers = array_values(array_filter(array_map('trim', explode(',', env_string('TRIP_RC_SANDBOX_USER_IDS')))));
    if (!$testers || count($testers) > 100) return null;
    foreach ($testers as $id) {
        if (!preg_match('/^[1-9][0-9]{0,9}$/D', $id)) return null;
    }
    $products = json_decode(env_string('TRIP_RC_SANDBOX_PRODUCTS', '{}'), true);
    if (!is_array($products) || !$products) return null;
    foreach ($products as $store => $ids) {
        if (!in_array($store, ['app_store', 'play_store'], true) || !is_array($ids) || !$ids) return null;
        foreach ($ids as $id) {
            if (!is_string($id) || !preg_match('/^prod[A-Za-z0-9_-]{1,100}$/D', $id)) return null;
        }
    }
    try {
        $verifier = new RevenueCatSandboxVerifier($project, $key, $entitlement);
    } catch (InvalidArgumentException $error) {
        return null;
    }
    return ['testers' => array_map('intval', $testers), 'products' => $products, 'verifier' => $verifier];
}

function subscription_sandbox_context(): array
{
    require_post();
    $config = revenuecat_sandbox_config();
    if ($config === null) {
        json_out(['ok' => false, 'code' => 'billing_sandbox_unavailable', 'error' => 'Billing testing is unavailable.'], 503);
    }
    $me = get_me();
    $userId = (int) $me['id'];
    if (!in_array($userId, $config['testers'], true)) {
        json_out(['ok' => false, 'code' => 'billing_sandbox_forbidden', 'error' => 'Billing testing is unavailable.'], 403);
    }
    $pdo = db();
    enforce_rate_limit($pdo, 'billing_sandbox', 'user:' . $userId, 12, 60);
    return [$pdo, $userId, $config];
}

function subscription_sandbox_session_action(): void
{
    [$pdo, $userId] = subscription_sandbox_context();
    $identity = subscription_sandbox_identity($pdo, $userId);
    json_out(['ok' => true, 'sandbox' => [
        'account_id' => $userId,
        'app_user_id' => $identity['account_token'],
        'provider' => 'revenuecat',
        'environment' => 'sandbox',
        'production_access' => false,
    ]]);
}

function subscription_sandbox_verify_action(): void
{
    [$pdo, $userId, $config] = subscription_sandbox_context();
    $body = read_json();
    if (!is_string($body['subscription_id'] ?? null) || !is_string($body['request_id'] ?? null)) {
        json_out(['ok' => false, 'code' => 'billing_invalid_request', 'error' => 'Invalid verification request.'], 400);
    }
    try {
        $result = subscription_sandbox_verify($pdo, $userId, $config['verifier'],
            $body['subscription_id'], $body['request_id'], $config['products']);
    } catch (DomainException | InvalidArgumentException $error) {
        json_out(['ok' => false, 'code' => 'billing_verification_rejected', 'error' => 'Test purchase could not be verified.'], 422);
    } catch (Throwable $error) {
        json_out(['ok' => false, 'code' => 'billing_verification_unavailable', 'error' => 'Test purchase verification is unavailable.'], 503);
    }
    json_out(['ok' => true, 'sandbox' => $result + ['environment' => 'sandbox', 'production_access' => false]]);
}
