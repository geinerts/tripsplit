<?php
declare(strict_types=1);

require_once __DIR__ . '/push/push_transport_apns_auth.php';

const SOCIAL_TOKEN_HTTP_TIMEOUT_SEC = 4;
const SOCIAL_TOKEN_CODE_MAX_LENGTH = 4096;

function social_token_setting(string $name): string
{
    return defined($name) ? trim((string) constant($name)) : '';
}

function social_token_storage_available(PDO $pdo): bool
{
    try {
        return $pdo->query('SELECT provider_token_enc FROM ' . table_name('user_identities')
            . ' WHERE 1 = 0') !== false;
    } catch (Throwable $error) {
        return false;
    }
}

function social_token_encryption_key(): ?string
{
    $configured = social_token_setting('SOCIAL_TOKEN_ENCRYPTION_KEY');
    return strlen($configured) >= 32 ? hash('sha256', $configured, true) : null;
}

function social_token_seal(string $token, string $clientId): ?string
{
    $key = social_token_encryption_key();
    if ($key === null) {
        return null;
    }
    $plain = json_encode(['t' => $token, 'c' => $clientId], JSON_UNESCAPED_SLASHES);
    $nonce = random_bytes(12);
    $tag = '';
    $cipher = openssl_encrypt((string) $plain, 'aes-256-gcm', $key, OPENSSL_RAW_DATA, $nonce, $tag, '', 16);
    return is_string($cipher) ? 'enc:v1:' . base64_encode($nonce . $tag . $cipher) : null;
}

/** @return array{t:string,c:string}|null */
function social_token_open(string $sealed): ?array
{
    $key = social_token_encryption_key();
    if ($key === null || !str_starts_with($sealed, 'enc:v1:')) {
        return null;
    }
    $raw = base64_decode(substr($sealed, 7), true);
    if (!is_string($raw) || strlen($raw) <= 28) {
        return null;
    }
    $plain = openssl_decrypt(substr($raw, 28), 'aes-256-gcm', $key, OPENSSL_RAW_DATA,
        substr($raw, 0, 12), substr($raw, 12, 16));
    $data = is_string($plain) ? json_decode($plain, true) : null;
    return is_array($data) && is_string($data['t'] ?? null) && is_string($data['c'] ?? null)
        ? ['t' => $data['t'], 'c' => $data['c']]
        : null;
}

function social_token_base64url(string $value): string
{
    return rtrim(strtr(base64_encode($value), '+/', '-_'), '=');
}

/** Short-lived ES256 client secret that Apple requires on its token endpoints. */
function social_token_apple_client_secret(string $clientId): ?string
{
    $teamId = social_token_setting('SOCIAL_APPLE_TEAM_ID');
    $keyId = social_token_setting('SOCIAL_APPLE_KEY_ID');
    $path = social_token_setting('SOCIAL_APPLE_PRIVATE_KEY_PATH');
    if ($teamId === '' || $keyId === '' || $clientId === '' || !is_readable($path)) {
        return null;
    }
    $key = openssl_pkey_get_private((string) file_get_contents($path));
    if ($key === false) {
        return null;
    }
    $now = time();
    $unsigned = social_token_base64url((string) json_encode(['alg' => 'ES256', 'kid' => $keyId]))
        . '.' . social_token_base64url((string) json_encode([
            'iss' => $teamId,
            'iat' => $now,
            'exp' => $now + 300,
            'aud' => 'https://appleid.apple.com',
            'sub' => $clientId,
        ], JSON_UNESCAPED_SLASHES));
    $der = '';
    if (!openssl_sign($unsigned, $der, $key, 'sha256')) {
        return null;
    }
    $signature = push_apns_es256_signature($der);
    return $signature === '' ? null : $unsigned . '.' . social_token_base64url($signature);
}

