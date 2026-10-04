import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripsplit/app/router/app_router.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/auth/auth_session_store.dart';
import 'package:tripsplit/core/auth/current_user_store.dart';
import 'package:tripsplit/core/auth/device_token_store.dart';
import 'package:tripsplit/core/auth/user_avatar_store.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/core/network/api_client.dart';
import 'package:tripsplit/core/network/http_method.dart';
import 'package:tripsplit/core/network/legacy_avatar_uploader.dart';
import 'package:tripsplit/core/network/legacy_feedback_reporter.dart';
import 'package:tripsplit/core/push/push_registration_service.dart';
import 'package:tripsplit/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:tripsplit/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:tripsplit/features/auth/domain/entities/auth_user.dart';
import 'package:tripsplit/features/auth/domain/entities/notification_preferences.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/auth/presentation/pages/profile_page.dart';
import 'package:tripsplit/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';
import 'package:tripsplit/features/auth/domain/usecases/deactivate_account_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/forgot_password_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/get_me_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/get_notification_preferences_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/login_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/logout_session_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/register_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_account_deletion_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_deactivation_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_email_verification_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/request_reactivation_link_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/set_credentials_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/social_login_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/update_notification_preferences_use_case.dart';
import 'package:tripsplit/features/auth/domain/usecases/update_profile_use_case.dart';

const user = AuthUser(
  id: 1,
  nickname: 'Synthetic Owner',
  email: 'owner@example.invalid',
  needsCredentials: false,
);

class RecordingApi extends Fake implements ApiClient {
  Map<String, dynamic>? body;
  String? path;
  int revocations = 0;
  Future<Map<String, dynamic>> Function()? respond;
  @override
  Future<Map<String, dynamic>> request({
    required String path,
    required HttpMethod method,
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    this.path = path;
    this.body = body;
    return respond != null
        ? await respond!()
        : {
            'ok': true,
            'me': {
              'id': 1,
              'nickname': 'Synthetic Owner',
              'email': user.email,
              'needs_credentials': false,
            },
          };
  }

  @override
  Future<void> revokeCurrentSession() async {
    revocations++;
  }
}

class UnusedUploader extends Fake implements LegacyAvatarUploader {}

class UnusedReporter extends Fake implements LegacyFeedbackReporter {}

class QuietPush extends Fake implements PushRegistrationService {
  @override
  Future<void> unregisterCurrentDevice() async {}
  @override
  Future<bool> syncRegistration() async => true;
}

class ControllerHarness {
  final api = RecordingApi();
  final session = AccountDataSession()..activate(1);
  final store = AuthSessionStore();
  final profiles = CurrentUserStore();
  int loggedOut = 0;
  late final AuthController controller;
  ControllerHarness() {
    final repo = AuthRepositoryImpl(AuthRemoteDataSourceImpl(api));
    controller = AuthController(
      LoginUseCase(repo),
      LogoutSessionUseCase(repo),
      SocialLoginUseCase(repo),
      RegisterUseCase(repo),
      SetCredentialsUseCase(repo),
      UpdateProfileUseCase(repo),
      GetMeUseCase(repo),
      ForgotPasswordUseCase(repo),
      RequestEmailVerificationLinkUseCase(repo),
      RequestReactivationLinkUseCase(repo),
      RequestDeactivationLinkUseCase(repo),
      DeactivateAccountUseCase(repo),
      RequestAccountDeletionLinkUseCase(repo),
      GetNotificationPreferencesUseCase(repo),
      UpdateNotificationPreferencesUseCase(repo),
      DeviceTokenStore(),
      store,
      profiles,
      UserAvatarStore(),
      UnusedUploader(),
      UnusedReporter(),
      QuietPush(),
      () async {
        loggedOut++;
      },
      accountSession: session,
    )..currentUser = user;
  }
  Future<void> saveSession(int id) async {
    await store.saveFromAuthPayload({
      'user_id': id,
      'access_token': 'synthetic-access-$id',
      'refresh_token': 'synthetic-refresh-$id',
      'access_expires_in_sec': 900,
      'refresh_expires_in_sec': 3600,
    });
  }
}

class ProfileController extends Fake implements AuthController {
  String? submittedCurrentPassword;
  String? submittedPassword;
  int deactivationEmails = 0;
  int deactivations = 0;
  int logouts = 0;
  @override
  Future<void> requestDeactivationLink() async {
    deactivationEmails++;
  }

  @override
  Future<void> deactivateAccount({required String password}) async {
    deactivations++;
  }

  @override
  Future<bool> logout() async {
    logouts++;
    return true;
  }

