<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class ReceiptMediaEndpointTest extends TestCase
{
    private string $root;
    private string $png;
    private const SECRET = 'receipt-endpoint-test-secret-not-for-production';

    protected function setUp(): void
    {
        $this->root = sys_get_temp_dir() . '/splyto-media-test-' . bin2hex(random_bytes(8));
        mkdir($this->root . '/api/config', 0700, true);
        mkdir($this->root . '/uploads/receipts', 0700, true);
        copy(__DIR__ . '/../../receipt-media.php', $this->root . '/api/receipt-media.php');
        copy(__DIR__ . '/../../config/config_uploads.php', $this->root . '/api/config/config_uploads.php');
        file_put_contents($this->root . '/api/api.php', '<?php');
        file_put_contents($this->root . '/api/config.php', '<?php '
            . 'define("RECEIPTS_REL_DIR", "uploads/receipts"); '
            . 'define("PRIVATE_MEDIA_SIGNING_SECRET", ' . var_export(self::SECRET, true) . '); '
            . 'define("PRIVATE_MEDIA_URL_TTL_SEC", 900); '
            . 'define("APP_DEBUG", false); '
            . 'require __DIR__ . "/config/config_uploads.php";');
        $this->png = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=', true);
        file_put_contents($this->root . '/uploads/receipts/example.png', $this->png);
        file_put_contents($this->root . '/outside.png', $this->png);
        symlink($this->root . '/outside.png', $this->root . '/uploads/receipts/escape.png');
    }

    protected function tearDown(): void
    {
        $files = new RecursiveIteratorIterator(
            new RecursiveDirectoryIterator($this->root, FilesystemIterator::SKIP_DOTS),
            RecursiveIteratorIterator::CHILD_FIRST
        );
        foreach ($files as $file) {
            if ($file->isDir() && !$file->isLink()) {
                rmdir($file->getPathname());
            } else {
                unlink($file->getPathname());
            }
        }
        rmdir($this->root);
    }

    private function signedQuery(string $path, ?int $expires = null): array
    {
        $expires ??= time() + 300;
        return [
            'path' => $path,
            'expires' => (string) $expires,
            'signature' => hash_hmac('sha256', "receipt\n" . $expires . "\n" . $path, self::SECRET),
        ];
    }

    private function request(array $query, string $method = 'GET'): array
    {
        $program = '$_GET = ' . var_export($query, true) . '; '
            . '$_SERVER["REQUEST_METHOD"] = ' . var_export($method, true) . '; '
            . 'ob_start(); register_shutdown_function(static function(): void {'
            . '$body = ob_get_clean(); echo json_encode(["status" => http_response_code() ?: 200, "body" => base64_encode($body)]); }); '
            . 'require ' . var_export($this->root . '/api/receipt-media.php', true) . ';';
        $process = proc_open([PHP_BINARY, '-d', 'display_errors=0', '-r', $program],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        return json_decode($output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_valid_signed_receipt_returns_original_image_bytes(): void
    {
        $response = $this->request($this->signedQuery('uploads/receipts/example.png'));
        self::assertSame(200, $response['status']);
        self::assertSame($this->png, base64_decode($response['body'], true));
    }

    public function test_expired_tampered_missing_and_escaped_receipts_are_indistinguishable(): void
    {
        $tampered = $this->signedQuery('uploads/receipts/example.png');
        $tampered['signature'] = str_repeat('0', 64);
        $queries = [
            [],
            ['path' => ['unexpected'], 'expires' => ['unexpected'], 'signature' => ['unexpected']],
            $tampered,
            $this->signedQuery('uploads/receipts/example.png', time() - 60),
            $this->signedQuery('uploads/receipts/missing.png'),
            $this->signedQuery('uploads/receipts/escape.png'),
            $this->signedQuery('uploads/receipts/../../outside.png'),
            $this->signedQuery('uploads/receipts/.env'),
        ];
        foreach ($queries as $query) {
            $response = $this->request($query);
            self::assertSame(404, $response['status']);
            self::assertSame('Not found.', base64_decode($response['body'], true));
        }
    }

    public function test_post_cannot_read_receipt_even_with_valid_signature(): void
    {
        $response = $this->request($this->signedQuery('uploads/receipts/example.png'), 'POST');
        self::assertSame(404, $response['status']);
    }
}
