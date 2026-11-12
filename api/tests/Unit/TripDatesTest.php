<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_trip_report.php';

final class TripDatesTest extends TestCase
{
    public function test_no_dates_and_full_period_are_accepted(): void
    {
        self::assertSame([null, null], trip_period_input([]));
        self::assertSame([null, null], trip_period_input(['date_from' => '', 'date_to' => ' ']));
        self::assertSame(
            ['2026-11-12', '2026-11-20'],
            trip_period_input(['date_from' => '2026-11-12', 'date_to' => '2026-11-20'])
        );
    }

    public function test_start_date_alone_is_accepted(): void
    {
        self::assertSame(['2026-11-12', null], trip_period_input(['date_from' => '2026-11-12']));
        self::assertSame(
            ['2026-11-12', null],
            trip_period_input(['date_from' => '2026-11-12', 'date_to' => ''])
        );
    }

    public function test_end_date_alone_is_rejected(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        trip_period_input(['date_to' => '2026-11-20']);
    }

    public function test_end_before_start_is_rejected(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        trip_period_input(['date_from' => '2026-11-20', 'date_to' => '2026-11-12']);
    }

    public function test_invalid_start_date_is_rejected(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        trip_period_input(['date_from' => '2026-02-30']);
    }

    public function test_report_range_for_a_start_only_trip(): void
    {
        $report = static fn (array $expenses, ?string $endedAt = null): array => [
            'date_from' => '2026-11-12',
            'date_to' => null,
            'ended_at' => $endedAt,
            'expenses' => $expenses,
        ];
        self::assertSame(
            '12.11.2026 – 18.11.2026',
            trip_report_date_range($report([['date' => '2026-11-13'], ['date' => '2026-11-18']]))
        );
        self::assertSame(
            '12.11.2026 – 21.11.2026',
            trip_report_date_range($report([], '2026-11-21 10:00:00'))
        );
        self::assertSame('12.11.2026', trip_report_date_range($report([])));
        self::assertSame('12.11.2026', trip_report_date_range($report([['date' => '2026-11-10']])));
    }
}
