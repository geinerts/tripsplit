<?php
declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
require_once __DIR__ . '/../../lib/helpers/helper_email.php';

final class EmailTemplatesTest extends TestCase
{
    public static function templates(): iterable
    {
        foreach (['build_password_reset_email', 'build_account_delete_email',
            'build_email_verification_email'] as $builder) { yield $builder => [$builder]; }
    }

    #[DataProvider('templates')]
    public function test_templates_preserve_action_link_and_escape_user_input(string $builder): void
    {
        $url = 'https://example.invalid/confirm?token=synthetic-preview&next=%22test%22';
        $name = 'Matiss <script>alert("x")</script> & friends';
        $extra = match ($builder) {
            'build_email_verification_email' => [7],
            default => [],
        };
        $html = $builder($url, $name, ...$extra);
        $document = new DOMDocument();
        $document->loadHTML($html);
        $xpath = new DOMXPath($document);
        self::assertSame(0, $xpath->query('//script')->length);
        self::assertStringContainsString('&lt;script&gt;', $html);
        $actionLinks = 0;
        foreach ($xpath->query('//a') as $link) {
            if ($link->getAttribute('href') === $url) { $actionLinks++; }
        }
        self::assertSame(2, $actionLinks, 'Button and fallback must retain the exact confirmation URL.');
        self::assertSame(1, $xpath->query('//img[@alt="Splyto"]')->length);
        self::assertSame(1, $xpath->query('//meta[@name="viewport"]')->length);
        self::assertSame(1, $xpath->query('//h1')->length);
        self::assertStringContainsString('#00B8CF', $html);
        self::assertStringContainsString('#E51B88', $html);
        self::assertStringContainsString('support@splyto.eu', $html);
        self::assertLessThan(20000, strlen($html));
    }

    public function test_sensitive_instructions_and_expiry_remain_visible(): void
    {
        $reset = build_password_reset_email('https://example.invalid/reset', '');
        self::assertStringContainsString('1 hour', $reset);
        self::assertStringContainsString('Hi there,', $reset);
        self::assertStringContainsString('password will stay unchanged', $reset);
        $delete = build_account_delete_email('https://example.invalid/delete', 'Owner');
        self::assertStringContainsString('Deletion cannot be undone', $delete);
        self::assertStringContainsString('Shared trip and expense records stay available', $delete);
        self::assertStringContainsString('until you confirm', $delete);
        self::assertStringContainsString('#B83445', $delete);
    }
}
