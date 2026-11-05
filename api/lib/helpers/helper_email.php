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

function email_template_escape(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function build_email_brand_logo_html(): string
{
    $baseUrl = defined('PUBLIC_BASE_URL') ? trim(PUBLIC_BASE_URL) : '';
    if ($baseUrl === '') { $baseUrl = defined('APP_BASE_URL') ? trim(APP_BASE_URL) : ''; }
    if ($baseUrl === '') { $baseUrl = 'https://splyto.eu'; }
    $logoUrl = email_template_escape(rtrim($baseUrl, '/') . '/mobile/assets/branding/logo_full.png');
    return '<img src="' . $logoUrl . '" alt="Splyto" width="156" height="62" '
        . 'style="display:block;border:0;outline:none;text-decoration:none;width:156px;height:62px;">';
}

/** Shared, table-based account email. All supplied text and links are escaped here. */
function build_account_email_template(
    string $title,
    string $firstName,
    string $message,
    string $actionLabel,
    string $actionUrl,
    string $notice,
    string $preheader,
    bool $destructive = false
): string {
    $title = email_template_escape($title);
    $greeting = trim($firstName) === '' ? 'Hi there,' : 'Hi ' . trim($firstName) . ',';
    $greeting = email_template_escape($greeting);
    $message = email_template_escape($message);
    $actionLabel = email_template_escape($actionLabel);
    $url = email_template_escape($actionUrl);
    $notice = email_template_escape($notice);
    $preheader = email_template_escape($preheader);
    $logo = build_email_brand_logo_html();
    $buttonColor = $destructive ? '#B83445' : '#008576';

    return <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="color-scheme" content="light">
  <meta name="supported-color-schemes" content="light">
  <title>{$title}</title>
  <style>
    body, table, td, a { -webkit-text-size-adjust:100%; -ms-text-size-adjust:100%; }
    table { border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt; }
    @media only screen and (max-width:600px) {
      .email-outer { padding:20px 12px !important; }
      .email-content { padding:28px 24px !important; }
      .email-header { padding:26px 24px 22px !important; }
      .email-title { font-size:28px !important; line-height:34px !important; }
    }
  </style>
</head>
<body style="margin:0;padding:0;width:100%;background-color:#F2F6F5;font-family:Arial,Helvetica,sans-serif;color:#193149;">
  <div style="display:none;font-size:1px;line-height:1px;color:#F2F6F5;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">{$preheader}</div>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" bgcolor="#F2F6F5">
    <tr><td class="email-outer" align="center" style="padding:40px 16px;">
      <!--[if mso]><table role="presentation" width="560"><tr><td><![endif]-->
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;max-width:560px;">
        <tr><td bgcolor="#FFFFFF" style="background-color:#FFFFFF;border:1px solid #DFE8E5;border-radius:20px;overflow:hidden;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
            <tr><td class="email-header" style="padding:30px 36px 26px;">
              {$logo}
            </td></tr>
            <tr><td style="padding:0 36px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td width="76%" height="3" bgcolor="#008576" style="height:3px;font-size:0;line-height:0;">&nbsp;</td>
                  <td width="16%" height="3" bgcolor="#00B8CF" style="height:3px;font-size:0;line-height:0;">&nbsp;</td>
                  <td width="8%" height="3" bgcolor="#E51B88" style="height:3px;font-size:0;line-height:0;">&nbsp;</td>
                </tr>
              </table>
            </td></tr>
            <tr><td class="email-content" style="padding:34px 36px 32px;">
              <p style="margin:0 0 14px;font-size:11px;line-height:16px;letter-spacing:2px;font-weight:bold;color:#008576;">YOUR SPLYTO ACCOUNT</p>
              <h1 class="email-title" style="margin:0 0 24px;font-size:32px;line-height:38px;letter-spacing:-0.8px;font-weight:700;color:#193149;">{$title}</h1>
              <p style="margin:0 0 10px;font-size:16px;line-height:25px;font-weight:bold;color:#193149;">{$greeting}</p>
              <p style="margin:0 0 26px;font-size:15px;line-height:25px;color:#53626B;">{$message}</p>
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr><td align="center" bgcolor="{$buttonColor}" style="background-color:{$buttonColor};border-radius:12px;mso-padding-alt:17px 20px;">
                  <a href="{$url}" style="display:block;padding:17px 20px;border:1px solid {$buttonColor};border-radius:12px;font-family:Arial,Helvetica,sans-serif;font-size:16px;line-height:22px;font-weight:bold;text-align:center;color:#FFFFFF;text-decoration:none;">{$actionLabel}</a>
                </td></tr>
                <tr><td height="24" style="height:24px;font-size:0;line-height:0;">&nbsp;</td></tr>
                <tr><td bgcolor="#EAF8FA" style="background-color:#EAF8FA;border-left:3px solid #00B8CF;padding:16px 18px;font-size:13px;line-height:21px;color:#365361;">{$notice}</td></tr>
              </table>
              <p style="margin:26px 0 7px;font-size:12px;line-height:19px;color:#68777D;">Button not opening? Copy this link into your browser:</p>
              <p style="margin:0;font-size:12px;line-height:19px;word-break:break-all;overflow-wrap:anywhere;"><a href="{$url}" style="color:#007A6D;text-decoration:underline;word-break:break-all;overflow-wrap:anywhere;">{$url}</a></p>
            </td></tr>
            <tr><td align="center" style="border-top:1px solid #E7EEEB;padding:20px 24px;">
              <p style="margin:0;font-size:12px;line-height:20px;color:#68777D;">Need a hand? <a href="mailto:support@splyto.eu" style="color:#007A6D;text-decoration:none;">support@splyto.eu</a></p>
            </td></tr>
          </table>
        </td></tr>
        <tr><td align="center" style="padding:22px 12px 0;">
          <p style="margin:0;font-size:12px;line-height:20px;color:#68777D;">Splyto &middot; Settle fast. Stay friends.</p>
          <p style="margin:4px 0 0;font-size:11px;line-height:18px;"><a href="https://splyto.eu" style="color:#68777D;text-decoration:none;">splyto.eu</a></p>
        </td></tr>
      </table>
      <!--[if mso]></td></tr></table><![endif]-->
    </td></tr>
  </table>
</body>
</html>
HTML;
}

function build_password_reset_email(string $resetUrl, string $firstName): string
{
    return build_account_email_template(
        'Set a new password', $firstName,
        'Choose a new password for your Splyto account. Your trips, friends and expenses will stay just as they are.',
        'Set password', $resetUrl,
        'This link expires in 1 hour. If you did not request it, ignore this email. Your password will stay unchanged.',
        'Your link to choose a new Splyto password. Valid for 1 hour.'
    );
}

function build_email_verification_email(string $verifyUrl, string $firstName, int $graceDays): string
{
    $days = $graceDays > 0 ? $graceDays : 7;
    return build_account_email_template(
        'One last step. You’re in.', $firstName,
        'Confirm your email address to activate your Splyto account and start sharing trips and expenses.',
        'Verify email', $verifyUrl,
        'Please verify within ' . $days . ' days to keep your account active. If you did not create this account, ignore this email.',
        'Confirm your email address to get started with Splyto.'
    );
}

function build_account_delete_email(string $deleteUrl, string $firstName): string
{
    return build_account_email_template(
        'Before you go.', $firstName,
        'You asked to delete your Splyto account. Confirm on the next page to permanently remove access and anonymize your profile. Shared trip and expense records stay available to other members.',
        'Review account deletion', $deleteUrl,
        'Deletion cannot be undone. This link works once. Your account is still active until you confirm. If you did not request this or changed your mind, ignore this email.',
        'Review your account deletion request. Nothing changes until you confirm.',
        true
    );
}
