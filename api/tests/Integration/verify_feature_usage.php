<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../bootstrap.php';
require __DIR__ . '/../Fixtures/isolated_mysql.php';
require_once __DIR__ . '/../../lib/helpers/helper_feature_usage.php';

$pdo = isolated_test_mysql();
$pdo->exec('DROP TABLE IF EXISTS trip_feature_usage_counts');
$pdo->exec((string) file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-07-add-feature-usage-counts.sql'));

$november = gmmktime(0, 0, 0, 11, 15, 2026);
$pdo->exec('INSERT INTO trip_feature_usage_counts VALUES ("2024-11", "random_pick", 7), ("2024-12", "random_pick", 8)');
record_feature_use($pdo, 'random_pick', $november);
record_feature_use($pdo, 'random_pick', $november);
record_feature_use($pdo, 'not_allowed', $november);

$rows = $pdo->query('SELECT usage_month, use_count FROM trip_feature_usage_counts ORDER BY usage_month')->fetchAll(PDO::FETCH_KEY_PAIR);
if ($rows !== ['2024-12' => 8, '2026-11' => 2]) {
    throw new RuntimeException('Unexpected feature usage rows: ' . json_encode($rows));
}
$columns = $pdo->query('SELECT column_name FROM information_schema.columns WHERE table_schema = DATABASE()
    AND table_name = "trip_feature_usage_counts" ORDER BY ordinal_position')->fetchAll(PDO::FETCH_COLUMN);
if ($columns !== ['usage_month', 'feature', 'use_count']) {
    throw new RuntimeException('The counter table must hold only month, feature and count.');
}
$pdo->exec('DROP TABLE trip_feature_usage_counts');
echo "PASS: feature usage upsert and retention on MySQL\n";
