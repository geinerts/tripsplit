<?php
declare(strict_types=1);

function push_apns_enabled(): bool
{
    if (!push_notifications_enabled() || !PUSH_APNS_ENABLED) {
        return false;
    }
    if (trim((string) PUSH_APNS_TEAM_ID) === '' || trim((string) PUSH_APNS_KEY_ID) === '') {
        return false;
    }
    if (trim((string) PUSH_APNS_PRIVATE_KEY_REL_PATH) === '') {
        return false;
    }
    $privateKeyPath = push_apns_private_key_abs();
    return $privateKeyPath !== '' && is_file($privateKeyPath) && is_readable($privateKeyPath);
}

function push_apns_private_key_abs(): string
{
    $rawPath = trim(str_replace('\\', '/', (string) PUSH_APNS_PRIVATE_KEY_REL_PATH));
    if ($rawPath === '') {
        return '';
    }
    if (strpos($rawPath, '..') !== false) {
        return '';
    }
    if (strpos($rawPath, '/') === 0) {
        $absolute = realpath($rawPath);
        return is_string($absolute) && $absolute !== '' ? $absolute : $rawPath;
    }

    $relative = $rawPath;
    $relative = ltrim($relative, '/');
    if ($relative === '') {
        return '';
    }

    // Backward compatibility: old deployments used ../keys/... with /api root.
    while (strpos($relative, '../') === 0) {
        $relative = substr($relative, 3);
    }
    if ($relative === '' || strpos($relative, '..') !== false) {
        return '';
    }

    $roots = [
        project_root_abs(),
        project_root_abs() . DIRECTORY_SEPARATOR . 'api',
    ];
    foreach ($roots as $root) {
        $candidate = $root . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
        if (is_file($candidate) && is_readable($candidate)) {
            return $candidate;
        }
    }

    return $roots[0] . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
}

function push_apns_jwt(): string
{
    static $cache = [
        'token' => '',
        'issued_at' => 0,
    ];

    $now = time();
    if (is_string($cache['token']) && $cache['token'] !== '' && ($now - (int) $cache['issued_at']) < 3000) {
        return $cache['token'];
    }

    $privateKeyPath = push_apns_private_key_abs();
    if ($privateKeyPath === '' || !is_file($privateKeyPath) || !is_readable($privateKeyPath)) {
        return '';
    }
    $privateKey = file_get_contents($privateKeyPath);
    if (!is_string($privateKey) || trim($privateKey) === '') {
        return '';
    }

    $header = push_base64url_encode(json_encode([
        'alg' => 'ES256',
        'kid' => trim((string) PUSH_APNS_KEY_ID),
    ], JSON_UNESCAPED_SLASHES));
    $claims = push_base64url_encode(json_encode([
        'iss' => trim((string) PUSH_APNS_TEAM_ID),
        'iat' => $now,
    ], JSON_UNESCAPED_SLASHES));
    if ($header === '' || $claims === '') {
        return '';
    }
    $unsigned = $header . '.' . $claims;

    $keyResource = openssl_pkey_get_private($privateKey);
    if ($keyResource === false) {
        return '';
    }

    $signature = '';
    $signed = openssl_sign($unsigned, $signature, $keyResource, 'sha256');
    if (is_resource($keyResource) || $keyResource instanceof OpenSSLAsymmetricKey) {
        openssl_free_key($keyResource);
    }
    if (!$signed || !is_string($signature) || $signature === '') {
        return '';
    }

    $jwt = $unsigned . '.' . push_base64url_encode($signature);
    $cache['token'] = $jwt;
    $cache['issued_at'] = $now;

    return $jwt;
}
