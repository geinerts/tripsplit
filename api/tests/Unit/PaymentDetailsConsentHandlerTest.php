<?php
declare(strict_types=1);
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class PaymentDetailsConsentHandlerTest extends TestCase
{
    public static function cases(): iterable {
        foreach (['true','false','missing','string','integer','rollback','unmigrated_true','unmigrated_missing'] as $case) yield [$case];
    }

    #[DataProvider('cases')]
    public function test_consent_is_explicit_payee_owned_and_transactional(string $case): void {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/payment_details_handler.php', $case],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]); $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $err . $out);
        self::assertSame('', $err);
        $result = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        $status = match ($case) { 'rollback'=>500, 'unmigrated_true'=>409, default=>200 };
        self::assertSame($status, $result['status']);
        self::assertFalse($result['open_transaction']);
        self::assertSame($status === 200 ? 1 : 0, $result['count']);
        self::assertSame($case === 'true' ? 1 : 0, $result['consent']);
        if ($status === 200) {
            self::assertSame(2, $result['payee']);
            self::assertSame(2, $result['requester']);
        }
        if (isset($result['read_status'])) {
            self::assertSame($case === 'true' ? 200 : 404, $result['read_status']);
            self::assertSame($case === 'true', $result['expected_details']);
        }
    }
}
