<?php
declare(strict_types=1);
// Real comment handlers on the isolated SQLite harness. No live config or network.
foreach (['core', 'algorithm', 'payments', 'payload', 'actions'] as $part) {
    require __DIR__ . '/../../lib/actions/settlements/settlements_' . $part . '.php';
}
require __DIR__ . '/../../lib/actions/expense_social_actions.php';
require __DIR__ . '/trip_invitations.php';
require __DIR__ . '/../../lib/helpers/push/push_localization.php';
require __DIR__ . '/../../lib/helpers/helper_notification_preferences.php';

define('RATE_LIMIT_COMMENT_WRITE_IP_MAX', 100);
define('RATE_LIMIT_COMMENT_WRITE_USER_MAX', 100);

$pdo = invitation_test_setup(false);
$GLOBALS['pdo'] = $pdo;
$actor = 1;
$body = [];
$assertions = 0;
$pdo->exec(file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-26-add-trip-budget.sql'));
$pdo->exec('ALTER TABLE trip_trips ADD COLUMN destinations_json TEXT NULL');
$pdo->exec('ALTER TABLE trip_expenses ADD COLUMN note VARCHAR(255) NULL');
$pdo->exec('CREATE TABLE trip_expense_comments (id INTEGER PRIMARY KEY AUTOINCREMENT, expense_id INT, trip_id INT, user_id INT, parent_comment_id INT NULL, body TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
$pdo->exec('CREATE TABLE trip_app_events (id INTEGER PRIMARY KEY AUTOINCREMENT, trip_id INT, user_id INT, event_type VARCHAR(64), entity_type VARCHAR(32), entity_id INT, payload_json TEXT, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)');
$pdo->exec('CREATE TABLE trip_expense_comment_mentions (comment_id INT, user_id INT, mention_text VARCHAR(191), is_active INT DEFAULT 1, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY (comment_id, user_id))');
$pdo->exec('UPDATE trip_users SET first_name="Anna", last_name="Bērziņa" WHERE id=2');
$pdo->exec('INSERT INTO trip_users(id,nickname,account_status) VALUES (4,"Nia","active"),(5,"Gone","deleted")');

$id = (int) invitation_call('create_trip_action', 1, ['name'=>'Greece'])['body']['trip']['id'];
$other = (int) invitation_call('create_trip_action', 3, ['name'=>'Other'])['body']['trip']['id'];
$_GET['trip_id'] = $id;
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ('.$id.',2,"member"),('.$id.',4,"member"),('.$id.',5,"member")');
$pdo->exec('INSERT INTO trip_expenses(id,trip_id,paid_by,note) VALUES (5,'.$id.',1,"Dinner"),(6,'.$id.',1,NULL)');

$notifications = static function () use ($pdo): array {
    $rows = $pdo->query('SELECT user_id, type, title, body, payload_json FROM trip_notifications
        WHERE type="expense_comment_mention" ORDER BY id')->fetchAll();
    $pdo->exec('DELETE FROM trip_notifications WHERE type="expense_comment_mention"');
    return array_map(static fn(array $row): array => [
        'user_id' => (int) $row['user_id'],
        'title' => $row['title'],
        'body' => $row['body'],
        'payload' => json_decode((string) $row['payload_json'], true),
    ], $rows);
};
$add = static fn(array $input, int $user = 1): array => invitation_call(
    'add_expense_comment_action', $user, ['expense_id'=>5] + $input
);
$edit = static fn(int $commentId, array $input): array => invitation_call(
    'update_expense_comment_action', 1, ['comment_id'=>$commentId, 'expense_id'=>5] + $input
);

$results = [];
$created = $add(['body'=>'Hi @anna bērziņa and @Nia', 'mentioned_user_ids'=>[2, 4, 4, '4']]);
$results['created'] = $created['body']['comment'];
$results['created_notifications'] = $notifications();
$commentId = (int) $created['body']['comment']['id'];

$results['foreign_ids'] = $add([
    'body' => '@Other and @Gone and @Nia and @Owner', 'mentioned_user_ids' => [3, 5, 999, -1, 'x', [2], 1],
])['body']['comment']['mentions'];
$results['foreign_notifications'] = $notifications();
$results['id_without_text'] = $add(['body'=>'No tag, not even @Niall', 'mentioned_user_ids'=>[4, 2]])['body']['comment']['mentions'];
$results['id_without_text_notifications'] = $notifications();
$results['bad_type'] = $add(['body'=>'@Nia', 'mentioned_user_ids'=>'4'])['body']['comment']['mentions'];
$results['no_field'] = $add(['body'=>'@Nia'])['body']['comment']['mentions'];
$results['bad_notifications'] = $notifications();

$reply = $add(['body'=>'@Owner see this', 'mentioned_user_ids'=>[1], 'parent_comment_id'=>$commentId], 2);
$results['reply'] = $reply['body']['comment'];
$results['reply_notifications'] = $notifications();

$results['note_free'] = invitation_call('add_expense_comment_action', 1, [
    'expense_id'=>6, 'body'=>'@Nia', 'mentioned_user_ids'=>[4],
])['status'];
$results['note_free_notifications'] = $notifications();

$results['edit_absent'] = $edit($commentId, ['body'=>'Hi @Nia and @Anna Bērziņa!'])['body']['comment']['mentions'];
$results['edit_absent_notifications'] = $notifications();
$results['edit_remove'] = $edit($commentId, ['body'=>'Hi @Nia', 'mentioned_user_ids'=>[4]])['body']['comment']['mentions'];
$results['edit_remove_notifications'] = $notifications();
$results['edit_readd'] = $edit($commentId, ['body'=>'Hi @Nia, @Anna Bērziņa', 'mentioned_user_ids'=>[2, 4]])['body']['comment']['mentions'];
$results['edit_readd_notifications'] = $notifications();

$pdo->exec('UPDATE trip_users SET first_name="Anna", last_name="Ozola" WHERE id=2');
$results['after_rename'] = $edit($commentId, ['body'=>'Hello @Anna Bērziņa', 'mentioned_user_ids'=>[2]])['body']['comment']['mentions'];
$pdo->exec('UPDATE trip_users SET first_name="Anna", last_name="Bērziņa" WHERE id=2');

$results['edit_new'] = $edit($commentId, ['body'=>'Hello @Anna Bērziņa, @Other', 'mentioned_user_ids'=>[2, 3]])['body']['comment']['mentions'];
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ('.$id.',3,"member")');
$results['edit_new_member'] = $edit($commentId, ['body'=>'Hello @Other', 'mentioned_user_ids'=>[3]])['body']['comment']['mentions'];
$results['edit_new_member_notifications'] = $notifications();

$_GET['expense_id'] = 5;
$results['list'] = invitation_call('list_expense_comments_action', 1)['body']['comments'];

$results['push_lv'] = push_localize_notification_for_locale(
    ['type'=>'expense_comment_mention', 'title'=>'You were mentioned in a comment', 'body'=>'Owner mentioned you in a comment on "Dinner".'], 'lv'
);
$results['push_lv_generic'] = push_localize_notification_for_locale(
    ['type'=>'expense_comment_mention', 'title'=>'You were mentioned in a comment', 'body'=>'Owner mentioned you in a comment.'], 'lv'
);
// The payer hears about comments on their expense, except their own or ones that mention them.
$pdo->exec('DELETE FROM trip_notifications');
$commentAdded = static function () use ($pdo): array {
    $rows = $pdo->query('SELECT user_id, type, title, body, payload_json FROM trip_notifications ORDER BY id')->fetchAll();
    $pdo->exec('DELETE FROM trip_notifications');
    return array_map(static fn(array $row): array => [
        'user_id' => (int) $row['user_id'],
        'type' => $row['type'],
        'title' => $row['title'],
        'body' => $row['body'],
        'payload' => json_decode((string) $row['payload_json'], true),
    ], $rows);
};
$plain = $add(['body'=>'Great dinner'], 2);
$results['comment_added'] = $commentAdded();
$results['comment_added_id'] = (int) $plain['body']['comment']['id'];
$add(['body'=>'Thanks all']);
$results['comment_by_payer'] = $commentAdded();
$add(['body'=>'@Owner look', 'mentioned_user_ids'=>[1]], 2);
$results['comment_mentions_payer'] = $commentAdded();
invitation_call('add_expense_comment_action', 4, ['expense_id'=>6, 'body'=>'Nice']);
$results['comment_added_no_note'] = $commentAdded();
$edit($results['comment_added_id'], ['body'=>'Great dinner!']);
$results['comment_edit'] = $commentAdded();
$results['comment_added_push_pref'] = notification_push_pref_key_for_type('expense_comment_added');
$results['comment_added_in_app_pref'] = notification_in_app_pref_key_for_type('expense_comment_added');
$results['comment_added_actor'] = notification_actor_user_id(['type'=>'expense_comment_added', 'payload'=>['commented_by_user_id'=>4]]);
$results['comment_added_push_lv'] = push_localize_notification_for_locale(
    ['type'=>'expense_comment_added', 'title'=>'New comment on your expense', 'body'=>'Nia commented on "Dinner".'], 'lv'
);

$results['in_app_pref'] = notification_in_app_pref_key_for_type('expense_comment_mention');
$results['push_pref'] = notification_push_pref_key_for_type('expense_comment_mention');
$results['actor'] = notification_actor_user_id(['type'=>'expense_comment_mention', 'payload'=>['mentioned_by_user_id'=>7]]);

echo json_encode($results, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE);
