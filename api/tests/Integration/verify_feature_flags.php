<?php
declare(strict_types=1);
// Feature flag migration and checks on real MySQL (docs/api/feature-flags.md).
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../bootstrap.php';
require __DIR__ . '/../Fixtures/isolated_mysql.php';
require_once __DIR__ . '/../../lib/helpers/helper_feature_flags.php';

function check(bool $ok, string $message): void
{
    if (!$ok) { throw new RuntimeException($message); }
}

$pdo = isolated_test_mysql();
$pdo->exec('SET FOREIGN_KEY_CHECKS = 0');
$pdo->exec('DROP TABLE IF EXISTS trip_user_features, trip_feature_flags, trip_users');
$pdo->exec('SET FOREIGN_KEY_CHECKS = 1');
$pdo->exec("CREATE TABLE trip_users (id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    account_status VARCHAR(20) NOT NULL DEFAULT 'active', guest_trip_id INT UNSIGNED NULL) ENGINE=InnoDB");
$pdo->exec("INSERT INTO trip_users (id, account_status, guest_trip_id) VALUES (1, 'active', NULL), (2, 'active', 7)");

$migration = (string) file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-20-feature-flags.sql');
$pdo->exec($migration);
$pdo->exec($migration); // must be safe to run twice
check($pdo->query("SELECT mode FROM trip_feature_flags WHERE flag_key = 'receipt_ai'")->fetchColumn() === 'off',
    'receipt_ai must start off');
check((int) $pdo->query('SELECT COUNT(*) FROM trip_user_features')->fetchColumn() === 0, 'no grants at start');
check(feature_flags_for_user($pdo, 1) === ['receipt_ai' => false], 'off means nobody');

$pdo->exec("INSERT INTO trip_user_features (user_id, flag_key) VALUES (1, 'receipt_ai'), (2, 'receipt_ai')");
$pdo->exec("UPDATE trip_feature_flags SET mode = 'allowlist'");
check(feature_enabled_for_user($pdo, 1, 'receipt_ai') === true, 'granted account gets the feature');
check(feature_enabled_for_user($pdo, 2, 'receipt_ai') === false, 'trip guest never gets the feature');
try {
    $pdo->exec("UPDATE trip_feature_flags SET mode = 'on'");
    $invalid = (string) $pdo->query("SELECT mode FROM trip_feature_flags")->fetchColumn();
    check($invalid !== 'on', 'mode accepts only off, allowlist and everyone');
} catch (PDOException $error) {
    // Strict mode rejects the value outright; that is fine too.
}
$pdo->exec("UPDATE trip_feature_flags SET mode = 'allowlist'");
$pdo->exec('DELETE FROM trip_users WHERE id = 1');
check((int) $pdo->query('SELECT COUNT(*) FROM trip_user_features WHERE user_id = 1')->fetchColumn() === 0,
    'grants are removed with the user');

$pdo->exec('DROP TABLE trip_user_features, trip_feature_flags, trip_users');
echo "PASS: feature flag migration (twice), defaults, modes, guest rule and cascade on MySQL\n";
