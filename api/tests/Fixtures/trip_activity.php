<?php
declare(strict_types=1);
// Real handlers on the isolated SQLite harness. No live config or network.
// Balances stay stubbed by the harness: this fixture only checks recorded events.
foreach (['core', 'algorithm', 'payments', 'payload', 'actions'] as $part) {
    require __DIR__ . '/../../lib/actions/settlements/settlements_' . $part . '.php';
}
require __DIR__ . '/../../lib/actions/expense_social_actions.php';
require __DIR__ . '/trip_invitations.php';

define('RATE_LIMIT_COMMENT_WRITE_IP_MAX', 100);
define('RATE_LIMIT_COMMENT_WRITE_USER_MAX', 100);
function format_cents_with_currency(int $cents, string $currency): string { return $cents . ' ' . $currency; }
function trip_currency_code_from_trip(array $trip): string { return 'EUR'; }
function app_events_trip_activity_available(PDO $pdo): bool { return true; }
function activity_event_log(callable $action): array {
    $GLOBALS['app_events'] = [];
    $action();
    return array_map(static fn(array $event): array => [
        'type' => $event[1],
        'entity_id' => $event[3] ?? null,
        'payload' => $event[5] ?? [],
    ], $GLOBALS['app_events']);
}

$pdo = invitation_test_setup(false);
$GLOBALS['pdo'] = $pdo;
$actor = 1;
$body = [];
$assertions = 0;
$pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-26-add-trip-budget.sql'));
$pdo->exec('ALTER TABLE trip_trips ADD COLUMN destinations_json TEXT NULL');
$pdo->exec('ALTER TABLE trip_expenses ADD COLUMN note VARCHAR(255) NULL');
$pdo->exec('CREATE TABLE trip_expense_comments (id INTEGER PRIMARY KEY AUTOINCREMENT, expense_id INT, trip_id INT, user_id INT, parent_comment_id INT NULL, body TEXT)');
$pdo->exec('DROP TABLE trip_settlements');
$pdo->exec('CREATE TABLE trip_settlements (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, from_user_id INT, to_user_id INT, amount_cents INT, status VARCHAR(20), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, marked_sent_at TIMESTAMP NULL, confirmed_at TIMESTAMP NULL, confirmed_by INT NULL)');
$pdo->exec('CREATE TABLE trip_app_events (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, user_id INT, event_type VARCHAR(64), entity_type VARCHAR(32), entity_id INT, payload_json TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');

$id = (int) invitation_call('create_trip_action', 1, ['name'=>'Greece'])['body']['trip']['id'];
$_GET['trip_id'] = $id;
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ('.$id.',2,"member")');
$update = static fn(array $input): array => activity_event_log(
    static fn() => invitation_call('update_trip_action', 1, ['id'=>$id] + $input)
);

$results = [];
$results['renamed'] = $update(['name'=>'Greece 2026']);
$results['same_name'] = $update(['name'=>'Greece 2026']);
$results['budget_set'] = $update(['budget_cents'=>50000]);
$results['same_budget'] = $update(['budget_cents'=>50000]);
$results['no_destinations'] = $update(['destinations'=>[]]);
$pdo->exec('UPDATE trip_trips SET destinations_json=\'[{"name":"Athens"}]\' WHERE id='.$id);
$results['destinations_cleared'] = $update(['destinations'=>[]]);

$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,note) VALUES (5,'.$id.',1,"Breakfast")');
$results['comment'] = activity_event_log(static fn() => invitation_call(
    'add_expense_comment_action', 2, ['expense_id'=>5, 'body'=>'private words']
));

$pdo->exec('UPDATE trip_trips SET status="settling" WHERE id='.$id);
$pdo->exec('INSERT INTO trip_settlements(id,trip_id,from_user_id,to_user_id,amount_cents,status) VALUES
    (1,'.$id.',2,1,1000,"sent"),(2,'.$id.',2,1,500,"sent")');
$confirm = static fn(int $settlement): array => activity_event_log(static fn() => invitation_call(
    'confirm_settlement_received_action', 1, ['settlement_id'=>$settlement]
));
$results['first_confirm'] = $confirm(1);
$results['last_confirm'] = $confirm(2);
$pdo->exec('UPDATE trip_trips SET status="settling" WHERE id='.$id);
$results['repeated_confirm'] = $confirm(2);

$pdo->exec('DELETE FROM trip_app_events');
$insert = $pdo->prepare('INSERT INTO trip_app_events(trip_id,user_id,event_type) VALUES (:trip,1,:type)');
foreach (['trip.all_members_ready', 'settlement.reminder_sent', 'trip.settled', 'expense.comment_added'] as $type) {
    $insert->execute(['trip'=>$id, 'type'=>$type]);
}
$results['feed'] = array_column(invitation_call('list_trip_activity_action', 2)['body']['events'], 'event_type');

echo json_encode($results, JSON_THROW_ON_ERROR);
