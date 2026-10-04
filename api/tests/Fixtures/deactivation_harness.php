<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/credentials_harness.php';
require __DIR__ . '/../../lib/actions/account_lifecycle_actions.php';
require __DIR__ . '/../../lib/actions/account_deactivation_actions.php';
define('RATE_LIMIT_MUTATION_WINDOW_SEC', 300);
function build_account_deactivation_email(string $url, string $name): string { return $url; }
function push_tokens_table_available(PDO $pdo): bool { return true; }
function reset_deactivation_schema(PDO $pdo): void
{
    reset_credentials_test_schema($pdo);
    $pdo->exec('ALTER TABLE trip_users ADD COLUMN avatar_path VARCHAR(255) NULL');
    $pdo->exec('ALTER TABLE trip_users ADD COLUMN deactivated_at DATETIME NULL');
    $pdo->exec('DROP TABLE IF EXISTS trip_account_action_tokens');
    $pdo->exec('DROP TABLE IF EXISTS trip_push_tokens');
    $mysql = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql';
    $id = $mysql ? 'BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
    $action = $mysql ? "ENUM('reactivate','delete')" : 'TEXT';
    $pdo->exec('CREATE TABLE trip_account_action_tokens (id ' . $id . ', user_id INT NOT NULL,
        action ' . $action . ', token_hash CHAR(64) UNIQUE, expires_at DATETIME,
        used_at DATETIME NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
    if ($mysql) {
        $pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-04-deactivation-email-proof.sql'));
    } else { $pdo->exec('ALTER TABLE trip_account_action_tokens ADD COLUMN credential_state_hash CHAR(64) NULL'); }
    $pdo->exec('CREATE TABLE trip_push_tokens (id ' . $id . ', user_id INT, is_active INT DEFAULT 1,
        updated_at DATETIME NULL)');
    $pdo->exec('INSERT INTO trip_push_tokens (user_id) VALUES (1), (2)');
}
function seed_deactivation_proof(PDO $pdo, string $char = 'a', string $action = 'deactivate'): void
{
    $user = fetch_me_row_by_id($pdo, 1);
    $pdo->prepare('INSERT INTO trip_account_action_tokens
        (user_id, action, token_hash, credential_state_hash, expires_at, created_at) VALUES (?, ?, ?, ?, ?, ?)')
        ->execute([1, $action, hash('sha256', str_repeat($char, 64)), deactivation_credential_state($user),
            gmdate('Y-m-d H:i:s', time() + 900), gmdate('Y-m-d H:i:s', time() - 120)]);
}
function deactivation_snapshot(PDO $pdo): array
{
    $rows = [];
    foreach (['users', 'refresh_tokens', 'account_action_tokens', 'push_tokens'] as $table) {
        $rows[$table] = $pdo->query('SELECT * FROM trip_' . $table . ' ORDER BY id')->fetchAll();
    }
    return $rows;
}
