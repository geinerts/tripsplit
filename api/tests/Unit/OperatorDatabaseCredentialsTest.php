<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../../scripts/lib/database_access.php';

final class OperatorDatabaseCredentialsTest extends TestCase
{
    private string $file;

    protected function setUp(): void
    {
        $this->file = tempnam(sys_get_temp_dir(), 'operator-db-');
        file_put_contents($this->file, "[client]\nhost=localhost\nuser=operator_test\npassword=synthetic-test-only\n");
        chmod($this->file, 0600);
    }

    protected function tearDown(): void
    {
        unlink($this->file);
    }

    public function testProtectedCredentialsParse(): void
    {
        self::assertSame('operator_test', operator_database_credentials($this->file)['user']);
    }

    public function testGroupReadableCredentialsRejected(): void
    {
        chmod($this->file, 0640);
        clearstatcache();
        $this->expectException(RuntimeException::class);
        operator_database_credentials($this->file);
    }

    public function testMissingFileHasNoRuntimeFallback(): void
    {
        $this->expectException(RuntimeException::class);
        operator_database_credentials($this->file . '.missing');
    }

    public function testExtraClientOptionsRejected(): void
    {
        file_put_contents($this->file, "init-command=SELECT 1\n", FILE_APPEND);
        $this->expectException(RuntimeException::class);
        operator_database_credentials($this->file);
    }

    public function testSymbolicLinkRejected(): void
    {
        symlink($this->file, $this->file . '.link');
        try {
            $this->expectException(RuntimeException::class);
            operator_database_credentials($this->file . '.link');
        } finally {
            unlink($this->file . '.link');
        }
    }

    public function testRolesHaveOnlyIntendedPrivileges(): void
    {
        $roles = database_identity_privileges();
        self::assertSame(['SELECT', 'INSERT', 'UPDATE', 'DELETE'], $roles['runtime']);
        self::assertSame(['SELECT', 'SHOW VIEW'], $roles['backup']);
        foreach ($roles as $grants) {
            foreach (['GRANT OPTION', 'FILE', 'SUPER', 'CREATE USER', 'TRIGGER', 'EVENT', 'CREATE ROUTINE'] as $forbidden) {
                self::assertNotContains($forbidden, $grants);
            }
        }
    }
}
