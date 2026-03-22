<?php
declare(strict_types=1);

function push_base64url_encode($raw): string
{
    if (!is_string($raw) || $raw === '') {
        return '';
    }
    return rtrim(strtr(base64_encode($raw), '+/', '-_'), '=');
}
