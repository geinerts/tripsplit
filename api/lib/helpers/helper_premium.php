<?php
declare(strict_types=1);

function premium_can_manage(array $session): bool
{
    return ($session['role'] ?? '') === 'superadmin'
        && (int) ($session['totp_enabled'] ?? 0) === 1
        && (int) ($session['is_2fa_verified'] ?? 0) === 1;
}

function premium_csrf_token(array $session): string
{
    return hash_hmac('sha256', 'premium-admin-v1', (string) ($session['token'] ?? ''));
}

function premium_assert_write(array $session, string $csrf): void
{
    if (!premium_can_manage($session) || empty($session['token'])
        || !hash_equals(premium_csrf_token($session), $csrf)) {
        throw new DomainException('Premium changes require superadmin, verified 2FA and a valid session token.');
    }
}

function premium_text(mixed $value, int $max, string $label): string
{
    if (!is_string($value)) throw new InvalidArgumentException($label . ' is required.');
    $text = trim($value);
    if ($text === '' || !mb_check_encoding($text, 'UTF-8') || mb_strlen($text) > $max || preg_match('/[\x00-\x1F\x7F]/u', $text)) {
        throw new InvalidArgumentException($label . ' is invalid.');
    }
    return $text;
}

function premium_end_time(mixed $value, int $now): string
{
    if (!is_string($value)) throw new InvalidArgumentException('End date is required.');
    $date = DateTimeImmutable::createFromFormat('!Y-m-d\TH:i:s\Z', $value, new DateTimeZone('UTC'));
    if (!$date || $date->format('Y-m-d\TH:i:s\Z') !== $value
        || $date->getTimestamp() <= $now || $date->getTimestamp() > $now + 5 * 366 * 86400) {
        throw new InvalidArgumentException('End date must be in the future, within five years.');
    }
    return $date->format('Y-m-d H:i:s');
}

function premium_id(mixed $value): int
{
    if (!is_int($value) || $value <= 0) throw new InvalidArgumentException('Invalid identifier.');
    return $value;
}

function premium_access_payload(int $userId, string $plan, ?string $endsAt, int $now): array
{
    return ['schema_version' => 1, 'account_id' => $userId, 'plan' => $plan,
        'source' => $plan === 'premium' ? 'admin_grant' : null,
        'expires_at' => $endsAt === null ? null : str_replace(' ', 'T', $endsAt) . 'Z',
        'checked_at' => gmdate('Y-m-d\TH:i:s\Z', $now), 'refresh_after_seconds' => 300,
        'billing_enabled' => false, 'limits_enforced' => false];
}

/** Account-scoped projection; sandbox purchases and profile flags never grant access. */
function premium_access_for_user(PDO $pdo, int $userId, ?int $now = null): array
{
    $now ??= time();
    try {
        $stmt = $pdo->prepare('SELECT g.ends_at FROM ' . table_name('premium_grants') . ' g'
            . ' JOIN ' . table_name('users') . ' u ON u.id = g.user_id'
            . ' WHERE g.user_id = :user_id AND u.account_status = :status AND g.revoked_at IS NULL'
            . ' AND g.starts_at <= :starts AND g.ends_at > :ends ORDER BY g.ends_at DESC LIMIT 1');
        $stmt->execute(['user_id' => $userId, 'status' => 'active', 'starts' => gmdate('Y-m-d H:i:s', $now),
            'ends' => gmdate('Y-m-d H:i:s', $now)]);
        $end = $stmt->fetchColumn();
        return premium_access_payload($userId, $end ? 'premium' : 'free', $end ?: null, $now);
    } catch (PDOException $error) {
        // Older servers/missing migration must not break login or claim Free/Pro.
        return premium_access_payload($userId, 'unknown', null, $now);
    }
}

