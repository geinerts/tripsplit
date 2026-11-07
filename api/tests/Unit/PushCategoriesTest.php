<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class PushCategoriesTest extends TestCase
{
    public function test_type_mapping_covers_every_category(): void
    {
        $expected = [
            'expense_added' => 'push_expense_added_enabled',
            'friend_invite_accepted' => 'push_friend_invites_enabled',
            'expense_comment_mention' => 'push_comments_enabled',
            'expense_comment_added' => 'push_comments_enabled',
            'trip_invitation' => 'push_trip_invites_enabled',
            'trip_member_removed' => 'push_trip_invites_enabled',
            'trip_ready_to_settle' => 'push_trip_status_enabled',
            'payment_requested' => 'push_payment_requests_enabled',
            'settlement_sent_cancelled' => 'push_payments_enabled',
            'settlement_reminder' => 'push_reminders_enabled',
            'something_new' => null,
        ];
        foreach ($expected as $type => $key) {
            self::assertSame($key, notification_push_pref_key_for_type($type), $type);
        }
        $defaults = notification_preferences_defaults();
        foreach (array_keys(notification_push_category_parents()) as $key) {
            self::assertTrue($defaults[$key], $key);
        }
    }

    public function test_preferences_and_migration_on_mysql(): void
    {
        if (getenv('SPLYTO_ISOLATED_MYSQL') !== '1') {
            self::markTestSkipped('Runs in the isolated MySQL test runtime.');
        }
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/push_categories.php'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]);
        $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $err . $out);
        $result = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        $this->addToAssertionCount($result['assertions']);
    }
}
