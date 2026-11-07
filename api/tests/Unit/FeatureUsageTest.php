<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_feature_usage.php';

final class FeatureUsageTest extends TestCase
{
    private function database(): PDO
    {
        $pdo = new PDO('sqlite::memory:');
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $table = table_name('feature_usage_counts');
        $pdo->exec("CREATE TABLE {$table} (usage_month TEXT, feature TEXT, use_count INTEGER, PRIMARY KEY (usage_month, feature))");
        return $pdo;
    }

    private function rows(PDO $pdo): array
    {
        $table = table_name('feature_usage_counts');
        return $pdo->query("SELECT usage_month || '/' || feature, use_count FROM {$table} ORDER BY 1")->fetchAll(PDO::FETCH_KEY_PAIR);
    }

    public function test_counts_per_month_and_feature_in_utc(): void
    {
        $pdo = $this->database();
        $endOfOctober = gmmktime(23, 59, 59, 10, 31, 2026);
        record_feature_use($pdo, 'random_pick', $endOfOctober);
        record_feature_use($pdo, 'random_pick', $endOfOctober);
        record_feature_use($pdo, 'analytics_open', $endOfOctober);
        record_feature_use($pdo, 'random_pick', $endOfOctober + 1);
        self::assertSame(['2026-10/analytics_open' => 1, '2026-10/random_pick' => 2, '2026-11/random_pick' => 1], $this->rows($pdo));
    }

    public function test_unknown_feature_is_ignored(): void
    {
        $pdo = $this->database();
        record_feature_use($pdo, 'user_42_opened_trip_7');
        self::assertSame([], $this->rows($pdo));
    }

    public function test_keeps_twenty_four_months(): void
    {
        $pdo = $this->database();
        $table = table_name('feature_usage_counts');
        $pdo->exec("INSERT INTO {$table} VALUES ('2024-11', 'random_pick', 1), ('2024-12', 'random_pick', 1)");
        record_feature_use($pdo, 'random_pick', gmmktime(0, 0, 0, 11, 15, 2026));
        self::assertSame(['2024-12/random_pick' => 1, '2026-11/random_pick' => 1], $this->rows($pdo));
    }

    public function test_missing_table_never_breaks_the_feature(): void
    {
        $pdo = new PDO('sqlite::memory:');
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        record_feature_use($pdo, 'random_pick');
        self::assertSame(['available' => false, 'months' => []], feature_usage_summary($pdo));
    }

    public function test_summary_is_newest_first_limited_and_complete(): void
    {
        $pdo = $this->database();
        $table = table_name('feature_usage_counts');
        foreach (['2026-04', '2026-05', '2026-06', '2026-07', '2026-08', '2026-09', '2026-10'] as $month) {
            $pdo->exec("INSERT INTO {$table} VALUES ('{$month}', 'random_pick', 3)");
        }
        $pdo->exec("INSERT INTO {$table} VALUES ('2026-10', 'retired_feature', 9)");
        $summary = feature_usage_summary($pdo);
        self::assertTrue($summary['available']);
        self::assertCount(6, $summary['months']);
        self::assertSame('2026-10', $summary['months'][0]['month']);
        self::assertSame(FEATURE_USAGE_NAMES, array_column($summary['months'][0]['counts'], 'feature'));
        self::assertSame(3, array_column($summary['months'][0]['counts'], 'count', 'feature')['random_pick']);
        self::assertSame(0, array_column($summary['months'][0]['counts'], 'count', 'feature')['analytics_open']);
    }

    public function test_table_is_mapped_and_the_migration_has_no_identifiers(): void
    {
        self::assertSame('trip_feature_usage_counts', table_name('feature_usage_counts'));
        $migration = (string) file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-07-add-feature-usage-counts.sql');
        $columns = substr($migration, (int) strpos($migration, 'CREATE TABLE'));
        self::assertDoesNotMatchRegularExpression('/user_id|trip_id|device|ip_address|created_at/', $columns);
    }

    /** These handlers have no database fixture: the count must follow the real work. */
    public function test_counts_follow_the_work_they_measure(): void
    {
        foreach ([
            ['orders_actions.php', '$pdo->commit();', "'random_pick'"],
            ['uploads_actions.php', 'bind_stored_receipt_to_owner($stored, $userId);', "'receipt_upload'"],
            ['travel_places_actions.php', '$pdo->commit();', "'travel_place_save'"],
            ['travel_places_actions.php', '$stmt->fetchAll())', "'travel_map_open'"],
        ] as [$file, $work, $count]) {
            $source = (string) file_get_contents(__DIR__ . '/../../lib/actions/' . $file);
            self::assertNotFalse(strpos($source, $count), $count);
            self::assertLessThan(strpos($source, $count), strpos($source, $work), $count);
        }
    }
}
