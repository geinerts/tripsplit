<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

require __DIR__ . '/../Fixtures/isolated_mysql.php';
$pdo = isolated_test_mysql();
$hasNames = true;
require __DIR__ . '/../Fixtures/registration_harness.php';

$scenario = $argv[1] ?? '';
$index = (int) ($argv[2] ?? -1);
if (!in_array($scenario, ['device_guest', 'device_credentials', 'email_credentials', 'existing'], true)
    || $index < 0 || $index > 5) {
    throw new RuntimeException('Unknown worker scenario');
}
$_SERVER['HTTP_X_DEVICE_TOKEN'] = $scenario === 'email_credentials'
    ? hash('sha256', 'synthetic-worker-' . $index) : str_repeat('a', 64);
$proof = runRegistrationHandler('register_proof_action')['payload']['register_proof'];
$requestBody = ['first_name' => 'Synthetic', 'last_name' => 'Worker', 'register_proof' => $proof];
if ($scenario !== 'device_guest') {
    $requestBody['email'] = $scenario === 'email_credentials'
        ? 'shared@example.invalid' : 'worker' . $index . '@example.invalid';
    $requestBody['password'] = 'SyntheticTestPassword9!';
}

// Parent releases all ready workers together; none may mutate before the barrier opens.
echo "READY\n";
flush();
stream_set_timeout(STDIN, 20);
if (trim((string) fgets(STDIN)) !== 'GO') {
    throw new RuntimeException('Registration worker barrier timed out');
}
$response = runRegistrationHandler('register_action');
echo json_encode(['response' => $response, 'auth_issued' => $authIssued,
    'mail_users' => $verificationMail, 'event_users' => $events], JSON_THROW_ON_ERROR) . "\n";
