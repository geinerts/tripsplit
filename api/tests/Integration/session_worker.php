<?php
declare(strict_types=1);
require __DIR__.'/../Fixtures/session_harness.php';
$pdo=isolated_test_mysql();
$mode=$argv[1];
$accessToken=create_access_token_for_user(1,1);
echo "READY\n"; flush();
if (trim((string)fgets(STDIN)) !== 'GO') throw new RuntimeException('Missing barrier');
if ($mode==='login') {
    $requestBody=['email'=>'owner@example.invalid','password'=>' Current-password-123 '];
    $result=credential_test_response('login_action');
} elseif ($mode==='refresh') {
    $r=rotate_refresh_token($pdo,str_repeat('1',96));
    $result=['status'=>$r?200:401,'payload'=>$r??[]];
} else {
    $result=session_event($mode);
}
echo json_encode(['status'=>$result['status'],'auth'=>$result['payload']['auth']??null,
    'open'=>$pdo->inTransaction()],JSON_THROW_ON_ERROR),"\n";
