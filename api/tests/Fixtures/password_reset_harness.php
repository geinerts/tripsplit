<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/credentials_harness.php';
require __DIR__ . '/../../lib/actions/password_reset_actions.php';
function build_password_reset_email(string $url, string $name): string { return $url; }

function reset_password_test_schema(PDO $pdo): void
{
    reset_credentials_test_schema($pdo);
    $pdo->exec('DROP TABLE IF EXISTS trip_password_resets');
    $mysql = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql';
    $id = $mysql ? 'BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
    $pdo->exec('CREATE TABLE trip_password_resets (id ' . $id . ', user_id INT NOT NULL,
        token_hash CHAR(64) UNIQUE, expires_at DATETIME, used_at DATETIME NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
    if ($mysql) {
        // Apply the real migration to an old synthetic table, preserving existing links.
        $pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-04-password-reset-state.sql'));
    } else {
        $pdo->exec('ALTER TABLE trip_password_resets ADD COLUMN credential_state_hash CHAR(64) NULL');
    }
}

function seed_password_reset(PDO $pdo, string $token = 'a', int $userId = 1): void
{
    $user = fetch_me_row_by_id($pdo, $userId);
    $pdo->prepare('INSERT INTO trip_password_resets
        (user_id, token_hash, credential_state_hash, expires_at, created_at) VALUES (?, ?, ?, ?, ?)')->execute([
            $userId, hash('sha256', str_repeat($token, 64)), password_reset_credential_state($user),
            gmdate('Y-m-d H:i:s', time() + 3600), gmdate('Y-m-d H:i:s', time() - 120),
        ]);
}

function password_reset_snapshot(PDO $pdo): array
{
    $result = [];
    foreach (['users', 'password_resets', 'refresh_tokens'] as $table) {
        $result[$table] = $pdo->query('SELECT * FROM trip_' . $table . ' ORDER BY id')->fetchAll();
    }
    return $result;
}
