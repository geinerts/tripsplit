<?php
declare(strict_types=1);

function social_auth_is_enabled(): bool
{
    return (bool) SOCIAL_AUTH_ENABLED;
}

function social_auth_timeout_seconds(): int
{
    $raw = (int) SOCIAL_AUTH_TIMEOUT_SEC;
    if ($raw < 2) {
        return 2;
    }
    if ($raw > 20) {
        return 20;
    }
    return $raw;
}

function social_auth_provider_from_value(string $value): string
{
    $provider = strtolower(trim($value));
    if ($provider === 'google' || $provider === 'apple') {
        return $provider;
    }
    json_out(['ok' => false, 'error' => 'Unsupported social provider.'], 400);
}

function social_auth_parse_csv_list(string $raw): array
{
    if (trim($raw) === '') {
        return [];
    }

    $items = preg_split('/\s*,\s*/', trim($raw)) ?: [];
    $out = [];
    foreach ($items as $item) {
        $value = trim((string) $item);
        if ($value !== '') {
            $out[$value] = $value;
        }
    }
    return array_values($out);
}

function social_auth_google_client_ids(): array
{
    static $cached = null;
    if (is_array($cached)) {
        return $cached;
    }

    $cached = social_auth_parse_csv_list((string) SOCIAL_AUTH_GOOGLE_CLIENT_IDS);
    return $cached;
}

function social_auth_apple_client_ids(): array
{
    static $cached = null;
    if (is_array($cached)) {
        return $cached;
    }

    $configured = social_auth_parse_csv_list((string) SOCIAL_AUTH_APPLE_CLIENT_IDS);
    if ($configured) {
        $cached = $configured;
        return $cached;
    }

    $fallbackBundleId = trim((string) PUSH_APNS_BUNDLE_ID);
    if ($fallbackBundleId !== '') {
        $cached = [$fallbackBundleId];
        return $cached;
    }

    $cached = [];
    return $cached;
}

function social_auth_identity_table_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $table = table_name('user_identities');
    if (!preg_match('/^[A-Za-z0-9_]+$/', $table)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $table]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function user_has_social_identity(PDO $pdo, int $userId): bool
{
    if ($userId <= 0) {
        return false;
    }
    if (!social_auth_identity_table_available($pdo)) {
        return false;
    }

    $stmt = $pdo->prepare(
        'SELECT 1
         FROM ' . table_name('user_identities') . '
         WHERE user_id = :user_id
         LIMIT 1'
    );
    $stmt->execute(['user_id' => $userId]);
    return (bool) $stmt->fetchColumn();
}

function social_auth_claim_is_true($value): bool
{
    if (is_bool($value)) {
        return $value;
    }
    if (is_int($value) || is_float($value)) {
        return ((int) $value) === 1;
    }
    $normalized = strtolower(trim((string) $value));
    return $normalized === 'true' || $normalized === '1' || $normalized === 'yes';
}

function social_auth_decode_jwt(string $idToken): array
{
    $raw = trim($idToken);
    $parts = explode('.', $raw);
    if (count($parts) !== 3) {
        throw new RuntimeException('Invalid token format.');
    }

    $headerEncoded = trim((string) $parts[0]);
    $payloadEncoded = trim((string) $parts[1]);
    $signatureEncoded = trim((string) $parts[2]);
    if ($headerEncoded === '' || $payloadEncoded === '' || $signatureEncoded === '') {
        throw new RuntimeException('Invalid token format.');
    }

    $headerJson = base64url_decode($headerEncoded);
    $payloadJson = base64url_decode($payloadEncoded);
    $signatureRaw = base64url_decode($signatureEncoded);
    if (!is_string($headerJson) || !is_string($payloadJson) || !is_string($signatureRaw)) {
        throw new RuntimeException('Invalid token encoding.');
    }

    $header = json_decode($headerJson, true);
    $payload = json_decode($payloadJson, true);
    if (!is_array($header) || !is_array($payload)) {
        throw new RuntimeException('Invalid token JSON.');
    }

    return [
        'header' => $header,
        'payload' => $payload,
        'signed' => $headerEncoded . '.' . $payloadEncoded,
        'signature_raw' => $signatureRaw,
    ];
}

