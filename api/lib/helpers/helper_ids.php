<?php
declare(strict_types=1);

function ids_to_csv(array $ids): string
{
    return implode(',', array_map('strval', normalize_user_ids($ids)));
}

function ids_from_csv(string $csv): array
{
    if (trim($csv) === '') {
        return [];
    }
    return normalize_user_ids(array_map('intval', explode(',', $csv)));
}