/** @return array{t:string,c:string}|null */
function social_token_exchange(string $provider, string $code, string $audience): ?array
{
    if ($provider === 'apple') {
        $url = 'https://appleid.apple.com/auth/token';
        $clientId = $audience;
        $secret = social_token_apple_client_secret($clientId);
        $extra = [];
    } else {
        $url = 'https://oauth2.googleapis.com/token';
        $clientId = social_token_setting('GOOGLE_WEB_CLIENT_ID');
        $secret = social_token_setting('GOOGLE_WEB_CLIENT_SECRET');
        // Native server auth codes are issued without a redirect URI.
        $extra = ['redirect_uri' => ''];
    }
    if ($clientId === '' || $secret === null || $secret === '') {
        return null;
    }
    $response = http_post_form_assoc($url, $extra + [
        'client_id' => $clientId,
        'client_secret' => $secret,
        'code' => $code,
        'grant_type' => 'authorization_code',
    ], SOCIAL_TOKEN_HTTP_TIMEOUT_SEC);
    $token = $response['json']['refresh_token'] ?? null;
    return $response['status'] === 200 && is_string($token) && $token !== ''
        ? ['t' => $token, 'c' => $clientId]
        : null;
}

/** Best effort: a failure here must never affect the login that triggered it. */
function social_token_capture_on_login(PDO $pdo, int $userId, string $provider, string $code, string $audience): void
{
    if ($code === '' || strlen($code) > SOCIAL_TOKEN_CODE_MAX_LENGTH
        || social_token_encryption_key() === null) {
        return;
    }
    try {
        if (!social_token_storage_available($pdo)) {
            return;
        }
        $table = table_name('user_identities');
        $existing = $pdo->prepare('SELECT provider_token_enc FROM ' . $table
            . ' WHERE user_id = :user_id AND provider = :provider LIMIT 1');
        $existing->execute(['user_id' => $userId, 'provider' => $provider]);
        if (trim((string) $existing->fetchColumn()) !== '') {
            return;
        }
        $exchanged = social_token_exchange($provider, $code, $audience);
        $sealed = $exchanged === null ? null : social_token_seal($exchanged['t'], $exchanged['c']);
        if ($sealed === null) {
            return;
        }
        $pdo->prepare('UPDATE ' . $table . ' SET provider_token_enc = :token
            WHERE user_id = :user_id AND provider = :provider')
            ->execute(['token' => $sealed, 'user_id' => $userId, 'provider' => $provider]);
    } catch (Throwable $error) {
        error_log('Social token capture failed for ' . $provider . '.');
    }
}

/** @return list<array{provider:string,sealed:string}> */
function social_tokens_for_user(PDO $pdo, int $userId): array
{
    if (!social_token_storage_available($pdo)) {
        return [];
    }
    $stmt = $pdo->prepare('SELECT provider, provider_token_enc FROM ' . table_name('user_identities')
        . ' WHERE user_id = :user_id AND provider_token_enc IS NOT NULL');
    $stmt->execute(['user_id' => $userId]);
    $out = [];
    foreach ($stmt->fetchAll() as $row) {
        $out[] = ['provider' => (string) $row['provider'], 'sealed' => (string) $row['provider_token_enc']];
    }
    return $out;
}

/** Best effort: the account is already deleted when this runs. */
function social_tokens_revoke(array $tokens): void
{
    foreach ($tokens as $entry) {
        $provider = (string) ($entry['provider'] ?? '');
        try {
            $opened = social_token_open((string) ($entry['sealed'] ?? ''));
            if ($opened === null) {
                error_log('Social token revocation skipped for ' . $provider . ': token unreadable.');
                continue;
            }
            if ($provider === 'apple') {
                $secret = social_token_apple_client_secret($opened['c']);
                if ($secret === null) {
                    error_log('Social token revocation skipped for apple: not configured.');
                    continue;
                }
                $response = http_post_form_assoc('https://appleid.apple.com/auth/revoke', [
                    'client_id' => $opened['c'],
                    'client_secret' => $secret,
                    'token' => $opened['t'],
                    'token_type_hint' => 'refresh_token',
                ], SOCIAL_TOKEN_HTTP_TIMEOUT_SEC);
            } else {
                $response = http_post_form_assoc('https://oauth2.googleapis.com/revoke', [
                    'token' => $opened['t'],
                ], SOCIAL_TOKEN_HTTP_TIMEOUT_SEC);
            }
            if ($response['status'] !== 200) {
                error_log('Social token revocation failed for ' . $provider . ': HTTP ' . $response['status'] . '.');
            }
        } catch (Throwable $error) {
            error_log('Social token revocation failed for ' . $provider . '.');
        }
    }
}
