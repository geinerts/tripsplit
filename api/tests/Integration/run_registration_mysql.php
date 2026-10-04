<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require __DIR__ . '/../Fixtures/isolated_mysql.php';
$pdo = isolated_test_mysql();
echo 'Runtime PHP ' . PHP_VERSION . '; MySQL ' . $pdo->query('SELECT VERSION()')->fetchColumn() . PHP_EOL;

// Run the same handler regression suite on native MySQL prepares and InnoDB constraints.
$process = proc_open([PHP_BINARY, 'vendor/bin/phpunit', '--do-not-cache-result',
    '--filter', 'RegistrationSecurityTest'], [STDIN, STDOUT, STDERR], $pipes);
if (!is_resource($process) || proc_close($process) !== 0) {
    throw new RuntimeException('MySQL registration regression suite failed');
}

function requireTest(bool $condition, string $message): void
{
    if (!$condition) { throw new RuntimeException($message); }
}

function raceRegistration(string $scenario): array
{
    $workers = [];
    try {
        for ($index = 0; $index < 6; $index++) {
            $process = proc_open([PHP_BINARY, __DIR__ . '/registration_worker.php', $scenario, (string) $index],
                [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
            requireTest(is_resource($process), 'Could not start worker');
            stream_set_timeout($pipes[1], 25);
            $workers[] = ['process' => $process, 'pipes' => $pipes];
        }
        foreach ($workers as $worker) {
            requireTest(fgets($worker['pipes'][1]) === "READY\n", 'Worker did not reach readiness barrier');
        }
        foreach ($workers as $worker) {
            requireTest(fwrite($worker['pipes'][0], "GO\n") === 3, 'Could not release worker');
            fflush($worker['pipes'][0]);
        }
        $results = [];
        foreach ($workers as $worker) {
            $line = fgets($worker['pipes'][1]);
            requireTest(is_string($line), 'Worker response timed out');
            $results[] = json_decode($line, true, 512, JSON_THROW_ON_ERROR);
        }
        foreach ($workers as &$worker) {
            foreach ([0, 1] as $index) { fclose($worker['pipes'][$index]); }
            $error = stream_get_contents($worker['pipes'][2]);
            fclose($worker['pipes'][2]);
            $exitCode = proc_close($worker['process']);
            $worker = [];
            requireTest($exitCode === 0 && $error === '', 'Worker failed: ' . $error);
        }
        unset($worker);
        return $results;
    } finally {
        foreach ($workers as $worker) {
            if ($worker === []) { continue; }
            proc_terminate($worker['process']);
            foreach ($worker['pipes'] as $pipe) { if (is_resource($pipe)) { fclose($pipe); } }
            proc_close($worker['process']);
        }
    }
}

$scenarios = ['device_guest', 'device_credentials', 'email_credentials', 'existing'];
for ($round = 1; $round <= 5; $round++) {
    foreach ($scenarios as $scenario) {
        reset_registration_mysql_schema($pdo);
        $before = null;
        if ($scenario === 'existing') {
            $pdo->prepare('INSERT INTO trip_users (nickname, email, password_hash,
                credentials_required, email_verified_at, device_token) VALUES (?, ?, ?, 0, ?, ?)')
                ->execute(['Existing', 'existing@example.invalid', 'synthetic-existing-hash',
                    '2026-01-01 00:00:00', str_repeat('a', 64)]);
            $before = $pdo->query('SELECT * FROM trip_users')->fetchAll();
        }
        $results = raceRegistration($scenario);
        $successes = array_filter($results, static fn(array $result): bool => $result['response']['status'] === 200);
        requireTest(count($successes) === ($scenario === 'existing' ? 0 : 1), 'Unexpected number of successful registrations');
        $authCount = $mailCount = $eventCount = 0;
        $rows = $pdo->query('SELECT * FROM trip_users')->fetchAll();
        requireTest(count($rows) === 1, 'Duplicate or missing user after race');
        foreach ($results as $result) {
            $authCount += count($result['auth_issued']);
            $mailCount += count($result['mail_users']);
            $eventCount += count($result['event_users']);
            if ($result['response']['status'] !== 200) {
                requireTest($result['response']['status'] === 409
                    && ($result['response']['payload']['code'] ?? '') === 'REGISTRATION_CONFLICT', 'Unexpected rejection');
                requireTest($result['auth_issued'] === [] && $result['mail_users'] === []
                    && $result['event_users'] === [], 'Rejected registration produced side effects');
            } elseif ($scenario === 'device_guest') {
                requireTest($result['auth_issued'] === [(int) $rows[0]['id']], 'Session bound to wrong account');
            } else {
                requireTest(($result['response']['payload']['code'] ?? '') === 'EMAIL_VERIFICATION_REQUIRED',
                    'Credentials registration bypassed verification');
                requireTest($result['mail_users'] === [(int) $rows[0]['id']], 'Verification bound to wrong account');
            }
        }
        requireTest($authCount === ($scenario === 'device_guest' ? 1 : 0), 'Unexpected session issuance');
        requireTest($eventCount === ($scenario === 'device_guest' ? 1 : 0), 'Unexpected registration events');
        requireTest($mailCount === (in_array($scenario, ['device_credentials', 'email_credentials'], true) ? 1 : 0),
            'Unexpected mail dispatch');
        if ($before !== null) { requireTest($before === $rows, 'Existing identity changed'); }
        echo "PASS race $round/$scenario: six workers, expected single winner or all rejected\n";
    }
}
echo "PASS: 20 registration races / 120 worker requests. No real mail or sessions issued.\n";
