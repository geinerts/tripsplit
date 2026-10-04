<?php
declare(strict_types=1);

/** Draft commercial limits, not authorization or a verified purchase record. */
function subscription_plan_catalog(): array
{
    return [
        'free' => [
            'active_owned_trips' => 1,
            'currencies_per_trip' => 2,
        ],
        'pro' => [
            'active_owned_trips' => null,
            'currencies_per_trip' => null,
        ],
    ];
}

function subscription_preview_payload(int $accountId): array
{
    if ($accountId <= 0) {
        throw new InvalidArgumentException('A subscription preview requires an account.');
    }

    // Keep rollout closed in code until verified billing and mutation guards exist.
    // Neither profile fields, environment flags nor client input can grant Pro.
    return [
        'schema_version' => 1,
        'catalog_version' => '2026-09-draft-1',
        'account_id' => $accountId,
        'mode' => 'preview',
        'plan' => 'free',
        'billing_enabled' => false,
        'limits_enforced' => false,
        'effective_limits' => [
            'active_owned_trips' => null,
            'currencies_per_trip' => null,
        ],
        'proposed_plans' => subscription_plan_catalog(),
    ];
}
