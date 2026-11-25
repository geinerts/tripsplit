<?php
declare(strict_types=1);
// Real expense, comment, activity, balance, analytics and report code on the isolated
// SQLite harness. No live config or network. See docs/api/personal-expenses.md.
require __DIR__ . '/../../lib/actions/settlements/settlements_algorithm.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_balance.php';
require __DIR__ . '/../../lib/actions/expense_social_actions.php';
require __DIR__ . '/trip_invitations.php';
require __DIR__ . '/../../lib/helpers/helper_expense_math.php';
require __DIR__ . '/../../lib/helpers/helper_analytics_summary.php';
require __DIR__ . '/../../lib/helpers/helper_trip_report.php';

define('RATE_LIMIT_EXPENSE_WRITE_IP_MAX', 100);
define('RATE_LIMIT_EXPENSE_WRITE_USER_MAX', 100);
define('RATE_LIMIT_COMMENT_WRITE_IP_MAX', 100);
define('RATE_LIMIT_COMMENT_WRITE_USER_MAX', 100);
function expenses_currency_columns_available(PDO $pdo): bool { return true; }
function convert_amount_to_trip_currency(int $cents, string $from, string $to, string $date): array {
    return ['converted_cents' => $cents, 'fx_rate_to_trip' => 1.0];
}
function trip_currency_code_from_trip(array $trip): string { return 'EUR'; }
function normalize_receipt_path(string $path, bool $allowEmpty = true): string { return trim($path); }
function receipt_public_url(?string $path): ?string { return $path ? 'https://example.invalid/r/' . $path : null; }
function receipt_thumb_public_url(?string $path): ?string { return $path ? 'https://example.invalid/t/' . $path : null; }
function request_client_mutation_id(): string { return ''; }
function mutation_idempotency_try_replay(...$args): void {}
function mutation_idempotency_store_response(...$args): void {}
function format_cents_with_currency(int $cents, string $code): string { return $code . ' ' . number_format($cents / 100, 2, '.', ''); }
function app_events_trip_activity_available(PDO $pdo): bool { return true; }
function avatar_public_url(?string $path): ?string { return null; }
function avatar_thumb_public_url(?string $path): ?string { return null; }

