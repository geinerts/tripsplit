import '../core/auth/auth_session_store.dart';
import '../core/auth/current_user_store.dart';
import '../core/auth/device_token_store.dart';
import '../core/auth/user_avatar_store.dart';
import '../core/config/app_env.dart';
import '../core/network/legacy_api_client.dart';
import '../core/network/legacy_avatar_uploader.dart';
import '../core/network/legacy_feedback_reporter.dart';
import '../core/network/legacy_receipt_uploader.dart';
import '../core/network/legacy_trip_image_uploader.dart';
import '../core/push/push_native_bridge.dart';
import '../core/push/push_registration_service.dart';
import '../core/push/push_registration_store.dart';
import '../core/perf/perf_monitor.dart';
import 'locale/app_locale_controller.dart';
import 'theme/theme_mode_controller.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/usecases/get_me_use_case.dart';
import '../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../features/auth/domain/usecases/login_use_case.dart';
import '../features/auth/domain/usecases/register_use_case.dart';
import '../features/auth/domain/usecases/set_credentials_use_case.dart';
import '../features/auth/domain/usecases/update_profile_use_case.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/friends/data/datasources/friends_remote_data_source.dart';
import '../features/friends/data/repositories/friends_repository_impl.dart';
import '../features/friends/domain/usecases/cancel_friend_invite_use_case.dart';
import '../features/friends/domain/usecases/load_friends_section_page_use_case.dart';
import '../features/friends/domain/usecases/load_friends_snapshot_use_case.dart';
import '../features/friends/domain/usecases/remove_friend_use_case.dart';
import '../features/friends/domain/usecases/respond_friend_invite_use_case.dart';
import '../features/friends/domain/usecases/send_friend_invite_use_case.dart';
import '../features/friends/presentation/controllers/friends_controller.dart';
import '../features/trips/data/datasources/trips_remote_data_source.dart';
import '../features/trips/data/local/trips_local_store.dart';
import '../features/trips/data/repositories/trips_repository_impl.dart';
import '../features/trips/domain/usecases/add_trip_members_use_case.dart';
import '../features/trips/domain/usecases/create_trip_invite_link_use_case.dart';
import '../features/trips/domain/usecases/create_trip_use_case.dart';
import '../features/trips/domain/usecases/delete_trip_use_case.dart';
import '../features/trips/domain/usecases/list_directory_users_use_case.dart';
import '../features/trips/domain/usecases/join_trip_invite_use_case.dart';
import '../features/trips/domain/usecases/list_trips_use_case.dart';
import '../features/trips/domain/usecases/update_trip_use_case.dart';
import '../features/trips/domain/usecases/upload_trip_image_use_case.dart';
import '../features/trips/presentation/controllers/trips_controller.dart';
import '../features/workspace/data/datasources/workspace_remote_data_source.dart';
import '../features/workspace/data/local/workspace_local_store.dart';
import '../features/workspace/data/repositories/workspace_repository_impl.dart';
import '../features/workspace/presentation/controllers/workspace_controller.dart';

class AppDependencies {
  AppDependencies({
    required this.authController,
    required this.tripsController,
    required this.friendsController,
    required this.workspaceController,
    required this.themeModeController,
    required this.localeController,
  });

  final AuthController authController;
  final TripsController tripsController;
  final FriendsController friendsController;
  final WorkspaceController workspaceController;
  final ThemeModeController themeModeController;
  final AppLocaleController localeController;

  factory AppDependencies.bootstrap() {
    final env = AppEnv.current;
    PerfMonitor.configure(
      enabled: env.enableVerboseLogs || env.enablePerformanceLogs,
    );

    final tokenStore = DeviceTokenStore();
    final authSessionStore = AuthSessionStore();
    final currentUserStore = CurrentUserStore();
    final avatarStore = UserAvatarStore();
    final apiClient = LegacyApiClient(
      baseUrl: env.apiBaseUrl,
      tokenStore: tokenStore,
      authSessionStore: authSessionStore,
      enableVerboseLogs: env.enableVerboseLogs,
      requestTimeout: env.apiRequestTimeout,
    );
    final receiptUploader = LegacyReceiptUploader(
      baseUrl: env.apiBaseUrl,
      tokenStore: tokenStore,
      authSessionStore: authSessionStore,
    );
    final avatarUploader = LegacyAvatarUploader(
      baseUrl: env.apiBaseUrl,
      tokenStore: tokenStore,
      authSessionStore: authSessionStore,
    );
    final feedbackReporter = LegacyFeedbackReporter(
      baseUrl: env.apiBaseUrl,
      tokenStore: tokenStore,
      authSessionStore: authSessionStore,
    );
    final tripImageUploader = LegacyTripImageUploader(
      baseUrl: env.apiBaseUrl,
      tokenStore: tokenStore,
      authSessionStore: authSessionStore,
    );
    final pushRegistrationService = PushRegistrationService(
      apiClient: apiClient,
      deviceTokenStore: tokenStore,
      nativeBridge: PushNativeBridge(),
      registrationStore: PushRegistrationStore(),
    );

    final authRemote = AuthRemoteDataSourceImpl(apiClient);
    final authRepository = AuthRepositoryImpl(authRemote);
    final authController = AuthController(
      LoginUseCase(authRepository),
      RegisterUseCase(authRepository),
      SetCredentialsUseCase(authRepository),
      UpdateProfileUseCase(authRepository),
      GetMeUseCase(authRepository),
      ForgotPasswordUseCase(authRepository),
      tokenStore,
      authSessionStore,
      currentUserStore,
      avatarStore,
      avatarUploader,
      feedbackReporter,
      pushRegistrationService,
    );

    final tripsRemote = TripsRemoteDataSourceImpl(apiClient, tripImageUploader);
    final tripsLocalStore = TripsLocalStore();
    final tripsRepository = TripsRepositoryImpl(tripsRemote, tripsLocalStore);
    final tripsController = TripsController(
      ListTripsUseCase(tripsRepository),
      ListDirectoryUsersUseCase(tripsRepository),
      CreateTripUseCase(tripsRepository),
      AddTripMembersUseCase(tripsRepository),
      DeleteTripUseCase(tripsRepository),
      CreateTripInviteLinkUseCase(tripsRepository),
      JoinTripInviteUseCase(tripsRepository),
      UpdateTripUseCase(tripsRepository),
      UploadTripImageUseCase(tripsRepository),
      tripsLocalStore,
    );

    final friendsRemote = FriendsRemoteDataSourceImpl(apiClient);
    final friendsRepository = FriendsRepositoryImpl(friendsRemote);
    final friendsController = FriendsController(
      LoadFriendsSnapshotUseCase(friendsRepository),
      LoadFriendsSectionPageUseCase(friendsRepository),
      SendFriendInviteUseCase(friendsRepository),
      RespondFriendInviteUseCase(friendsRepository),
      CancelFriendInviteUseCase(friendsRepository),
      RemoveFriendUseCase(friendsRepository),
      tripsController,
    );

    final workspaceRemote = WorkspaceRemoteDataSourceImpl(
      apiClient,
      receiptUploader,
    );
    final workspaceLocalStore = WorkspaceLocalStore();
    final workspaceRepository = WorkspaceRepositoryImpl(
      workspaceRemote,
      workspaceLocalStore,
    );
    final workspaceController = WorkspaceController(workspaceRepository);
    final themeModeController = ThemeModeController();
    final localeController = AppLocaleController();

    return AppDependencies(
      authController: authController,
      tripsController: tripsController,
      friendsController: friendsController,
      workspaceController: workspaceController,
      themeModeController: themeModeController,
      localeController: localeController,
    );
  }
}
