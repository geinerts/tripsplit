<?php
declare(strict_types=1);

function claim_quick_start_action(): void
{
    require_post();
    $me = get_me();
    $userId = (int) ($me['id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid session user.'], 401);
    }
    json_out(['ok' => true, 'show_quick_start' => claim_quick_start(db(), $userId)]);
}