$pdo = invitation_test_setup(false);
$GLOBALS['pdo'] = $pdo;
$actor = 1;
$body = [];
$assertions = 0;
foreach (['expenses', 'expense_participants', 'settlements'] as $table) {
    $pdo->exec('DROP TABLE trip_' . $table);
}
$pdo->exec('CREATE TABLE trip_expenses (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, amount DECIMAL(12,2),
    currency_code CHAR(3) DEFAULT "EUR", source_amount DECIMAL(12,2), fx_rate_to_trip DECIMAL(18,8) DEFAULT 1,
    category VARCHAR(64) DEFAULT "other", note VARCHAR(255) DEFAULT "", split_mode VARCHAR(16) DEFAULT "equal",
    paid_by INT, expense_date DATE, receipt_path VARCHAR(255) NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
$pdo->exec('CREATE TABLE trip_expense_participants (expense_id INT, user_id INT, owed_cents INT, split_value INT DEFAULT 0)');
$pdo->exec('CREATE TABLE trip_expense_items (id INTEGER PRIMARY KEY AUTOINCREMENT, expense_id INT, position INT, name VARCHAR(80), amount_cents INT, is_extra INT)');
$pdo->exec('CREATE TABLE trip_expense_item_participants (item_id INT, user_id INT)');
$pdo->exec('CREATE TABLE trip_settlements (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, from_user_id INT, to_user_id INT, amount_cents INT, status VARCHAR(20))');
$pdo->exec('CREATE TABLE trip_expense_comments (id INTEGER PRIMARY KEY AUTOINCREMENT, expense_id INT, trip_id INT, user_id INT, parent_comment_id INT NULL, body TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
$pdo->exec('CREATE TABLE trip_app_events (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, user_id INT, event_type VARCHAR(64), entity_type VARCHAR(32), entity_id INT, payload_json TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
$pdo->exec('ALTER TABLE trip_trip_members ADD COLUMN joined_at TIMESTAMP DEFAULT "2026-11-01 10:00:00"');
$pdo->exec('ALTER TABLE trip_users ADD COLUMN created_at TIMESTAMP DEFAULT "2026-01-01 10:00:00"');
$pdo->exec('INSERT INTO trip_trips (id, name, created_by, trip_mode, currency_code) VALUES (1, "Rome", 1, "group", "EUR"), (2, "Me", 1, "solo", "EUR")');
$pdo->exec('INSERT INTO trip_trip_members (trip_id, user_id, role) VALUES (1,1,"owner"),(1,2,"member"),(1,3,"member"),(2,1,"owner")');
$_SERVER['HTTP_X_TRIP_ID'] = '1';

$call = static fn (string $handler, int $user, array $input = []): array => invitation_call($handler, $user, $input);
$add = static fn (int $user, array $input): array => $call('add_expense_action', $user, $input + [
    'amount' => 30, 'currency_code' => 'EUR', 'category' => 'shopping', 'note' => 'Souvenir', 'date' => '2026-12-01',
]);
// Records what app_event() received in the activity table, as the real helper does.
$flushEvents = static function () use ($pdo): void {
    $insert = $pdo->prepare('INSERT INTO trip_app_events (trip_id, user_id, event_type, entity_type, entity_id, payload_json)
        VALUES (:trip, :user, :type, :entity_type, :entity, :payload)');
    foreach ($GLOBALS['app_events'] ?? [] as $event) {
        $insert->execute(['user' => $event[0], 'type' => $event[1], 'entity_type' => $event[2], 'entity' => $event[3],
            'trip' => $event[4], 'payload' => json_encode($event[5] ?? [])]);
    }
    $GLOBALS['app_events'] = [];
};
$r = [];

// Before the migration nothing changes, and asking for a personal expense is refused.
$r['before'] = [$add(1, ['is_personal' => true])['status'], $add(1, ['is_personal' => true])['body']['error'] ?? ''];
$r['before_column'] = expenses_personal_column_available($pdo);
$r['before_plain'] = $add(1, ['is_personal' => false, 'participants' => [1, 2]])['status'];
$r['before_list'] = array_map(static fn (array $e): array => [$e['is_personal'], $e['locked']],
    $call('list_expenses_action', 2)['body']['expenses']);
$r['before_balances'] = array_column(compute_trip_balance_data($pdo, 1)['balances'], 'paid');
$r['before_social'] = get_expense_for_trip($pdo, 1, 1, 2)['id'] ?? null;
$pdo->exec('DELETE FROM trip_expenses');
$pdo->exec('DELETE FROM trip_expense_participants');
$pdo->exec('DELETE FROM sqlite_sequence WHERE name = "trip_expenses"');
$pdo->exec('DELETE FROM trip_notifications');
$GLOBALS['app_events'] = [];
$pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-25-add-expense-is-personal.sql'));

$error = static fn (array $response): array => [$response['status'], $response['body']['error'] ?? ''];
$r['errors'] = [
    'shared' => $error($add(1, ['is_personal' => true, 'participants' => [1, 2]])),
    'other_person' => $error($add(1, ['is_personal' => true, 'participants' => [2]])),
    'shares' => $error($add(1, ['is_personal' => true, 'split_mode' => 'shares', 'splits' => [['user_id' => 1, 'value' => 1]]])),
    'bad_value' => $error($add(1, ['is_personal' => 'yes'])),
    'solo' => (function () use ($add, $error): array {
        $_SERVER['HTTP_X_TRIP_ID'] = '2';
        $result = $error($add(1, ['is_personal' => true]));
        $_SERVER['HTTP_X_TRIP_ID'] = '1';
        return $result;
    })(),
];
$r['nothing_saved'] = (int) $pdo->query('SELECT COUNT(*) FROM trip_expenses')->fetchColumn();

// 1 buys a souvenir for themself, 2 pays a dinner for all, 3 treats themself (not personal).
$personalId = (int) $add(1, ['is_personal' => true, 'participants' => [1]])['body']['expense_id'];
$pdo->exec('UPDATE trip_expenses SET receipt_path = "r/1.jpg" WHERE id = ' . $personalId);
$dinnerId = (int) $add(2, ['amount' => 90, 'category' => 'food', 'note' => 'Dinner', 'participants' => [1, 2, 3]])['body']['expense_id'];
$treatId = (int) $add(3, ['amount' => 12, 'category' => 'food', 'note' => 'Gelato', 'participants' => [3]])['body']['expense_id'];
$flushEvents();
$r['stored'] = $pdo->query('SELECT id, is_personal, split_mode FROM trip_expenses ORDER BY id')->fetchAll();
$r['personal_participants'] = $pdo->query('SELECT user_id, owed_cents FROM trip_expense_participants WHERE expense_id = ' . $personalId)->fetchAll();
$r['notified'] = $pdo->query('SELECT user_id, payload_json FROM trip_notifications WHERE type = "expense_added" ORDER BY id')->fetchAll();

$byId = static fn (array $rows): array => array_column($rows, null, 'id');
$r['list_payer'] = $byId($call('list_expenses_action', 1)['body']['expenses']);
$r['list_other'] = $byId($call('list_expenses_action', 2)['body']['expenses']);
$r['workspace_other'] = $byId(workspace_load_trip_expenses($pdo, 1, 300, 2));
$r['workspace_nobody'] = $byId(workspace_load_trip_expenses($pdo, 1, 300));
$r['personal_totals'] = [personal_expense_total_cents($pdo, 1, 1), personal_expense_total_cents($pdo, 1, 2)];

$balances = compute_trip_balance_data($pdo, 1);
$r['balances'] = array_map(static fn (array $b): array => [$b['id'], $b['paid'], $b['owed'], $b['net']], $balances['balances']);
$r['settlements'] = $balances['recommended_settlements'];

// Comments: only the payer may open a personal expense.
$r['comments'] = [
    'other_add' => $error($call('add_expense_comment_action', 2, ['expense_id' => $personalId, 'body' => 'Nice'])),
    'other_list' => $error($call('list_expense_comments_action', 2, ['expense_id' => $personalId] + ($_GET = ['expense_id' => $personalId]))),
    'other_reactions' => $error($call('list_expense_reactions_action', 2)),
    'payer_open' => get_expense_for_trip($pdo, $personalId, 1, 1)['id'] ?? null,
    'other_group' => get_expense_for_trip($pdo, $dinnerId, 1, 2)['id'] ?? null,
];
$_GET = [];

// Older apps send no is_personal: kept while still only the payer, cleared once shared.
$update = static fn (int $user, array $input): array => $call('update_expense_action', $user, $input + [
    'id' => $personalId, 'amount' => 40, 'category' => 'shopping', 'note' => 'Souvenirs', 'date' => '2026-12-01',
]);
$r['update_kept'] = [$update(1, ['participants' => [1], 'split_mode' => 'equal'])['status'],
    (int) $pdo->query('SELECT is_personal FROM trip_expenses WHERE id = ' . $personalId)->fetchColumn()];
$r['update_other'] = $error($update(2, ['is_personal' => true, 'participants' => [2]]));
$r['update_shared_refused'] = $error($update(1, ['is_personal' => true, 'participants' => [1, 3]]));
$r['update_cleared'] = [$update(1, ['participants' => [1, 3]])['status'],
    (int) $pdo->query('SELECT is_personal FROM trip_expenses WHERE id = ' . $personalId)->fetchColumn()];
$r['update_back'] = [$update(1, ['is_personal' => true, 'participants' => [1]])['status'],
    (int) $pdo->query('SELECT is_personal FROM trip_expenses WHERE id = ' . $personalId)->fetchColumn(),
    $pdo->query('SELECT user_id FROM trip_expense_participants WHERE expense_id = ' . $personalId)->fetchAll(PDO::FETCH_COLUMN)];
$r['update_treat'] = [$call('update_expense_action', 3, ['id' => $treatId, 'amount' => 12, 'participants' => [3], 'date' => '2026-12-01'])['status'],
    (int) $pdo->query('SELECT is_personal FROM trip_expenses WHERE id = ' . $treatId)->fetchColumn()];
$flushEvents();

// Activity: others get only the amount of a personal expense.
$activity = static function (int $user) use ($call, $personalId): array {
    $events = array_filter($call('list_trip_activity_action', $user)['body']['events'],
        static fn (array $e): bool => $e['entity_id'] === $personalId);
    return array_values(array_map(static fn (array $e): array => [$e['event_type'], $e['payload']], $events));
};
$r['activity_payer'] = $activity(1);
$r['activity_other'] = $activity(2);

// Analytics and report leave personal expenses out; the reader sees their own as one total.
$summary = static fn (int $user): array => analytics_summary_build($pdo, $user)[1] ?? analytics_summary_build($pdo, $user)[0];
$r['analytics_payer'] = $summary(1);
$r['analytics_other'] = $summary(2);
$report = static fn (int $user): array => trip_report_load($pdo, 1, $user);
$r['report_payer'] = array_intersect_key($report(1), array_flip(['total_cents', 'personal_cents', 'expense_count', 'categories', 'members']));
$r['report_other'] = array_intersect_key($report(2), array_flip(['total_cents', 'personal_cents', 'expense_count']));

echo json_encode($r, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE);
