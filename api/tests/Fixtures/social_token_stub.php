<?php
declare(strict_types=1);

// Replaces only the outbound HTTP call. Sealing, signing and storage run the real code.
$GLOBALS['tokenHttp'] = [];
$GLOBALS['tokenHttpMode'] = 'ok';
function http_post_form_assoc(string $url, array $fields, int $timeout): array
{
    $GLOBALS['tokenHttp'][] = ['url' => $url, 'fields' => $fields];
    return match ($GLOBALS['tokenHttpMode']) {
        'refused' => ['status' => 400, 'json' => ['error' => 'invalid_grant']],
        'throws' => throw new RuntimeException('code-should-not-be-logged'),
        default => ['status' => 200, 'json' => ['refresh_token' => 'synthetic-refresh-token']],
    };
}

function configure_social_token_test(string $scenario): void
{
    ini_set('error_log', '/dev/null');
    $GLOBALS['tokenHttpMode'] = str_contains($scenario, 'refused') ? 'refused'
        : (str_contains($scenario, 'throws') ? 'throws' : 'ok');
    if (str_contains($scenario, 'unconfigured')) {
        return;
    }
    $randFile = tempnam(sys_get_temp_dir(), 'splyto-test-rng-');
    putenv('SPLYTO_TEST_RAND_FILE=' . $randFile);
    try {
        $key = openssl_pkey_new(['private_key_bits' => 2048, 'private_key_type' => OPENSSL_KEYTYPE_EC, 'curve_name' => 'prime256v1',
            'config' => __DIR__ . '/openssl-test.cnf']);
        if ($key === false || !openssl_pkey_export($key, $pem, null, ['config' => __DIR__ . '/openssl-test.cnf'])) {
            throw new RuntimeException('Cannot create synthetic EC key');
        }
    } finally {
        unlink($randFile);
        putenv('SPLYTO_TEST_RAND_FILE');
    }
    $path = tempnam(sys_get_temp_dir(), 'splyto-test-p8-');
    file_put_contents($path, $pem);
    register_shutdown_function(static fn () => @unlink($path));
    define('SOCIAL_TOKEN_ENCRYPTION_KEY', str_repeat('k', 32));
    define('SOCIAL_APPLE_TEAM_ID', 'SYNTHTEAM');
    define('SOCIAL_APPLE_KEY_ID', 'SYNTHKEY');
    define('SOCIAL_APPLE_PRIVATE_KEY_PATH', $path);
    define('GOOGLE_WEB_CLIENT_ID', 'synthetic-web-client');
    define('GOOGLE_WEB_CLIENT_SECRET', 'synthetic-web-secret');
}

function social_token_http_report(): array
{
    return array_map(static function (array $call): array {
        $secret = (string) ($call['fields']['client_secret'] ?? '');
        $parts = explode('.', $secret);
        $decode = static fn (string $v) => base64_decode(strtr($v, '-_', '+/'), true);
        return $call + ['jwt' => count($parts) === 3 ? [
            'header' => json_decode((string) $decode($parts[0]), true),
            'claims' => json_decode((string) $decode($parts[1]), true),
            'signature_bytes' => strlen((string) $decode($parts[2])),
        ] : null];
    }, $GLOBALS['tokenHttp']);
}
