<?php
declare(strict_types=1);

// Operator credentials are deliberately separate from the web-readable app environment.
function operator_database_credentials(string $file): array
{
    if (is_link($file) || !is_file($file) || !is_readable($file)) {
        throw new RuntimeException('Operator database credentials are missing or unreadable.');
    }
    $mode = fileperms($file);
    if ($mode === false || ($mode & 0077) !== 0) {
        throw new RuntimeException('Operator database credentials must not be accessible to group/others.');
    }
    $ini = @parse_ini_file($file, true, INI_SCANNER_RAW);
    $client = is_array($ini) ? ($ini['client'] ?? []) : [];
    foreach (['host', 'user', 'password'] as $key) {
        if (!isset($client[$key]) || !is_string($client[$key]) || $client[$key] === '') {
            throw new RuntimeException('Invalid operator database credentials.');
        }
    }
    if (count($client) !== 3 || count($ini) !== 1) {
        throw new RuntimeException('Unexpected operator database credential options.');
    }
    return $client;
}

function operator_database_connection(string $file): PDO
{
    $client = operator_database_credentials($file);
    if (!preg_match('/^[A-Za-z0-9_.-]+$/D', $client['host']) ||
        !preg_match('/^[A-Za-z0-9_]+$/D', DB_NAME) || $client['user'] === DB_USER) {
        throw new RuntimeException('Operator database identity must be separate from runtime.');
    }
    try {
        return new PDO('mysql:host=' . $client['host'] . ';dbname=' . DB_NAME . ';charset=utf8mb4',
            $client['user'], $client['password'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
            ]);
    } catch (PDOException $error) {
        throw new RuntimeException('Operator database connection failed. Check the protected credentials file.');
    }
}

function database_maintenance_lock_name(): string
{
    return 'trip_schema_migrations_' . substr(hash('sha256', DB_HOST . ':' . DB_NAME . ':' . DB_TABLE_PREFIX), 0, 20);
}

function database_identity_privileges(): array
{
    return [
        'runtime' => ['SELECT', 'INSERT', 'UPDATE', 'DELETE'],
        'migrator' => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'ALTER', 'DROP', 'INDEX', 'REFERENCES'],
        'backup' => ['SELECT', 'SHOW VIEW'],
    ];
}
