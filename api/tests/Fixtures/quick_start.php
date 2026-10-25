<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/trip_invitations.php';
require __DIR__ . '/../../lib/actions/quick_start_actions.php';

$assertions = 0;
$pdo = invitation_test_setup(false);
invitation_expect(!claim_quick_start($pdo, 1), 'Unmigrated server fails closed');
$pdo->exec("ALTER TABLE trip_users ADD COLUMN quick_start_state VARCHAR(16) NOT NULL DEFAULT 'pending'");
$pdo->exec("UPDATE trip_users SET quick_start_state='legacy' WHERE id=3");
invitation_expect(!claim_quick_start($pdo, 3), 'Existing account never automatically opens');
$first = invitation_call('claim_quick_start_action', 1, ['user_id'=>2]);
invitation_expect($first['body']['show_quick_start'] === true, 'New empty account claims guide');
invitation_expect(!claim_quick_start($pdo, 1), 'Second device/relogin cannot claim again');
invitation_expect(claim_quick_start($pdo, 2), 'Client-supplied user ID ignored; second account independent');

// Real creation and join handlers must persist experience, even before a Home
// visit, and must not count an invitation as accepted membership.
$pdo->exec("UPDATE trip_users SET quick_start_state='pending' WHERE id IN (1,2)");
$created = invitation_call('create_trip_action', 1, ['name'=>'Guide test','member_ids'=>[2]]);
invitation_expect($created['status'] === 200, 'Trip created');
$tripId = $created['body']['trip']['id'];
invitation_expect(!claim_quick_start($pdo, 1), 'Creator suppressed');
invitation_expect($pdo->query('SELECT quick_start_state FROM trip_users WHERE id=1')->fetchColumn() === 'experienced', 'Creation permanently records experience');
invitation_expect($pdo->query('SELECT quick_start_state FROM trip_users WHERE id=2')->fetchColumn() === 'pending', 'Pending invite does not count as membership');
$_SERVER['HTTP_X_TRIP_ID'] = (string) $tripId;
$code = $pdo->query('SELECT invite_code FROM trip_trip_invites WHERE target_user_id=2')->fetchColumn();
$preview = invitation_call('preview_trip_invite_action', 2, ['invite_token'=>$code]);
$joined = invitation_call('join_trip_invite_action', 2, [
    'invite_token'=>$code, 'preview_nonce'=>$preview['body']['invite']['preview_nonce'],
]);
invitation_expect($joined['status'] === 200, 'Invitation accepted');
invitation_expect($pdo->query('SELECT quick_start_state FROM trip_users WHERE id=2')->fetchColumn() === 'experienced', 'Accepted member permanently suppressed');
$pdo->exec('DELETE FROM trip_trip_members');
$pdo->exec('DELETE FROM trip_trips');
invitation_expect(!claim_quick_start($pdo, 1) && !claim_quick_start($pdo, 2), 'Deleting all trips does not reset eligibility');

$pdo->exec("UPDATE trip_users SET quick_start_state='pending' WHERE id=2");
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES (99,2,"member")');
invitation_expect(!claim_quick_start($pdo, 2), 'Any membership including archived trips blocks the claim');
$pdo->exec('DELETE FROM trip_trip_members');
invitation_expect(!claim_quick_start($pdo, 2), 'Observed pre-existing membership stays suppressed after deletion');
invitation_expect(!$pdo->inTransaction(), 'No transaction leaked');
echo json_encode(['assertions'=>$assertions], JSON_THROW_ON_ERROR);
