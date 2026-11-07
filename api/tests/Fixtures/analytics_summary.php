<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/trip_invitations.php';
require_once __DIR__ . '/../../lib/helpers/helper_expense_math.php';
require_once __DIR__ . '/../../lib/actions/analytics_actions.php';

ini_set('error_log', '/dev/null');
$assertions = 0;
$pdo = invitation_test_setup(false);
foreach ([
    'ALTER TABLE trip_users ADD COLUMN created_at TIMESTAMP',
    'ALTER TABLE trip_expenses ADD COLUMN amount DECIMAL(10,2)',
    'ALTER TABLE trip_expenses ADD COLUMN category VARCHAR(64)',
    'ALTER TABLE trip_expenses ADD COLUMN note VARCHAR(255)',
    'ALTER TABLE trip_expenses ADD COLUMN split_mode VARCHAR(20) DEFAULT "equal"',
    'ALTER TABLE trip_expenses ADD COLUMN expense_date DATE',
    'ALTER TABLE trip_expense_participants ADD COLUMN owed_cents INT',
    'ALTER TABLE trip_expense_participants ADD COLUMN split_value INT',
] as $sql) {
    $pdo->exec($sql);
}
$pdo->exec('INSERT INTO trip_users(id,nickname,account_status,created_at) VALUES
    (4,"Anna","active","2026-01-01"),
    (5,"Bert","active","2026-01-02"),
    (6,"Outsider","active","2026-01-03")');
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code,status,created_at) VALUES
    (10,"Group",4,"group","EUR","active","2026-02-01"),
    (20,"Archived",4,"group","USD","archived","2026-01-01"),
    (30,"Empty",4,"group","EUR","active","2026-03-01"),
    (40,"Not mine",6,"group","EUR","active","2026-03-02")');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES
    (10,4,"owner"),(10,5,"member"),(20,4,"owner"),(30,4,"owner"),(40,6,"owner")');
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount,category,note,expense_date) VALUES
    (100,10,4,30.00,"food","Dinner","2026-02-02"),
    (101,10,5,10.00,"food","Coffee","2026-02-02"),
    (102,10,5,60.00,"","Taxi","2026-02-03"),
    (103,10,5,5.00,"food","Bert only","2026-03-01"),
    (104,10,5,0.01,"food","Rounding","2026-03-02"),
    (200,20,4,12.50,"stay","Hostel","2026-01-05"),
    (400,40,6,99.00,"food","Secret note","2026-01-05")');
$pdo->exec('INSERT INTO trip_expense_participants(expense_id,user_id,owed_cents) VALUES
    (100,4,1000),(100,5,2000),
    (101,4,500),(101,5,500),
    (102,4,1),(102,5,1),
    (103,5,500),
    (104,4,0),(104,5,0),
    (200,4,1250),
    (400,6,9900)');

$pdo->exec('CREATE TABLE trip_feature_usage_counts (usage_month TEXT, feature TEXT, use_count INTEGER, PRIMARY KEY (usage_month, feature))');
$_SERVER['HTTP_X_TRIP_ID'] = '';
$response = invitation_call('analytics_summary_action', 4);
invitation_expect($response['status'] === 200 && $response['body']['ok'] === true, 'Summary loads without a trip header');
$byId = array_column($response['body']['trips'], null, 'trip_id');
invitation_expect(array_keys($byId) === [30, 10, 20], 'All own trips are included, newest first, and no others');
invitation_expect($byId[20]['currency_code'] === 'USD', 'Each trip has its own currency');
invitation_expect($byId[30]['buckets'] === [] && $byId[30]['members'] === [], 'A trip without expenses has empty lists');
invitation_expect(!str_contains(json_encode($response['body'], JSON_THROW_ON_ERROR), 'Secret note'), 'Another trip stays out');

$group = $byId[10];
invitation_expect(array_map(static fn(array $b): string => $b['date'] . '|' . $b['category'], $group['buckets'])
    === ['2026-02-02|food', '2026-02-03|other', '2026-03-01|food', '2026-03-02|food'], 'Rows are per date and category');
invitation_expect($group['buckets'][0] === [
    'date' => '2026-02-02',
    'category' => 'food',
    'total_cents' => 4000,
    'share_cents' => 1500,
    'paid_cents' => 3000,
    'expense_count' => 2,
    'shared_expense_count' => 2,
], 'A row adds up total, own share and own payments');
invitation_expect($group['buckets'][1]['share_cents'] === 3000, 'Unusable stored amounts fall back to an equal split');
invitation_expect($group['buckets'][2]['share_cents'] === 0 && $group['buckets'][2]['shared_expense_count'] === 0
    && $group['buckets'][2]['expense_count'] === 1, 'An expense without the user still counts for the trip total');
invitation_expect($group['buckets'][3]['share_cents'] === 1, 'The remaining cent follows member order, as in list_expenses');
invitation_expect($group['members'] === [
    ['id' => 5, 'nickname' => 'Bert', 'paid_cents' => 7501],
    ['id' => 4, 'nickname' => 'Anna', 'paid_cents' => 3000],
], 'Members are ordered by what they paid');
invitation_expect(array_column($group['largest_by_total'], 'id') === [102, 100, 101, 103, 104], 'Largest by total');
invitation_expect(array_column($group['largest_by_share'], 'amount_cents') === [3000, 1000, 500, 1], 'Largest by own share skips zero');
invitation_expect(array_keys($group['largest_by_total'][0]) === ['id', 'category', 'note', 'amount_cents'], 'Largest rows hold only these fields');

$other = array_column(invitation_call('analytics_summary_action', 5)['body']['trips'], null, 'trip_id');
invitation_expect(array_keys($other) === [10], 'Another member sees only their trips');
invitation_expect($other[10]['buckets'][0]['share_cents'] === 2500 && $other[10]['buckets'][0]['paid_cents'] === 1000, 'Shares are personal');
invitation_expect($other[10]['buckets'][0]['total_cents'] === 4000, 'Totals are the same for everyone');

$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount,category,note,expense_date) VALUES (500,30,4,1.00,"food","","2026-03-03")');
$counted = static fn(): int => (int) $pdo->query('SELECT COALESCE(SUM(use_count), 0) FROM trip_feature_usage_counts WHERE feature = "analytics_open"')->fetchColumn();
invitation_expect($counted() === 2, 'Each successful summary is counted');
$missing = invitation_call('analytics_summary_action', 4);
invitation_expect($counted() === 2, 'A failed summary is not counted');
invitation_expect($missing['status'] === 500 && $missing['body']['code'] === 'analytics_incomplete', 'A missing allocation fails instead of guessing');
$pdo->exec('DELETE FROM trip_expenses WHERE id=500');
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount,category,note,expense_date) VALUES (501,30,4,0.00,"food","","2026-03-03")');
invitation_expect(invitation_call('analytics_summary_action', 4)['status'] === 200, 'A zero expense needs no allocation');

echo json_encode(['assertions' => $assertions], JSON_THROW_ON_ERROR);
