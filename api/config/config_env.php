<?php
declare(strict_types=1);

function load_env_file(string $path): void
{
    if (!is_file($path) || !is_readable($path)) {
        return;
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if (!is_array($lines)) {
        return;
    }

    foreach ($lines as $rawLine) {
        $line = trim($rawLine);
        if ($line === '' || strpos($line, '#') === 0) {
            continue;
        }

        $pos = strpos($line, '=');
        if ($pos === false || $pos < 1) {
            continue;
        }

        $key = trim(substr($line, 0, $pos));
        if (!preg_match('/^[A-Z0-9_]+$/', $key)) {
            continue;
        }

        $value = trim(substr($line, $pos + 1));
        if (
            (substr($value, 0, 1) === '"' && substr($value, -1) === '"') ||
            (substr($value, 0, 1) === '\'' && substr($value, -1) === '\'')
        ) {
            $value = substr($value, 1, -1);
        }

        if (!array_key_exists($key, $_ENV)) {
            $_ENV[$key] = $value;
        }
        if (!array_key_exists($key, $_SERVER)) {
            $_SERVER[$key] = $value;
        }
        if (getenv($key) === false) {
            putenv($key . '=' . $value);
        }
    }
}

function env_string(string $key, string $default = ''): string
{
    $raw = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    if ($raw === false || $raw === null) {
        return $default;
    }
    $value = trim((string) $raw);
    return $value !== '' ? $value : $default;
}

function env_bool(string $key, bool $default = false): bool
{
    $raw = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    if ($raw === false || $raw === null) {
        return $default;
    }
    $value = strtolower(trim((string) $raw));
    if (in_array($value, ['1', 'true', 'yes', 'on'], true)) {
        return true;
    }
    if (in_array($value, ['0', 'false', 'no', 'off'], true)) {
        return false;
    }
    return $default;
}

function env_int(string $key, int $default = 0): int
{
    $raw = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    if ($raw === false || $raw === null) {
        return $default;
    }
    if (!is_numeric($raw)) {
        return $default;
    }
    return (int) $raw;
}
