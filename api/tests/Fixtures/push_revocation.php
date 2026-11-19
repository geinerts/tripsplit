<?php
declare(strict_types=1);
// Signing out everywhere must also stop push delivery to every device.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/credentials_harness.php';
require_once __DIR__ . '/../../lib/helpers/push/push_core.php';

$pdo = credentials_test_db();
reset_credentials_test_schema($pdo);
$pdo->exec('CREATE TABLE trip_push_tokens (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INT, push_token TEXT,
    is_active INTEGER DEFAULT 1, updated_at TEXT DEFAULT CURRENT_TIMESTAMP)');
foreach ([[1, 'victim-phone'], [1, 'other-phone'], [2, 'someone-else']] as [$userId, $token]) {
    $pdo->prepare('INSERT INTO trip_push_tokens (user_id, push_token) VALUES (?, ?)')->execute([$userId, $token]);
    $pdo->prepare("INSERT INTO trip_refresh_tokens (user_id, token_hash, expires_at) VALUES (?, ?, '2999-01-01')")
        ->execute([$userId, hash('sha256', $token)]);
}

revoke_sessions_and_push_for_user($pdo, 1);

echo json_encode([
    'active_push' => $pdo->query('SELECT push_token FROM trip_push_tokens WHERE is_active = 1 ORDER BY id')
        ->fetchAll(PDO::FETCH_COLUMN),
    'active_sessions' => $pdo->query('SELECT user_id FROM trip_refresh_tokens WHERE revoked_at IS NULL ORDER BY id')
        ->fetchAll(PDO::FETCH_COLUMN),
]);
