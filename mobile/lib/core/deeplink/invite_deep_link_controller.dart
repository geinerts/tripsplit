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
}

class InviteDeepLinkController {
  InviteDeepLinkController({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  final StreamController<String> _inviteCodeController =
      StreamController<String>.broadcast();
  StreamSubscription<Uri>? _uriSubscription;
  bool _started = false;
  String? _pendingInviteCode;

  Stream<String> get inviteCodeStream => _inviteCodeController.stream;

  String? consumePendingInviteCode() {
    final value = _pendingInviteCode;
    _pendingInviteCode = null;
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
    if (inviteCode == null || inviteCode.isEmpty) {
      return;
    }
    _pendingInviteCode = inviteCode;
    _inviteCodeController.add(inviteCode);
  }

  Future<void> dispose() async {
    await _uriSubscription?.cancel();
    await _inviteCodeController.close();
  }
}
