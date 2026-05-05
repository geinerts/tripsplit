import 'dart:async';

import 'package:app_links/app_links.dart';

class InviteDeepLinkParser {
  const InviteDeepLinkParser._();

  static String? extractInviteCodeFromRaw(String rawInput) {
    final raw = rawInput.trim();
    if (raw.isEmpty) {
      return null;
    }
    final direct = _extractInviteCode(raw);
    if (direct != null) {
      return direct;
    }

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final fromUri = extractInviteCodeFromUri(uri);
      if (fromUri != null) {
        return fromUri;
      }
    }

    final fromRaw = RegExp(r'(?:^|[?&])invite=([^&\s]+)').firstMatch(raw);
    final rawValue = (fromRaw?.group(1) ?? '').trim();
    if (rawValue.isNotEmpty) {
      final decoded = Uri.decodeComponent(rawValue).trim();
      final code = _extractInviteCode(decoded);
      if (code != null) {
        return code;
      }
    }

    final withoutPrefix = raw.replaceFirst(
      RegExp(r'^(invite:|trip-invite:)', caseSensitive: false),
      '',
    );
    return _extractInviteCode(withoutPrefix.trim());
  }

  static String? extractInviteCodeFromUri(Uri uri) {
    final fromQuery = (uri.queryParameters['invite'] ?? '').trim();
    if (fromQuery.isNotEmpty) {
      final code = _extractInviteCode(Uri.decodeComponent(fromQuery).trim());
      if (code != null) {
        return code;
      }
    }

    final fragment = uri.fragment.trim();
    if (fragment.isNotEmpty) {
      final match = RegExp(r'(?:^|[?&])invite=([^&]+)').firstMatch(fragment);
      final value = (match?.group(1) ?? '').trim();
      if (value.isNotEmpty) {
        final code = _extractInviteCode(Uri.decodeComponent(value).trim());
        if (code != null) {
          return code;
        }
      }
    }

    // Fallback for custom scheme like tripsplit://invite/<slug-code>
    final path = uri.path.trim();
    if (path.isNotEmpty) {
      final candidate = path.startsWith('/') ? path.substring(1) : path;
      final code = _extractInviteCode(candidate);
      if (code != null) {
        return code;
      }
    }

    return null;
  }

  static int? extractFriendUserIdFromRaw(String rawInput) {
    return extractFriendTargetFromRaw(rawInput)?.userId;
  }

  static FriendDeepLinkTarget? extractFriendTargetFromRaw(String rawInput) {
    final raw = rawInput.trim();
    if (raw.isEmpty) {
      return null;
    }
    if (RegExp(r'^\d+$').hasMatch(raw)) {
      final userId = int.tryParse(raw);
      return userId == null || userId <= 0
          ? null
          : FriendDeepLinkTarget(userId: userId);
    }
    final fromOpaqueCode = FriendLinkCodec.decode(raw);
    if (fromOpaqueCode != null) {
      return FriendDeepLinkTarget(userId: fromOpaqueCode);
    }

    final uri = Uri.tryParse(raw);
    if (uri != null) {
      final fromUri = extractFriendTargetFromUri(uri);
      if (fromUri != null) {
        return fromUri;
      }
    }

    final queryMatch = RegExp(
      r'(?:^|[?&])(?:uid|user_id|friend|friend_id)=(\d+)(?:&|$)',
      caseSensitive: false,
    ).firstMatch(raw);
    final queryValue = (queryMatch?.group(1) ?? '').trim();
    if (RegExp(r'^\d+$').hasMatch(queryValue)) {
      final userId = int.tryParse(queryValue);
      return userId == null || userId <= 0
          ? null
          : FriendDeepLinkTarget(userId: userId);
    }

    return null;
  }

  static int? extractFriendUserIdFromUri(Uri uri) {
    return extractFriendTargetFromUri(uri)?.userId;
  }

  static FriendDeepLinkTarget? extractFriendTargetFromUri(Uri uri) {
    final scheme = uri.scheme.trim().toLowerCase();
    final host = uri.host.trim().toLowerCase();
    final pathSegments = uri.pathSegments
        .map((segment) => segment.trim().toLowerCase())
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    final isCustomFriendHost =
        (scheme == 'splyto' || scheme == 'tripsplit') &&
        (host == 'friend' || host == 'friends' || host == 'add-friend');
    final isFriendPath =
        pathSegments.isNotEmpty &&
        (pathSegments.first == 'friend' ||
            pathSegments.first == 'friends' ||
            pathSegments.first == 'add-friend');
    final hasFriendQuery =
        uri.queryParameters.containsKey('friend') ||
        uri.queryParameters.containsKey('friend_id');

    if (!isCustomFriendHost && !isFriendPath && !hasFriendQuery) {
      return null;
    }

    int? userId;
    for (final key in const <String>['uid', 'user_id', 'friend', 'friend_id']) {
      final candidate = (uri.queryParameters[key] ?? '').trim();
      if (RegExp(r'^\d+$').hasMatch(candidate)) {
        userId = int.tryParse(candidate);
        break;
      }
    }
    userId ??= _extractFriendUserIdFromOpaqueCode(uri);

    if (userId == null) {
      final numericSegment = isCustomFriendHost
          ? (pathSegments.isNotEmpty ? pathSegments.first : '')
          : (pathSegments.length >= 2 ? pathSegments[1] : '');
      if (RegExp(r'^\d+$').hasMatch(numericSegment)) {
        userId = int.tryParse(numericSegment);
      }
    }

    if (userId == null || userId <= 0) {
      return null;
    }

    return FriendDeepLinkTarget(
      userId: userId,
      displayName: _extractFriendDisplayName(uri),
    );
  }

  static int? _extractFriendUserIdFromOpaqueCode(Uri uri) {
    for (final key in const <String>['code', 'friend_code']) {
      final candidate = (uri.queryParameters[key] ?? '').trim();
      final userId = FriendLinkCodec.decode(candidate);
      if (userId != null) {
        return userId;
      }
    }

    final pathSegments = uri.pathSegments
        .map((segment) => segment.trim())
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    for (final segment in pathSegments) {
      final normalized = segment.toLowerCase();
      if (normalized == 'friend' ||
          normalized == 'friends' ||
          normalized == 'add-friend') {
        continue;
      }
      final userId = FriendLinkCodec.decode(segment);
      if (userId != null) {
        return userId;
      }
    }

    return null;
  }

  static String? _extractInviteCode(String value) {
    final raw = value.trim().toLowerCase();
    if (raw.isEmpty || raw.contains(RegExp(r'\s'))) {
      return null;
    }
    if (_looksLikeInviteCode(raw)) {
      return raw;
    }
    final tagged = RegExp(
      r'^[a-z0-9][a-z0-9-]*-([a-z0-9]{10})$',
    ).firstMatch(raw);
    final code = (tagged?.group(1) ?? '').trim();
    if (_looksLikeInviteCode(code)) {
      return code;
    }
    return null;
  }

  static bool _looksLikeInviteCode(String value) {
    final raw = value.trim();
    return RegExp(r'^[a-z0-9]{10}$').hasMatch(raw);
  }

  static String? _extractFriendDisplayName(Uri uri) {
    for (final key in const <String>['name', 'display_name', 'displayName']) {
      final raw = (uri.queryParameters[key] ?? '').trim();
      if (raw.isEmpty) {
        continue;
      }
      final decoded = Uri.decodeComponent(raw).trim();
      if (decoded.isNotEmpty) {
        return decoded;
      }
    }
    return null;
  }
}

