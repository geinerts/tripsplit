<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class CurrencyCatalogTest extends TestCase
{
    private function run_(string $code): mixed
    {
        $script = '<?php
            function json_out(array $p, int $s = 200): void { echo json_encode(["status" => $s]); exit(0); }
            function validate_date_iso($d) { return $d; }
            function cents_to_decimal(int $c): string { return number_format($c / 100, 2, ".", ""); }
            define("FX_PROVIDER_BASE_URL", "");
            define("FX_TIMEOUT_SEC", 1);
            require ' . var_export(__DIR__ . '/../../lib/helpers/helper_currency.php', true) . ';
            echo json_encode(' . $code . ');';
        $file = tempnam(sys_get_temp_dir(), 'currency');
        file_put_contents($file, $script);
        $output = shell_exec(escapeshellarg(PHP_BINARY) . ' ' . escapeshellarg($file));
        unlink($file);
        return json_decode((string) $output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_the_catalog_and_profile_use_the_same_120_currencies(): void
    {
        $codes = $this->run_('trip_supported_currency_codes()');
        self::assertCount(120, array_unique($codes));
        self::assertSame($codes, $this->run_('fx_provider_supported_currency_codes()'));
        self::assertSame('VND', $this->run_('normalize_profile_currency_code_or_default("VND")'));
        self::assertSame('EUR', $this->run_('normalize_profile_currency_code_or_default("BTC")'));
        self::assertSame(['status' => 400], $this->run_('normalize_currency_code("BTC")'));
    }

    public function test_messages_write_amounts_as_each_currency_does(): void
    {
        self::assertSame('JPY 1500', $this->run_('format_cents_with_currency(150000, "JPY")'));
        self::assertSame('VND 50000000', $this->run_('format_cents_with_currency(5000000000, "VND")'));
        self::assertSame('EUR 12.50', $this->run_('format_cents_with_currency(1250, "EUR")'));
    }

    public function test_a_result_too_large_for_the_amount_column_is_refused(): void
    {
        // From 2026 the lev converts at its fixed rate, so this needs no network.
        self::assertSame(['status' => 400], $this->run_('convert_amount_to_trip_currency(900_000_000_000, "EUR", "BGN", "2026-11-05")'));
        self::assertSame(195_583_000, $this->run_('convert_amount_to_trip_currency(100_000_000, "EUR", "BGN", "2026-11-05")["converted_cents"]'));
        $migration = (string) file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-06-widen-money-columns.sql');
        foreach (['owed_cents', 'split_value', 'amount_cents'] as $column) {
            self::assertStringContainsString("MODIFY COLUMN {$column} BIGINT UNSIGNED", $migration);
        }
        $schema = (string) file_get_contents(__DIR__ . '/../../../sql/schema.sql');
        self::assertDoesNotMatchRegularExpression('/(owed_cents|amount_cents|split_value) INT UNSIGNED/', $schema);
    }
}
