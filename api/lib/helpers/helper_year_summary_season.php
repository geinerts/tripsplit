<?php
declare(strict_types=1);

/** The previous calendar year is available only in January–March, in UTC. */
function year_summary_season_year(?int $now = null): ?int
{
    $now ??= time();
    return (int) gmdate('n', $now) <= 3 ? (int) gmdate('Y', $now) - 1 : null;
}
