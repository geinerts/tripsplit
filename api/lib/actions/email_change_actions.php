<?php
declare(strict_types=1);

// Keep explicit tombstones for old app versions and previously issued links.
function email_change_removed_action(): void
{
    json_out(['ok' => false, 'code' => 'EMAIL_CHANGE_UNAVAILABLE',
        'error' => 'Email address changes are no longer available.'], 410);
}
function request_email_change_action(): void { email_change_removed_action(); }
function confirm_email_change_action(): void { email_change_removed_action(); }
function cancel_email_change_action(): void { email_change_removed_action(); }