function social_auth_asn1_length(int $length): string
{
    if ($length < 0x80) {
        return chr($length);
    }
    $encoded = '';
    while ($length > 0) {
        $encoded = chr($length & 0xFF) . $encoded;
        $length >>= 8;
    }
    return chr(0x80 | strlen($encoded)) . $encoded;
}

function social_auth_asn1_integer(string $value): string
{
    $normalized = ltrim($value, "\x00");
    if ($normalized === '') {
        $normalized = "\x00";
    }
    if ((ord($normalized[0]) & 0x80) !== 0) {
        $normalized = "\x00" . $normalized;
    }
    return "\x02" . social_auth_asn1_length(strlen($normalized)) . $normalized;
}

function social_auth_public_key_pem_from_jwk(array $jwk): ?string
{
    if (strtoupper(trim((string) ($jwk['kty'] ?? ''))) !== 'RSA') {
        return null;
    }
    $modulusRaw = base64url_decode((string) ($jwk['n'] ?? ''));
    $exponentRaw = base64url_decode((string) ($jwk['e'] ?? ''));
    if (!is_string($modulusRaw) || !is_string($exponentRaw) || $modulusRaw === '' || $exponentRaw === '') {
        return null;
    }

    $rsaPublicKey = "\x30" . social_auth_asn1_length(
        strlen(social_auth_asn1_integer($modulusRaw) . social_auth_asn1_integer($exponentRaw))
    ) . social_auth_asn1_integer($modulusRaw) . social_auth_asn1_integer($exponentRaw);

    $algorithmIdentifier = "\x30\x0D\x06\x09\x2A\x86\x48\x86\xF7\x0D\x01\x01\x01\x05\x00";
    $bitString = "\x03" . social_auth_asn1_length(strlen($rsaPublicKey) + 1) . "\x00" . $rsaPublicKey;
    $subjectPublicKeyInfo = "\x30" . social_auth_asn1_length(
        strlen($algorithmIdentifier . $bitString)
    ) . $algorithmIdentifier . $bitString;

    return "-----BEGIN PUBLIC KEY-----\n"
        . chunk_split(base64_encode($subjectPublicKeyInfo), 64, "\n")
        . "-----END PUBLIC KEY-----\n";
}

function social_auth_fetch_jwks(string $provider): array
{
    static $cache = [];
    if (isset($cache[$provider]) && is_array($cache[$provider])) {
        return $cache[$provider];
    }

    $url = $provider === 'google'
        ? 'https://www.googleapis.com/oauth2/v3/certs'
        : 'https://appleid.apple.com/auth/keys';

    $payload = http_get_json_assoc($url, social_auth_timeout_seconds());
    $keys = $payload['keys'] ?? null;
    if (!is_array($keys) || $keys === []) {
        throw new RuntimeException('Social provider key set is empty.');
    }

    $out = [];
    foreach ($keys as $key) {
        if (!is_array($key)) {
            continue;
        }
        $kid = trim((string) ($key['kid'] ?? ''));
        if ($kid === '') {
            continue;
        }
        $out[] = $key;
    }
    if (!$out) {
        throw new RuntimeException('No valid signing keys received from provider.');
    }

    $cache[$provider] = $out;
    return $out;
}

function social_auth_verify_signature(array $jwtDecoded, array $jwks): bool
{
    $header = (array) ($jwtDecoded['header'] ?? []);
    $signed = (string) ($jwtDecoded['signed'] ?? '');
    $signatureRaw = (string) ($jwtDecoded['signature_raw'] ?? '');
    $alg = strtoupper(trim((string) ($header['alg'] ?? '')));
    $kid = trim((string) ($header['kid'] ?? ''));
    if ($alg !== 'RS256') {
        throw new RuntimeException('Unsupported social token algorithm.');
    }
    if ($signed === '' || $signatureRaw === '') {
        return false;
    }

    foreach ($jwks as $jwk) {
        $keyKid = trim((string) ($jwk['kid'] ?? ''));
        if ($kid !== '' && $keyKid !== '' && $kid !== $keyKid) {
            continue;
        }

        $pem = social_auth_public_key_pem_from_jwk((array) $jwk);
        if (!is_string($pem) || trim($pem) === '') {
            continue;
        }
        $verified = openssl_verify($signed, $signatureRaw, $pem, OPENSSL_ALGO_SHA256);
        if ($verified === 1) {
            return true;
        }
    }

    return false;
}

