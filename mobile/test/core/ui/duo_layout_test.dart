import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/ui/app_bottom_nav_bar.dart';
import 'package:tripsplit/core/ui/app_scaffold.dart';
import 'package:tripsplit/core/ui/app_sheet.dart';
import 'package:tripsplit/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tripsplit/features/auth/presentation/pages/auth_intro_page.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_form_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class _Auth implements AuthController {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Widget _app(Widget home, {double scale = 1}) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: home,
);

void _view(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetPadding);
  addTearDown(tester.view.resetViewInsets);
  addTearDown(tester.view.resetViewPadding);
}

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'open Duo trip form has two aligned columns and retains field state scale=$scale',
      (tester) async {
        _view(tester);
        tester.view.physicalSize = const Size(951, 669);
        tester.view.padding = const FakeViewPadding(right: 84, bottom: 34);
        await tester.pumpWidget(
          _app(TripFormPage(pickImage: (_) async => null), scale: scale),
        );
        await tester.pumpAndSettle();
        final name = find.byKey(const ValueKey('trip-form-name'));
        final cover = find.byKey(const ValueKey('trip-cover-picker'));
        final submit = find.byKey(const ValueKey('trip-form-submit'));
        final coverRect = tester.getRect(cover);
        final nameRect = tester.getRect(name);
        final actionRect = tester.getRect(submit);
        expect(nameRect.top, closeTo(coverRect.top, 1));
        expect(nameRect.left - coverRect.right, closeTo(28, 1));
        expect(actionRect.left, closeTo(nameRect.left, 1));
        expect(actionRect.right, closeTo(nameRect.right, 1));
        expect(actionRect.width, lessThan(420));
        await tester.enterText(name, 'Lisbon with friends');
        final fieldState = tester.state(name);
        final editable = tester.state<EditableTextState>(
          find.byType(EditableText),
        );
        editable.widget.controller.selection = const TextSelection.collapsed(
          offset: 6,
        );
        for (final width in [466.0, 669.0, 951.0]) {
          tester.view.physicalSize = Size(width, 669);
          tester.view.viewInsets = const FakeViewPadding(bottom: 250);
          await tester.pumpAndSettle();
          expect(tester.state(name), same(fieldState));
          expect(
            tester.state<EditableTextState>(find.byType(EditableText)),
            same(editable),
          );
          expect(editable.widget.focusNode.hasFocus, isTrue);
          expect(editable.widget.controller.selection.baseOffset, 6);
          expect(find.text('Lisbon with friends'), findsOneWidget);
          expect(tester.getRect(submit).bottom, lessThanOrEqualTo(419));
          if (width == 951) {
            expect(
              tester.getRect(name).left,
              greaterThan(tester.getRect(cover).right),
            );
          } else {
            expect(
              tester.getRect(name).top,
              greaterThan(tester.getRect(cover).bottom),
            );
          }
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'compact Duo form uses width below status region, retaining draft',
    (tester) async {
      _view(tester);
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      const channel = MethodChannel('app.splyto/window_layout');
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (_) async => {
          'width': 466.0,
          'height': 678.0,
          'left': 0.0,
          'top': 170.0,
          'right': 0.0,
          'bottom': 34.0,
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          null,
        ),
      );
      tester.view.physicalSize = const Size(466, 678);
      tester.view.padding = const FakeViewPadding(right: 84, bottom: 34);
      tester.view.viewPadding = const FakeViewPadding(right: 84, bottom: 34);
      await tester.pumpWidget(_app(TripFormPage(pickImage: (_) async => null)));
      await tester.pumpAndSettle();
      final name = find.byKey(const ValueKey('trip-form-name'));
      final submit = find.byKey(const ValueKey('trip-form-submit'));
      expect(tester.getRect(name).center.dx, closeTo(233, 1));
      expect(tester.getRect(submit).center.dx, closeTo(233, 1));
      expect(tester.getSize(name).width, 426);
      expect(
        tester.getRect(find.byKey(const ValueKey('trip-cover-picker'))).top,
        greaterThanOrEqualTo(170),
      );
      expect(
        tester.getRect(find.text('Create new trip')).right,
        lessThanOrEqualTo(382),
      );
      await tester.enterText(name, 'Duo draft');
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      tester.view.padding = const FakeViewPadding(right: 84);
      await tester.pumpAndSettle();
      expect(tester.getRect(submit).bottom, lessThanOrEqualTo(428));
      expect(tester.getRect(submit).center.dx, closeTo(233, 1));
      tester.view.viewInsets = const FakeViewPadding();
      tester.view.physicalSize = const Size(951, 669);
      await tester.pumpAndSettle();
      expect(find.text('Duo draft'), findsOneWidget);
      tester.view.physicalSize = const Size(466, 678);
      tester.view.padding = const FakeViewPadding(right: 84, bottom: 34);
      await tester.pumpAndSettle();
      expect(tester.getRect(name).center.dx, closeTo(233, 1));
      expect(find.text('Duo draft'), findsOneWidget);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('unavailable native layout keeps the camera safe area', (
    tester,
  ) async {
    _view(tester);
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(466, 678);
    tester.view.padding = const FakeViewPadding(right: 84, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(right: 84, bottom: 34);
    await tester.pumpWidget(_app(TripFormPage(pickImage: (_) async => null)));
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.byKey(const ValueKey('trip-form-submit'))).right,
      lessThanOrEqualTo(382),
    );
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets(
    'folding retains body state and selected navigation; camera inset is respected',
    (tester) async {
      _view(tester);
      tester.view.physicalSize = const Size(466, 678);
      final taps = <AppBottomNavItem>[];
      await tester.pumpWidget(
        _app(
          AppPageScaffold(
            appBar: AppBar(title: const Text('Splyto')),
            body: const _Draft(),
            bottomNavigationBar: AppBottomNavBar(
              selectedItem: AppBottomNavItem.friends,
              onSelected: taps.add,
              avatarLetter: 'M',
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Preserve my draft');
      final state = tester.state(find.byType(_Draft));
      for (final size in [
        const Size(951, 669),
        const Size(669, 951),
        const Size(466, 678),
      ]) {
        tester.view.physicalSize = size;
        tester.view.padding = size.width > 700
            ? const FakeViewPadding(right: 90, bottom: 20)
            : const FakeViewPadding(top: 44, bottom: 20);
        await tester.pumpAndSettle();
        expect(tester.state(find.byType(_Draft)), same(state));
        expect(find.text('Preserve my draft'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('app-navigation-rail')),
          size.width > 700 ? findsOneWidget : findsNothing,
        );
        final rect = tester.getRect(find.byType(TextField));
        expect(
          rect.right,
          lessThanOrEqualTo(size.width - tester.view.padding.right),
        );
        await tester.tap(find.byKey(const ValueKey('nav-expenses')));
        expect(taps.last, AppBottomNavItem.expenses);
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'trip draft survives folding with keyboard and stays within readable width',
    (tester) async {
      _view(tester);
      tester.view.physicalSize = const Size(466, 678);
      await tester.pumpWidget(_app(TripFormPage(pickImage: (_) async => null)));
      await tester.enterText(
        find.byKey(const ValueKey('trip-form-name')),
        'Duo holiday',
      );
      for (final size in [
        const Size(951, 669),
        const Size(669, 951),
        const Size(466, 678),
      ]) {
        tester.view.physicalSize = size;
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        await tester.pumpAndSettle();
        expect(find.text('Duo holiday'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(const ValueKey('trip-form-name'))).width,
          lessThanOrEqualTo(720),
        );
        expect(
          tester.getRect(find.byKey(const ValueKey('trip-form-submit'))).bottom,
          lessThanOrEqualTo(size.height - 250),
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'sheet respects asymmetric safe area and keeps draft when folded',
    (tester) async {
      _view(tester);
      tester.view.physicalSize = const Size(951, 669);
      tester.view.padding = const FakeViewPadding(right: 90);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showAppBottomSheet<void>(
                  context: context,
                  builder: (_) => const SizedBox(height: 900, child: _Draft()),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sheet draft');
      final rect = tester.getRect(find.byType(AppBottomSheetSurface));
      expect(rect.width, lessThanOrEqualTo(640));
      expect(rect.height, lessThanOrEqualTo(669));
      expect(rect.right, lessThanOrEqualTo(861));
      tester.view.physicalSize = const Size(466, 678);
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 20);
      await tester.pumpAndSettle();
      expect(find.text('Sheet draft'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'welcome and account choice resize without overflow scale=$scale',
      (tester) async {
        _view(tester);
        tester.view.physicalSize = const Size(466, 678);
        await tester.pumpWidget(
          _app(AuthIntroPage(controller: _Auth()), scale: scale),
        );
        for (final size in [
          const Size(951, 669),
          const Size(669, 951),
          const Size(844, 390),
          const Size(466, 678),
        ]) {
          tester.view.physicalSize = size;
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
        await tester.tap(find.text('Get started'));
        await tester.pumpAndSettle();
        tester.view.physicalSize = const Size(951, 669);
        await tester.pumpAndSettle();
        expect(find.text('Create your account.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _Draft extends StatefulWidget {
  const _Draft();
  @override
  State<_Draft> createState() => _DraftState();
}

class _DraftState extends State<_Draft> {
  final text = TextEditingController();
  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListView(children: [TextField(controller: text)]);
}
