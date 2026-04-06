import '../config/app_env.dart';

class MediaUrlResolver {
  const MediaUrlResolver._();

  static String? normalize(Object? rawValue) {
    final raw = (rawValue as String?)?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }

    if (raw.startsWith('data:')) {
      return raw;
    }

    final base = Uri.tryParse(AppEnv.current.apiBaseUrl);
    if (base == null || !base.hasScheme || base.host.isEmpty) {
      return raw;
    }

    final normalizedBase = _withTrailingSlash(base);
    final projectBasePath = _projectBasePath(normalizedBase.path);

    if (raw.startsWith('/')) {
      return _composeAbsolute(
        base: normalizedBase,
        path: _rewriteUploadsPath(raw, projectBasePath),
      );
    }

    final parsedRaw = Uri.tryParse(raw);
    if (parsedRaw != null && parsedRaw.hasScheme && parsedRaw.host.isNotEmpty) {
      return _normalizeAbsolute(
        parsedRaw,
        base: normalizedBase,
        projectBasePath: projectBasePath,
      );
    }

    return normalizedBase.resolve(raw).toString();
  }

  static Uri _withTrailingSlash(Uri uri) {
    final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return uri.replace(path: path);
  }

  static String _projectBasePath(String basePath) {
    final trimmed = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    if (trimmed.isEmpty || trimmed == '/') {
      return '';
    }
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }

  static String _composeAbsolute({required Uri base, required String path}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final resolved = base.replace(
      path: normalizedPath,
      queryParameters: null,
      query: null,
      fragment: null,
    );
    return resolved.toString();
  }

  static String _normalizeAbsolute(
    Uri uri, {
    required Uri base,
    required String projectBasePath,
  }) {
    var next = uri;
    final sameHost = next.host.toLowerCase() == base.host.toLowerCase();
    final uploadsIndex = _uploadsSegmentIndex(next.path);
    final isUploadsPath = uploadsIndex >= 0;

    if (!sameHost && isUploadsPath) {
      return _composeAbsolute(
        base: base,
        path: _rewriteUploadsPath(next.path, projectBasePath),
      );
    }

    if (base.scheme == 'https' && next.scheme == 'http' && sameHost) {
      next = next.replace(
        scheme: 'https',
        port: base.hasPort ? base.port : 443,
      );
    }

    if (sameHost) {
      final rewrittenPath = _rewriteUploadsPath(next.path, projectBasePath);
      if (rewrittenPath != next.path) {
        next = next.replace(path: rewrittenPath);
      }
    }

    return next.toString();
  }

  static String _rewriteUploadsPath(String path, String projectBasePath) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uploadsIndex = _uploadsSegmentIndex(normalizedPath);
    if (uploadsIndex >= 0) {
      final uploadsTail = normalizedPath.substring(uploadsIndex);
      if (projectBasePath.isEmpty) {
        return uploadsTail;
      }
      return '$projectBasePath$uploadsTail';
    }

    if (projectBasePath.isEmpty) {
      return normalizedPath;
    }
    if (normalizedPath.startsWith('$projectBasePath/')) {
      return normalizedPath;
    }
    if (normalizedPath == projectBasePath) {
      return normalizedPath;
    }
    if (normalizedPath.startsWith('/uploads/')) {
      return '$projectBasePath$normalizedPath';
    }
    return normalizedPath;
  }

  static int _uploadsSegmentIndex(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return normalizedPath.indexOf('/uploads/');
  }
}
