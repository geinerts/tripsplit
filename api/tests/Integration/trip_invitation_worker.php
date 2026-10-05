<?php
declare(strict_types=1);
require __DIR__ . '/../Fixtures/trip_invitations.php';
$pdo = isolated_test_mysql();
$_SERVER['HTTP_X_TRIP_ID'] = $argv[2];
$mode = $argv[1];
$body = json_decode($argv[3], true, 512, JSON_THROW_ON_ERROR);
echo "READY\n";
flush();
if (trim((string) fgets(STDIN)) !== 'GO') exit(2);
$result = match ($mode) {
    'join' => invitation_call('join_trip_invite_action', 2, $body),
    'decline' => invitation_call('decline_trip_invite_action', 2, $body),
    'remove' => invitation_call('remove_trip_member_action', 1, ['user_id'=>2]),
    'revoke' => invitation_call('revoke_trip_invitation_action', 1, $body),
    'add' => invitation_call('add_trip_members_action', 1, ['member_ids'=>3]),
};
echo json_encode(['status'=>$result['status'], 'open'=>$pdo->inTransaction()], JSON_THROW_ON_ERROR) . "\n";