function social_auth_extract_audiences($claim): array
{
    if (is_string($claim)) {
        $value = trim($claim);
        return $value !== '' ? [$value] : [];
    }
    if (!is_array($claim)) {
        return [];
    }
    $out = [];
    foreach ($claim as $item) {
        $value = trim((string) $item);
        if ($value !== '') {
            $out[$value] = $value;
        }
    }
    return array_values($out);
}

function social_auth_validate_claims(string $provider, array $payload): array
{
    $issuer = trim((string) ($payload['iss'] ?? ''));
    $subject = trim((string) ($payload['sub'] ?? ''));
    $exp = (int) ($payload['exp'] ?? 0);
    $iat = (int) ($payload['iat'] ?? 0);
    $audiences = social_auth_extract_audiences($payload['aud'] ?? null);
    $now = time();

    if ($subject === '' || str_length($subject) > 191) {
        throw new RuntimeException('Invalid social account subject.');
    }
    if ($exp <= 0 || $exp < ($now - 60)) {
        throw new RuntimeException('Social token expired.');
    }
    if ($iat > 0 && $iat > ($now + 300)) {
        throw new RuntimeException('Social token has invalid issue time.');
    }

    if ($provider === 'google') {
        if ($issuer !== 'https://accounts.google.com' && $issuer !== 'accounts.google.com') {
            throw new RuntimeException('Invalid Google token issuer.');
        }
        $allowedAudiences = social_auth_google_client_ids();
        if (!$allowedAudiences) {
            throw new RuntimeException('Google social auth is not configured on server.');
        }
    } else {
        if ($issuer !== 'https://appleid.apple.com') {
            throw new RuntimeException('Invalid Apple token issuer.');
        }
        $allowedAudiences = social_auth_apple_client_ids();
        if (!$allowedAudiences) {
            throw new RuntimeException('Apple social auth is not configured on server.');
        }
    }

    $audienceMatch = '';
    foreach ($audiences as $audience) {
        if (in_array($audience, $allowedAudiences, true)) {
            $audienceMatch = $audience;
            break;
        }
    }
    if ($audienceMatch === '') {
        throw new RuntimeException('Invalid social token audience.');
    }

    $emailRaw = strtolower(trim((string) ($payload['email'] ?? '')));
    $email = null;
    if ($emailRaw !== '' && filter_var($emailRaw, FILTER_VALIDATE_EMAIL)) {
        $email = $emailRaw;
    }

    $emailVerified = social_auth_claim_is_true($payload['email_verified'] ?? false);

    return [
        'provider' => $provider,
        'subject' => $subject,
        'issuer' => $issuer,
        'audience' => $audienceMatch,
        'email' => $email,
        'email_verified' => $emailVerified,
    ];
}

function verify_social_id_token(string $provider, string $idToken): array
{
    if (!social_auth_is_enabled()) {
        json_out(['ok' => false, 'error' => 'Social login is disabled.'], 503);
    }

    $normalizedProvider = social_auth_provider_from_value($provider);
    $token = trim($idToken);
    if ($token === '') {
        json_out(['ok' => false, 'error' => 'Missing social id token.'], 400);
    }

    try {
        $decoded = social_auth_decode_jwt($token);
        $jwks = social_auth_fetch_jwks($normalizedProvider);
        if (!social_auth_verify_signature($decoded, $jwks)) {
            json_out(['ok' => false, 'error' => 'Invalid social id token signature.'], 401);
        }
        $claims = social_auth_validate_claims(
            $normalizedProvider,
            (array) ($decoded['payload'] ?? []),
        );
    } catch (Throwable $error) {
        $message = $error->getMessage();
        $lower = strtolower($message);
        if (str_contains($lower, 'configured') || str_contains($lower, 'disabled')) {
            json_out(['ok' => false, 'error' => $message], 503);
        }
        if (
            str_contains($lower, 'provider key')
            || str_contains($lower, 'signing keys')
            || str_contains($lower, 'request failed')
        ) {
            json_out(['ok' => false, 'error' => 'Social auth provider is temporarily unavailable.'], 502);
        }
        json_out(['ok' => false, 'error' => 'Invalid social id token.'], 401);
    }

    $claims['payload_json'] = json_encode(
        (array) ($decoded['payload'] ?? []),
        JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES
    ) ?: '{}';
    return $claims;
}
