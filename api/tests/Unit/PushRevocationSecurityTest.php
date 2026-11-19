<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class PushRevocationSecurityTest extends TestCase
{
    public function test_signing_out_everywhere_also_stops_push_to_every_device(): void
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/push_revocation.php'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]);
        $error = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $error . $out);
        $r = json_decode($out, true, 512, JSON_THROW_ON_ERROR);

        self::assertSame(['someone-else'], $r['active_push']);
        self::assertSame([2], array_map('intval', $r['active_sessions']));
    }

    /** Every path that signs a user out everywhere uses the combined helper. */
    public function test_revocation_paths_also_stop_push(): void
    {
        $root = __DIR__ . '/../../lib/actions/';
        $reset = (string) file_get_contents($root . 'password_reset_actions.php');
        $auth = (string) file_get_contents($root . 'auth_actions.php');
        $admin = (string) file_get_contents($root . 'admin_panel_actions.php');

        self::assertStringContainsString('revoke_sessions_and_push_for_user($pdo, $userId);', $reset);
        self::assertSame(2, substr_count($auth, 'revoke_sessions_and_push_for_user($pdo, $userId);'));
        self::assertStringContainsString('revoke_sessions_and_push_for_user($pdo, $userId);', $admin);
    }
}
