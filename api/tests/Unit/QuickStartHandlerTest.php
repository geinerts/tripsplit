<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class QuickStartHandlerTest extends TestCase
{
    public function test_account_scoping_and_membership_lifecycle(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/quick_start.php'],
            [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]);
        $err = stream_get_contents($pipes[2]);
        fclose($pipes[1]); fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $err . $out);
        self::assertSame('', $err);
        $result = json_decode($out, true, 512, JSON_THROW_ON_ERROR);
        self::assertGreaterThan(0, $result['assertions']);
        $this->addToAssertionCount($result['assertions']);
    }
}
