<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../../lib/actions/settlements/settlements_core.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_algorithm.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_balance.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_payload.php';
require __DIR__ . '/../../lib/actions/settlements/settlements_actions.php';
require __DIR__ . '/../../lib/helpers/helper_validation.php';
require __DIR__ . '/trip_invitations.php';

$assertions = 0;
$pdo = invitation_test_setup(false);
$pdo->exec('ALTER TABLE trip_users ADD COLUMN created_at TIMESTAMP');
$pdo->exec('ALTER TABLE trip_trip_members ADD COLUMN joined_at TIMESTAMP');
$pdo->exec('ALTER TABLE trip_trip_members ADD COLUMN ready_to_settle INT DEFAULT 0');
$pdo->exec('ALTER TABLE trip_trip_members ADD COLUMN ready_to_settle_at TIMESTAMP');
$pdo->exec('ALTER TABLE trip_expenses ADD COLUMN amount DECIMAL(10,2)');
$pdo->exec('ALTER TABLE trip_expense_participants ADD COLUMN owed_cents INT');
$pdo->exec('DROP TABLE trip_settlements');
$pdo->exec('CREATE TABLE trip_settlements (id INTEGER PRIMARY KEY AUTOINCREMENT,
 trip_id INT, from_user_id INT, to_user_id INT, amount_cents INT, status VARCHAR(20),
 created_at TIMESTAMP, marked_sent_at TIMESTAMP, confirmed_at TIMESTAMP)');

foreach ([1 => 'solo', 2 => 'solo', 3 => 'group', 4 => 'group'] as $id => $mode) {
    $pdo->prepare('INSERT INTO trip_trips(id,name,created_by,trip_mode,currency_code) VALUES (?,"Test",1,?,"EUR")')->execute([$id,$mode]);
    $pdo->prepare('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (?,1,"owner")')->execute([$id]);
}
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,amount) VALUES (1,2,1,42.50)');
$pdo->exec('INSERT INTO trip_expense_participants(expense_id,user_id,owed_cents) VALUES (1,1,4250)');
foreach ([1, 2] as $id) {
    $_SERVER['HTTP_X_TRIP_ID'] = (string) $id;
    $denied = invitation_call('end_trip_action', 2);
    invitation_expect($denied['status'] !== 200, 'Non-owner cannot finish a personal trip');
    $result = invitation_call('end_trip_action', 1);
    invitation_expect($result['status'] === 200, 'Owner can finish without readiness');
    invitation_expect($result['body']['trip']['status'] === 'archived', 'Solo trip archives immediately');
    invitation_expect($result['body']['settlements'] === [], 'No solo settlements');
    $row = $pdo->query('SELECT * FROM trip_trips WHERE id=' . $id)->fetch();
    invitation_expect($row['ended_at'] !== null && $row['archived_at'] !== null, 'Finish and archive dates stored');
    invitation_expect(invitation_call('end_trip_action', 1)['status'] === 409, 'Cannot finish twice');
}
invitation_expect((int) $pdo->query('SELECT COUNT(*) FROM trip_expenses WHERE trip_id=2')->fetchColumn() === 1, 'Expense history is preserved');
$_SERVER['HTTP_X_TRIP_ID'] = '3';
invitation_expect(invitation_call('end_trip_action', 1)['status'] === 409, 'One-member group still requires readiness');
$pdo->exec('UPDATE trip_trip_members SET ready_to_settle=1 WHERE trip_id=3');
invitation_expect(invitation_call('end_trip_action', 1)['status'] === 200, 'Ready group still finishes');
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (4,2,"member")');
$pdo->exec('UPDATE trip_trip_members SET ready_to_settle=1 WHERE trip_id=4 AND user_id=1');
$_SERVER['HTTP_X_TRIP_ID'] = '4';
invitation_expect(invitation_call('end_trip_action', 1)['status'] === 409, 'Group requires every member ready');
invitation_expect(!$pdo->inTransaction(), 'No transaction leaked');
echo json_encode(['assertions'=>$assertions], JSON_THROW_ON_ERROR);
