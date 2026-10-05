<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/lifecycle_harness.php';
$pdo=credentials_test_db(); reset_lifecycle_schema($pdo);
[$script,$action,$scenario]=$argv;
seed_lifecycle_user($pdo,$action,str_contains($scenario,'social') || $scenario==='identity_failure');
$accessToken = create_access_token_for_user(1, 1);
$request=str_starts_with($scenario,'request');
if (!$request || in_array($scenario,['request_prior','request_mail_failure','request_limit'],true)) {
    seed_lifecycle_proof($pdo,$action);
    if (!$request || $scenario==='request_limit') seed_lifecycle_proof($pdo,$action,'b');
    if ($scenario==='request_limit') seed_lifecycle_proof($pdo,$action,'c');
}
seed_lifecycle_proof($pdo,'delete','e',2);
if ($scenario==='legacy') $pdo->exec('UPDATE trip_account_action_tokens SET credential_state_hash=NULL WHERE user_id=1');
if ($scenario==='expired') $pdo->exec("UPDATE trip_account_action_tokens SET expires_at='2000-01-01' WHERE user_id=1");
if ($scenario==='used') $pdo->exec('UPDATE trip_account_action_tokens SET used_at=UTC_TIMESTAMP() WHERE user_id=1');
if ($scenario==='wrong_purpose') $pdo->exec("UPDATE trip_account_action_tokens SET action='deactivate' WHERE user_id=1");
if ($scenario==='wrong_user') $pdo->exec('UPDATE trip_account_action_tokens SET user_id=2 WHERE user_id=1');
if ($scenario==='changed_email') $pdo->exec("UPDATE trip_users SET email='changed@example.invalid' WHERE id=1");
if ($scenario==='changed_password') $pdo->exec("UPDATE trip_users SET password_hash='changed' WHERE id=1");
if ($scenario==='changed_epoch') $pdo->exec("UPDATE trip_users SET deactivated_at='2026-02-01' WHERE id=1");
if ($scenario==='changed_verification') $pdo->exec("UPDATE trip_users SET email_verified_at='2026-02-01' WHERE id=1");
if (str_ends_with($scenario,'unverified')) $pdo->exec('UPDATE trip_users SET email_verified_at=NULL WHERE id=1');
if (str_ends_with($scenario,'guest')) $pdo->exec('UPDATE trip_users SET credentials_required=1 WHERE id=1');
if (str_ends_with($scenario,'wrong_status')) $pdo->exec("UPDATE trip_users SET account_status='".($action==='delete'?'deactivated':'active')."' WHERE id=1");
if (str_ends_with($scenario,'deleted')) $pdo->exec("UPDATE trip_users SET account_status='deleted',deleted_at=UTC_TIMESTAMP() WHERE id=1");
if ($scenario==='missing_schema') $pdo->exec('ALTER TABLE trip_account_action_tokens DROP COLUMN credential_state_hash');
if ($scenario==='missing_sessions') $pdo->exec('DROP TABLE trip_refresh_tokens');
if ($scenario==='request_anonymous') $accessToken='';
if ($scenario==='request_mail_failure') $mailSucceeds=false;
if (str_ends_with($scenario,'_failure') && !$request) {
    $table=match($scenario) {'session_failure'=>'trip_refresh_tokens','proof_failure'=>'trip_account_action_tokens',
        'push_failure'=>'trip_push_tokens','user_failure'=>'trip_users','friend_failure'=>'trip_friends','identity_failure'=>'trip_user_identities'};
    $operation=in_array($scenario,['friend_failure','identity_failure'],true)?'DELETE':'UPDATE';
    $pdo->exec('CREATE TRIGGER fail_lifecycle BEFORE '.$operation.' ON '.$table.' '
        .($pdo->getAttribute(PDO::ATTR_DRIVER_NAME)==='mysql'
            ? "FOR EACH ROW SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Synthetic failure'"
            : "BEGIN SELECT RAISE(ABORT, 'Synthetic failure'); END"));
}
// Missing-session checks need a snapshot that does not query the intentionally absent table.
function scenario_snapshot(PDO $pdo, string $scenario): array {
    if ($scenario!=='missing_sessions') return lifecycle_snapshot($pdo);
    return ['users'=>$pdo->query('SELECT * FROM trip_users ORDER BY id')->fetchAll(),
        'account_action_tokens'=>$pdo->query('SELECT * FROM trip_account_action_tokens ORDER BY id')->fetchAll()];
}
$before=scenario_snapshot($pdo,$scenario);
$requestBody=$request ? ['email'=>$scenario==='request_unknown'?'unknown@example.invalid':'owner@example.invalid',
    'password'=>str_contains($scenario,'social')?'':' Current-password-123 ', 'recipient'=>'attacker@example.invalid']
    : ['token'=>str_repeat('a',64)];
if ($scenario==='malformed') $requestBody['token']='not-a-proof';
if ($scenario==='newline') $requestBody['token'].="\n";
if ($scenario==='request_wrong_password' || $scenario==='request_social_wrong_password') $requestBody['password']='wrong';
if ($scenario==='request_missing_password') $requestBody['password']='';
$handler=$request ? ($action==='delete'?'request_account_deletion_link_action':'request_reactivation_link_action')
    : ($action==='delete'?'confirm_account_deletion_action':'confirm_reactivation_action');
$failure=false; $second=null;
try {
    $response=credential_test_response($handler);
    if(in_array($scenario,['replay','request_cooldown'],true)) $second=credential_test_response($handler);
    if($scenario==='old_link_after_new_state') {
        // Reconstruct the original state to prove consumption, not only a changed state hash, rejects old links.
        $u=$before['users'][0];
        $pdo->prepare('UPDATE trip_users SET account_status=?,deactivated_at=?,deleted_at=?,email=?,password_hash=?,credentials_required=?,email_verified_at=? WHERE id=1')
            ->execute([$u['account_status'],$u['deactivated_at'],$u['deleted_at'],$u['email'],$u['password_hash'],$u['credentials_required'],$u['email_verified_at']]);
        $requestBody=['token'=>str_repeat('b',64)]; $second=credential_test_response($handler);
    }
} catch (PDOException $e) { $failure=true; $response=null; }
$after=scenario_snapshot($pdo,$scenario);
$ownerProofs=array_values(array_filter($after['account_action_tokens'],fn($r)=>(int)$r['user_id']===1));
echo json_encode(['response'=>$response,'second'=>$second,'failure'=>$failure,'unchanged'=>$before===$after,
    'other_unchanged'=>unrelated_lifecycle_rows($before)===unrelated_lifecycle_rows($after),
    'open'=>$pdo->inTransaction(),'user'=>$after['users'][0],
    'sessions'=>count(array_filter($after['refresh_tokens']??[],fn($r)=>(int)$r['user_id']===1 && $r['revoked_at']===null)),
    'push'=>(int)($after['push_tokens'][0]['is_active']??0),'proofs'=>$ownerProofs,
    'friends'=>count(array_filter($after['friends']??[],fn($r)=>(int)$r['user_a_id']===1 || (int)$r['user_b_id']===1)),
    'identities'=>count(array_filter($after['user_identities']??[],fn($r)=>(int)$r['user_id']===1)),
    'mail'=>count($mail),'recipients'=>array_column($mail,'to'),'mail_body'=>$mail[0]['body']??null],JSON_THROW_ON_ERROR);
