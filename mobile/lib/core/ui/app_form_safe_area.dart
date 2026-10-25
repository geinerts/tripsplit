import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Uses UIKit's full-width safe rectangle on compact windows with a side
/// status area. Falls back to Flutter's safe area on older systems/other devices.
class AppFormSafeArea extends StatefulWidget {
  const AppFormSafeArea({super.key, this.header, required this.child});

  final Widget? header;
  final Widget child;

  @override
  State<AppFormSafeArea> createState() => _AppFormSafeAreaState();
}

class _AppFormSafeAreaState extends State<AppFormSafeArea>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('app.splyto/window_layout');
  Size? _requestedSize;
  EdgeInsets? _requestedPadding;
  EdgeInsets? _nativeInsets;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _request++;
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // A fold can change UIKit geometry before Flutter's next layout frame.
    _requestedSize = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final media = MediaQuery.of(context);
    if (_requestedSize == media.size &&
        _requestedPadding == media.viewPadding) {
      return;
    }
    _requestedSize = media.size;
    _requestedPadding = media.viewPadding;
    _nativeInsets = null;
    final request = ++_request;
    if (widget.header == null ||
        kIsWeb ||
        defaultTargetPlatform != TargetPlatform.iOS ||
        media.size.width >= 700 ||
        media.viewPadding.horizontal == 0) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(media, request));
  }

  Future<void> _load(MediaQueryData media, int request) async {
    try {
      final values = await _channel.invokeMapMethod<String, dynamic>(
        'getLayout',
      );
      if (!mounted || request != _request || values == null) return;
      double value(String key) => (values[key] as num).toDouble();
      // Never apply geometry from the previous display during a fold.
      if ((value('width') - media.size.width).abs() > 1 ||
          (value('height') - media.size.height).abs() > 1) {
        return;
      }
      final insets = EdgeInsets.fromLTRB(
        value('left'),
        value('top'),
        value('right'),
        value('bottom'),
      );
      if (insets.horizontal >= media.viewPadding.horizontal ||
          media.size.height - insets.vertical < 320) {
        return;
      }
      setState(() => _nativeInsets = insets);
    } on MissingPluginException {
      // Older builds and non-native previews keep the standard safe area.
    } on PlatformException {
      // A detached native view must not prevent opening a form.
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final media = MediaQuery.of(context);
      // With very little height (for example a floating keyboard), retain the
      // side-safe layout instead of placing content inside the status region.
      final native =
          _nativeInsets != null &&
              constraints.maxHeight >= _nativeInsets!.top + 180
          ? _nativeInsets
          : null;
      final padding = native == null
          ? media.padding
          : EdgeInsets.fromLTRB(
              math.max(0, native.left - media.viewInsets.left),
              math.max(0, native.top - media.viewInsets.top),
              math.max(0, native.right - media.viewInsets.right),
              math.max(0, native.bottom - media.viewInsets.bottom),
            );
      // Keep the same tree in both layouts, so text fields and scroll state survive.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: math.max(
                  native?.top ?? 0,
                  constraints.maxHeight * .4,
                ),
              ),
              child: SingleChildScrollView(
                primary: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: native?.top ?? 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: 1,
                    child: SafeArea(
                      bottom: false,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: widget.header!,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: MediaQuery(
              data: media.copyWith(
                padding: padding,
                viewPadding: native ?? media.viewPadding,
              ),
              child: SafeArea(
                top: widget.header == null,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
