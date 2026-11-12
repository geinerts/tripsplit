<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class UnverifiedAccountErasureTest extends TestCase
{
    public function test_only_old_unverified_unused_accounts_are_erased_and_their_email_is_freed(): void
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/unverified_erasure.php'],
            [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        $out = stream_get_contents($pipes[1]);
        $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $err . $out);
        $r = json_decode($out, true, 512, JSON_THROW_ON_ERROR);

        self::assertSame(30, $r['dry']['erase_days']);
        self::assertSame([1], $r['dry']['user_ids']);
        self::assertSame(0, $r['dry']['erased']);
        self::assertSame('erase@example.invalid', $r['before'], 'a dry run changes nothing');

        self::assertSame(1, $r['run']['erased']);
        $users = array_column($r['users'], null, 'id');
        self::assertSame('deleted', $users[1]['account_status']);
        self::assertNull($users[1]['email']);
        self::assertNull($users[1]['password_hash']);
        self::assertSame('Deleted User', $users[1]['nickname']);
        foreach ([2, 3, 4, 5, 6, 7, 8] as $kept) {
            self::assertNotNull($users[$kept]['email'], "user {$kept} must be kept");
            self::assertNotSame('deleted', $users[$kept]['account_status']);
        }
        self::assertSame(0, $r['again']['erased'], 'the new sign-up with the freed email is not touched');
    }
}
