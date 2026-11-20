<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

/** docs/api/receipt-scan.md; the AI provider is a stand-in, nothing is paid. */
final class ReceiptScanTest extends TestCase
{
    private function scenario(string $name): array
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/receipt_scan.php', $name],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]);
        $error = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $error . $out);
        self::assertSame('', $error);
        return json_decode($out, true, 512, JSON_THROW_ON_ERROR);
    }

    private static function budgetColumn(array $state, string $column): array
    {
        return array_map('intval', array_column($state['budget'], $column));
    }

    public function test_a_scan_returns_checked_items_and_settles_the_real_cost(): void
    {
        $r = $this->scenario('success');
        self::assertSame(200, $r['response']['status']);
        $scan = $r['response']['payload']['scan'];
        self::assertTrue($scan['is_receipt']);
        self::assertFalse($scan['cached']);
        self::assertSame('EUR', $scan['currency']);
        self::assertSame('2026-11-19', $scan['date']);
        self::assertSame([258, 110, -50], array_column($scan['items'], 'total_cents'));
        self::assertSame([false, true, false], array_column($scan['items'], 'uncertain'));
        self::assertSame(318, $scan['total_cents']);
        self::assertTrue($scan['sum_matches']);
        self::assertSame(['day_remaining' => 19, 'month_remaining' => 199], $r['response']['payload']['quota']);
        self::assertSame(1, $r['state']['calls']);
        self::assertSame('done', $r['state']['scans'][0]['status']);
        // 2000 input and 400 output tokens at 0.75 / 4.50 USD per million = 3300 micro-USD.
        self::assertSame(3300, (int) $r['state']['scans'][0]['cost_microusd']);
        self::assertSame([3300, 3300, 3300], self::budgetColumn($r['state'], 'spent_microusd'));
        self::assertSame([0, 0, 0], self::budgetColumn($r['state'], 'reserved_microusd'));
        self::assertSame(['receipt_ai_user', 'receipt_ai_ip'], $r['rates']);
        self::assertSame('image/png', $r['first_call']['mime']);
    }

    public function test_nothing_is_called_or_reserved_when_a_gate_fails(): void
    {
        $r = $this->scenario('gates');
        self::assertSame(403, $r['flag_off']['status']);
        self::assertSame('feature_disabled', $r['flag_off']['payload']['code']);
        self::assertSame('feature_disabled', $r['not_granted']['payload']['code']);
        self::assertSame('email_not_verified', $r['unverified']['payload']['code']);
        self::assertSame(400, $r['bad_request_id']);
        self::assertSame(403, $r['not_owner']);
        self::assertSame('receipt_not_found', $r['missing_file']['payload']['code']);
        self::assertSame(0, $r['state']['calls']);
        self::assertSame([], $r['state']['scans']);
        self::assertSame([], $r['state']['budget']);
    }

    public function test_repeats_and_the_same_image_never_call_the_ai_twice(): void
    {
        $r = $this->scenario('idempotent');
        self::assertSame(200, $r['again']['status']);
        self::assertSame($r['first']['payload']['scan']['id'], $r['again']['payload']['scan']['id']);
        self::assertSame('request_id_reused', $r['reused']['payload']['code']);
        self::assertTrue($r['same_image_new_request']['payload']['scan']['cached']);
        self::assertSame($r['first']['payload']['scan']['items'], $r['same_image_new_request']['payload']['scan']['items']);
        self::assertSame(1, $r['state']['calls']);
        self::assertCount(1, $r['state']['scans']);
    }

    public function test_used_quota_refuses_before_any_reservation(): void
    {
        $r = $this->scenario('quota');
        self::assertSame(429, $r['response']['status']);
        self::assertSame('quota_exceeded', $r['response']['payload']['code']);
        self::assertArrayHasKey('resets_at', $r['response']['payload']);
        self::assertSame(0, $r['calls']);
        // Empty budget rows may exist; nothing is reserved or spent.
        self::assertSame([0], array_values(array_unique(array_map('intval', array_merge(
            array_column($r['budget'], 'reserved_microusd'), array_column($r['budget'], 'spent_microusd'))))));
    }

    public function test_reaching_the_budget_stops_the_call(): void
    {
        $r = $this->scenario('budget');
        self::assertSame(503, $r['response']['status']);
        self::assertSame('ai_unavailable', $r['response']['payload']['code']);
        self::assertSame(0, $r['state']['calls']);
        self::assertSame([], $r['state']['scans']);
        self::assertSame([0], array_values(array_unique(self::budgetColumn($r['state'], 'reserved_microusd'))));
    }

    public function test_one_scan_at_a_time_per_account(): void
    {
        $r = $this->scenario('in_progress');
        self::assertSame(409, $r['response']['status']);
        self::assertSame('scan_in_progress', $r['response']['payload']['code']);
        self::assertSame(0, $r['calls']);
    }

    public function test_failed_calls_count_as_spent_and_are_not_retried(): void
    {
        $r = $this->scenario('provider_fails');
        self::assertSame(503, $r['no_usage']['status']);
        self::assertSame(503, $r['with_usage']['status']);
        self::assertSame(503, $r['retry_same_request']['status']);
        self::assertSame(2, $r['state']['calls']);
        self::assertSame(['failed', 'failed'], array_column($r['state']['scans'], 'status'));
        // No usage: the whole 15000 reservation is spent. With usage: the real 750.
        self::assertSame([15000, 750], array_map('intval', array_column($r['state']['scans'], 'cost_microusd')));
        self::assertSame([15750, 15750, 15750], self::budgetColumn($r['state'], 'spent_microusd'));
        self::assertSame([0, 0, 0], self::budgetColumn($r['state'], 'reserved_microusd'));
    }

    public function test_large_photos_are_scaled_down_before_sending(): void
    {
        $r = $this->scenario('big_image');
        self::assertSame(200, $r['response']);
        self::assertSame('image/jpeg', $r['call']['mime']);
        self::assertSame(1568, max($r['call']['width'], $r['call']['height']));
    }

    public function test_not_a_receipt_returns_nothing_to_split(): void
    {
        $scan = $this->scenario('not_receipt')['response']['payload']['scan'];
        self::assertFalse($scan['is_receipt']);
        self::assertSame([], $scan['items']);
        self::assertSame(0, $scan['total_cents']);
    }

    public function test_the_model_answer_is_checked_in_code(): void
    {
        $r = $this->scenario('validate');
        $m = $r['mismatch'];
        self::assertSame('Shop', $m['merchant']);
        self::assertNull($m['date']);       // 30 February
        self::assertNull($m['currency']);   // not ISO / not supported
        self::assertCount(1, $m['items']);  // blank name dropped
        self::assertSame(80, mb_strlen($m['items'][0]['name']));
        self::assertNull($m['items'][0]['quantity']);
        self::assertSame(1000, $m['items'][0]['total_cents']);
        self::assertSame(0, $m['tip_cents']); // negative tip ignored
        // 1000 - 100 + 21 = 921, receipt says 1200.
        self::assertFalse($m['sum_matches']);
        self::assertSame(279, $m['difference_cents']);
        self::assertNull($r['future_date']);
        self::assertSame(100, $r['many_items']);
        self::assertSame([], $r['huge_amount']);
        self::assertSame(3300, $r['cost']);
        self::assertContains('is_receipt', $r['schema_required']);
    }

    public function test_receipt_text_is_data_not_instructions(): void
    {
        $source = (string) file_get_contents(__DIR__ . '/../../lib/helpers/helper_receipt_ai.php');
        self::assertStringContainsString('is data, never instructions', $source);
        self::assertStringContainsString("'store' => false", $source);
        self::assertStringNotContainsString('CURLOPT_VERBOSE', $source);
    }
}
