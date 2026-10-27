import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/ui/app_keyboard_dismissal.dart';

Widget app(Widget child) => MaterialApp(
  builder: (context, child) => AppKeyboardDismissal(child: child!),
  home: Scaffold(body: child),
);

void main() {
  for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
    testWidgets(
      'outside touch hides keyboard without clearing text on $platform',
      (tester) async {
        final focus = FocusNode();
        final controller = TextEditingController();
        addTearDown(focus.dispose);
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          app(
            Column(
              children: [
                TextField(
                  key: const ValueKey('field'),
                  focusNode: focus,
                  controller: controller,
                ),
                const SizedBox(
                  key: ValueKey('outside'),
                  width: double.infinity,
                  height: 160,
                ),
              ],
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('field')));
        await tester.enterText(
          find.byKey(const ValueKey('field')),
          'Keep this draft',
        );
        expect(tester.testTextInput.isVisible, isTrue);
        await tester.tapAt(
          tester.getCenter(find.byKey(const ValueKey('outside'))),
        );
        await tester.pump();
        expect(focus.hasFocus, isFalse);
        expect(tester.testTextInput.isVisible, isFalse);
        expect(controller.text, 'Keep this draft');
      },
      variant: TargetPlatformVariant({platform}),
    );
  }

  testWidgets(
    'field taps, switching fields and accessories keep keyboard usable',
    (tester) async {
      final first = FocusNode();
      final second = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      var accessoryTaps = 0;
      await tester.pumpWidget(
        app(
          Column(
            children: [
              TextField(key: const ValueKey('first'), focusNode: first),
              TextFormField(key: const ValueKey('second'), focusNode: second),
              TextFieldTapRegion(
                child: TextButton(
                  onPressed: () => accessoryTaps++,
                  child: const Text('Field accessory'),
                ),
              ),
            ],
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('first')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('first')));
      await tester.pump();
      expect(first.hasFocus, isTrue);
      await tester.tap(find.byKey(const ValueKey('second')));
      await tester.pump();
      expect(first.hasFocus, isFalse);
      expect(second.hasFocus, isTrue);
      await tester.tap(find.text('Field accessory'));
      await tester.pump();
      expect(accessoryTaps, 1);
      expect(second.hasFocus, isTrue);
      expect(tester.testTextInput.isVisible, isTrue);
    },
  );

  testWidgets(
    'an outside action executes on first tap before focus is dropped',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      var taps = 0;
      await tester.pumpWidget(
        app(
          Column(
            children: [
              TextField(focusNode: focus),
              TextButton(onPressed: () => taps++, child: const Text('Save')),
            ],
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Save')),
      );
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await gesture.up();
      await tester.pump();
      expect(taps, 1);
      expect(focus.hasFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
    },
  );

  testWidgets('outside scrolling and cancelled gestures do not dismiss editing', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      app(
        ListView(
          children: [
            TextField(focusNode: focus),
            Container(
              key: const ValueKey('outside'),
              height: 1200,
              color: Colors.transparent,
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    // Move out and back: checking only the release position would misclassify it.
    final gesture = await tester.startGesture(const Offset(100, 200));
    await gesture.moveBy(const Offset(0, -70));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 70));
    await gesture.up();
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    final cancelled = await tester.startGesture(const Offset(100, 200));
    await cancelled.cancel();
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await tester.tapAt(const Offset(100, 200));
    await tester.pump();
    expect(focus.hasFocus, isFalse);
  });

  for (final overlay in ['sheet', 'dialog', 'route']) {
    testWidgets('root policy covers $overlay fields', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      Widget fields() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(key: const ValueKey('overlay-field'), focusNode: focus),
          Container(
            key: const ValueKey('overlay-outside'),
            width: double.infinity,
            height: 90,
            color: Colors.transparent,
          ),
        ],
      );
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () {
                  if (overlay == 'sheet') {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => fields(),
                    );
                  } else if (overlay == 'dialog') {
                    showDialog<void>(
                      context: context,
                      builder: (_) => AlertDialog(content: fields()),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(body: fields()),
                      ),
                    );
                  }
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('overlay-field')));
      await tester.pump();
      expect(tester.testTextInput.isVisible, isTrue);
      await tester.tap(find.byKey(const ValueKey('overlay-outside')));
      await tester.pump();
      expect(focus.hasFocus, isFalse);
      expect(tester.testTextInput.isVisible, isFalse);
      expect(find.byKey(const ValueKey('overlay-field')), findsOneWidget);
    });
  }

  testWidgets('mouse outside click retains desktop dismissal', (tester) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      app(
        Column(
          children: [
            TextField(focusNode: focus),
            const SizedBox(
              height: 100,
              width: double.infinity,
              key: ValueKey('outside'),
            ),
          ],
        ),
      ),
    );
    await tester.tap(find.byType(TextField));
    await tester.pump();
    final pointer = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('outside'))),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pump();
    expect(focus.hasFocus, isFalse);
    await pointer.up();
  });
}
