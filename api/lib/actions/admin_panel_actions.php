<?php
declare(strict_types=1);
require_once __DIR__ . '/../helpers/helper_travel_places.php';
require_once __DIR__ . '/../helpers/helper_account_deletion_feedback.php';
require_once __DIR__ . '/../helpers/helper_feature_usage.php';
require_once __DIR__ . '/../helpers/helper_password_capability.php';

// ══════════════════════════════════════════════════════════════════════════════
// Admin Panel v2 Actions
// Auth: cookie-based sessions with mandatory TOTP 2FA, RBAC roles.
// All write actions emit an audit log entry.
// ══════════════════════════════════════════════════════════════════════════════

// The actions live in admin_panel/ by area. Function and action names are the
// API contract and are unchanged; this file only loads them.
require_once __DIR__ . '/admin_panel/auth.php';
require_once __DIR__ . '/admin_panel/overview.php';
require_once __DIR__ . '/admin_panel/users.php';
require_once __DIR__ . '/admin_panel/operations.php';
require_once __DIR__ . '/admin_panel/admin_users.php';
