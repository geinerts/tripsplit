<?php
declare(strict_types=1);

function api_action_handlers(): array
{
    static $handlers = null;
    if (is_array($handlers)) {
        return $handlers;
    }

    $handlers = [
        'forgot_password'  => 'forgot_password_action',
        'reset_password'   => 'reset_password_action',
        'request_email_verification_link' => 'request_email_verification_link_action',
        'confirm_email_verification' => 'confirm_email_verification_action',
        'request_email_change' => 'request_email_change_action',
        'confirm_email_change' => 'confirm_email_change_action',
        'cancel_email_change' => 'cancel_email_change_action',
        'register_proof'   => 'register_proof_action',
        'register'         => 'register_action',
        'login'            => 'login_action',
        'social_auth'      => 'social_auth_action',
        'refresh_session' => 'refresh_session_action',
        'set_credentials' => 'set_credentials_action',
        'update_profile' => 'update_profile_action',
        'me' => 'me_action',
        'deactivate_account' => 'deactivate_account_action',
        'request_reactivation_link' => 'request_reactivation_link_action',
        'confirm_reactivation' => 'confirm_reactivation_action',
        'request_account_deletion_link' => 'request_account_deletion_link_action',
        'confirm_account_deletion' => 'confirm_account_deletion_action',
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
        'delete_trip' => 'delete_trip_action',
        'add_trip_members' => 'add_trip_members_action',
        'users' => 'users_action',
        'upload_trip_image' => 'upload_trip_image_action',
        'upload_receipt' => 'upload_receipt_action',
        'upload_avatar' => 'upload_avatar_action',
        'remove_avatar' => 'remove_avatar_action',
        'list_expense_reactions'  => 'list_expense_reactions_action',
        'toggle_expense_reaction' => 'toggle_expense_reaction_action',
        'list_expense_comment_reactions' => 'list_expense_comment_reactions_action',
        'toggle_expense_comment_reaction' => 'toggle_expense_comment_reaction_action',
        'list_expense_comments'   => 'list_expense_comments_action',
        'add_expense_comment'     => 'add_expense_comment_action',
        'update_expense_comment'  => 'update_expense_comment_action',
        'delete_expense_comment'  => 'delete_expense_comment_action',
        'add_expense' => 'add_expense_action',
        'update_expense' => 'update_expense_action',
        'delete_expense' => 'delete_expense_action',
        'list_expenses' => 'list_expenses_action',
        'balances' => 'balances_action',
        'end_trip' => 'end_trip_action',
        'set_ready_to_settle' => 'set_ready_to_settle_action',
        'mark_settlement_sent' => 'mark_settlement_sent_action',
        'confirm_settlement_received' => 'confirm_settlement_received_action',
        'remind_settlement' => 'remind_settlement_action',
        'list_notifications' => 'list_notifications_action',
        'list_notifications_global' => 'list_notifications_global_action',
        'mark_notifications_read' => 'mark_notifications_read_action',
        'mark_notifications_read_global' => 'mark_notifications_read_global_action',
        'register_push_token' => 'register_push_token_action',
        'unregister_push_token' => 'unregister_push_token_action',
        'get_notification_preferences' => 'get_notification_preferences_action',
        'update_notification_preferences' => 'update_notification_preferences_action',
        'create_trip_invite' => 'create_trip_invite_action',
        'preview_trip_invite' => 'preview_trip_invite_action',
        'join_trip_invite' => 'join_trip_invite_action',
        'submit_feedback' => 'submit_feedback_action',
        'workspace_snapshot' => 'workspace_snapshot_action',
        'shared_trips_with_user' => 'shared_trips_with_user_action',
        'generate_order' => 'generate_order_action',
        'list_orders' => 'list_orders_action',
        'admin_feedback_feed' => 'admin_feedback_feed_action',
        'admin_archive_feedback' => 'admin_archive_feedback_action',
        'admin_delete_feedback' => 'admin_delete_feedback_action',
        'admin_summary' => 'admin_summary_action',
        'admin_users' => 'admin_users_action',
        'admin_user_detail' => 'admin_user_detail_action',
        'admin_delete_expense' => 'admin_delete_expense_action',
        'admin_update_user' => 'admin_update_user_action',
        'admin_delete_user' => 'admin_delete_user_action',

        // ── Admin Panel v2 (session auth + RBAC) ──────────────────────────────
        'admin_panel_login'             => 'admin_panel_login_action',
        'admin_panel_verify_2fa'        => 'admin_panel_verify_2fa_action',
        'admin_panel_logout'            => 'admin_panel_logout_action',
        'admin_panel_session_check'     => 'admin_panel_session_check_action',
        'admin_panel_setup_totp'        => 'admin_panel_setup_totp_action',
        'admin_panel_confirm_totp'      => 'admin_panel_confirm_totp_action',
        'admin_panel_disable_totp'      => 'admin_panel_disable_totp_action',
        'admin_panel_active_sessions'   => 'admin_panel_active_sessions_action',
        'admin_panel_revoke_session'    => 'admin_panel_revoke_session_action',
        'admin_panel_dashboard'         => 'admin_panel_dashboard_action',
        'admin_panel_user_search'       => 'admin_panel_user_search_action',
        'admin_panel_user_detail'       => 'admin_panel_user_detail_action',
        'admin_panel_user_suspend'      => 'admin_panel_user_suspend_action',
        'admin_panel_user_reactivate'   => 'admin_panel_user_reactivate_action',
        'admin_panel_user_delete'       => 'admin_panel_user_delete_action',
        'admin_panel_clear_push_tokens' => 'admin_panel_clear_push_tokens_action',
        'admin_panel_push_queue'        => 'admin_panel_push_queue_action',
        'admin_panel_push_retry'        => 'admin_panel_push_retry_action',
        'admin_panel_incidents'         => 'admin_panel_incidents_action',
        'admin_panel_create_incident'   => 'admin_panel_create_incident_action',
        'admin_panel_update_incident'   => 'admin_panel_update_incident_action',
        'admin_panel_audit_log'         => 'admin_panel_audit_log_action',
        'admin_panel_app_events'        => 'admin_panel_app_events_action',
        'admin_panel_admin_users'       => 'admin_panel_admin_users_action',
        'admin_panel_create_admin_user' => 'admin_panel_create_admin_user_action',
        'admin_panel_update_admin_user' => 'admin_panel_update_admin_user_action',
        'admin_panel_delete_admin_user' => 'admin_panel_delete_admin_user_action',
        'admin_panel_feedback'          => 'admin_panel_feedback_action',
        'admin_panel_archive_feedback'  => 'admin_panel_archive_feedback_action',
        'admin_panel_delete_feedback'   => 'admin_panel_delete_feedback_action',
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
