<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/deactivation_harness.php';
$pdo = isolated_test_mysql();
$p = proc_open([PHP_BINARY, 'vendor/bin/phpunit', '--do-not-cache-result', '--filter', 'DeactivationSecurityTest'], [STDIN,STDOUT,STDERR], $pipes);
if (!is_resource($p) || proc_close($p) !== 0) { throw new RuntimeException('Deactivation regressions failed'); }
function assert_deactivation_race(bool $ok, string $message): void
{ if (!$ok) { throw new RuntimeException($message); } }
for ($round = 1; $round <= 5; $round++) {
    foreach (['request','same_link','different_links'] as $mode) {
        reset_deactivation_schema($pdo); seed_credential_user($pdo, 'social');
        if ($mode !== 'request') { seed_deactivation_proof($pdo); seed_deactivation_proof($pdo, 'b'); }
        $workers = [];
        try {
            for ($i = 0; $i < 4; $i++) {
                $p = proc_open([PHP_BINARY, __DIR__ . '/deactivation_worker.php', $mode, (string)$i],
                    [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
                assert_deactivation_race(is_resource($p), 'Worker failed to start');
                stream_set_timeout($pipes[1],30); $workers[]=['process'=>$p,'pipes'=>$pipes];
            }
            foreach ($workers as $w) { assert_deactivation_race(fgets($w['pipes'][1]) === "READY\n", 'Worker not ready'); }
            foreach ($workers as $w) { fwrite($w['pipes'][0],"GO\n"); fflush($w['pipes'][0]); }
            $results=[];
            foreach ($workers as &$w) {
                $line=fgets($w['pipes'][1]); assert_deactivation_race(is_string($line),'Missing response');
                $results[]=json_decode($line,true,512,JSON_THROW_ON_ERROR);
                fclose($w['pipes'][0]); fclose($w['pipes'][1]);
                $error=stream_get_contents($w['pipes'][2]); fclose($w['pipes'][2]);
                $exit=proc_close($w['process']); $w=[];
                assert_deactivation_race($exit===0 && $error==='','Worker failure: '.$error);
            }
            unset($w);
            foreach($results as $r) { assert_deactivation_race(!$r['open'],'Open transaction'); }
            $success=count(array_filter($results,fn($r)=>$r['status']===200));
            assert_deactivation_race($success === ($mode==='request'?4:1),'Unexpected success count');
            assert_deactivation_race(array_sum(array_column($results,'mail')) === ($mode==='request'?1:0),'Unexpected delivery count');
            foreach($results as $r) { assert_deactivation_race(in_array($r['status'],[200,400],true),'Unexpected response'); }
            $snapshot=deactivation_snapshot($pdo);
            assert_deactivation_race($snapshot['users'][0]['account_status'] === ($mode==='request'?'active':'deactivated'),'Incorrect account status');
            $sessions=count(array_filter($snapshot['refresh_tokens'],fn($r)=>(int)$r['user_id']===1 && $r['revoked_at']===null));
            assert_deactivation_race($sessions===($mode==='request'?2:0),'Incorrect session state');
            assert_deactivation_race((int)$snapshot['push_tokens'][0]['is_active']===($mode==='request'?1:0),'Incorrect push state');
            assert_deactivation_race($snapshot['refresh_tokens'][2]['revoked_at']===null && (int)$snapshot['push_tokens'][1]['is_active']===1,'Other user affected');
            echo "PASS deactivation race $round/$mode\n";
        } finally {
            foreach($workers as $w) {
                if($w===[])continue;
                proc_terminate($w['process']);
                foreach($w['pipes'] as $pipe) { if(is_resource($pipe))fclose($pipe); }
                proc_close($w['process']);
            }
        }
    }
}
echo "PASS: 15 deactivation races / 60 synthetic requests\n";
