<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/web/splyto_share_page_text.php';

final class SharePageTextTest extends TestCase
{
    public function test_every_language_has_every_text(): void
    {
        self::assertCount(16, SPLYTO_SHARE_PAGE_TEXT);
        $keys = array_keys(SPLYTO_SHARE_PAGE_TEXT['en']);
        foreach (SPLYTO_SHARE_PAGE_TEXT as $language => $text) {
            self::assertSame($keys, array_keys($text), $language);
            foreach ($text as $key => $value) {
                self::assertNotSame('', trim($value), "$language $key");
            }
            self::assertStringContainsString('SPLYTO', $text['install'], $language);
        }
    }

    public function test_language_comes_from_the_browser_with_english_as_fallback(): void
    {
        self::assertSame('lv', splyto_share_page_language('lv-LV,lv;q=0.9,en;q=0.8'));
        self::assertSame('de', splyto_share_page_language('ja,de;q=0.7,en;q=0.5'));
        self::assertSame('en', splyto_share_page_language('en;q=0.9,de;q=0.1'));
        self::assertSame('nb', splyto_share_page_language('no'));
        self::assertSame('en', splyto_share_page_language('ja'));
        self::assertSame('en', splyto_share_page_language(''));
    }

    public function test_only_an_https_ios_link_is_offered(): void
    {
        foreach (['' => SPLYTO_IOS_INSTALL_URL, 'javascript:alert(1)' => '', 'https://testflight.apple.com/join/x' => 'https://testflight.apple.com/join/x'] as $value => $expected) {
            putenv('TRIP_IOS_INSTALL_URL=' . $value);
            self::assertSame($expected, splyto_app_install_links()['ios']);
        }
        putenv('TRIP_IOS_INSTALL_URL');
        self::assertSame(SPLYTO_IOS_INSTALL_URL, splyto_app_install_links()['ios']);
    }
}
