<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/lifecycle_harness.php';
require __DIR__ . '/../../lib/actions/password_reset_actions.php';
function token_from_header(): string { return str_repeat('a', 64); }
function app_event(PDO $pdo, int $id, ...$args): void {}
function build_password_reset_email(string $url, string $name): string { return $url; }

function reset_session_schema(PDO $pdo): void
{
    reset_lifecycle_schema($pdo);
    seed_lifecycle_user($pdo, 'delete');
    $pdo->prepare('UPDATE trip_users SET password_hash = ? WHERE id = 1')
        ->execute([password_hash(' Current-password-123 ', PASSWORD_BCRYPT)]);
    $pdo->exec('DROP TABLE IF EXISTS trip_password_resets');
    $id = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql'
        ? 'BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
    $pdo->exec('CREATE TABLE trip_password_resets (id ' . $id . ', user_id INT,
        token_hash CHAR(64), credential_state_hash CHAR(64), expires_at DATETIME,
        used_at DATETIME NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
    $pdo->prepare('INSERT INTO trip_password_resets
        (user_id, token_hash, credential_state_hash, expires_at) VALUES (1, ?, ?, ?)')->execute([
            hash('sha256', str_repeat('c', 64)), password_reset_credential_state(fetch_me_row_by_id($pdo, 1)),
            gmdate('Y-m-d H:i:s', time() + 3600)]);
    seed_deactivation_proof($pdo);
}

function session_event(string $event): array
{
    $GLOBALS['requestBody'] = $event === 'reset'
        ? ['token' => str_repeat('c', 64), 'password' => 'Replacement-password-456']
        : ['token' => str_repeat('a', 64)];
    return credential_test_response($event === 'reset' ? 'reset_password_action' : 'confirm_deactivation_action');
}
