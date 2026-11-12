<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class AdminUserSearchTest extends TestCase
{
    public function test_users_list_filters_sorts_and_summarizes_without_guests_or_password_data(): void
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/admin_user_search.php'],
            [1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        $out = stream_get_contents($pipes[1]);
        $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $err . $out);
        $r = json_decode($out, true, 512, JSON_THROW_ON_ERROR);

        self::assertSame([3, 2, 1], $r['newest']);
        self::assertSame([1, 2, 3], $r['oldest']);
        self::assertSame([1, 3, 2], $r['last_active']);
        self::assertSame([2, 1, 3], $r['trips']);
        self::assertSame([1], $r['ios']);
        self::assertSame([2], $r['apple']);
        self::assertSame([1, 3], array_values(array_intersect([1, 3], $r['email'])));
        self::assertCount(2, $r['email']);
        self::assertSame([1], $r['premium']);
        self::assertSame([3, 2], $r['unverified']);
        self::assertSame([1], $r['percent']);
        self::assertSame([1], $r['literal_percent']);
        self::assertSame([3], $r['deleted']);
        self::assertSame(3, $r['page']['total']);
        self::assertSame([2], array_column($r['page']['users'], 'id'));

        $growth = array_column($r['growth'], null, 'date');
        self::assertCount(30, $r['growth']);
        self::assertSame('2026-10-14', $r['growth'][0]['date']);
        self::assertSame(['date' => '2026-11-12', 'signups' => 0, 'active' => 2, 'trips' => 0], $growth['2026-11-12']);
        self::assertSame(2, $growth['2026-11-11']['trips']);
        self::assertSame(1, $growth['2026-11-10']['active']);
        self::assertSame(1, $growth['2026-11-01']['signups']);
        self::assertSame(0, $growth['2026-11-04']['signups'], 'guest sign-ups are not counted');

        self::assertSame(['pending' => 2, 'oldest_pending_at' => '2026-11-12 07:40:00', 'failed_24h' => 1,
            'last_sent_at' => '2026-11-12 07:00:01'], $r['push']);

        self::assertSame(['Splyto/1.0 Android', 'Splyto/1.0 iOS'], array_column($r['sessions'], 'user_agent'),
            'revoked and expired sessions are hidden, newest use first');
        foreach ($r['sessions'] as $session) {
            self::assertSame(['id', 'created_at', 'last_used_at', 'user_agent'], array_keys($session));
        }
        self::assertSame(['2026-11-12 07:30:00', '2026-11-12 07:00:00'], array_column($r['timeline'], 'created_at'));
        self::assertSame([null, 'Rome'], array_column($r['timeline'], 'trip_name'));

        $security = $r['security'];
        self::assertSame(['failed_logins' => 2, 'failed_2fa' => 1, 'locked' => 0, 'successful_logins' => 1], $security['counts_7d']);
        self::assertCount(4, $security['events'], 'other audit actions and events older than 7 days are left out');
        self::assertSame([['scope' => 'login_ip', 'windows' => 2, 'requests' => 28, 'peak' => 25],
            ['scope' => 'refresh_ip', 'windows' => 1, 'requests' => 8, 'peak' => 8]], $security['rate_limits_24h']);
        self::assertSame(1, $security['active_admin_sessions']);

        $first = $r['first'];
        self::assertSame(1, $first['trips_count']);
        self::assertSame('2026-11-12 07:00:00', $first['last_active_at'], 'revoked sessions still count as activity');
        self::assertTrue($first['premium_grant']);
        self::assertSame(['email'], $first['sign_in_methods']);
        self::assertArrayNotHasKey('password_hash', $first);
        self::assertArrayNotHasKey('has_password_login', $first);
    }
}