class FriendLinkCodec {
  const FriendLinkCodec._();

  static const String _alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const int _mask31 = 0x7fffffff;
  static const int _salt = 0x5a17c9e3;
  static const int _offset = 0x13579bdf;

  static String encode(int userId) {
    if (userId <= 0) {
      return '';
    }
    final mixed = (((userId ^ _salt) + _offset) & _mask31);
    final body = _encodeBase32(mixed).padLeft(7, _alphabet[0]);
    final checksum = _encodeBase32(_checksum(mixed)).padLeft(2, _alphabet[0]);
    return '$body$checksum';
  }

  static int? decode(String rawCode) {
    final code = rawCode.trim().toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    if (code.length != 9) {
      return null;
    }

    final body = code.substring(0, 7);
    final checksum = code.substring(7);
    final mixed = _decodeBase32(body);
    if (mixed < 0) {
      return null;
    }
    final expectedChecksum = _encodeBase32(
      _checksum(mixed),
    ).padLeft(2, _alphabet[0]);
    if (checksum != expectedChecksum) {
      return null;
    }

    final userId = (((mixed - _offset) & _mask31) ^ _salt);
    return userId > 0 ? userId : null;
  }

  static String _encodeBase32(int value) {
    if (value <= 0) {
      return _alphabet[0];
    }
    var next = value;
    final chars = <String>[];
    while (next > 0) {
      chars.add(_alphabet[next & 31]);
      next = next >> 5;
    }
    return chars.reversed.join();
  }

