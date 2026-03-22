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
    $relative = trim(str_replace('\\', '/', (string) PUSH_APNS_PRIVATE_KEY_REL_PATH));
    $relative = ltrim($relative, '/');
    if ($relative === '' || strpos($relative, '..') !== false) {
        return '';
    }

    return project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
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

