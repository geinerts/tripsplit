<?php
declare(strict_types=1);
require __DIR__.'/../Fixtures/session_harness.php';
$pdo=isolated_test_mysql();
$p=proc_open([PHP_BINARY,'vendor/bin/phpunit','--do-not-cache-result','--filter','SessionRevocationSecurityTest'],[STDIN,STDOUT,STDERR],$pipes);
if(!is_resource($p)||proc_close($p)!==0)throw new RuntimeException('Session regressions failed');
function check_session_race(bool $ok,string $message): void { if(!$ok)throw new RuntimeException($message); }
for($round=1;$round<=6;$round++)foreach(['reset','deactivate'] as $event) {
    reset_session_schema($pdo);
    $other=$pdo->query('SELECT * FROM trip_refresh_tokens WHERE user_id=2')->fetchAll();
    $workers=[];
    try {
        foreach(['login','refresh',$event] as $mode) {
            $p=proc_open([PHP_BINARY,__DIR__.'/session_worker.php',$mode],
                [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes);
            check_session_race(is_resource($p),'Cannot start worker');
            stream_set_timeout($pipes[1],30);
            $workers[]=['process'=>$p,'pipes'=>$pipes,'mode'=>$mode];
        }
        foreach($workers as $w)check_session_race(fgets($w['pipes'][1])==="READY\n",'Missing worker barrier');
        $order=$round%2?[0,1,2]:[2,1,0];
        foreach($order as $i){fwrite($workers[$i]['pipes'][0],"GO\n");fflush($workers[$i]['pipes'][0]);}
        $results=[];
        foreach($workers as &$w){
            $line=fgets($w['pipes'][1]);check_session_race(is_string($line),'No worker result');
            $r=json_decode($line,true,512,JSON_THROW_ON_ERROR);
            fclose($w['pipes'][0]);fclose($w['pipes'][1]);
            $err=stream_get_contents($w['pipes'][2]);fclose($w['pipes'][2]);
            $exit=proc_close($w['process']);$mode=$w['mode'];$w=[];
            check_session_race($exit===0&&$err==='','Worker error: '.$err);
            check_session_race(!$r['open'],'Open transaction');
            check_session_race(in_array($r['status'],[200,401,403],true),'Unexpected response');
            if($mode===$event)check_session_race($r['status']===200,'Security event did not succeed');
            $results[]=$r;
        }
        unset($w);
        foreach($results as $r)if($r['auth']) {
            check_session_race(resolve_user_id_from_access_token($r['auth']['access_token'],$pdo)===0,'Access survived event');
            check_session_race(rotate_refresh_token($pdo,$r['auth']['refresh_token'])===null,'Refresh survived event');
        }
        check_session_race((int)$pdo->query('SELECT COUNT(*) FROM trip_refresh_tokens WHERE user_id=1 AND revoked_at IS NULL')->fetchColumn()===0,'Active session remains');
        check_session_race($pdo->query('SELECT * FROM trip_refresh_tokens WHERE user_id=2')->fetchAll()===$other,'Other account changed');
        echo "PASS session race $round/$event: login + refresh + security event\n";
    } finally {
        foreach($workers as $w){if($w===[])continue;proc_terminate($w['process']);
            foreach($w['pipes']as $pipe)if(is_resource($pipe))fclose($pipe);proc_close($w['process']);}
    }
}
echo "PASS: 12 session races / 36 synthetic requests\n";
