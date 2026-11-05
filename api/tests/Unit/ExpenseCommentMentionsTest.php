<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class ExpenseCommentMentionsTest extends TestCase
{
    private static array $r;

    public static function setUpBeforeClass(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__.'/../Fixtures/expense_comment_mentions.php'],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors.$output);
        self::$r = json_decode($output, true, 512, JSON_THROW_ON_ERROR);
    }

    private static function userIds(array $rows): array
    {
        $ids = array_column($rows, 'user_id');
        sort($ids);
        return $ids;
    }

    public function test_new_comment_stores_text_as_written_and_notifies_each_member(): void
    {
        self::assertEqualsCanonicalizing(
            [['user_id'=>2, 'name'=>'anna bērziņa'], ['user_id'=>4, 'name'=>'Nia']],
            self::$r['created']['mentions']
        );
        self::assertSame([2, 4], self::userIds(self::$r['created_notifications']));
        $first = self::$r['created_notifications'][0];
        self::assertSame('You were mentioned in a comment', $first['title']);
        self::assertSame('Owner mentioned you in a comment on "Dinner".', $first['body']);
        self::assertSame(5, $first['payload']['expense_id']);
        self::assertSame((int) self::$r['created']['id'], $first['payload']['comment_id']);
        self::assertSame(1, $first['payload']['mentioned_by_user_id']);
        self::assertStringNotContainsString('Hi @', json_encode(self::$r['created_notifications'], JSON_THROW_ON_ERROR));
    }

    public function test_ids_outside_the_trip_and_inactive_users_are_ignored_and_self_is_not_notified(): void
    {
        self::assertSame([1], self::userIds(self::$r['foreign_ids']));
        self::assertSame([], self::$r['foreign_notifications']);
    }

    public function test_id_requires_the_name_in_the_text_outside_a_longer_word(): void
    {
        self::assertSame([], self::$r['id_without_text']);
        self::assertSame([], self::$r['id_without_text_notifications']);
    }

    public function test_invalid_or_absent_field_is_a_plain_comment(): void
    {
        self::assertSame([], self::$r['bad_type']);
        self::assertSame([], self::$r['no_field']);
        self::assertSame([], self::$r['bad_notifications']);
    }

    public function test_reply_mentions_and_notifies_like_a_comment(): void
    {
        self::assertNotNull(self::$r['reply']['parent_comment_id']);
        self::assertSame([['user_id'=>1, 'name'=>'Owner']], self::$r['reply']['mentions']);
        self::assertSame([1], self::userIds(self::$r['reply_notifications']));
        self::assertSame('Anna Bērziņa mentioned you in a comment on "Dinner".', self::$r['reply_notifications'][0]['body']);
    }

    public function test_expense_without_note_uses_the_generic_sentence(): void
    {
        self::assertSame('Owner mentioned you in a comment.', self::$r['note_free_notifications'][0]['body']);
    }

    public function test_old_client_edit_keeps_mentions_unchanged(): void
    {
        self::assertSame([2, 4], self::userIds(self::$r['edit_absent']));
        self::assertSame([], self::$r['edit_absent_notifications']);
    }

    public function test_edit_removes_mentions_and_never_notifies_the_same_person_twice(): void
    {
        self::assertSame([4], self::userIds(self::$r['edit_remove']));
        self::assertSame([], self::$r['edit_remove_notifications']);
        self::assertSame([2, 4], self::userIds(self::$r['edit_readd']));
        self::assertSame([], self::$r['edit_readd_notifications']);
    }

    public function test_stored_text_survives_a_rename(): void
    {
        self::assertSame([['user_id'=>2, 'name'=>'Anna Bērziņa']], self::$r['after_rename']);
    }

    public function test_edit_notifies_only_a_newly_mentioned_member(): void
    {
        self::assertSame([2], self::userIds(self::$r['edit_new']));
        self::assertSame([3], self::userIds(self::$r['edit_new_member']));
        self::assertSame([3], self::userIds(self::$r['edit_new_member_notifications']));
    }

    public function test_list_returns_active_mentions_per_comment(): void
    {
        $byId = array_column(self::$r['list'], 'mentions', 'id');
        self::assertSame([['user_id'=>3, 'name'=>'Other']], $byId[(int) self::$r['created']['id']]);
        self::assertSame([['user_id'=>1, 'name'=>'Owner']], $byId[(int) self::$r['reply']['id']]);
    }

    public function test_push_text_is_localized_and_follows_trip_updates_preferences(): void
    {
        self::assertSame('Tevi pieminēja komentārā', self::$r['push_lv']['title']);
        self::assertSame('Owner tevi pieminēja komentārā pie "Dinner".', self::$r['push_lv']['body']);
        self::assertSame('Owner tevi pieminēja komentārā.', self::$r['push_lv_generic']['body']);
        self::assertSame('in_app_trip_updates_enabled', self::$r['in_app_pref']);
        self::assertSame('push_trip_updates_enabled', self::$r['push_pref']);
        self::assertSame(7, self::$r['actor']);
    }
}
