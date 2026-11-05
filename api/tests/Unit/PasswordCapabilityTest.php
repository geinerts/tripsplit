<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_auth_user.php';
require_once __DIR__ . '/../../lib/helpers/helper_currency.php';

final class PasswordCapabilityTest extends TestCase
{
    private function database(bool $withCapability = true): PDO
    {
        $pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $pdo->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, password_hash TEXT'
            . ($withCapability ? ', has_password INTEGER NULL' : '') . ')');
        $pdo->exec("INSERT INTO trip_users (id, password_hash) VALUES (1, 'legacy-placeholder-or-password')");
        return $pdo;
    }

    public function test_legacy_hash_is_not_evidence_of_a_chosen_password(): void
    {
        $pdo = $this->database();
        self::assertNull(user_password_capability($pdo, 1));
        self::assertNull(user_password_capability($pdo, 999));
        record_user_password_capability($pdo, 1, false);
        self::assertFalse(user_password_capability($pdo, 1));
        record_user_password_capability($pdo, 1, true);
        self::assertTrue(user_password_capability($pdo, 1));
        self::assertSame('legacy-placeholder-or-password', $pdo->query('SELECT password_hash FROM trip_users')->fetchColumn());
    }

    public function test_me_payload_reads_the_authenticated_users_stored_status(): void
    {
        $pdo = $this->database();
        $user = ['id' => 1, 'nickname' => 'Owner', 'has_password' => true];
        self::assertNull(build_me_payload($user, $pdo)['has_password']);
        record_user_password_capability($pdo, 1, false);
        self::assertFalse(build_me_payload($user, $pdo)['has_password']);
        record_user_password_capability($pdo, 1, true);
        self::assertTrue(build_me_payload($user, $pdo)['has_password']);
        self::assertNull(build_me_payload($user)['has_password']);
        self::assertArrayNotHasKey('password_hash', build_me_payload($user, $pdo));
    }

    public function test_old_schema_remains_usable_without_inventing_capability(): void
    {
        $pdo = $this->database(false);
        self::assertNull(user_password_capability($pdo, 1));
        record_user_password_capability($pdo, 1, true);
        self::assertNull(user_password_capability($pdo, 1));
    }

    public function test_capability_rolls_back_with_credential_transaction(): void
    {
        $pdo = $this->database();
        $pdo->beginTransaction();
        record_user_password_capability($pdo, 1, true);
        $pdo->rollBack();
        self::assertNull(user_password_capability($pdo, 1));
    }
}
