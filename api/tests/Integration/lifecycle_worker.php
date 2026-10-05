<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../Fixtures/lifecycle_harness.php';
$pdo=isolated_test_mysql();
[$script,$action,$mode,$index]=$argv;
$accessToken = create_access_token_for_user(1, 1);
$requestBody=$mode==='request' ? ['email'=>'owner@example.invalid']
    : ['token'=>str_repeat(($mode==='different_links'||$mode==='cross_action') && (int)$index%2 ? 'b':'a',64)];
$handler=$mode==='request'
    ? ($action==='delete'?'request_account_deletion_link_action':'request_reactivation_link_action')
    : ($action==='delete'?'confirm_account_deletion_action':'confirm_reactivation_action');
if($mode==='cross_action' && (int)$index%2)$handler='confirm_deactivation_action';
echo "READY\n";flush();
if(trim((string)fgets(STDIN))!=='GO')throw new RuntimeException('Missing barrier');
$r=credential_test_response($handler);
echo json_encode(['status'=>$r['status'],'mail'=>count($mail),'open'=>$pdo->inTransaction()]),"\n";
