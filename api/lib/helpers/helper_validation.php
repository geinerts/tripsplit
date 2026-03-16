<?php
declare(strict_types=1);

function validate_email_address(string $email): string
{
    $email = strtolower(trim($email));
    if ($email === '' || str_length($email) > 255 || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok' => false, 'error' => 'Email is invalid.'], 400);
    }
    return $email;
}

function validate_password_plain(string $password): string
{
    if (str_length($password) < 8 || str_length($password) > 128) {
        json_out(['ok' => false, 'error' => 'Password must be 8-128 chars.'], 400);
    }
    if (!preg_match('/[A-Z]/', $password)) {
        json_out(['ok' => false, 'error' => 'Password must include at least one uppercase letter.'], 400);
    }
    if (!preg_match('/[0-9]/', $password)) {
        json_out(['ok' => false, 'error' => 'Password must include at least one number.'], 400);
    }
    if (!preg_match('/[^A-Za-z0-9]/', $password)) {
        json_out(['ok' => false, 'error' => 'Password must include at least one symbol.'], 400);
    }
    return $password;
}

function validate_password_for_login(string $password): string
{
    if (str_length($password) < 1 || str_length($password) > 128) {
        json_out(['ok' => false, 'error' => 'Password is invalid.'], 400);
    }
    return $password;
}

function validate_person_name(string $name, string $fieldLabel): string
{
    $name = trim(preg_replace('/\s+/', ' ', $name) ?? '');
    if (str_length($name) < 2 || str_length($name) > 64) {
        json_out(['ok' => false, 'error' => $fieldLabel . ' must be 2-64 chars.'], 400);
    }
    if (!preg_match('/^[\p{L}][\p{L}\p{M}\' -]*$/u', $name)) {
        json_out(['ok' => false, 'error' => $fieldLabel . ' has unsupported characters.'], 400);
    }
    return $name;
}

function base64url_encode(string $raw): string
{
    return rtrim(strtr(base64_encode($raw), '+/', '-_'), '=');
}

function base64url_decode(string $raw): ?string
{
    $normalized = strtr(trim($raw), '-_', '+/');
    if ($normalized === '') {
        return null;
    }
    $padding = strlen($normalized) % 4;
    if ($padding > 0) {
        $normalized .= str_repeat('=', 4 - $padding);
    }
    $decoded = base64_decode($normalized, true);
    return is_string($decoded) ? $decoded : null;
}

