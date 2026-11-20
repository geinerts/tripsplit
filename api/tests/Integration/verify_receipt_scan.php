<?php
declare(strict_types=1);
// Receipt-scan migration and budget reservation on real MySQL: parallel
// reservations never exceed the budget, settle closes reservations.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../bootstrap.php';
require __DIR__ . '/../Fixtures/isolated_mysql.php';
foreach ([
    'OPENAI_API_KEY' => '', 'RECEIPT_AI_MODEL' => 'gpt-5.4-mini-2026-03-17',
    'RECEIPT_AI_PRICE_INPUT_MICROUSD' => 750_000, 'RECEIPT_AI_PRICE_OUTPUT_MICROUSD' => 4_500_000,
    'RECEIPT_AI_RESERVE_MICROUSD' => 15_000, 'RECEIPT_AI_BUDGET_HOUR_MICROUSD' => 500_000,
    'RECEIPT_AI_BUDGET_DAY_MICROUSD' => 45_000, 'RECEIPT_AI_BUDGET_MONTH_MICROUSD' => 15_000_000,
    'RECEIPT_AI_USER_DAY_MAX' => 20, 'RECEIPT_AI_USER_MONTH_MAX' => 200,
    'RECEIPT_AI_MAX_OUTPUT_TOKENS' => 2000, 'RECEIPT_AI_TIMEOUT_SEC' => 30,
] as $name => $value) {
    if (!defined($name)) { define($name, $value); }
}
require_once __DIR__ . '/../../lib/helpers/helper_receipt_ai.php';

function check(bool $ok, string $message): void
{
    if (!$ok) { throw new RuntimeException($message); }
}

$pdo = isolated_test_mysql();
$now = (int) ($argv[3] ?? time());

if (($argv[1] ?? '') === 'worker') {
    ini_set('error_log', '/dev/null'); // "budget reached" is logged on purpose
    $userId = (int) $argv[2];
    try {
        receipt_ai_reserve($pdo, $userId, 'req-' . $userId, 'receipts/x.webp', str_repeat('a', 64), $now);
        echo "reserved\n";
    } catch (ApiResponseException $response) {
        echo $response->statusCode . "\n";
    }
    exit(0);
}

$pdo->exec('SET FOREIGN_KEY_CHECKS = 0');
$pdo->exec('DROP TABLE IF EXISTS trip_ai_scans, trip_ai_budget, trip_users');
$pdo->exec('SET FOREIGN_KEY_CHECKS = 1');
$pdo->exec('CREATE TABLE trip_users (id INT UNSIGNED NOT NULL PRIMARY KEY) ENGINE=InnoDB');
$pdo->exec('INSERT INTO trip_users (id) VALUES ' . implode(',', array_map(static fn (int $i): string => "($i)", range(1, 8))));
$migration = (string) file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-20-receipt-scans.sql');
$pdo->exec($migration);
$pdo->exec($migration); // safe to run twice

// Eight accounts reserve at once; the day budget fits three reservations.
$workers = [];
foreach (range(1, 8) as $userId) {
    $workers[] = proc_open([PHP_BINARY, __FILE__, 'worker', (string) $userId, (string) $now],
        [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
    $outputs[] = $pipes;
}
$answers = [];
foreach ($workers as $i => $process) {
    $answers[] = trim((string) stream_get_contents($outputs[$i][1]));
    $error = (string) stream_get_contents($outputs[$i][2]);
    $code = proc_close($process);
    check($code === 0 && $error === '', 'worker failed (' . $code . '): ' . $error . ' ' . end($answers));
}
sort($answers);
check(count(array_filter($answers, static fn (string $a): bool => $a === 'reserved')) === 3, 'exactly three reservations fit: ' . json_encode($answers));
check(count(array_filter($answers, static fn (string $a): bool => $a === '503')) === 5, 'the rest are refused: ' . json_encode($answers));
[$hour, $day, $month] = receipt_ai_periods($now);
$reserved = (int) $pdo->query("SELECT reserved_microusd FROM trip_ai_budget WHERE period = '$day'")->fetchColumn();
check($reserved === 45_000, 'day reservation equals three scans');

// Settling with a real cost releases the reservation and records the cost.
foreach ($pdo->query('SELECT id FROM trip_ai_scans ORDER BY id')->fetchAll(PDO::FETCH_COLUMN) as $index => $scanId) {
    receipt_ai_settle($pdo, (int) $scanId, $index === 0 ? 'failed' : 'done', $index === 0 ? null : 3300, [], $now);
}
$row = $pdo->query("SELECT spent_microusd, reserved_microusd FROM trip_ai_budget WHERE period = '$day'")->fetch(PDO::FETCH_ASSOC);
check((int) $row['reserved_microusd'] === 0, 'no reservation left after settling');
check((int) $row['spent_microusd'] === 15_000 + 3300 + 3300, 'unknown cost keeps the reservation, known cost replaces it');
$usage = receipt_ai_admin_usage($pdo, $now);
check($usage['budget']['day']['spent_microusd'] === 21_600 && $usage['scans_today'] === 3, 'admin usage matches');

$pdo->exec('DELETE FROM trip_users WHERE id = 1');
check((int) $pdo->query('SELECT COUNT(*) FROM trip_ai_scans WHERE user_id = 1')->fetchColumn() === 0, 'scans are removed with the user');
$pdo->exec('DROP TABLE trip_ai_scans, trip_ai_budget, trip_users');
echo "PASS: receipt-scan migration (twice), parallel budget reservation, settle and cascade on MySQL\n";
