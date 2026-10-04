<?php
declare(strict_types=1);

require_once __DIR__ . '/helper_subscription_sandbox.php';

final class RevenueCatSandboxVerifier implements SubscriptionSandboxVerifier
{
    private Closure $get;

    public function __construct(
        private readonly string $projectId,
        #[SensitiveParameter] private readonly string $secretKey,
        private readonly string $entitlementKey,
        ?Closure $get = null
    ) {
        if (!preg_match('/^[A-Za-z0-9_-]{1,100}$/D', $projectId)
            || !preg_match('/^[A-Za-z0-9._-]{1,100}$/D', $entitlementKey)
            || strlen($secretKey) < 20 || preg_match('/[\r\n]/', $secretKey)) {
            throw new InvalidArgumentException('RevenueCat sandbox configuration is incomplete.');
        }
        $this->get = $get ?? static fn(string $url, string $key): array => revenuecat_sandbox_get($url, $key);
    }

    public function verify(string $accountToken, string $purchaseReference): array
    {
        // RevenueCat subscription ID, never a URL or arbitrary API path.
        if (!preg_match('/^sub[A-Za-z0-9_-]{1,100}$/D', $purchaseReference)) {
            throw new DomainException('Invalid RevenueCat subscription reference.');
        }
        $data = ($this->get)('https://api.revenuecat.com/v2/projects/'
            . rawurlencode($this->projectId) . '/subscriptions/' . rawurlencode($purchaseReference), $this->secretKey);
        if (($data['object'] ?? '') !== 'subscription' || ($data['id'] ?? '') !== $purchaseReference
            || ($data['environment'] ?? '') !== 'sandbox'
            || ($data['customer_id'] ?? '') !== $accountToken
            || ($data['original_customer_id'] ?? '') !== $accountToken
            || ($data['ownership'] ?? '') !== 'purchased'
            || !in_array($data['store'] ?? '', ['app_store', 'play_store'], true)) {
            throw new DomainException('RevenueCat purchase binding is invalid.');
        }
        $entitlements = $data['entitlements']['items'] ?? null;
        if (!is_array($entitlements)) throw new DomainException('RevenueCat entitlement is missing.');
        $hasEntitlement = false;
        foreach ($entitlements as $entitlement) {
            if (is_array($entitlement) && ($entitlement['lookup_key'] ?? '') === $this->entitlementKey
                && ($entitlement['project_id'] ?? '') === $this->projectId
                && ($entitlement['state'] ?? '') === 'active') {
                $hasEntitlement = true;
            }
        }
        if (!$hasEntitlement || !array_key_exists('ends_at', $data)
            || !is_bool($data['gives_access'] ?? null)
            || !in_array($data['auto_renewal_status'] ?? '', ['will_renew', 'will_not_renew',
                'will_change_product', 'will_pause', 'requires_price_increase_consent', 'has_already_renewed'], true)) {
            throw new DomainException('RevenueCat subscription state is invalid.');
        }
        return [
            'environment' => 'sandbox',
            'account_token' => $accountToken,
            'store' => $data['store'],
            // Stable provider subscription ID; latest store renewal IDs are not stable.
            'original_purchase_id' => 'revenuecat:' . $this->projectId . ':' . $data['id'],
            'product_id' => $data['product_id'] ?? null,
            'expires_at_ms' => $data['ends_at'],
            'access_allowed' => $data['gives_access'],
            'provider_status' => $data['status'] ?? null,
            'auto_renew' => in_array($data['auto_renewal_status'],
                ['will_renew', 'will_change_product', 'has_already_renewed'], true),
        ];
    }
}

function revenuecat_sandbox_get(string $url, #[SensitiveParameter] string $secretKey): array
{
    if (!preg_match('#^https://api\.revenuecat\.com/v2/projects/[A-Za-z0-9_-]+/subscriptions/sub[A-Za-z0-9_-]+$#D', $url)) {
        throw new InvalidArgumentException('Invalid RevenueCat URL.');
    }
    $body = '';
    $curl = curl_init($url);
    curl_setopt_array($curl, [
        CURLOPT_HTTPHEADER => ['Authorization: Bearer ' . $secretKey, 'Accept: application/json'],
        CURLOPT_CONNECTTIMEOUT => 3,
        CURLOPT_TIMEOUT => 10,
        CURLOPT_FOLLOWLOCATION => false,
        CURLOPT_PROTOCOLS => CURLPROTO_HTTPS,
        CURLOPT_SSL_VERIFYPEER => true,
        CURLOPT_SSL_VERIFYHOST => 2,
        CURLOPT_WRITEFUNCTION => static function ($handle, string $chunk) use (&$body): int {
            if (strlen($body) + strlen($chunk) > 1048576) return 0;
            $body .= $chunk;
            return strlen($chunk);
        },
    ]);
    $ok = curl_exec($curl);
    $status = (int) curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
    if ($ok === false || $status !== 200) {
        // Do not propagate provider bodies, customer IDs, keys or transport details.
        throw new RuntimeException('RevenueCat verification is unavailable.');
    }
    try {
        $data = json_decode($body, true, 64, JSON_THROW_ON_ERROR);
    } catch (JsonException $error) {
        throw new RuntimeException('Invalid RevenueCat response.');
    }
    if (!is_array($data) || array_is_list($data)) {
        throw new RuntimeException('Invalid RevenueCat response.');
    }
    return $data;
}
