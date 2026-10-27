import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Gives every text field, including fields in navigator overlays, the same
/// outside-tap behavior on mobile. TextFieldTapRegion keeps field accessories
/// and other text fields inside the editing region.
class AppKeyboardDismissal extends StatefulWidget {
  const AppKeyboardDismissal({super.key, required this.child});

  final Widget child;

  @override
  State<AppKeyboardDismissal> createState() => _AppKeyboardDismissalState();
}

class _AppKeyboardDismissalState extends State<AppKeyboardDismissal> {
  (FocusNode, PointerDownEvent)? _outsideTap;

  void _onTapDown(EditableTextTapOutsideIntent intent) {
    final event = intent.pointerDownEvent;
    if (event.kind == PointerDeviceKind.touch) {
      // Wait for release so scrolling is not mistaken for a tap and keyboard
      // dismissal cannot move an action button before its tap completes.
      _outsideTap = (intent.focusNode, event);
    } else {
      _outsideTap = null;
      intent.focusNode.unfocus();
    }
  }

  void _onTapUp(EditableTextTapUpOutsideIntent intent) {
    final candidate = _outsideTap;
    _outsideTap = null;
    if (candidate == null ||
        candidate.$2.pointer != intent.pointerUpEvent.pointer ||
        candidate.$1 != intent.focusNode) {
      return;
    }
    if ((intent.pointerUpEvent.position - candidate.$2.position).distance <=
            kTouchSlop &&
        intent.focusNode.hasFocus) {
      intent.focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerMove: (event) {
      final candidate = _outsideTap;
      if (candidate != null &&
          candidate.$2.pointer == event.pointer &&
          (event.position - candidate.$2.position).distance > kTouchSlop) {
        _outsideTap = null;
      }
    },
    onPointerCancel: (event) {
      if (_outsideTap?.$2.pointer == event.pointer) _outsideTap = null;
    },
    child: Actions(
      actions: <Type, Action<Intent>>{
        EditableTextTapOutsideIntent:
            CallbackAction<EditableTextTapOutsideIntent>(
              onInvoke: (intent) {
                _onTapDown(intent);
                return null;
              },
            ),
        EditableTextTapUpOutsideIntent:
            CallbackAction<EditableTextTapUpOutsideIntent>(
              onInvoke: (intent) {
                _onTapUp(intent);
                return null;
              },
            ),
      },
      child: widget.child,
    ),
  );
}
