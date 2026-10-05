<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/deactivation_harness.php';
require __DIR__ . '/../../lib/helpers/helper_social_auth.php';
function build_account_delete_email(string $url, string $name): string { return $url; }
function build_account_reactivation_email(string $url, string $name): string { return $url; }

function reset_lifecycle_schema(PDO $pdo): void
{
    reset_deactivation_schema($pdo);
    $pdo->exec('ALTER TABLE trip_users ADD COLUMN deleted_at DATETIME NULL');
    foreach (['bank_country_code','bank_account_holder','bank_account_number','bank_iban','bank_bic',
        'bank_sort_code','bank_routing_number','revolut_handle','revolut_me_link','paypal_me_link','wise_pay_link'] as $field) {
        $pdo->exec('ALTER TABLE trip_users ADD COLUMN '.$field.' VARCHAR(255) NULL');
    }
    $pdo->exec('DROP TABLE IF EXISTS trip_friends');
    $pdo->exec('DROP TABLE IF EXISTS trip_user_identities');
    $pdo->exec('CREATE TABLE trip_friends (id INT PRIMARY KEY, user_a_id INT, user_b_id INT)');
    $pdo->exec('CREATE TABLE trip_user_identities (id INT PRIMARY KEY, user_id INT, provider VARCHAR(20), provider_subject VARCHAR(191))');
}
function seed_lifecycle_user(PDO $pdo, string $action, bool $social = false): void
{
    seed_credential_user($pdo, $social ? 'social' : 'established');
    $pdo->exec("UPDATE trip_users SET bank_iban='synthetic-bank-account', wise_pay_link='synthetic-payment-link'");
    if ($action === 'reactivate') {
        $pdo->exec("UPDATE trip_users SET account_status='deactivated', deactivated_at='2026-01-01 00:00:00' WHERE id=1");
    }
    $pdo->exec('INSERT INTO trip_friends VALUES (1,1,2),(2,2,3)');
    $pdo->exec("INSERT INTO trip_user_identities VALUES (2,2,'google','unrelated')");
    if ($social) $pdo->exec("INSERT INTO trip_user_identities VALUES (1,1,'apple','synthetic-owner')");
}
function seed_lifecycle_proof(PDO $pdo, string $action, string $char = 'a', int $userId = 1): void
{
    $user = fetch_me_row_by_id($pdo, $userId);
    $pdo->prepare('INSERT INTO trip_account_action_tokens
        (user_id,action,token_hash,credential_state_hash,expires_at,created_at) VALUES (?,?,?,?,?,?)')
        ->execute([$userId,$action,hash('sha256',str_repeat($char,64)),account_action_proof_state($user,$action),
            gmdate('Y-m-d H:i:s',time()+3600),gmdate('Y-m-d H:i:s',time()-120)]);
}
function lifecycle_snapshot(PDO $pdo): array
{
    $rows = deactivation_snapshot($pdo);
    foreach (['friends','user_identities'] as $name) $rows[$name]=$pdo->query('SELECT * FROM trip_'.$name.' ORDER BY id')->fetchAll();
    return $rows;
}
function unrelated_lifecycle_rows(array $snapshot): array
{
    $result=[];
    foreach($snapshot as $table=>$rows) {
        $result[$table]=array_values(array_filter($rows,static fn($r)=>$table==='users'
            ? (int)$r['id']!==1 : ($table==='friends'
                ? (int)$r['user_a_id']!==1 && (int)$r['user_b_id']!==1 : (int)$r['user_id']!==1)));
    }
    return $result;
}
