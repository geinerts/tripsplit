<?php
declare(strict_types=1);

function push_notifications_enabled(): bool
{
    return (bool) PUSH_ENABLED && extension_loaded('curl');
}

function push_delivery_limit(): int
{
    $limit = (int) PUSH_QUEUE_BATCH_LIMIT;
    if ($limit < 1) {
        return 1;
    }
    if ($limit > 500) {
        return 500;
    }
    return $limit;
}

function push_timeout_seconds(): int
{
    $timeout = (int) PUSH_TIMEOUT_SEC;
    if ($timeout < 2) {
        return 2;
    }
    if ($timeout > 20) {
        return 20;
    }
    return $timeout;
}

function push_max_tokens_per_user(): int
{
    $limit = (int) PUSH_MAX_TOKENS_PER_USER;
    if ($limit < 1) {
        return 1;
    }
    if ($limit > 20) {
        return 20;
    }
    return $limit;
}

function push_critical_types(): array
{
    static $cached = null;
    if (is_array($cached)) {
        return $cached;
    }

    $raw = trim((string) PUSH_CRITICAL_TYPES);
    if ($raw === '') {
        $cached = [];
        return $cached;
    }

    $parts = preg_split('/[\s,;]+/', strtolower($raw)) ?: [];
    $allowed = [];
    foreach ($parts as $part) {
        $type = trim((string) $part);
        if ($type === '') {
            continue;
        }
        if (!preg_match('/^[a-z0-9_]+$/', $type)) {
            continue;
        }
        $allowed[$type] = true;
    }
    $cached = array_keys($allowed);
    return $cached;
}

function push_should_queue_notification_type(string $type): bool
{
    $normalizedType = strtolower(trim($type));
    if ($normalizedType === '') {
        return false;
    }

    $critical = push_critical_types();
    if (!$critical) {
        return true;
    }

    return in_array($normalizedType, $critical, true);
}

function push_tokens_table_available(PDO $pdo): bool
{
    return push_table_available($pdo, 'push_tokens');
}

function push_queue_table_available(PDO $pdo): bool
{
    return push_table_available($pdo, 'push_queue');
}

function push_table_available(PDO $pdo, string $tableKey): bool
{
    static $cache = [];
    if (array_key_exists($tableKey, $cache)) {
        return $cache[$tableKey];
    }

    try {
        $rawTable = trim(table_name($tableKey), '`');
        if ($rawTable === '' || !preg_match('/^[A-Za-z0-9_]+$/', $rawTable)) {
            $cache[$tableKey] = false;
            return false;
        }
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $rawTable]);
        $cache[$tableKey] = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cache[$tableKey] = false;
    }

    return $cache[$tableKey];
}

function normalize_push_platform(string $platform): string
{
    $value = strtolower(trim($platform));
    if ($value === 'ios' || $value === 'android' || $value === 'web') {
        return $value;
    }
    return '';
}

function normalize_push_provider(?string $provider, string $platform = ''): string
{
    $value = strtolower(trim((string) $provider));
    if ($value === 'apns' || $value === 'fcm') {
        return $value;
    }

    if ($platform === 'ios') {
        return 'apns';
    }
    if ($platform === 'android' || $platform === 'web') {
        return 'fcm';
    }

    return '';
}

function normalize_push_token_value(string $token): string
{
    $value = trim($token);
    if ($value === '') {
        return '';
    }
    if (strlen($value) < 20 || strlen($value) > 4096) {
        return '';
    }
    if (!preg_match('/^[\x21-\x7E]+$/', $value)) {
        return '';
    }
    return $value;
}

function normalize_push_device_uid(?string $raw): string
{
    $value = trim((string) $raw);
    if ($value === '') {
        return '';
    }
    if (strlen($value) > 128) {
        $value = substr($value, 0, 128);
    }
    if (!preg_match('/^[A-Za-z0-9._:-]+$/', $value)) {
        return '';
    }
    return $value;
}

function normalize_push_app_bundle(?string $raw): string
{
    $value = trim((string) $raw);
    if ($value === '') {
        return '';
    }
    if (strlen($value) > 191) {
        $value = substr($value, 0, 191);
    }
    if (!preg_match('/^[A-Za-z0-9._-]+$/', $value)) {
        return '';
    }
    return $value;
}
