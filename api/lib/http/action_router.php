<?php
declare(strict_types=1);

function api_action_handlers(): array
{
    static $handlers = null;
    if (is_array($handlers)) {
        return $handlers;
    }

    $handlers = [
        'register_proof' => 'register_proof_action',
        'register' => 'register_action',
        'login' => 'login_action',
        'refresh_session' => 'refresh_session_action',
        'set_credentials' => 'set_credentials_action',
        'update_profile' => 'update_profile_action',
        'me' => 'me_action',
        'trips' => 'trips_action',
        'all_users' => 'all_users_action',
        'search_users' => 'search_users_action',
        'friends_list' => 'friends_list_action',
        'send_friend_invite' => 'send_friend_invite_action',
        'respond_friend_invite' => 'respond_friend_invite_action',
        'cancel_friend_invite' => 'cancel_friend_invite_action',
        'remove_friend' => 'remove_friend_action',
        'create_trip' => 'create_trip_action',
        'update_trip' => 'update_trip_action',
        'add_trip_members' => 'add_trip_members_action',
        'users' => 'users_action',
        'upload_trip_image' => 'upload_trip_image_action',
        'upload_receipt' => 'upload_receipt_action',
        'upload_avatar' => 'upload_avatar_action',
        'remove_avatar' => 'remove_avatar_action',
        'add_expense' => 'add_expense_action',
        'update_expense' => 'update_expense_action',
        'delete_expense' => 'delete_expense_action',
        'list_expenses' => 'list_expenses_action',
        'balances' => 'balances_action',
        'end_trip' => 'end_trip_action',
        'mark_settlement_sent' => 'mark_settlement_sent_action',
        'confirm_settlement_received' => 'confirm_settlement_received_action',
        'list_notifications' => 'list_notifications_action',
        'list_notifications_global' => 'list_notifications_global_action',
        'mark_notifications_read' => 'mark_notifications_read_action',
        'mark_notifications_read_global' => 'mark_notifications_read_global_action',
        'submit_feedback' => 'submit_feedback_action',
        'workspace_snapshot' => 'workspace_snapshot_action',
        'generate_order' => 'generate_order_action',
        'list_orders' => 'list_orders_action',
        'admin_feedback_feed' => 'admin_feedback_feed_action',
        'admin_summary' => 'admin_summary_action',
        'admin_users' => 'admin_users_action',
        'admin_user_detail' => 'admin_user_detail_action',
        'admin_delete_expense' => 'admin_delete_expense_action',
        'admin_update_user' => 'admin_update_user_action',
        'admin_delete_user' => 'admin_delete_user_action',
    ];

    return $handlers;
}

function dispatch_api_action(string $action): bool
{
    $action = trim($action);
    if ($action === '') {
        return false;
    }

    $handlers = api_action_handlers();
    if (!array_key_exists($action, $handlers)) {
        return false;
    }

    $handler = $handlers[$action];
    if (!is_string($handler) || $handler === '' || !function_exists($handler)) {
        throw new RuntimeException('Action handler is not available for "' . $action . '".');
    }

    $handler();
    return true;
}
