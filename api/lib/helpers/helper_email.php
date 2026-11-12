<?php
declare(strict_types=1);

/**
 * Resend email helper — sends transactional emails via Resend API.
 */
function send_email_via_resend(string $to, string $subject, string $htmlBody, array $attachments = []): bool
{
    $apiKey = RESEND_API_KEY;
    $fromAddress = RESEND_FROM_ADDRESS;

    if ($apiKey === '' || $fromAddress === '') {
        error_log('[email] Resend API key or from address not configured.');
        return false;
    }

    // Each attachment is ['filename' => string, 'content' => base64 string].
    $message = [
        'from'    => $fromAddress,
        'to'      => [$to],
        'subject' => $subject,
        'html'    => $htmlBody,
    ];
    if ($attachments) {
        $message['attachments'] = $attachments;
    }
    $payload = json_encode($message);

    $context = stream_context_create([
        'http' => [
            'method'        => 'POST',
            'header'        => implode("\r\n", [
                'Authorization: Bearer ' . $apiKey,
                'Content-Type: application/json',
                'Content-Length: ' . strlen($payload),
            ]),
            'content'       => $payload,
            'timeout'       => $attachments ? 30 : 10,
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

function email_asset_base_url(): string
{
    $baseUrl = defined('PUBLIC_BASE_URL') ? trim(PUBLIC_BASE_URL) : '';
    if ($baseUrl === '') { $baseUrl = defined('APP_BASE_URL') ? trim(APP_BASE_URL) : ''; }
    if ($baseUrl === '') { $baseUrl = 'https://splyto.eu'; }
    return rtrim($baseUrl, '/');
}

function build_email_brand_logo_html(): string
{
    $logoUrl = email_template_escape(email_asset_base_url() . '/email-logo-dark-v2.png');
    // Same light logo as the app's dark theme. It always sits on the fixed dark header band,
    // so it stays legible whether or not the mail client re-colors the message.
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
    // Clients with forced dark mode (Outlook, some Gmail apps, Resend's preview) invert
    // background colours but never images, so the header's dark band is also an image.
    $headerBg = email_template_escape(email_asset_base_url() . '/email-header-bg-v1.png');
    $buttonColor = $destructive ? '#B83445' : '#008576';

    return <<<HTML
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="color-scheme" content="light dark">
  <meta name="supported-color-schemes" content="light dark">
  <title>{$title}</title>
  <style>
    body, table, td, a { -webkit-text-size-adjust:100%; -ms-text-size-adjust:100%; }
    table { border-collapse:collapse; mso-table-lspace:0pt; mso-table-rspace:0pt; }
    :root { color-scheme:light dark; supported-color-schemes:light dark; }
    @media (prefers-color-scheme: dark) {
      body, .bg-page { background-color:#0F1A22 !important; }
      .card { background-color:#17232E !important; border-color:#26394A !important; }
      .email-title, .t-strong { color:#FFFFFF !important; }
      .t-body { color:#C3D0D6 !important; }
      .t-muted { color:#8FA3AD !important; }
      .notice { background-color:#122A35 !important; color:#C3D6DD !important; }
      .footer-row { border-top-color:#26394A !important; }
      .link { color:#4FD1C5 !important; }
    }
    @media only screen and (max-width:600px) {
      .email-outer { padding:20px 12px !important; }
      .email-content { padding:28px 24px !important; }
      .email-header { padding:26px 24px 22px !important; }
      .email-title { font-size:28px !important; line-height:34px !important; }
    }
  </style>
</head>
<body class="bg-page" style="margin:0;padding:0;width:100%;background-color:#F2F6F5;font-family:Arial,Helvetica,sans-serif;color:#193149;">
  <div style="display:none;font-size:1px;line-height:1px;color:#F2F6F5;max-height:0;max-width:0;opacity:0;overflow:hidden;mso-hide:all;">{$preheader}</div>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" bgcolor="#F2F6F5" class="bg-page">
    <tr><td class="email-outer" align="center" style="padding:40px 16px;">
      <!--[if mso]><table role="presentation" width="560"><tr><td><![endif]-->
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="width:100%;max-width:560px;">
        <tr><td class="card" bgcolor="#FFFFFF" style="background-color:#FFFFFF;border:1px solid #DFE8E5;border-radius:20px;overflow:hidden;">
          <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
            <tr><td class="email-header" bgcolor="#15222E" background="{$headerBg}" style="padding:30px 36px 26px;background-color:#15222E;background-image:url('{$headerBg}');background-repeat:repeat;">
              {$logo}
            </td></tr>
            <tr><td style="padding:0;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr>
                  <td width="76%" height="3" bgcolor="#008576" style="height:3px;font-size:0;line-height:0;background-color:#008576;background-image:linear-gradient(#008576,#008576);">&nbsp;</td>
                  <td width="16%" height="3" bgcolor="#00B8CF" style="height:3px;font-size:0;line-height:0;background-color:#00B8CF;background-image:linear-gradient(#00B8CF,#00B8CF);">&nbsp;</td>
                  <td width="8%" height="3" bgcolor="#E51B88" style="height:3px;font-size:0;line-height:0;background-color:#E51B88;background-image:linear-gradient(#E51B88,#E51B88);">&nbsp;</td>
                </tr>
              </table>
            </td></tr>
            <tr><td class="email-content" style="padding:34px 36px 32px;">
              <p style="margin:0 0 14px;font-size:11px;line-height:16px;letter-spacing:2px;font-weight:bold;color:#008576;">YOUR SPLYTO ACCOUNT</p>
              <h1 class="email-title" style="margin:0 0 24px;font-size:32px;line-height:38px;letter-spacing:-0.8px;font-weight:700;color:#193149;">{$title}</h1>
              <p class="t-strong" style="margin:0 0 10px;font-size:16px;line-height:25px;font-weight:bold;color:#193149;">{$greeting}</p>
              <p class="t-body" style="margin:0 0 26px;font-size:15px;line-height:25px;color:#53626B;">{$message}</p>
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0">
                <tr><td align="center" bgcolor="{$buttonColor}" style="background-color:{$buttonColor};background-image:linear-gradient({$buttonColor},{$buttonColor});border-radius:12px;mso-padding-alt:17px 20px;">
                  <a href="{$url}" style="display:block;padding:17px 20px;border:1px solid {$buttonColor};border-radius:12px;font-family:Arial,Helvetica,sans-serif;font-size:16px;line-height:22px;font-weight:bold;text-align:center;color:#FFFFFF;text-decoration:none;">{$actionLabel}</a>
                </td></tr>
                <tr><td height="24" style="height:24px;font-size:0;line-height:0;">&nbsp;</td></tr>
                <tr><td class="notice" bgcolor="#EAF8FA" style="background-color:#EAF8FA;border-left:3px solid #00B8CF;padding:16px 18px;font-size:13px;line-height:21px;color:#365361;">{$notice}</td></tr>
              </table>
              <p class="t-muted" style="margin:26px 0 7px;font-size:12px;line-height:19px;color:#68777D;">Button not opening? Copy this link into your browser:</p>
              <p style="margin:0;font-size:12px;line-height:19px;word-break:break-all;overflow-wrap:anywhere;"><a class="link" href="{$url}" style="color:#007A6D;text-decoration:underline;word-break:break-all;overflow-wrap:anywhere;">{$url}</a></p>
            </td></tr>
            <tr><td class="footer-row" align="center" style="border-top:1px solid #E7EEEB;padding:20px 24px;">
              <p class="t-muted" style="margin:0;font-size:12px;line-height:20px;color:#68777D;">Need a hand? <a class="link" href="mailto:support@splyto.eu" style="color:#007A6D;text-decoration:none;">support@splyto.eu</a></p>
            </td></tr>
          </table>
        </td></tr>
        <tr><td align="center" style="padding:22px 12px 0;">
          <p class="t-muted" style="margin:0;font-size:12px;line-height:20px;color:#68777D;">Splyto &middot; Settle fast. Stay friends.</p>
          <p style="margin:4px 0 0;font-size:11px;line-height:18px;"><a class="t-muted" href="https://splyto.eu" style="color:#68777D;text-decoration:none;">splyto.eu</a></p>
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

function build_email_verification_email(
    string $verifyUrl,
    string $firstName,
    int $graceDays,
    int $linkTtlSeconds = 86_400
): string {
    $days = $graceDays > 0 ? $graceDays : 7;
    $hours = max(1, intdiv($linkTtlSeconds > 0 ? $linkTtlSeconds : 86_400, 3600));
    // You can sign in only after verifying; unverified accounts are deactivated
    // after the grace period (and reactivated if verified later).
    return build_account_email_template(
        'One last step. You’re in.', $firstName,
        'Confirm your email address to activate your Splyto account and start sharing trips and expenses.',
        'Verify email', $verifyUrl,
        'You can sign in once your email is verified. This link is valid for ' . $hours . ' hours; '
            . 'you can request a new one from the sign-in screen. Accounts that are not verified within '
            . $days . ' days are deactivated. If you did not create this account, ignore this email.',
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
