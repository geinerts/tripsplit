import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A push notification the person tapped: its type, trip and ids, as the
/// server sent them (see api/lib/helpers/push/).
@immutable
class PushTap {
  const PushTap({required this.type, this.tripId = 0, this.values = const {}});

  factory PushTap.fromMap(Map<Object?, Object?> raw) {
    final values = <String, String>{
      for (final entry in raw.entries)
        if (entry.key is String && entry.value != null)
          entry.key! as String: '${entry.value}',
    };
    return PushTap(
      type: (values['type'] ?? '').trim().toLowerCase(),
      tripId: int.tryParse(values['trip_id'] ?? '') ?? 0,
      values: values,
    );
  }

  final String type;
  final int tripId;
  final Map<String, String> values;

  int? intValue(String key) => int.tryParse(values[key] ?? '');

  String? stringValue(String key) {
    final value = values[key]?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}

/// Taps on push notifications, from iOS and Android.
class PushTapChannel {
  PushTapChannel._();

  static const MethodChannel _channel = MethodChannel('app.splyto/push');
  static Object? _owner;

  /// Calls [onTap] for every later tap and returns the tap that opened the
  /// app, if any. Native code keeps taps until this is called. The latest
  /// [owner] wins; [stop] with an older owner does nothing.
  static Future<PushTap?> listen(
    Object owner,
    ValueChanged<PushTap> onTap,
  ) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      return null;
    }
    _owner = owner;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'notificationTapped' && call.arguments is Map) {
        onTap(PushTap.fromMap(call.arguments as Map));
      }
      return null;
    });
    try {
      final raw = await _channel.invokeMethod<Object?>(
        'takePendingNotificationTap',
      );
      return raw is Map ? PushTap.fromMap(raw) : null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  static void stop(Object owner) {
    if (kIsWeb || !identical(_owner, owner)) return;
    _owner = null;
    _channel.setMethodCallHandler(null);
  }
}