  @override
  Uint8List? avatarBytesFor(AuthUser? user) => null;
  @override
  String? avatarUrlFor(AuthUser? user, {bool preferThumb = false}) => null;
  @override
  AuthUser? get currentUser => user;
  @override
  NotificationPreferences get notificationPreferences =>
      const NotificationPreferences.defaults();
  @override
  Future<AuthUser> loadCurrentUser() async => user;
  @override
  Future<NotificationPreferences> loadNotificationPreferences() async =>
      notificationPreferences;
  @override
  Future<AuthUser> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? currentPassword,
    String? preferredCurrencyCode,
    Map<String, String?>? paymentDetails,
  }) async {
    submittedCurrentPassword = currentPassword;
    submittedPassword = password;
    return user;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('profile email is visible but cannot be edited', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: ProfilePage(
          controller: ProfileController(),
          showBottomNav: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(user.email!).first);
    await tester.pumpAndSettle();
    expect(find.text(user.email!), findsOneWidget);
    final tile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text(user.email!),
        matching: find.byType(ListTile),
      ),
    );
    expect(tile.onTap, isNull);
    await tester.tap(find.text(user.email!));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'deactivation email does not deactivate or log out before confirmation',
    (tester) async {
      final controller = ProfileController();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ProfilePage(controller: controller, showBottomNav: false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Deactivate account'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deactivate account'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Send deactivation link'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send deactivation link'));
      await tester.pumpAndSettle();
      expect(controller.deactivationEmails, 1);
      expect(controller.deactivations, 0);
      expect(controller.logouts, 0);
      expect(
        find.text(
          'Check your email to confirm deactivation. Your account is still active.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'password reauthentication survives all controller/repository layers unchanged',
    () async {
      final h = ControllerHarness();
      await h.controller.updateProfile(
        email: user.email,
        password: 'New-password-123',
        currentPassword: ' Current-password-123 ',
      );
      expect(h.api.body, {
        'email': user.email,
        'password': 'New-password-123',
        'current_password': ' Current-password-123 ',
      });
      expect(h.api.path, contains('update_profile'));
    },
  );
  test('ordinary profile change sends no credential fields', () async {
    final h = ControllerHarness();
    await h.controller.updateProfile(firstName: 'Synthetic', lastName: 'Owner');
    expect(h.api.body, {'first_name': 'Synthetic', 'last_name': 'Owner'});
  });
  test(
    'deactivation email request sends no password and preserves session',
    () async {
      final h = ControllerHarness();
      await h.saveSession(1);
      await h.controller.requestDeactivationLink();
      expect(h.api.path, contains('request_deactivation_link'));
      expect(h.api.body, isEmpty);
      expect(await h.store.readAccountOwner(), 1);
      expect(h.loggedOut, 0);
    },
  );
  test(
    'verification-required enrollment clears local session and profile',
    () async {
      final h = ControllerHarness();
      await h.saveSession(1);
      await h.profiles.write(user);
      h.api.respond = () async => {
        'ok': true,
        'email_verification_required': true,
        'message': 'Verify your email.',
      };
      await expectLater(
        h.controller.setCredentials(
          email: user.email!,
          password: 'New-password-123',
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            'EMAIL_VERIFICATION_REQUIRED',
          ),
        ),
      );
      expect(h.controller.currentUser, isNull);
      expect(h.session.userId, isNull);
      expect(await h.store.readValidRefreshToken(), isNull);
      expect(await h.profiles.read(), isNull);
      expect(h.loggedOut, 1);
    },
  );
  test('late enrollment response cannot log a different account out', () async {
    final h = ControllerHarness();
    final pending = Completer<Map<String, dynamic>>();
    h.api.respond = () => pending.future;
    final call = h.controller.setCredentials(
      email: user.email!,
      password: 'New-password-123',
    );
    final expectation = expectLater(
      call,
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'account_changed'),
      ),
    );
    h.session.activate(2);
    h.controller.currentUser = user.copyWith(id: 2);
    await h.saveSession(2);
    pending.complete({'ok': true, 'email_verification_required': true});
    await expectation;
    expect(h.controller.currentUser?.id, 2);
    expect(await h.store.readAccountOwner(), 2);
    expect(h.loggedOut, 0);
    expect(h.api.revocations, 0);
  });
  test('wrong current password does not clear a valid session', () async {
    final h = ControllerHarness();
    await h.saveSession(1);
    h.api.respond = () async => throw const ApiException(
      'Incorrect current password.',
      code: 'REAUTHENTICATION_REQUIRED',
    );
    await expectLater(
      h.controller.updateProfile(
        email: user.email,
        password: 'New-password-123',
        currentPassword: 'wrong',
      ),
      throwsA(isA<ApiException>()),
    );
    expect(await h.store.readAccountOwner(), 1);
    expect(h.loggedOut, 0);
  });
  testWidgets(
    'password screen requires current password and provides recovery',
    (tester) async {
      final controller = ProfileController();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routes: {
            AppRouter.forgotPassword: (_) =>
                const Scaffold(body: Text('Recovery screen')),
          },
          home: ProfilePage(controller: controller, showBottomNav: false),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Change password'), 300);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      expect(find.text('Current password'), findsOneWidget);
      expect(find.text('Set password by email'), findsOneWidget);
      final fields = find.byType(TextFormField);
      expect(fields, findsNWidgets(3));
      await tester.enterText(fields.at(1), 'New-password-123');
      await tester.enterText(fields.at(2), 'New-password-123');
      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(controller.submittedPassword, isNull);
      await tester.enterText(fields.at(0), ' Current-password-123 ');
      await tester.ensureVisible(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(controller.submittedCurrentPassword, ' Current-password-123 ');
      expect(controller.submittedPassword, 'New-password-123');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'email password setup needs no current password and preserves session',
    (tester) async {
      final h = ControllerHarness();
      await h.saveSession(1);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: ForgotPasswordPage(
            controller: h.controller,
            initialEmail: user.email,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Set password by email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text(user.email!), findsOneWidget);
      await tester.tap(find.text('Send reset link'));
      await tester.pumpAndSettle();
      expect(h.api.path, contains('forgot_password'));
      expect(h.api.body, {'email': user.email});
      expect(h.controller.currentUser?.id, 1);
      expect(await h.store.readAccountOwner(), 1);
      expect(h.loggedOut, 0);
      expect(find.text('Back to profile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('profile opens email setup without filling any password fields', (
    tester,
  ) async {
    String? requestedEmail;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        routes: {
          AppRouter.forgotPassword: (context) {
            requestedEmail =
                ModalRoute.of(context)!.settings.arguments as String;
            return const Scaffold(body: Text('Email setup screen'));
          },
        },
        home: ProfilePage(
          controller: ProfileController(),
          showBottomNav: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Change password'), 300);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set password by email'));
    await tester.pumpAndSettle();
    expect(requestedEmail, user.email);
    expect(find.text('Email setup screen'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
