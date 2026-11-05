<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/credentials_harness.php';
require __DIR__ . '/../../lib/actions/account_lifecycle_actions.php';
require __DIR__ . '/../../lib/helpers/helper_social_auth.php';
function build_account_delete_email(string $url, string $name): string { return $url; }

define('RATE_LIMIT_MUTATION_WINDOW_SEC', 300);
function push_tokens_table_available(PDO $pdo): bool { return true; }
function reset_base_lifecycle_schema(PDO $pdo): void
{
    reset_credentials_test_schema($pdo);
    $pdo->exec('ALTER TABLE trip_users ADD COLUMN avatar_path VARCHAR(255) NULL');
    $pdo->exec('ALTER TABLE trip_users ADD COLUMN deactivated_at DATETIME NULL');
    $pdo->exec('DROP TABLE IF EXISTS trip_account_action_tokens');
    $pdo->exec('DROP TABLE IF EXISTS trip_push_tokens');
    $mysql = $pdo->getAttribute(PDO::ATTR_DRIVER_NAME) === 'mysql';
    $id = $mysql ? 'BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
    $action = $mysql ? "ENUM('reactivate','delete')" : 'TEXT';
    $pdo->exec('CREATE TABLE trip_account_action_tokens (id ' . $id . ', user_id INT NOT NULL,
        action ' . $action . ', token_hash CHAR(64) UNIQUE, expires_at DATETIME,
        used_at DATETIME NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
    if ($mysql) {
        $pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-04-deactivation-email-proof.sql'));
    } else { $pdo->exec('ALTER TABLE trip_account_action_tokens ADD COLUMN credential_state_hash CHAR(64) NULL'); }
    $pdo->exec('CREATE TABLE trip_push_tokens (id ' . $id . ', user_id INT, is_active INT DEFAULT 1,
        updated_at DATETIME NULL)');
    $pdo->exec('INSERT INTO trip_push_tokens (user_id) VALUES (1), (2)');
}
function base_lifecycle_snapshot(PDO $pdo): array
{
    $rows = [];
    foreach (['users', 'refresh_tokens', 'account_action_tokens', 'push_tokens'] as $table) {
        $rows[$table] = $pdo->query('SELECT * FROM trip_' . $table . ' ORDER BY id')->fetchAll();
    }
    return $rows;
}

function reset_lifecycle_schema(PDO $pdo): void
{
    reset_base_lifecycle_schema($pdo);
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
    $rows = base_lifecycle_snapshot($pdo);
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
