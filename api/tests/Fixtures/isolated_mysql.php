<?php
declare(strict_types=1);

function isolated_test_mysql(): PDO
{
    if (PHP_SAPI !== 'cli' || getenv('SPLYTO_ISOLATED_MYSQL') !== '1'
        || !is_file('/splyto-isolated-test-runtime')) {
        throw new RuntimeException('MySQL tests must run in the dedicated Docker test runtime.');
    }
    // Deliberately no configurable DSN or production .env fallback.
    $pdo = new PDO('mysql:host=mysql;dbname=splyto_security_test;charset=utf8mb4',
        'splyto_test', 'isolated-test-password-not-production', [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    if ($pdo->query('SELECT DATABASE()')->fetchColumn() !== 'splyto_security_test'
        || $pdo->query('SELECT marker FROM splyto_test_environment')->fetchColumn()
            !== 'synthetic-registration-tests-only') {
        throw new RuntimeException('Refusing to use an unmarked test database.');
    }
    $pdo->exec('SET SESSION innodb_lock_wait_timeout = 10');
    return $pdo;
}

function reset_registration_mysql_schema(PDO $pdo, bool $hasNames = true): void
{
    if ($pdo->query('SELECT DATABASE()')->fetchColumn() !== 'splyto_security_test'
        || $pdo->query('SELECT marker FROM splyto_test_environment')->fetchColumn()
            !== 'synthetic-registration-tests-only') {
        throw new RuntimeException('Refusing to reset an unmarked test database.');
    }
    $pdo->exec('DROP TABLE IF EXISTS trip_users');
    $pdo->exec('CREATE TABLE trip_users (
        id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
        nickname VARCHAR(32) NOT NULL,
        ' . ($hasNames ? 'first_name VARCHAR(64) NULL, last_name VARCHAR(64) NULL,' : '') . '
        email VARCHAR(255) NULL, password_hash VARCHAR(255) NULL,
        credentials_required TINYINT(1) NOT NULL DEFAULT 1,
        email_verified_at TIMESTAMP NULL DEFAULT NULL,
        account_status ENUM(\'active\', \'deactivated\', \'deleted\') NOT NULL DEFAULT \'active\',
        device_token CHAR(64) NOT NULL,
        UNIQUE KEY uq_trip_users_device_token (device_token),
        UNIQUE KEY uq_trip_users_email (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
}
