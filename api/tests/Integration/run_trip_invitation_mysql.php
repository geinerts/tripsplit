<?php
declare(strict_types=1);
require __DIR__ . '/../Fixtures/trip_invitations.php';
$assertions = 0;
for ($round = 1; $round <= 5; $round++) {
    foreach ([['join','decline'], ['join','join'], ['join','remove'], ['add','add'], ['join','revoke']] as $modes) {
        $pdo = invitation_test_setup(true);
        $created = invitation_call('create_trip_action', 1, ['name'=>'Race trip','member_ids'=>[2]]);
        $tripId = $created['body']['trip']['id'];
        $_SERVER['HTTP_X_TRIP_ID'] = (string) $tripId;
        $code = $pdo->query('SELECT invite_code FROM trip_trip_invites')->fetchColumn();
        if (in_array('remove', $modes, true)) {
            $pdo->exec('INSERT INTO trip_trip_members VALUES (' . $tripId . ',2,"member")');
            $code = invitation_call('create_trip_invite_action', 1)['body']['invite_token'];
        }
        $preview = invitation_call('preview_trip_invite_action', 2, ['invite_token'=>$code]);
        $input = ['invite_token'=>$code,'preview_nonce'=>$preview['body']['invite']['preview_nonce']];
        $input['invitation_id'] = (int) $pdo->query('SELECT id FROM trip_trip_invites WHERE target_user_id=2 LIMIT 1')->fetchColumn();
        $workers = [];
        try {
            foreach ($modes as $mode) {
                $process = proc_open([PHP_BINARY,__DIR__.'/trip_invitation_worker.php',$mode,(string)$tripId,json_encode($input)],
                    [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
                invitation_expect(is_resource($process), 'Worker starts');
                stream_set_timeout($pipes[1], 30);
                $workers[] = ['process'=>$process,'pipes'=>$pipes];
            }
            foreach ($workers as $w) invitation_expect(fgets($w['pipes'][1]) === "READY\n", 'Worker ready');
            foreach ($round % 2 ? [0,1] : [1,0] as $i) {
                fwrite($workers[$i]['pipes'][0], "GO\n");
                fflush($workers[$i]['pipes'][0]);
            }
            $statuses = [];
            foreach ($workers as &$w) {
                $result = json_decode((string) fgets($w['pipes'][1]), true, 512, JSON_THROW_ON_ERROR);
                fclose($w['pipes'][0]); fclose($w['pipes'][1]);
                $err = stream_get_contents($w['pipes'][2]); fclose($w['pipes'][2]);
                $exit = proc_close($w['process']); $w = [];
                invitation_expect($exit === 0 && $err === '', 'Worker succeeded: ' . $err);
                invitation_expect(!$result['open'], 'No transaction leaked');
                invitation_expect(in_array($result['status'], [200,404,409], true), 'No unexpected status');
                $statuses[] = $result['status'];
            }
            unset($w);
            if ($modes === ['add','add']) {
                invitation_expect((int)$pdo->query('SELECT COUNT(*) FROM trip_trip_invites WHERE target_user_id=3')->fetchColumn() === 1, 'Concurrent invitations deduplicated');
                invitation_expect((int)$pdo->query('SELECT COUNT(*) FROM trip_notifications WHERE user_id=3')->fetchColumn() === 1, 'One notification');
                invitation_expect(find_trip_for_user($pdo,3,$tripId) === null, 'Invite did not grant membership');
            } elseif (in_array('remove', $modes, true)) {
                invitation_expect($statuses[1] === 200, 'Removal completed');
                invitation_expect(find_trip_for_user($pdo,2,$tripId) === null, 'Removal wins over stale join');
            } else {
                sort($statuses);
                invitation_expect($statuses === [200,409] || ($modes === ['join','revoke'] && $statuses === [200,404]), 'Exactly one decision succeeds');
                $response = $pdo->query('SELECT response FROM trip_trip_invites LIMIT 1')->fetchColumn();
                invitation_expect((find_trip_for_user($pdo,2,$tripId) !== null) === ($response === 'accepted'), 'Membership matches winning response');
            }
            echo 'PASS invitation race ' . $round . '/' . implode('+', $modes) . "\n";
        } finally {
            foreach ($workers as $w) {
                if ($w === []) continue;
                proc_terminate($w['process']);
                foreach ($w['pipes'] as $pipe) if (is_resource($pipe)) fclose($pipe);
                proc_close($w['process']);
            }
        }
    }
}
echo "PASS: 25 invitation races / 50 requests; $assertions assertions\n";
