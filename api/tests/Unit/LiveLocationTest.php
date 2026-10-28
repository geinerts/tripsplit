<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;
final class LiveLocationTest extends TestCase
{
    public function test_opt_in_membership_expiry_stop_and_cleanup(): void
    {
        $process=proc_open([PHP_BINARY,__DIR__.'/../Fixtures/live_location.php'],[0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes);
        self::assertIsResource($process); fclose($pipes[0]);
        $output=stream_get_contents($pipes[1]);$errors=stream_get_contents($pipes[2]);fclose($pipes[1]);fclose($pipes[2]);
        self::assertSame(0,proc_close($process),$errors);self::assertSame('',$errors);
        $result=json_decode($output,true,512,JSON_THROW_ON_ERROR);
        self::assertGreaterThanOrEqual(30,$result['assertions']);
    }
}
