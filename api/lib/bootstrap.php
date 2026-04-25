<?php
declare(strict_types=1);

require_once __DIR__ . '/helpers/api_core_helpers.php';
require_once __DIR__ . '/helpers/helper_email.php';
require_once __DIR__ . '/helpers/helper_app_events.php';

require_once __DIR__ . '/actions/auth_actions.php';
require_once __DIR__ . '/actions/auth_social_actions.php';
require_once __DIR__ . '/actions/password_reset_actions.php';
require_once __DIR__ . '/actions/email_verification_actions.php';
require_once __DIR__ . '/actions/email_change_actions.php';
require_once __DIR__ . '/actions/account_lifecycle_actions.php';
require_once __DIR__ . '/actions/friends_actions.php';
require_once __DIR__ . '/actions/trips_actions.php';
require_once __DIR__ . '/actions/uploads_actions.php';
require_once __DIR__ . '/actions/expenses_actions.php';
require_once __DIR__ . '/actions/expense_social_actions.php';
require_once __DIR__ . '/actions/settlements_actions.php';
require_once __DIR__ . '/actions/notifications_actions.php';
require_once __DIR__ . '/actions/feedback_actions.php';
require_once __DIR__ . '/actions/orders_actions.php';
require_once __DIR__ . '/actions/workspace_actions.php';
require_once __DIR__ . '/actions/admin_actions.php';
require_once __DIR__ . '/actions/admin_panel_actions.php';

require_once __DIR__ . '/http/action_router.php';
