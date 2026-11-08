<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class AdminUserSignalsTest extends TestCase
{
    public function test_users_show_sign_in_methods_platforms_and_verification_without_password_data(): void
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/admin_user_signals.php'],
            [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        $out = stream_get_contents($pipes[1]);
        $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $err . $out);
        $r = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        $users = array_column($r['users'], null, 'id');

        self::assertSame(['email'], $users[1]['sign_in_methods']);
        self::assertSame(['android', 'ios'], $users[1]['platforms']);
        self::assertTrue($users[1]['email_verified']);
        self::assertSame(['apple'], $users[2]['sign_in_methods']);
        self::assertSame([], $users[2]['platforms']);
        self::assertFalse($users[2]['email_verified']);
        self::assertSame(['email', 'google'], $users[3]['sign_in_methods']);
        self::assertSame([], $users[4]['sign_in_methods']);
        foreach ($users as $user) {
            self::assertArrayNotHasKey('has_password_login', $user);
            self::assertArrayNotHasKey('password_hash', $user);
        }
        self::assertSame([], $r['empty']);
    }
}
