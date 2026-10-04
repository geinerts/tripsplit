<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/credentials_harness.php';
$pdo = isolated_test_mysql();
$process = proc_open([PHP_BINARY, 'vendor/bin/phpunit', '--do-not-cache-result',
    '--filter', 'CredentialsSecurityTest'], [STDIN, STDOUT, STDERR], $pipes);
if (!is_resource($process) || proc_close($process) !== 0) {
    throw new RuntimeException('MySQL credential regression suite failed');
}

function assertCredentials(bool $condition, string $message): void {
    if (!$condition) { throw new RuntimeException($message); }
}

for ($round = 1; $round <= 5; $round++) {
    foreach (['enroll', 'password'] as $scenario) {
        reset_credentials_test_schema($pdo);
        seed_credential_user($pdo, $scenario === 'enroll' ? 'guest' : 'established');
        $workers = [];
        try {
            for ($i = 0; $i < 4; $i++) {
                $process = proc_open([PHP_BINARY, __DIR__ . '/credentials_worker.php', $scenario, (string) $i],
                    [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
                assertCredentials(is_resource($process), 'Worker could not start');
                stream_set_timeout($pipes[1], 30);
                $workers[] = ['process' => $process, 'pipes' => $pipes];
            }
            foreach ($workers as $worker) {
                assertCredentials(fgets($worker['pipes'][1]) === "READY\n", 'Worker not ready');
            }
            foreach ($workers as $worker) { fwrite($worker['pipes'][0], "GO\n"); fflush($worker['pipes'][0]); }
            $results = [];
            foreach ($workers as &$worker) {
                $line = fgets($worker['pipes'][1]);
                assertCredentials(is_string($line), 'Missing worker response');
                $results[] = json_decode($line, true, 512, JSON_THROW_ON_ERROR);
                fclose($worker['pipes'][0]); fclose($worker['pipes'][1]);
                $error = stream_get_contents($worker['pipes'][2]); fclose($worker['pipes'][2]);
                $exit = proc_close($worker['process']); $worker = [];
                assertCredentials($exit === 0 && $error === '', 'Worker failure: ' . $error);
            }
            unset($worker);
            $winners = array_values(array_filter($results, static fn(array $r): bool => $r['status'] === 200));
            assertCredentials(count($winners) === 1, 'Expected exactly one credential mutation');
            foreach ($results as $result) {
                if ($result['status'] !== 200) {
                    assertCredentials(in_array($result['status'], [403, 409], true), 'Unexpected loser response');
                    assertCredentials(!$result['auth'] && $result['mail_count'] === 0, 'Rejected mutation had side effects');
                }
            }
            $user = fetch_me_row_by_id($pdo, 1);
            assertCredentials(password_verify('New-password-456-' . $winners[0]['index'], $user['password_hash']),
                'Stored password does not belong to winner');
            $active = (int) $pdo->query('SELECT COUNT(*) FROM trip_refresh_tokens WHERE user_id = 1 AND revoked_at IS NULL')->fetchColumn();
            assertCredentials($active === ($scenario === 'enroll' ? 0 : 1), 'Wrong session count');
            assertCredentials((int) $pdo->query('SELECT COUNT(*) FROM trip_refresh_tokens WHERE user_id = 2 AND revoked_at IS NULL')->fetchColumn() === 1,
                'Unrelated user session revoked');
            assertCredentials($winners[0]['mail_count'] === ($scenario === 'enroll' ? 1 : 0), 'Wrong delivery count');
            echo "PASS credential race $round/$scenario: one winner, three rejected\n";
        } finally {
            foreach ($workers as $worker) {
                if ($worker === []) { continue; }
                proc_terminate($worker['process']);
                foreach ($worker['pipes'] as $pipe) { if (is_resource($pipe)) { fclose($pipe); } }
                proc_close($worker['process']);
            }
        }
    }
}
echo "PASS: 10 credential races / 40 synthetic requests. No real mail.\n";
