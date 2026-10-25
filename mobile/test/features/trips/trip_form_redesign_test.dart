import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/features/trips/data/models/trip_model.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_user.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_form_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

const friends = [
  TripUser(id: 9, nickname: 'Anna with a long family name'),
  TripUser(id: 8, nickname: 'Daniel'),
];

class _Harness {
  TripFormDraft? result;
  bool closed = false;
  Future<void> mount(
    WidgetTester tester, {
    bool edit = false,
    String locale = 'en',
    bool dark = false,
    double scale = 1,
    double width = 390,
    bool settle = true,
    Future<List<TripUser>> Function()? load,
    Future<TripImageDraft?> Function(ImageSource)? pick,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark() : AppTheme.light(),
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<TripFormDraft>(
                  MaterialPageRoute(
                    builder: (_) => TripFormPage(
                      trip: edit
                          ? TripModel.fromLegacyMap({
                              'id': 1,
                              'name': 'Lisbon getaway',
                            })
                          : null,
                      loadFriends: load ?? () async => friends,
                      pickImage: pick ?? (_) async => null,
                    ),
                  ),
                );
                closed = true;
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
  }
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('trip-form-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> dates(WidgetTester tester) async {
  for (final key in ['trip-date-from', 'trip-date-to']) {
    await tapVisible(tester, find.byKey(ValueKey(key)));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }
}

void main() {
  for (final locale in ['en', 'lv', 'es']) {
    for (final dark in [false, true]) {
      for (final edit in [false, true]) {
        testWidgets('trip form 320px 200% $locale dark=$dark edit=$edit', (
          tester,
        ) async {
          final h = _Harness();
          await h.mount(
            tester,
            edit: edit,
            locale: locale,
            dark: dark,
            width: 320,
            scale: 2,
          );
          expect(tester.takeException(), isNull);
          await tapVisible(
            tester,
            find.byKey(const ValueKey('trip-form-name')),
          );
          await tester.enterText(
            find.byKey(const ValueKey('trip-form-name')),
            'A long trip name with details',
          );
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          addTearDown(tester.view.resetViewInsets);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final button = tester.getRect(
            find.byKey(const ValueKey('trip-form-submit')),
          );
          expect(button.bottom, lessThanOrEqualTo(544));
          await tester.tap(find.byIcon(Icons.close).first);
          await tester.pumpAndSettle();
          expect(h.closed, isTrue);
          expect(h.result, isNull);
        });
      }
    }
  }
  testWidgets(
    'create validates, preserves currency search draft and submits sorted participants',
    (tester) async {
      final h = _Harness();
      await h.mount(tester);
      await tester.tap(find.byKey(const ValueKey('trip-form-submit')));
      await tester.pumpAndSettle();
      expect(h.closed, isFalse);
      expect(
        find.text('Trip name must be at least 2 characters.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const ValueKey('trip-form-name')),
        '  Weekend away  ',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await dates(tester);
      await tapVisible(tester, find.byKey(const ValueKey('trip-currency')));
      await tester.enterText(
        find.byKey(const ValueKey('trip-currency-search')),
        'nonsense',
      );
      await tester.pumpAndSettle();
      expect(find.text('No currencies found'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('trip-currency-search')),
        'USD',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('USD ·'));
      await tester.pumpAndSettle();
      for (final id in [9, 8]) {
        await tapVisible(tester, find.byKey(ValueKey('trip-friend-$id')));
      }
      await tester.tap(find.byKey(const ValueKey('trip-form-submit')));
      await tester.pumpAndSettle();
      expect(h.result!.name, 'Weekend away');
      expect(h.result!.currencyCode, 'USD');
      expect(h.result!.memberIds, [8, 9]);
      expect(h.result!.dateFrom, h.result!.dateTo);
      expect(DateTime.tryParse(h.result!.dateFrom!), isNotNull);
    },
  );
  testWidgets('currency search and selection stay above the keyboard', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester, width: 320, scale: 2);
    await tapVisible(tester, find.byKey(const ValueKey('trip-currency')));
    await tester.enterText(
      find.byKey(const ValueKey('trip-currency-search')),
      'USD',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final usd = find.textContaining('USD ·');
    expect(tester.getRect(usd).bottom, lessThanOrEqualTo(544));
    await tester.tap(usd);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('trip-currency-search')), findsNothing);
  });
  testWidgets('solo clears selection and submits no members', (tester) async {
    final h = _Harness();
    await h.mount(tester);
    await tester.enterText(
      find.byKey(const ValueKey('trip-form-name')),
      'Solo trip',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await dates(tester);
    await tapVisible(tester, find.byKey(const ValueKey('trip-friend-8')));
    await tapVisible(tester, find.byKey(const ValueKey('trip-mode-solo')));
    await tester.tap(find.byKey(const ValueKey('trip-form-submit')));
    await tester.pumpAndSettle();
    expect(h.result!.tripMode, 'solo');
    expect(h.result!.memberIds, isEmpty);
  });
  testWidgets('friend failure can retry without erasing name', (tester) async {
    var calls = 0;
    final h = _Harness();
    await h.mount(
      tester,
      load: () async {
        if (++calls == 1) throw Exception('Offline');
        return friends;
      },
    );
    await tester.enterText(
      find.byKey(const ValueKey('trip-form-name')),
      'Weekend',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tapVisible(tester, find.text('Retry'));
    expect(calls, 2);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('trip-form-name')))
          .controller!
          .text,
      'Weekend',
    );
    expect(find.byKey(const ValueKey('trip-friend-8')), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('closing form ignores pending friend response', (tester) async {
    final pending = Completer<List<TripUser>>();
    final h = _Harness();
    await h.mount(tester, load: () => pending.future, settle: false);
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    pending.complete(friends);
    await tester.pumpAndSettle();
    expect(h.closed, isTrue);
    expect(h.result, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets('edit submits name without requiring create-only fields', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester, edit: true);
    expect(find.byKey(const ValueKey('trip-currency')), findsNothing);
    await tester.enterText(
      find.byKey(const ValueKey('trip-form-name')),
      'Updated trip',
    );
    await tester.tap(find.byKey(const ValueKey('trip-form-submit')));
    await tester.pumpAndSettle();
    expect(h.result!.name, 'Updated trip');
    expect(h.result!.image, isNull);
    expect(h.result!.removeImage, isFalse);
  });
  testWidgets('double submit returns one draft and leaves the caller open', (
    tester,
  ) async {
    final h = _Harness();
    await h.mount(tester, edit: true);
    final save = tester
        .widget<ElevatedButton>(find.byKey(const ValueKey('trip-form-submit')))
        .onPressed!;
    save();
    save();
    await tester.pumpAndSettle();
    expect(h.result!.name, 'Lisbon getaway');
    expect(find.text('Open'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'image selection cancellation preserves selection and removal is explicit',
    (tester) async {
      final bytes = Uint8List.fromList(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j2i8AAAAASUVORK5CYII=',
        ),
      );
      var calls = 0;
      final h = _Harness();
      await h.mount(
        tester,
        edit: true,
        pick: (_) async =>
            ++calls == 1 ? (bytes: bytes, fileName: 'cover.png') : null,
      );
      Future<void> choose() async {
        await tester.tap(find.byKey(const ValueKey('trip-cover-picker')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await tester.tap(find.text('Choose from Library'));
        await tester.pumpAndSettle();
      }

      await choose();
      await choose();
      expect(find.byType(Image), findsOneWidget);
      final photo = find.byKey(const ValueKey('trip-cover-photo'));
      expect(tester.widget<Image>(photo).fit, BoxFit.contain);
      final size = tester.getSize(photo);
      expect(size.width / size.height, closeTo(16 / 9, .001));
      expect((tester.widget<Image>(photo).image as MemoryImage).bytes, bytes);
      await tester.tap(find.byKey(const ValueKey('trip-cover-picker')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Remove image'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('trip-form-submit')));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(h.result!.image, isNull);
      expect(h.result!.removeImage, isTrue);
    },
  );
}
