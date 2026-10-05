<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../Fixtures/lifecycle_harness.php';
$pdo=isolated_test_mysql();
$p=proc_open([PHP_BINARY,'vendor/bin/phpunit','--do-not-cache-result','--filter','AccountLifecycleSecurityTest|LifecycleSchemaContractTest'],[STDIN,STDOUT,STDERR],$pipes);
if(!is_resource($p)||proc_close($p)!==0)throw new RuntimeException('Lifecycle regressions failed');
function assert_lifecycle_race(bool $ok,string $message): void
{ if(!$ok)throw new RuntimeException($message); }
$cases=[];
foreach(['delete','reactivate']as $action)foreach(['request','same_link','different_links']as $mode)$cases[]=[$action,$mode];
$cases[]=['delete','cross_action'];
for($round=1;$round<=5;$round++)foreach($cases as [$action,$mode]){
    reset_lifecycle_schema($pdo);seed_lifecycle_user($pdo,$action,true);
    if($mode!=='request'){
        seed_lifecycle_proof($pdo,$action);
        if($mode==='cross_action')seed_deactivation_proof($pdo,'b');
        else seed_lifecycle_proof($pdo,$action,'b');
    }
    seed_lifecycle_proof($pdo,'delete','e',2);
    $other=unrelated_lifecycle_rows(lifecycle_snapshot($pdo));$workers=[];
    try{
        for($i=0;$i<4;$i++){
            $p=proc_open([PHP_BINARY,__DIR__.'/lifecycle_worker.php',$action,$mode,(string)$i],
                [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes);
            assert_lifecycle_race(is_resource($p),'Worker failed to start');
            stream_set_timeout($pipes[1],30);$workers[]=['process'=>$p,'pipes'=>$pipes];
        }
        foreach($workers as $w)assert_lifecycle_race(fgets($w['pipes'][1])==="READY\n",'Worker not ready');
        foreach($workers as $w){fwrite($w['pipes'][0],"GO\n");fflush($w['pipes'][0]);}
        $results=[];
        foreach($workers as &$w){
            $line=fgets($w['pipes'][1]);assert_lifecycle_race(is_string($line),'Missing response');
            $results[]=json_decode($line,true,512,JSON_THROW_ON_ERROR);
            fclose($w['pipes'][0]);fclose($w['pipes'][1]);
            $err=stream_get_contents($w['pipes'][2]);fclose($w['pipes'][2]);
            $exit=proc_close($w['process']);$w=[];
            assert_lifecycle_race($exit===0&&$err==='','Worker failure: '.$err);
        }
        unset($w);
        foreach($results as $r)assert_lifecycle_race(!$r['open']&&in_array($r['status'],[200,400],true),'Unexpected response');
        $success=count(array_filter($results,fn($r)=>$r['status']===200));
        assert_lifecycle_race($success===($mode==='request'?4:1),'More than one confirmation or incorrect request result');
        assert_lifecycle_race(array_sum(array_column($results,'mail'))===($mode==='request'?1:0),'Duplicate email');
        $snapshot=lifecycle_snapshot($pdo);
        assert_lifecycle_race(unrelated_lifecycle_rows($snapshot)===$other,'Other account affected');
        $expected=$mode==='request'?($action==='delete'?'active':'deactivated'):($action==='delete'?'deleted':'active');
        assert_lifecycle_race($mode==='cross_action'?in_array($snapshot['users'][0]['account_status'],['deleted','deactivated'],true)
            :$snapshot['users'][0]['account_status']===$expected,'Unexpected account status');
        $sessions=count(array_filter($snapshot['refresh_tokens'],fn($r)=>(int)$r['user_id']===1&&$r['revoked_at']===null));
        assert_lifecycle_race($sessions===($mode==='request'?2:0),'Wrong refresh state');
        assert_lifecycle_race((int)$snapshot['push_tokens'][0]['is_active']===($mode==='request'?1:0),'Wrong push state');
        $unused=count(array_filter($snapshot['account_action_tokens'],fn($r)=>(int)$r['user_id']===1&&$r['used_at']===null));
        assert_lifecycle_race($unused===($mode==='request'?1:0),'Wrong proof consumption');
        echo "PASS lifecycle race $round/$action/$mode\n";
    }finally{
        foreach($workers as $w){if($w===[])continue;proc_terminate($w['process']);
            foreach($w['pipes']as $pipe)if(is_resource($pipe))fclose($pipe);proc_close($w['process']);}
    }
}
echo "PASS: 35 lifecycle races / 140 synthetic requests\n";
