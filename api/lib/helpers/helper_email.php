<?php
declare(strict_types=1);

/**
 * Resend email helper — sends transactional emails via Resend API.
 */
function send_email_via_resend(string $to, string $subject, string $htmlBody): bool
{
    $apiKey = RESEND_API_KEY;
    $fromAddress = RESEND_FROM_ADDRESS;

    if ($apiKey === '' || $fromAddress === '') {
        error_log('[email] Resend API key or from address not configured.');
        return false;
    }

    $payload = json_encode([
        'from'    => $fromAddress,
        'to'      => [$to],
        'subject' => $subject,
        'html'    => $htmlBody,
    ]);

    $context = stream_context_create([
        'http' => [
            'method'        => 'POST',
            'header'        => implode("\r\n", [
                'Authorization: Bearer ' . $apiKey,
                'Content-Type: application/json',
                'Content-Length: ' . strlen($payload),
            ]),
            'content'       => $payload,
            'timeout'       => 10,
            'ignore_errors' => true,
        ],
    ]);

    $response = @file_get_contents('https://api.resend.com/emails', false, $context);

    if ($response === false) {
        error_log('[email] Resend request failed (network error).');
        return false;
    }

    $decoded = json_decode($response, true);
    if (!is_array($decoded) || isset($decoded['statusCode']) && (int) $decoded['statusCode'] >= 400) {
        error_log('[email] Resend error: ' . $response);
        return false;
    }

    return true;
}

function build_password_reset_email(string $resetUrl, string $firstName): string
{
    $name = htmlspecialchars($firstName, ENT_QUOTES, 'UTF-8');
    $url  = htmlspecialchars($resetUrl, ENT_QUOTES, 'UTF-8');

    return <<<HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Reset your password</title>
    </head>
    <body style="margin:0;padding:0;background:#f4f4f5;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f5;padding:40px 0;">
        <tr><td align="center">
          <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">

            <!-- Header -->
            <tr>
              <td style="background:linear-gradient(135deg,#BFE9D3,#57B487);padding:32px;text-align:center;">
                <span style="font-size:28px;font-weight:800;color:#1a3d2b;letter-spacing:-0.5px;">SPLYTO</span>
              </td>
            </tr>

            <!-- Body -->
            <tr>
              <td style="padding:40px 36px;">
                <h2 style="margin:0 0 16px;font-size:22px;color:#111827;">Reset your password</h2>
                <p style="margin:0 0 24px;font-size:15px;color:#4b5563;line-height:1.6;">
                  Hi {$name}, we received a request to reset your Splyto password.
                  Click the button below — the link expires in <strong>1 hour</strong>.
                </p>

                <!-- Button -->
                <table cellpadding="0" cellspacing="0" style="margin:0 0 32px;">
                  <tr>
                    <td style="background:linear-gradient(135deg,#57B487,#2D7A5E);border-radius:10px;">
                      <a href="{$url}" style="display:inline-block;padding:14px 32px;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;">
                        Reset password
                      </a>
                    </td>
                  </tr>
                </table>

                <p style="margin:0 0 8px;font-size:13px;color:#9ca3af;">
                  If you didn't request this, you can safely ignore this email.
                </p>
                <p style="margin:0;font-size:13px;color:#9ca3af;">
                  Or copy this link: <span style="color:#2D7A5E;">{$url}</span>
                </p>
              </td>
            </tr>

            <!-- Footer -->
            <tr>
              <td style="padding:20px 36px;border-top:1px solid #f3f4f6;text-align:center;">
                <p style="margin:0;font-size:12px;color:#9ca3af;">© Splyto · splyto.egm.lv</p>
              </td>
            </tr>

          </table>
        </td></tr>
      </table>
    </body>
    </html>
    HTML;
}

function build_account_reactivation_email(string $reactivateUrl, string $firstName): string
{
    $name = htmlspecialchars($firstName, ENT_QUOTES, 'UTF-8');
    $url  = htmlspecialchars($reactivateUrl, ENT_QUOTES, 'UTF-8');

    return <<<HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Reactivate your account</title>
    </head>
    <body style="margin:0;padding:0;background:#f4f4f5;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f5;padding:40px 0;">
        <tr><td align="center">
          <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
            <tr>
              <td style="background:linear-gradient(135deg,#BFE9D3,#57B487);padding:32px;text-align:center;">
                <span style="font-size:28px;font-weight:800;color:#1a3d2b;letter-spacing:-0.5px;">SPLYTO</span>
              </td>
            </tr>
            <tr>
              <td style="padding:40px 36px;">
                <h2 style="margin:0 0 16px;font-size:22px;color:#111827;">Reactivate your account</h2>
                <p style="margin:0 0 24px;font-size:15px;color:#4b5563;line-height:1.6;">
                  Hi {$name}, your account is currently deactivated.
                  Click below to restore access.
                </p>
                <table cellpadding="0" cellspacing="0" style="margin:0 0 32px;">
                  <tr>
                    <td style="background:linear-gradient(135deg,#57B487,#2D7A5E);border-radius:10px;">
                      <a href="{$url}" style="display:inline-block;padding:14px 32px;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;">
                        Reactivate account
                      </a>
                    </td>
                  </tr>
                </table>
                <p style="margin:0;font-size:13px;color:#9ca3af;">
                  Or copy this link: <span style="color:#2D7A5E;">{$url}</span>
                </p>
              </td>
            </tr>
          </table>
        </td></tr>
      </table>
    </body>
    </html>
    HTML;
}

function build_account_delete_email(string $deleteUrl, string $firstName): string
{
    $name = htmlspecialchars($firstName, ENT_QUOTES, 'UTF-8');
    $url  = htmlspecialchars($deleteUrl, ENT_QUOTES, 'UTF-8');

    return <<<HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Confirm account deletion</title>
    </head>
    <body style="margin:0;padding:0;background:#f4f4f5;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;">
      <table width="100%" cellpadding="0" cellspacing="0" style="background:#f4f4f5;padding:40px 0;">
        <tr><td align="center">
          <table width="480" cellpadding="0" cellspacing="0" style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 2px 8px rgba(0,0,0,0.08);">
            <tr>
              <td style="background:linear-gradient(135deg,#ffd6d6,#ef4444);padding:32px;text-align:center;">
                <span style="font-size:28px;font-weight:800;color:#7f1d1d;letter-spacing:-0.5px;">SPLYTO</span>
              </td>
            </tr>
            <tr>
              <td style="padding:40px 36px;">
                <h2 style="margin:0 0 16px;font-size:22px;color:#111827;">Confirm permanent deletion</h2>
                <p style="margin:0 0 24px;font-size:15px;color:#4b5563;line-height:1.6;">
                  Hi {$name}, this action permanently deletes your account access and anonymizes your profile data.
                  This cannot be undone.
                </p>
                <table cellpadding="0" cellspacing="0" style="margin:0 0 32px;">
                  <tr>
                    <td style="background:#dc2626;border-radius:10px;">
                      <a href="{$url}" style="display:inline-block;padding:14px 32px;font-size:15px;font-weight:600;color:#ffffff;text-decoration:none;">
                        Delete account permanently
                      </a>
                    </td>
                  </tr>
                </table>
                <p style="margin:0;font-size:13px;color:#9ca3af;">
                  Or copy this link: <span style="color:#b91c1c;">{$url}</span>
                </p>
              </td>
            </tr>
          </table>
        </td></tr>
      </table>
    </body>
    </html>
    HTML;
}
