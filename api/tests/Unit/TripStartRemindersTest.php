<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class TripStartRemindersTest extends TestCase
{
    public function test_members_of_trips_starting_tomorrow_are_reminded_once(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__.'/../Fixtures/trip_start_reminders.php'],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        $r = json_decode($output, true, 512, JSON_THROW_ON_ERROR);
        self::assertSame('2026-11-21', $r['dry']['date']);
        self::assertCount(2, $r['dry']['rows']);
        self::assertSame(0, $r['dry_rows']);
        // Only the active trip starting tomorrow, only active accounts.
        self::assertSame(1, $r['first']['trips']);
        self::assertSame(2, $r['first']['sent']);
        self::assertSame(0, $r['again']['sent']);
        self::assertSame(2, $r['again']['skipped']);
        self::assertSame([11, 12], array_map(fn($row) => (int) $row['user_id'], $r['stored']));
        foreach ($r['stored'] as $row) {
            self::assertSame(21, (int) $row['trip_id']);
            self::assertSame('trip_starts_tomorrow', $row['type']);
            self::assertSame('"Lisbon" starts tomorrow.', $row['body']);
        }
        self::assertSame('"Your trip" starts tomorrow.', $r['text']['body']);
    }
}