  static int _decodeBase32(String value) {
    var result = 0;
    for (final unit in value.codeUnits) {
      final index = _alphabet.indexOf(String.fromCharCode(unit));
      if (index < 0) {
        return -1;
      }
      result = (result << 5) | index;
    }
    return result;
  }

  static int _checksum(int mixed) {
    return (mixed ^ (mixed >> 7) ^ (mixed >> 17) ^ 0x2d4b) & 0x3ff;
  }
}

class FriendDeepLinkTarget {
  const FriendDeepLinkTarget({required this.userId, this.displayName});

  final int userId;
  final String? displayName;
}

class InviteDeepLinkController {
  InviteDeepLinkController({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  final StreamController<String> _inviteCodeController =
      StreamController<String>.broadcast();
  final StreamController<FriendDeepLinkTarget> _friendTargetController =
      StreamController<FriendDeepLinkTarget>.broadcast();
  StreamSubscription<Uri>? _uriSubscription;
  bool _started = false;
  String? _pendingInviteCode;
  FriendDeepLinkTarget? _pendingFriendTarget;

  Stream<String> get inviteCodeStream => _inviteCodeController.stream;
  Stream<FriendDeepLinkTarget> get friendTargetStream =>
      _friendTargetController.stream;
  Stream<int> get friendUserIdStream =>
      _friendTargetController.stream.map((target) => target.userId);

  String? consumePendingInviteCode() {
    final value = _pendingInviteCode;
    _pendingInviteCode = null;
    return value;
  }

  int? consumePendingFriendUserId() {
    return consumePendingFriendTarget()?.userId;
  }

  FriendDeepLinkTarget? consumePendingFriendTarget() {
    final value = _pendingFriendTarget;
    _pendingFriendTarget = null;
    return value;
  }

  void start() {
    if (_started) {
      return;
    }
    _started = true;
    unawaited(_emitInitialLinkIfAny());
    _uriSubscription = _appLinks.uriLinkStream.listen(_handleIncomingUri);
  }

  Future<void> _emitInitialLinkIfAny() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleIncomingUri(uri);
      }
    } catch (_) {
      // Ignore malformed/unsupported initial links.
    }
  }

  void _handleIncomingUri(Uri uri) {
    final inviteCode = InviteDeepLinkParser.extractInviteCodeFromUri(uri);
    if (inviteCode != null && inviteCode.isNotEmpty) {
      _pendingInviteCode = inviteCode;
      _inviteCodeController.add(inviteCode);
    }

    final friendTarget = InviteDeepLinkParser.extractFriendTargetFromUri(uri);
    if (friendTarget != null && friendTarget.userId > 0) {
      _pendingFriendTarget = friendTarget;
      _friendTargetController.add(friendTarget);
    }
  }

  Future<void> dispose() async {
    await _uriSubscription?.cancel();
    await _inviteCodeController.close();
    await _friendTargetController.close();
  }
}
