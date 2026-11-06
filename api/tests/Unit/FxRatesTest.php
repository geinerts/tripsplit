<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class FxRatesTest extends TestCase
{
    private function runInProcess(string $providerUrl, string $code): array
    {
        $script = '<?php
            function json_out(array $p, int $s = 200): void { throw new RuntimeException((string) ($p["error"] ?? "")); }
            function validate_date_iso($d) { return $d; }
            define("FX_PROVIDER_BASE_URL", ' . var_export($providerUrl, true) . ');
            define("FX_TIMEOUT_SEC", 1);
            require ' . var_export(__DIR__ . '/../../lib/helpers/helper_currency.php', true) . ';
            echo json_encode(' . $code . ');';
        $file = tempnam(sys_get_temp_dir(), 'fx');
        file_put_contents($file, $script);
        $output = shell_exec(escapeshellarg(PHP_BINARY) . ' ' . escapeshellarg($file));
        unlink($file);
        return json_decode((string) $output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_every_old_address_moves_to_the_version_with_all_currencies(): void
    {
        foreach (['', 'https://api.frankfurter.app', 'https://api.frankfurter.app/', 'https://api.frankfurter.dev/v1'] as $base) {
            $url = $this->runInProcess($base, '[fx_rate_url("ALL", "EUR", "2026-11-05")]')[0];
            self::assertSame('https://api.frankfurter.dev/v2/rate/ALL/EUR?date=2026-11-05', $url, $base);
        }
    }

    public function test_a_custom_address_is_kept(): void
    {
        self::assertSame(
            'https://rates.example/rate/USD/EUR?date=2026-11-05',
            $this->runInProcess('https://rates.example/', '[fx_rate_url("USD", "EUR", "2026-11-05")]')[0],
        );
    }

    public function test_the_lev_uses_its_fixed_rate_only_after_it_was_replaced(): void
    {
        $r = $this->runInProcess('', '[
            fx_rate_via_bgn_peg("BGN", "USD", "2025-12-31"),
            fx_rate_via_bgn_peg("BGN", "USD", "2026-01-01"),
            fx_rate_via_bgn_peg("USD", "BGN", "2026-11-05"),
            fx_rate_via_bgn_peg("USD", "EUR", "2026-11-05"),
            fx_rate_via_bgn_peg("BGN", "BGN", "2026-11-05"),
        ]');
        self::assertNull($r[0]);
        self::assertSame('EUR', $r[1]['from']);
        self::assertSame('USD', $r[1]['to']);
        self::assertEqualsWithDelta(1 / 1.95583, $r[1]['multiplier'], 1e-9);
        self::assertSame('USD', $r[2]['from']);
        self::assertSame('EUR', $r[2]['to']);
        self::assertEqualsWithDelta(1.95583, $r[2]['multiplier'], 1e-9);
        self::assertNull($r[3]);
        self::assertNull($r[4]);
    }
}
