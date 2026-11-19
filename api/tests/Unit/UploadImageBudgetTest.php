<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class UploadImageBudgetTest extends TestCase
{
    private string $dir;
    protected function setUp(): void
    {
        $this->dir = sys_get_temp_dir() . '/splyto-image-budget-' . bin2hex(random_bytes(8));
        mkdir($this->dir, 0700);
        foreach (['CLASS_UPLOAD_REL_PATH' => 'api/lib/verot/class.upload.php',
            'UPLOAD_IMAGE_WEBP_QUALITY' => 85, 'UPLOAD_IMAGE_THUMB_MAX_SIDE' => 320,
            'UPLOAD_IMAGE_THUMB_WEBP_QUALITY' => 80] as $key => $value) {
            if (!defined($key)) { define($key, $value); }
        }
    }
    protected function tearDown(): void
    {
        foreach (glob($this->dir . '/*') as $file) { unlink($file); }
        rmdir($this->dir);
    }
    private function png(int $width, int $height): string
    {
        $chunk = static fn(string $type, string $body): string => pack('N', strlen($body))
            . $type . $body . pack('N', crc32($type . $body));
        // Valid one-colour palette PNG; construct compressed scanlines without decoding pixels.
        $file = $this->dir . '/' . $width . '-' . $height . '.png';
        file_put_contents($file, "\x89PNG\r\n\x1a\n"
            . $chunk('IHDR', pack('NNCCCCC', $width, $height, 8, 3, 0, 0, 0))
            . $chunk('PLTE', "\0\0\0")
            . $chunk('IDAT', gzcompress(str_repeat("\0", ($width + 1) * $height)))
            . $chunk('IEND', ''));
        return $file;
    }
    public function test_compressed_large_images_cannot_reach_any_conversion_or_storage_path(): void
    {
        foreach ([[4000, 3001], [12001, 1]] as [$width, $height]) {
            $file = $this->png($width, $height);
            self::assertLessThan(100_000, filesize($file));
            self::assertFalse(upload_image_within_decode_budget($file));
            self::assertNull(decode_image_from_upload($file));
            $target = $this->dir . '/out.webp';
            self::assertFalse(convert_uploaded_image_to_webp_via_class_upload($file, $target, 'image/png'));
            self::assertFalse(convert_uploaded_image_to_webp($file, $target, 'image/png'));
            self::assertFalse(create_webp_thumbnail($file, $target));
            self::assertFileDoesNotExist($target);
            $ensured = false;
            try {
                store_uploaded_image_as_webp($file, 'uploads/receipts', static function () use (&$ensured): void { $ensured = true; }, 'image/png');
                self::fail('Oversized image was accepted');
            } catch (ApiResponseException $e) { self::assertSame(400, $e->statusCode); }
            self::assertFalse($ensured);
        }
    }
    public function test_normal_jpeg_png_and_webp_still_decode_convert_and_thumbnail(): void
    {
        foreach (['png', 'jpeg', 'webp'] as $format) {
            $file = $this->dir . '/small.' . $format;
            $image = imagecreatetruecolor(120, 80);
            ('image' . $format)($image, $file);
            unset($image);
            self::assertTrue(upload_image_within_decode_budget($file));
            $decoded = decode_image_from_upload($file);
            self::assertInstanceOf(GdImage::class, $decoded);
            self::assertSame(120, imagesx($decoded));
            unset($decoded);
            $target = $this->dir . '/' . $format . '.webp';
            self::assertTrue(convert_uploaded_image_to_webp($file, $target, 'image/' . $format));
            self::assertTrue(create_webp_thumbnail($target, $this->dir . '/' . $format . '-thumb.webp'));
        }
    }
    public function test_bad_metadata_is_rejected_without_decoder_output(): void
    {
        $file = $this->dir . '/invalid.png';
        file_put_contents($file, 'not an image');
        self::assertFalse(upload_image_within_decode_budget($file));
        self::assertNull(decode_image_from_upload($file));
    }
}
