<?php
declare(strict_types=1);

function json_out(array $payload, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('X-Request-Id: ' . request_id());
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: no-referrer');
    header('Permissions-Policy: camera=(), microphone=(), geolocation=()');
    header('Cross-Origin-Resource-Policy: same-origin');

    $isHttps = false;
    $https = strtolower(trim((string) ($_SERVER['HTTPS'] ?? '')));
    if ($https === 'on' || $https === '1') {
        $isHttps = true;
    }
    if (TRUST_PROXY_HEADERS) {
        $forwardedProto = strtolower(trim((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')));
        if ($forwardedProto === 'https') {
            $isHttps = true;
        }
    }
    if ($isHttps) {
        header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
    }

    $jsonFlags = JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES;
    if (defined('JSON_INVALID_UTF8_SUBSTITUTE')) {
        $jsonFlags |= JSON_INVALID_UTF8_SUBSTITUTE;
    }
    if (defined('JSON_PARTIAL_OUTPUT_ON_ERROR')) {
        $jsonFlags |= JSON_PARTIAL_OUTPUT_ON_ERROR;
    }

    $json = json_encode($payload, $jsonFlags);
    if (!is_string($json)) {
        if ($status < 500) {
            http_response_code(500);
        }
        $json = '{"ok":false,"error":"Response encoding failed."}';
    }

    echo $json;
    exit;
}

function max_json_body_bytes(): int
{
    $limit = (int) API_MAX_JSON_BYTES;
    if ($limit < 4_096) {
        return 4_096;
    }
    if ($limit > 1_048_576) {
        return 1_048_576;
    }
    return $limit;
}

function cache_last_json_body(array $payload): void
{
    $GLOBALS['trip_last_json_body'] = $payload;
}

function last_json_body(): array
{
    $value = $GLOBALS['trip_last_json_body'] ?? null;
    return is_array($value) ? $value : [];
}

function read_json(): array
{
    $contentLength = (int) ($_SERVER['CONTENT_LENGTH'] ?? 0);
    $maxBytes = max_json_body_bytes();
    if ($contentLength > $maxBytes) {
        json_out(['ok' => false, 'error' => 'Request body is too large.'], 413);
    }

    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') {
        cache_last_json_body([]);
        return [];
    }
    if (strlen($raw) > $maxBytes) {
        json_out(['ok' => false, 'error' => 'Request body is too large.'], 413);
    }

    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        json_out(['ok' => false, 'error' => 'Invalid JSON body.'], 400);
    }

    cache_last_json_body($decoded);

    return $decoded;
}

function require_post(): void
{
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') {
        json_out(['ok' => false, 'error' => 'Method not allowed.'], 405);
    }
}

