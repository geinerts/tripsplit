import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/auth/auth_session_store.dart';
import '../../../../core/auth/device_token_store.dart';
import '../../../../core/auth/user_avatar_store.dart';
import '../../../../core/network/legacy_avatar_uploader.dart';
import '../../data/models/auth_user_model.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/get_me_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/set_credentials_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';

class AuthController {
  AuthController(
    this._loginUseCase,
    this._registerUseCase,
    this._setCredentialsUseCase,
    this._updateProfileUseCase,
    this._getMeUseCase,
    this._tokenStore,
    this._authSessionStore,
    this._avatarStore,
    this._avatarUploader,
  );

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final SetCredentialsUseCase _setCredentialsUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetMeUseCase _getMeUseCase;
  final DeviceTokenStore _tokenStore;
  final AuthSessionStore _authSessionStore;
  final UserAvatarStore _avatarStore;
  final LegacyAvatarUploader _avatarUploader;

  AuthUser? currentUser;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final user = await _withStoredAvatar(
      await _loginUseCase.call(email: email, password: password),
    );
    currentUser = user;
    return user;
  }

  Future<AuthUser> register({
    required String firstName,
    required String lastName,
    required String nickname,
    required String email,
    required String password,
  }) async {
    final user = await _withStoredAvatar(
      await _registerUseCase.call(
        firstName: firstName,
        lastName: lastName,
        nickname: nickname,
        email: email,
        password: password,
      ),
    );
    currentUser = user;
    return user;
  }

  Future<AuthUser> setCredentials({
    required String email,
    required String password,
  }) async {
    final user = await _withStoredAvatar(
      await _setCredentialsUseCase.call(email: email, password: password),
    );
    currentUser = user;
    return user;
  }

  Future<AuthUser> updateProfile({
    required String nickname,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
  }) async {
    final user = await _withStoredAvatar(
      await _updateProfileUseCase.call(
        firstName: firstName,
        lastName: lastName,
        nickname: nickname,
        email: email,
        password: password,
      ),
    );
    currentUser = user;
    return user;
  }

  Future<AuthUser> loadCurrentUser() async {
    final user = await _withStoredAvatar(await _getMeUseCase.call());
    currentUser = user;
    return user;
  }

  Uint8List? avatarBytesFor(AuthUser? user) {
    final encoded = user?.avatarBase64;
    if (encoded == null || encoded.trim().isEmpty) {
      return null;
    }
    try {
      return base64Decode(encoded);
    } catch (_) {
      return null;
    }
  }

  String? avatarUrlFor(AuthUser? user, {bool preferThumb = false}) {
    final candidates = preferThumb
        ? <String?>[user?.avatarThumbUrl, user?.avatarUrl]
        : <String?>[user?.avatarUrl, user?.avatarThumbUrl];
    for (final candidate in candidates) {
      final raw = candidate?.trim();
      if (raw != null && raw.isNotEmpty) {
        return raw;
      }
    }
    return null;
  }

  Future<AuthUser?> updateLocalAvatar(Uint8List? bytes) async {
    final user = currentUser;
    if (user == null || user.id <= 0) {
      return null;
    }
    final encoded = bytes == null || bytes.isEmpty ? null : base64Encode(bytes);
    await _avatarStore.writeAvatarBase64(
      userId: user.id,
      avatarBase64: encoded,
    );
    final next = encoded == null
        ? user.copyWith(clearAvatar: true)
        : user.copyWith(avatarBase64: encoded);
    currentUser = next;
    return next;
  }

  Future<AuthUser?> uploadAvatar({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final user = currentUser;
    if (user == null || user.id <= 0 || bytes.isEmpty) {
      return null;
    }

    final uploaded = await _avatarUploader.uploadAvatar(
      fileName: fileName,
      bytes: bytes,
    );
    final encoded = base64Encode(bytes);
    final merged = _mergeRemoteMe(
      user,
      uploaded.mePayload,
    ).copyWith(
      avatarBase64: encoded,
      avatarUrl: uploaded.avatarUrl,
      avatarThumbUrl: uploaded.avatarThumbUrl,
    );

    await _avatarStore.writeAvatarBase64(
      userId: merged.id,
      avatarBase64: encoded,
    );
    currentUser = merged;
    return merged;
  }

  Future<AuthUser?> removeAvatar() async {
    final user = currentUser;
    if (user == null || user.id <= 0) {
      return null;
    }

    final removed = await _avatarUploader.removeAvatar();
    final merged = _mergeRemoteMe(
      user,
      removed.mePayload,
    ).copyWith(clearAvatar: true);

    await _avatarStore.writeAvatarBase64(userId: merged.id, avatarBase64: null);
    currentUser = merged;
    return merged;
  }

  Future<void> logout() async {
    await _authSessionStore.clear();
    await _tokenStore.resetToken();
    currentUser = null;
  }

  Future<AuthUser> _withStoredAvatar(AuthUser user) async {
    final stored = await _avatarStore.readAvatarBase64(user.id);
    if (stored == null || stored == user.avatarBase64) {
      return user;
    }
    return user.copyWith(avatarBase64: stored);
  }

  AuthUser _mergeRemoteMe(AuthUser fallback, Map<String, dynamic>? mePayload) {
    if (mePayload == null) {
      return fallback;
    }
    return AuthUserModel.fromLegacyMap(mePayload);
  }
}
