<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class PushLocalizationTest extends TestCase
{
    public function test_all_supported_locales_preserve_dynamic_payment_details(): void
    {
        foreach (['en', 'lv', 'es', 'de', 'fr', 'it', 'pt', 'pl', 'nl', 'sv', 'da', 'nb', 'fi', 'cs', 'uk', 'ru'] as $locale) {
            self::assertSame($locale, normalize_push_locale_code($locale . '-XX'));
            $result = push_localize_notification_for_locale([
                'type' => 'payment_requested', 'title' => 'Payment requested',
                'body' => 'Matīss requested €12.50 from you.',
            ], $locale);
            self::assertNotEmpty($result['title']);
            self::assertStringContainsString('Matīss', $result['body']);
            self::assertStringContainsString('€12.50', $result['body']);
            self::assertStringNotContainsString('{', $result['body']);
            $catalog = json_decode(file_get_contents(__DIR__ . '/../../lib/helpers/push/locales/' . $locale . '.json'), true, 512, JSON_THROW_ON_ERROR);
            $english = json_decode(file_get_contents(__DIR__ . '/../../lib/helpers/push/locales/en.json'), true, 512, JSON_THROW_ON_ERROR);
            self::assertSame(array_keys($english), array_keys($catalog));
            foreach ($english as $key => $text) {
                preg_match_all('/\{\w+\}/', $text, $expected);
                preg_match_all('/\{\w+\}/', $catalog[$key], $actual);
                sort($expected[0]); sort($actual[0]);
                self::assertSame($expected[0], $actual[0], $locale . ':' . $key);
            }
        }
    }
    public function test_locale_alias_and_untrusted_locale_fallback(): void
    {
        self::assertSame('nb', normalize_push_locale_code('no_NO'));
        self::assertSame('en', normalize_push_locale_code('ja'));
        self::assertSame('en', normalize_push_locale_code('../../config'));
        self::assertSame('en', normalize_push_locale_code(null));
    }
}
