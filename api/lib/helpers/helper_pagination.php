<?php
declare(strict_types=1);

function pagination_limit($raw, int $default, int $max): int
{
    $limit = (int) $raw;
    if ($limit <= 0) {
        $limit = $default;
    }
    if ($limit < 1) {
        $limit = 1;
    }
    if ($limit > $max) {
        $limit = $max;
    }
    return $limit;
}

function pagination_offset($raw): int
{
    $offset = (int) $raw;
    if ($offset < 0) {
        return 0;
    }
    return $offset;
}

function pagination_requested(array $query): bool
{
    if (array_key_exists('cursor', $query)) {
        return true;
    }
    if (array_key_exists('offset', $query)) {
        return true;
    }
    if (array_key_exists('limit', $query)) {
        return true;
    }
    if (array_key_exists('paged', $query)) {
        return true;
    }
    return false;
}

function pagination_decode_cursor(string $cursor): ?array
{
    $cursor = trim($cursor);
    if ($cursor === '') {
        return null;
    }
    if (strlen($cursor) > 512) {
        json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
    }

    $normalized = strtr($cursor, '-_', '+/');
    $padding = strlen($normalized) % 4;
    if ($padding > 0) {
        $normalized .= str_repeat('=', 4 - $padding);
    }

    $decoded = base64_decode($normalized, true);
    if (!is_string($decoded) || $decoded === '') {
        json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
    }

    $payload = json_decode($decoded, true);
    if (!is_array($payload)) {
        json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
    }

    return $payload;
}

function pagination_encode_cursor(array $payload): string
{
    $json = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($json) || $json === '') {
        return '';
    }

    return rtrim(strtr(base64_encode($json), '+/', '-_'), '=');
}

