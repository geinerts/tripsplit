<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;
require_once __DIR__ . '/../../lib/helpers/helper_share_preview.php';
final class ShareImageEncodingTest extends TestCase
{
    protected function setUp(): void
    {
        if (!extension_loaded('gd')) self::markTestSkipped('GD required for preview encoding.');
    }
    public function test_qr_png_preserves_every_pixel_and_dimensions(): void
    {
        $image = share_create_canvas();
        share_fill_gradient($image, '#03100b', '#173825');
        share_draw_qr($image, 'https://splyto.example/friend?code=synthetic', 30, 30, 420);
        ob_start(); imagepng($image); $before = ob_get_clean();
        $bytes = share_encode_image($image);
        self::assertLessThan(strlen($before), strlen($bytes));
        self::assertSame('image/png', getimagesizefromstring($bytes)['mime']);
        $decoded = imagecreatefromstring($bytes);
        self::assertSame(1200, imagesx($decoded));
        self::assertSame(630, imagesy($decoded));
        $differences = 0;
        for ($y = 0; $y < 630; $y++) {
            for ($x = 0; $x < 1200; $x++) {
                if ((imagecolorat($image, $x, $y) & 0xffffff) !== (imagecolorat($decoded, $x, $y) & 0xffffff)) $differences++;
            }
        }
        self::assertSame(0, $differences, 'QR and text pixels must remain lossless.');
    }
    public function test_jpeg_preserves_dimensions_and_is_not_progressive(): void
    {
        $image = share_create_canvas();
        share_fill_gradient($image, '#102030', '#50a0e0');
        $jpeg = share_encode_image($image, 'jpeg');
        self::assertSame('image/jpeg', getimagesizefromstring($jpeg)['mime']);
        $decoded = imagecreatefromstring($jpeg);
        self::assertSame(1200, imagesx($decoded));
        self::assertSame(630, imagesy($decoded));
        self::assertFalse(imageinterlace($decoded));
    }
    public function test_open_graph_mime_matches_format_and_rejects_arbitrary_attributes(): void
    {
        $args = ['A trip', '', 'https://splyto.example/invite', 'https://splyto.example/share-image.php?format=jpeg&v=trip5'];
        self::assertStringContainsString('content="image/jpeg"', share_open_graph_tags(...[...$args, 'image/jpeg']));
        self::assertStringContainsString('content="image/png"', share_open_graph_tags(...$args));
        $html = share_open_graph_tags(...[...$args, '\"><script>']);
        self::assertStringNotContainsString('<script>', $html);
        self::assertStringContainsString('&amp;v=trip5', $html);
    }
}
