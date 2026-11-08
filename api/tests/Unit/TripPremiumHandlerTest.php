<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

/** Runs the real trips handler in a separate process with the isolated SQLite harness. */
final class TripPremiumHandlerTest extends TestCase
{
    public function test_trips_list_sends_trip_premium_to_current_members_only(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/trip_premium.php'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        $r = json_decode($output, true, 512, JSON_THROW_ON_ERROR);
        $rome = (string) $r['ids']['rome'];
        $oslo = (string) $r['ids']['oslo'];
        $off = ['trip_export' => false];
        $on = ['trip_export' => true];

        self::assertSame([$oslo => $off, $rome => $off], $r['no_tables']);
        self::assertSame([$oslo => $off, $rome => $off], $r['free']);
        self::assertSame([$oslo => $off, $rome => $on], $r['owner_with_trip_premium']);
        self::assertSame([$rome => $on], $r['member_with_trip_premium']);
        self::assertSame([], $r['outsider_before_joining']);
        self::assertSame([$rome => $on], $r['member_who_joined_later']);
        self::assertSame([], $r['member_who_left']);
        self::assertSame([$rome => $off], $r['after_revoke']);
        self::assertSame([$oslo => $on, $rome => $on], $r['own_premium']);
        self::assertSame([$rome => $off], $r['other_member_without_own_premium']);
    }
}
