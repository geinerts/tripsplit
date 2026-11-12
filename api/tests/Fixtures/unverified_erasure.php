<?php
declare(strict_types=1);
// Runs process_unverified_account_erasure() on SQLite (or isolated MySQL) with synthetic accounts.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/lifecycle_harness.php';

$pdo = credentials_test_db();
$GLOBALS['pdo'] = $pdo;
reset_lifecycle_schema($pdo);
try {
    $pdo->exec('ALTER TABLE trip_users ADD COLUMN created_at DATETIME NULL');
} catch (PDOException $error) {
    // The MySQL test schema already has created_at.
}
$pdo->exec('DROP TABLE IF EXISTS trip_trip_members');
$pdo->exec('CREATE TABLE trip_trip_members (trip_id INT, user_id INT)');
$pdo->exec('DELETE FROM trip_users');
$pdo->exec('DELETE FROM trip_friends');
$pdo->exec('DELETE FROM trip_user_identities');

$now = strtotime('2026-11-12 08:00:00 UTC');
$old = gmdate('Y-m-d H:i:s', $now - 40 * 86400);
$recent = gmdate('Y-m-d H:i:s', $now - 20 * 86400);
$add = static function (int $id, string $email, string $status, ?string $verified, string $created) use ($pdo): void {
    $pdo->prepare('INSERT INTO trip_users (id, nickname, first_name, email, password_hash, credentials_required,
        email_verified_at, account_status, device_token, created_at) VALUES (?, ?, ?, ?, ?, 0, ?, ?, ?, ?)')
        ->execute([$id, 'User ' . $id, 'User', $email, 'hash', $verified, $status, str_repeat((string) $id, 64), $created]);
};
$add(1, 'erase@example.invalid', 'deactivated', null, $old);          // erased
$add(2, 'recent@example.invalid', 'deactivated', null, $recent);      // too recent
$add(3, 'verified@example.invalid', 'deactivated', '2026-10-01', $old); // verified (admin suspension)
$add(4, 'active@example.invalid', 'active', null, $old);              // not deactivated yet
$add(5, 'member@example.invalid', 'deactivated', null, $old);         // has a trip
$add(6, 'friend@example.invalid', 'deactivated', null, $old);         // has a friend
$add(7, 'session@example.invalid', 'deactivated', null, $old);        // once signed in
$add(8, 'apple@example.invalid', 'deactivated', null, $old);          // Apple link
$pdo->exec('INSERT INTO trip_trip_members VALUES (9, 5)');
$pdo->exec('INSERT INTO trip_friends VALUES (1, 6, 4)');
$pdo->exec("INSERT INTO trip_refresh_tokens (user_id, token_hash, expires_at) VALUES (7, 'h', '2026-12-01')");
$pdo->exec("INSERT INTO trip_user_identities VALUES (1, 8, 'apple', 'subject')");

$dry = process_unverified_account_erasure($pdo, ['now' => $now, 'dry_run' => true]);
$before = $pdo->query('SELECT email FROM trip_users WHERE id = 1')->fetchColumn();
$run = process_unverified_account_erasure($pdo, ['now' => $now]);
$users = $pdo->query('SELECT id, email, password_hash, account_status, nickname FROM trip_users ORDER BY id')->fetchAll(PDO::FETCH_ASSOC);
// The freed address can be used for a new sign-up.
$pdo->prepare('INSERT INTO trip_users (nickname, email, credentials_required, device_token, created_at) VALUES (?, ?, 0, ?, ?)')
    ->execute(['New', 'erase@example.invalid', str_repeat('z', 64), gmdate('Y-m-d H:i:s', $now)]);
$again = process_unverified_account_erasure($pdo, ['now' => $now]);
echo json_encode(['dry' => $dry, 'before' => $before, 'run' => $run, 'users' => $users, 'again' => $again], JSON_THROW_ON_ERROR);
