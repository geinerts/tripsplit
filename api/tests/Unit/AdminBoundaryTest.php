<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class AdminBoundaryTest extends TestCase
{
    private function server(array $overrides = []): array
    {
        return array_replace([
            'SERVER_NAME' => 'ops.splyto.eu', 'HTTP_HOST' => 'ops.splyto.eu',
            'HTTPS' => 'on', 'REQUEST_METHOD' => 'POST',
            'HTTP_ORIGIN' => 'https://ops.splyto.eu', 'HTTP_SEC_FETCH_SITE' => 'same-origin',
        ], $overrides);
    }

    public function test_dedicated_https_vhost_and_origin_are_allowed(): void
    {
        foreach (['ops.splyto.eu', 'OPS.SPLYTO.EU', 'ops.splyto.eu:443'] as $host) {
            $server = $this->server(['HTTP_HOST' => $host]);
            self::assertTrue(admin_request_is_on_private_host($server));
            self::assertTrue(admin_request_has_same_origin($server));
        }
        self::assertTrue(admin_request_has_same_origin($this->server(['HTTP_ORIGIN' => 'https://ops.splyto.eu:443'])));
    }

    public function test_public_vhost_cannot_be_overridden_with_host_or_proxy_headers(): void
    {
        foreach (['splyto.eu', 'www.splyto.eu', 'dev.egm.lv', '', 'ops.splyto.eu.attacker.invalid'] as $vhost) {
            $server = $this->server([
                'SERVER_NAME' => $vhost,
                'HTTP_X_FORWARDED_HOST' => 'ops.splyto.eu',
                'HTTP_FORWARDED' => 'host=ops.splyto.eu;proto=https',
            ]);
            self::assertFalse(admin_request_is_on_private_host($server));
            self::assertFalse(admin_request_has_same_origin($server));
        }
    }

    public function test_invalid_hosts_and_cleartext_are_denied(): void
    {
        foreach (['', 'splyto.eu', 'ops.splyto.eu:80', 'ops.splyto.eu.', 'ops.splyto.eu,evil.invalid', 'ops.splyto.eu@evil.invalid'] as $host) {
            self::assertFalse(admin_request_is_on_private_host($this->server(['HTTP_HOST' => $host])));
        }
        foreach (['', 'off', 'https'] as $https) {
            self::assertFalse(admin_request_is_on_private_host($this->server([
                'HTTPS' => $https, 'HTTP_X_FORWARDED_PROTO' => 'https',
            ])));
        }
    }

    public function test_missing_foreign_and_malformed_write_origins_are_denied(): void
    {
        foreach (['', 'null', 'https://splyto.eu', 'http://ops.splyto.eu', 'https://ops.splyto.eu/', 'https://ops.splyto.eu:444', 'https://ops.splyto.eu.evil.invalid'] as $origin) {
            self::assertFalse(admin_request_has_same_origin($this->server(['HTTP_ORIGIN' => $origin])));
        }
        foreach (['cross-site', 'same-site'] as $site) {
            self::assertFalse(admin_request_has_same_origin($this->server(['HTTP_SEC_FETCH_SITE' => $site])));
        }
    }

    public function test_every_admin_route_is_hidden_on_public_api_before_handlers_run(): void
    {
        $previous = $_SERVER;
        try {
            $_SERVER = $this->server(['SERVER_NAME' => 'splyto.eu', 'HTTP_HOST' => 'splyto.eu']);
            $count = 0;
            foreach (array_keys(api_action_handlers()) as $action) {
                if (str_starts_with($action, 'admin_panel_')) {
                    self::assertFalse(dispatch_api_action($action), $action);
                    $count++;
                }
            }
            self::assertGreaterThan(30, $count);
        } finally {
            $_SERVER = $previous;
        }
    }

    public function test_cross_origin_admin_post_is_stopped_before_authentication(): void
    {
        $previous = $_SERVER;
        try {
            $_SERVER = $this->server(['HTTP_ORIGIN' => 'https://splyto.eu']);
            dispatch_api_action('admin_panel_login');
            self::fail('Cross-origin login should not run.');
        } catch (ApiResponseException $response) {
            self::assertSame(403, $response->statusCode);
        } finally {
            $_SERVER = $previous;
        }
    }
}
