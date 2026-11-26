<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
// The share in the profile currency, in the isolated SQLite harness. No live config or network:
// rates are stubbed, one fixed rate per date so per-expense conversion shows.
require __DIR__ . '/trip_invitations.php';
if (!function_exists('normalize_currency_code_or_default')) {
    function normalize_currency_code_or_default($code): string { return strtoupper(trim((string) $code)) ?: 'EUR'; }
}
if (!function_exists('normalize_profile_currency_code_or_default')) {
    function normalize_profile_currency_code_or_default($code): string { return is_string($code) && $code !== '' ? $code : 'EUR'; }
}
if (!function_exists('expenses_currency_columns_available')) {
    function expenses_currency_columns_available(PDO $pdo): bool { return true; }
}
if (!function_exists('convert_expense_amount_to_target_currency_cents')) {
    function convert_expense_amount_to_target_currency_cents(int $source, string $sourceCurrency, int $trip,
        string $tripCurrency, string $date, string $target): ?int {
        if ($target === 'XXX') return null;
        // 0.5 on 2 March, 0.25 on 3 March.
        return (int) round($trip * ($date === '2026-03-02' ? 0.5 : 0.25));
    }
}

ini_set('error_log', '/dev/null');
$assertions = 0;
$pdo = invitation_test_setup(false);
foreach ([
    'ALTER TABLE trip_expenses ADD COLUMN amount DECIMAL(10,2)',
    'ALTER TABLE trip_expenses ADD COLUMN currency_code VARCHAR(3)',
    'ALTER TABLE trip_expenses ADD COLUMN source_amount DECIMAL(10,2)',
    'ALTER TABLE trip_expenses ADD COLUMN fx_rate_to_trip DECIMAL(18,8)',
    'ALTER TABLE trip_expenses ADD COLUMN expense_date DATE',
    'ALTER TABLE trip_expenses ADD COLUMN created_at TIMESTAMP',
    'ALTER TABLE trip_expense_participants ADD COLUMN owed_cents INT',
    'ALTER TABLE trip_settlements ADD COLUMN status VARCHAR(20)',
] as $sql) {
    $pdo->exec($sql);
}
$pdo->exec('INSERT INTO trip_users(id,nickname,account_status) VALUES (4,"Anna","active"),(5,"Bert","active")');
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code,status) VALUES (10,"Sofia",4,"group","BGN","active")');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (10,4,"owner"),(10,5,"member")');
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount,currency_code,source_amount,expense_date) VALUES
    (100,10,4,195.58,"BGN",195.58,"2026-03-02"),
    (101,10,5,97.79,"BGN",97.79,"2026-03-03")');
$pdo->exec('INSERT INTO trip_expense_participants(expense_id,user_id,owed_cents) VALUES
    (100,4,9779),(100,5,9779),(101,4,4890),(101,5,4889)');

$owed = static fn(string $preferred, int $myOwed): ?int
    => trip_user_owed_in_preferred_currency_cents($pdo, 10, 4, 'BGN', $preferred, $myOwed);
invitation_expect($owed('BGN', 14669) === 14669, 'The trip currency needs no conversion');
invitation_expect($owed('EUR', 0) === 0, 'No share is zero in any currency');
// 97.79 at 0.5 plus 48.90 at 0.25: 48.90 + 12.23 = 61.13 (rounded per expense).
invitation_expect($owed('EUR', 14669) === 6113, 'Each share is converted at its expense date');
// A share the trip shows differently (for example an equal split fallback) is scaled to it.
invitation_expect($owed('EUR', 29338) === 12226, 'The result follows the share the trip shows');
invitation_expect($owed('XXX', 14669) === null, 'A missing rate gives no total instead of a wrong one');
invitation_expect(trip_user_owed_in_preferred_currency_cents($pdo, 10, 99, 'BGN', 'EUR', 500) === null,
    'A share with no stored parts is unknown instead of guessed');

$_SERVER['HTTP_X_TRIP_ID'] = '';
$list = invitation_call('trips_action', 4);
$trip = array_column($list['body']['trips'] ?? [], null, 'id')[10] ?? [];
invitation_expect(array_key_exists('my_owed_preferred_cents', $trip), 'The trips list sends the converted share');

echo json_encode(['assertions' => $assertions], JSON_THROW_ON_ERROR);
