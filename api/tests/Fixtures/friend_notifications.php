<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/isolated_mysql.php';
require __DIR__ . '/../../lib/helpers/helper_trip.php';
require __DIR__ . '/../../lib/helpers/helper_pagination.php';
require __DIR__ . '/../../lib/actions/notifications_actions.php';
require __DIR__ . '/../../lib/actions/friends/friends_helpers.php';
require __DIR__ . '/../../lib/actions/friends/friends_mutations.php';
foreach (['RATE_LIMIT_FRIENDS_INVITE_IP_MAX','RATE_LIMIT_FRIENDS_INVITE_USER_MAX','RATE_LIMIT_MUTATION_WINDOW_SEC','RATE_LIMIT_SEARCH_IP_MAX','RATE_LIMIT_SEARCH_USER_MAX','RATE_LIMIT_SEARCH_WINDOW_SEC'] as $key) define($key, 100);
class Response extends RuntimeException {
    public function __construct(public array $payload, public int $status) { parent::__construct(); }
}
function json_out(array $payload, int $status = 200): void { throw new Response($payload, $status); }
function table_name(string $key): string { return 'trip_' . $key; }
function db(): PDO { return $GLOBALS['pdo']; }
function get_me(): array { return ['id'=>$GLOBALS['actor'], 'nickname'=>'User '.$GLOBALS['actor']]; }
function require_post(): void {}
function read_json(): array { return $GLOBALS['body']; }
function client_ip_address(): string { return '192.0.2.1'; }
function enforce_rate_limit(...$args): void {}
function users_name_columns_available(PDO $pdo): bool { return false; }
function users_active_filter_sql(...$args): string { return ''; }
function normalize_me_name_value($value): ?string { return $value ?: null; }
function combine_full_name($first, $last): ?string { return null; }
function me_display_name(array $user): string { return $user['nickname']; }
function normalize_user_ids(array $ids): array { return array_values(array_unique(array_filter(array_map('intval', $ids), fn($id)=>$id>0))); }
function push_should_queue_notification_type(string $type): bool { return true; }
function user_allows_push_notification(...$args): bool { return true; }
function queue_push_notification(...$args): void { $GLOBALS['pushes'][] = $args; }
function log_api_exception(...$args): void { throw new RuntimeException('Unexpected push failure'); }
function app_event(...$args): void {}
class_alias(class_exists('Pdo\\Sqlite') ? 'Pdo\\Sqlite' : PDO::class, 'FriendSQLiteBase');
class FriendSQLite extends FriendSQLiteBase {
    public function prepare(string $query, array $options = []): PDOStatement|false {
        return parent::prepare(str_replace(['FOR UPDATE', 'UTC_TIMESTAMP()'], ['', 'CURRENT_TIMESTAMP'], $query), $options);
    }
}
$mysql = getenv('SPLYTO_ISOLATED_MYSQL') === '1';
$pdo = $mysql ? isolated_test_mysql() : new FriendSQLite('sqlite::memory:', null, null,
    [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
if ($mysql) {
    foreach (['trip_notifications','trip_friends','trip_trips','trip_users'] as $table) $pdo->exec('DROP TABLE IF EXISTS '.$table);
} else {
    $pdo->exec('PRAGMA foreign_keys=ON');
}
$idType = $mysql ? 'INT UNSIGNED' : 'INTEGER';
$id = $idType . ' PRIMARY KEY ' . ($mysql ? 'AUTO_INCREMENT' : 'AUTOINCREMENT');
$pdo->exec('CREATE TABLE trip_users (id '.$idType.' PRIMARY KEY, nickname VARCHAR(64), avatar_path TEXT)');
$pdo->exec('INSERT INTO trip_users VALUES (1,"One",NULL),(2,"Two",NULL),(3,"Three",NULL)');
$pdo->exec('CREATE TABLE trip_friends (id '.$id.',user_a_id INT,user_b_id INT,requested_by INT,status VARCHAR(20),responded_at TIMESTAMP NULL,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,UNIQUE(user_a_id,user_b_id))');
$pdo->exec('CREATE TABLE trip_trips (id '.$idType.' PRIMARY KEY,name TEXT)');
$pdo->exec('CREATE TABLE trip_notifications (id '.$id.',trip_id '.$idType.($mysql ? ' NOT NULL' : ' NULL').',user_id '.$idType.',type VARCHAR(48),title TEXT,body TEXT,payload_json '.($mysql ? 'JSON' : 'TEXT').',is_read INT DEFAULT 0,read_at TIMESTAMP NULL,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(trip_id) REFERENCES trip_trips(id), FOREIGN KEY(user_id) REFERENCES trip_users(id))');
$migration = __DIR__.'/../../../sql/migrations/2026-10-23-persist-friend-notifications.sql';
if ($mysql) $pdo->exec(file_get_contents($migration));
$pushes=[]; $assertions=0;
function check(bool $ok): void { if (!$ok) throw new RuntimeException('Assertion failed at '.json_encode(debug_backtrace(DEBUG_BACKTRACE_IGNORE_ARGS,1))); $GLOBALS['assertions']++; }
function callAction(string $name, int $actor, array $body=[], array $query=[]): array {
    $GLOBALS['actor']=$actor; $GLOBALS['body']=$body; $_GET=$query;
    try { $name(); } catch (Response $r) { return [$r->status,$r->payload]; }
    throw new RuntimeException('Missing response');
}
function inbox(int $actor, array $query=[]): array { return callAction('list_notifications_global_action',$actor,[],['paged'=>1]+$query)[1]; }
// A new account with no trips receives one durable notification and one push.
check(callAction('send_friend_invite_action',1,['user_id'=>2])[0]===200);
$first=inbox(2); $id=$first['notifications'][0]['id'];
check($id>0 && $first['unread_count']===1 && count($first['notifications'])===1);
check($first['notifications'][0]['trip_id']===0 && count($pushes)===1);
check(callAction('send_friend_invite_action',1,['user_id'=>2])[0]===409);
check(count(inbox(2)['notifications'])===1 && count($pushes)===1);
// Reading does not accept the invitation; the badge stays clear on reload.
check(callAction('mark_notifications_read_global_action',2)[1]['unread_count']===0);
check(inbox(2)['pending_friend_invites_count']===1 && inbox(2)['unread_count']===0);
check(callAction('respond_friend_invite_action',2,['request_id'=>1,'accept'=>true])[0]===200);
check(inbox(2)['notifications'][0]['id']===$id && inbox(2)['notifications'][0]['is_read']);
check(inbox(1)['notifications'][0]['type']==='friend_invite_accepted' && count($pushes)===2);
// Wrong recipient cannot read another account's notifications.
callAction('mark_notifications_read_global_action',3,['notification_ids'=>[inbox(1)['notifications'][0]['id']]]);
check(inbox(1)['unread_count']===1);
check(callAction('mark_notifications_read_global_action',1,['notification_ids'=>[-1]])[0]===400);
check(inbox(1)['unread_count']===1);
// Removing and re-inviting preserves prior history and creates a new event.
callAction('remove_friend_action',1,['user_id'=>2]);
callAction('send_friend_invite_action',1,['user_id'=>2]);
check(count(inbox(2)['notifications'])===2 && inbox(2)['unread_count']===1);
// Reciprocal invite accepts without a shared trip and consumes the unread invite.
check(callAction('send_friend_invite_action',2,['user_id'=>1])[1]['auto_accepted']);
check(inbox(2)['unread_count']===0 && count(inbox(2)['notifications'])===2);
// Cancellation retains history without an outstanding unread badge.
callAction('send_friend_invite_action',1,['user_id'=>3]);
callAction('cancel_friend_invite_action',1,['request_id'=>2]);
check(count(inbox(3)['notifications'])===1 && inbox(3)['unread_count']===0);
// Cursor and legacy lists both use durable rows without synthetic duplicates.
$page=inbox(2,['limit'=>1]);
check($page['pagination']['has_more'] && count($page['notifications'])===1);
$next=inbox(2,['limit'=>1,'cursor'=>$page['pagination']['next_cursor']]);
check($next['notifications'][0]['id']===$id && !$next['pagination']['has_more']);
$legacy=callAction('list_notifications_global_action',2)[1];
check(count($legacy['notifications'])===2 && $legacy['unread_count']===0);
if ($mysql) {
    // Simulate the legacy synthetic-only inbox, then replay the real migration.
    callAction('send_friend_invite_action',1,['user_id'=>3]);
    $pdo->exec('DELETE FROM trip_notifications WHERE type="friend_invite_received"');
    $pdo->exec(file_get_contents($migration));
    check(count(inbox(2)['notifications'])===1 && inbox(2)['unread_count']===0);
    check(count(inbox(3)['notifications'])===1 && inbox(3)['unread_count']===1);
    $pdo->exec(file_get_contents($migration));
    check(count(inbox(2)['notifications'])===1 && count(inbox(3)['notifications'])===1);
}
echo json_encode(['assertions'=>$assertions]);