function premium_user_detail(PDO $pdo, int $userId, array $session): array
{
    $result = ['access' => premium_access_for_user($pdo, $userId), 'can_manage' => premium_can_manage($session),
        'csrf_token' => premium_can_manage($session) ? premium_csrf_token($session) : null,
        'grants' => [], 'history' => []];
    if (!in_array($session['role'], ['superadmin', 'admin'], true)) return $result;
    try {
        $stmt = $pdo->prepare('SELECT g.*, p.name AS partner_name FROM ' . table_name('premium_grants') . ' g'
            . ' LEFT JOIN ' . table_name('premium_partners') . ' p ON p.id = g.partner_id'
            . ' WHERE g.user_id = ? ORDER BY g.id DESC LIMIT 100');
        $stmt->execute([$userId]);
        $result['grants'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $stmt = $pdo->prepare('SELECT action, reason, admin_username, created_at, before_json, after_json FROM '
            . table_name('premium_events') . ' WHERE user_id = ? ORDER BY id DESC LIMIT 100');
        $stmt->execute([$userId]);
        $result['history'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (PDOException $error) {
        $result['can_manage'] = false;
        $result['csrf_token'] = null;
    }
    return $result;
}

/** Every mutation and both audit records commit or roll back together. */
function premium_mutate(PDO $pdo, array $session, string $csrf, array $body, ?int $now = null): array
{
    premium_assert_write($session, $csrf);
    $now ??= time();
    $stamp = gmdate('Y-m-d H:i:s', $now);
    $operation = $body['operation'] ?? '';
    if (!in_array($operation, ['partner_create', 'grant_create', 'grant_extend', 'grant_revoke'], true)) {
        throw new InvalidArgumentException('Unknown Premium operation.');
    }
    $requestId = $body['request_id'] ?? '';
    if (!is_string($requestId) || !preg_match('/^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$/D', $requestId)) {
        throw new InvalidArgumentException('Invalid request identifier.');
    }
    $reason = premium_text($body['reason'] ?? null, 500, 'Reason');
    ksort($body);
    $requestHash = hash('sha256', json_encode([$session['admin_user_id'], $body], JSON_THROW_ON_ERROR));
    if ($pdo->inTransaction()) throw new LogicException('Unexpected transaction.');
    $pdo->beginTransaction();
    try {
        // Serialize each administrator's requests, then lock the target user/grant.
        $admin = $pdo->prepare('SELECT role, is_active, totp_enabled FROM ' . table_name('admin_users') . ' WHERE id = ? FOR UPDATE');
        $admin->execute([(int) $session['admin_user_id']]);
        $freshAdmin = $admin->fetch(PDO::FETCH_ASSOC);
        if (!$freshAdmin || $freshAdmin['role'] !== 'superadmin' || (int) $freshAdmin['is_active'] !== 1
            || (int) $freshAdmin['totp_enabled'] !== 1) throw new DomainException('Admin permission changed.');
        $replay = $pdo->prepare('SELECT request_hash, grant_id, partner_id FROM ' . table_name('premium_events') . ' WHERE request_id = ?');
        $replay->execute([$requestId]);
        $previous = $replay->fetch(PDO::FETCH_ASSOC);
        if ($previous) {
            if (!hash_equals($previous['request_hash'], $requestHash)) throw new DomainException('Request identifier already used.');
            $pdo->commit();
            return ['grant_id' => $previous['grant_id'], 'partner_id' => $previous['partner_id'], 'replayed' => true];
        }
        $before = null;
        $userId = $grantId = $partnerId = null;
        if ($operation === 'partner_create') {
            $name = premium_text($body['name'] ?? null, 120, 'Partner name');
            $pdo->prepare('INSERT INTO ' . table_name('premium_partners') . ' (name, created_at) VALUES (?, ?)')->execute([$name, $stamp]);
            $partnerId = (int) $pdo->lastInsertId();
            $after = ['id' => $partnerId, 'name' => $name];
        } else {
            if ($operation === 'grant_create') {
                $userId = premium_id($body['user_id'] ?? null);
            } else {
                $grantId = premium_id($body['grant_id'] ?? null);
                $getGrant = $pdo->prepare('SELECT user_id FROM ' . table_name('premium_grants') . ' WHERE id = ?');
                $getGrant->execute([$grantId]);
                $userId = (int) $getGrant->fetchColumn();
                if ($userId <= 0) throw new DomainException('Grant not found.');
            }
            $user = $pdo->prepare('SELECT account_status FROM ' . table_name('users') . ' WHERE id = ? FOR UPDATE');
            $user->execute([$userId]);
            $status = $user->fetchColumn();
            if (!$status || ($operation !== 'grant_revoke' && $status !== 'active')) {
                throw new DomainException('An active user is required.');
            }
            if ($operation === 'grant_create') {
                $source = $body['source'] ?? '';
                if (!in_array($source, ['partner', 'testing', 'compensation'], true)) throw new InvalidArgumentException('Invalid grant source.');
                $end = premium_end_time($body['ends_at'] ?? null, $now);
                if ($source === 'partner') {
                    $partnerId = premium_id($body['partner_id'] ?? null);
                    $partner = $pdo->prepare('SELECT id FROM ' . table_name('premium_partners') . ' WHERE id = ?');
                    $partner->execute([$partnerId]);
                    if (!$partner->fetchColumn()) throw new DomainException('Partner not found.');
                }
                $pdo->prepare('INSERT INTO ' . table_name('premium_grants')
                    . ' (user_id, partner_id, source, starts_at, ends_at, reason, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)')
                    ->execute([$userId, $partnerId, $source, $stamp, $end, $reason, $stamp]);
                $grantId = (int) $pdo->lastInsertId();
            } else {
                $getGrant = $pdo->prepare('SELECT * FROM ' . table_name('premium_grants') . ' WHERE id = ? FOR UPDATE');
                $getGrant->execute([$grantId]);
                $before = $getGrant->fetch(PDO::FETCH_ASSOC);
                if (!$before || (int) $before['version'] !== premium_id($body['version'] ?? null) || $before['revoked_at'] !== null) {
                    throw new DomainException('Grant changed. Reload before trying again.');
                }
                $partnerId = $before['partner_id'];
                if ($operation === 'grant_extend') {
                    $end = premium_end_time($body['ends_at'] ?? null, $now);
                    if ($end <= $before['ends_at']) throw new InvalidArgumentException('New end date must extend the current grant.');
                    $pdo->prepare('UPDATE ' . table_name('premium_grants') . ' SET ends_at = ?, version = version + 1 WHERE id = ?')->execute([$end, $grantId]);
                } else {
                    $pdo->prepare('UPDATE ' . table_name('premium_grants') . ' SET revoked_at = ?, version = version + 1 WHERE id = ?')->execute([$stamp, $grantId]);
                }
            }
            $current = $pdo->prepare('SELECT * FROM ' . table_name('premium_grants') . ' WHERE id = ?');
            $current->execute([$grantId]);
            $after = $current->fetch(PDO::FETCH_ASSOC);
        }
        $pdo->prepare('INSERT INTO ' . table_name('premium_events')
            . ' (request_id, request_hash, admin_user_id, admin_username, user_id, grant_id, partner_id, action, reason, before_json, after_json, created_at)'
            . ' VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)')->execute([
                $requestId, $requestHash, $session['admin_user_id'], $session['username'], $userId, $grantId, $partnerId,
                $operation, $reason, $before === null ? null : json_encode($before, JSON_THROW_ON_ERROR),
                json_encode($after, JSON_THROW_ON_ERROR), $stamp]);
        admin_audit($pdo, $session, 'premium.' . $operation, $grantId === null ? 'premium_partner' : 'premium_grant',
            $grantId ?? $partnerId, ['user_id' => $userId, 'reason' => $reason, 'before' => $before, 'after' => $after], true);
        $pdo->commit();
        return ['grant_id' => $grantId, 'partner_id' => $partnerId, 'replayed' => false];
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
}
