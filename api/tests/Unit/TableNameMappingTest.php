<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

/**
 * Test harnesses replace table_name(), so a table missing from the real mapping
 * only fails in production ("Invalid table mapping"). Check every key in use.
 */
final class TableNameMappingTest extends TestCase
{
    public function test_every_table_name_key_in_use_is_mapped(): void
    {
        $config = (string) file_get_contents(__DIR__ . '/../../config/config_db.php');
        preg_match_all("/'([a-z0-9_]+)'\\s*=>\\s*DB_TABLE_PREFIX/", $config, $mapped);
        $mapped = array_flip($mapped[1]);
        self::assertArrayHasKey('premium_trip_grants', $mapped);

        $missing = [];
        $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator(__DIR__ . '/../../lib'));
        foreach ([...iterator_to_array($files), new SplFileInfo(__DIR__ . '/../../api.php')] as $file) {
            if (!$file->isFile() || $file->getExtension() !== 'php') {
                continue;
            }
            preg_match_all("/table_name\\(\\s*'([a-z0-9_]+)'\\s*\\)/", (string) file_get_contents($file->getPathname()), $used);
            foreach ($used[1] as $key) {
                if (!isset($mapped[$key])) {
                    $missing[$key][] = basename($file->getPathname());
                }
            }
        }
        self::assertSame([], $missing, 'table_name keys missing from config/config_db.php');
    }
}
