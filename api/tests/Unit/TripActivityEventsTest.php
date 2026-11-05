<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class TripActivityEventsTest extends TestCase
{
    private static array $r;

    public static function setUpBeforeClass(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__.'/../Fixtures/trip_activity.php'],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors.$output);
        self::$r = json_decode($output, true, 512, JSON_THROW_ON_ERROR);
    }

    private static function changed(array $events): array
    {
        self::assertCount(1, $events);
        self::assertSame('trip.updated', $events[0]['type']);
        return array_keys(array_filter($events[0]['payload']));
    }

    public function test_trip_updated_names_the_change(): void
    {
        self::assertSame(['name_changed'], self::changed(self::$r['renamed']));
        self::assertSame(['budget_changed'], self::changed(self::$r['budget_set']));
        self::assertSame(['destinations_changed'], self::changed(self::$r['destinations_cleared']));
    }

    public function test_saving_without_changes_writes_no_event(): void
    {
        self::assertSame([], self::$r['same_name']);
        self::assertSame([], self::$r['same_budget']);
        self::assertSame([], self::$r['no_destinations']);
    }

    public function test_comment_event_names_the_expense_but_not_the_comment(): void
    {
        $event = self::$r['comment'][0];
        self::assertSame('expense.comment_added', $event['type']);
        self::assertSame(5, $event['entity_id']);
        self::assertSame('Breakfast', $event['payload']['note']);
        self::assertStringNotContainsString('private words', json_encode($event, JSON_THROW_ON_ERROR));
    }

    public function test_trip_settled_is_written_once_by_the_last_confirmation(): void
    {
        self::assertSame(['settlement.confirmed'], array_column(self::$r['first_confirm'], 'type'));
        self::assertSame(['settlement.confirmed', 'trip.settled'], array_column(self::$r['last_confirm'], 'type'));
        self::assertNotContains('trip.settled', array_column(self::$r['repeated_confirm'], 'type'));
    }

    public function test_expense_events_carry_the_expense_note(): void
    {
        $source = file_get_contents(__DIR__.'/../../lib/actions/expenses_actions.php');
        foreach (['created', 'updated', 'deleted'] as $type) {
            self::assertMatchesRegularExpression(
                '/app_event\(\$pdo, \$userId, \'expense\.'.$type.'\'.*?\'note\' =>.*?\]\);/s',
                $source,
                $type
            );
        }
    }

    public function test_feed_shows_group_milestones_and_hides_reminders(): void
    {
        self::assertSame(
            ['expense.comment_added', 'trip.settled', 'trip.all_members_ready'],
            self::$r['feed']
        );
    }
}
