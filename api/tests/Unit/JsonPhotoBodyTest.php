<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class JsonPhotoBodyTest extends TestCase
{
    public function test_large_photos_have_a_bounded_opt_in_without_relaxing_other_actions(): void
    {
        $socket = stream_socket_server('tcp://127.0.0.1:0', $errno, $error);
        self::assertIsResource($socket, $error);
        $address = stream_socket_get_name($socket, false);
        fclose($socket);
        $process = proc_open(
            [PHP_BINARY, '-S', $address, __DIR__ . '/../Fixtures/json_body_http.php'],
            [0 => ['pipe', 'r'], 1 => ['file', '/dev/null', 'w'], 2 => ['file', '/dev/null', 'w']],
            $pipes,
        );
        self::assertIsResource($process);
        fclose($pipes[0]);
        try {
            $ready = false;
            for ($i = 0; $i < 100; $i++) {
                $connection = @stream_socket_client('tcp://' . $address, $errno, $error, 0.05);
                if ($connection !== false) { fclose($connection); $ready = true; break; }
                usleep(20_000);
            }
            self::assertTrue($ready, 'Isolated HTTP test server did not start');
            $photo = base64_encode(str_repeat('x', 524_288));
            $payload = json_encode(['photo_base64' => $photo, 'city' => 'Lisbon'], JSON_THROW_ON_ERROR);
            foreach (['', '&no_length=1'] as $lengthMode) {
                [$status, $body] = $this->post($address, '?photo=1' . $lengthMode, $payload);
                self::assertSame(200, $status);
                self::assertSame(strlen($photo), $body['bytes']);
                self::assertSame(413, $this->post($address, '?' . ltrim($lengthMode, '&'), $payload)[0]);
                self::assertSame(413, $this->post($address, '?photo=1' . $lengthMode, str_repeat('x', 720_897))[0]);
            }
            self::assertSame(400, $this->post($address, '?photo=1', '{broken')[0]);
            self::assertSame(200, $this->post($address, '', '{"city":"Lisbon"}')[0]);
        } finally {
            proc_terminate($process);
            proc_close($process);
        }
    }

    private function post(string $address, string $query, string $payload): array
    {
        $context = stream_context_create(['http' => [
            'method' => 'POST', 'header' => "Content-Type: application/json\r\nConnection: close",
            'content' => $payload, 'ignore_errors' => true, 'timeout' => 5,
        ]]);
        $stream = fopen('http://' . $address . '/' . $query, 'rb', false, $context);
        self::assertIsResource($stream);
        $response = stream_get_contents($stream);
        $headers = stream_get_meta_data($stream)['wrapper_data'];
        fclose($stream);
        preg_match('/\s(\d{3})\s/', $headers[0], $match);
        self::assertIsString($response);
        return [(int)$match[1], json_decode($response, true, 512, JSON_THROW_ON_ERROR)];
    }
}
