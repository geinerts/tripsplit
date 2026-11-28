<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class QuickSplitSharesTest extends TestCase
{
    private static ?array $result = null;

    private static function fixture(): array
    {
        if (self::$result !== null) {
            return self::$result;
        }
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/quick_split_shares.php'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        return self::$result = json_decode((string) $output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_before_the_migration_sharing_answers_409_and_get_is_unchanged(): void
    {
        self::assertSame([409, 'absent'], self::fixture()['before']);
    }

    public function test_the_creator_gets_one_link_that_is_not_stored_in_clear(): void
    {
        $r = self::fixture();
        self::assertSame(200, $r['first']['status']);
        self::assertStringStartsWith('https://splyto.eu/split?code=', $r['first']['body']['share']['url']);
        self::assertMatchesRegularExpression('/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\dZ$/', $r['first']['body']['share']['expires_at']);
        self::assertFalse($r['first']['body']['share']['show_receipt']);
        self::assertTrue($r['token_shape']);
        self::assertTrue($r['again_same_url']);
        self::assertSame(1, $r['rows_after_two_shares']);
        self::assertTrue($r['token_not_stored']);
        self::assertTrue($r['get_owner']);
        self::assertFalse($r['get_member_has_no_share']);
    }

    public function test_the_receipt_is_shown_only_when_asked_with_true_and_there_is_one(): void
    {
        $r = self::fixture();
        self::assertFalse($r['receipt_without_photo']);
        self::assertFalse($r['truthy_is_not_true']);
        self::assertTrue($r['receipt_on']);
        self::assertTrue($r['receipt_page']);
        self::assertNull($r['receipt_page_after_off']);
    }

    public function test_only_the_creator_can_share_or_stop_sharing(): void
    {
        $r = self::fixture();
        self::assertSame(403, $r['errors']['member']['status']);
        self::assertSame('Only the creator can share this quick split.', $r['errors']['member']['body']['error']);
        self::assertSame(404, $r['errors']['stranger']);
        self::assertSame(404, $r['errors']['missing']);
        self::assertSame(403, $r['errors']['revoke_member']);
    }

    public function test_the_page_shows_names_and_amounts_only(): void
    {
        $r = self::fixture();
        self::assertSame([], $r['page_json_leaks']);
        self::assertSame(['O', 'I', 'AB'], array_column($r['page']['people'], 'initials'));
        self::assertSame(2000, array_sum(array_column($r['page']['people'], 'amount_cents')));
        self::assertSame([[1, 3], [2]], array_column($r['page']['items'], 'person_ids'));
        self::assertSame(300, $r['page']['extra_cents']);
        self::assertSame('Owner', $r['page']['sharer_name']);
        self::assertSame([true, true, true, true], $r['bad_tokens']);
    }

    public function test_the_link_ends_when_expired_revoked_moved_deleted_or_the_creator_is_suspended(): void
    {
        $r = self::fixture();
        self::assertFalse($r['expired_resolves']);
        self::assertTrue($r['renewed_is_new']);
        self::assertFalse($r['suspended_resolves']);
        self::assertSame(['ok' => true], $r['revoke']);
        self::assertFalse($r['revoked_resolves']);
        self::assertNull($r['get_after_revoke']);
        self::assertFalse($r['moved_resolves']);
        self::assertSame(409, $r['moved_share']);
        self::assertSame(0, $r['links_after_delete']);
        self::assertSame(0, $r['links_after_account_erased']);
    }

    public function test_router_schema_and_migration_agree(): void
    {
        $root = __DIR__ . '/../../';
        $router = (string) file_get_contents($root . 'lib/http/action_router.php');
        self::assertStringContainsString("'share_quick_split' => 'share_quick_split_action'", $router);
        self::assertStringContainsString("'revoke_quick_split_share' => 'revoke_quick_split_share_action'", $router);
        $schema = (string) file_get_contents($root . '../sql/schema.sql');
        $migration = (string) file_get_contents($root . '../sql/migrations/2026-11-28-quick-split-shares.sql');
        self::assertStringContainsString('CREATE TABLE IF NOT EXISTS trip_quick_split_shares (', $schema);
        self::assertStringContainsString('CREATE TABLE IF NOT EXISTS trip_quick_split_shares (', $migration);
        self::assertStringContainsString('token_salt CHAR(32)', $migration);
        self::assertStringContainsString('ON DELETE CASCADE', $migration);
    }
}
