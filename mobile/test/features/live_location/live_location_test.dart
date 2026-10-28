import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/core/auth/account_data_session.dart';
import 'package:tripsplit/core/errors/api_exception.dart';
import 'package:tripsplit/features/live_location/data/live_location_device.dart';
import 'package:tripsplit/features/live_location/data/live_location_repository.dart';
import 'package:tripsplit/features/live_location/domain/live_location.dart';
import 'package:tripsplit/features/live_location/presentation/live_location_controller.dart';
import 'package:tripsplit/features/live_location/presentation/live_map_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

DateTime Function() clock = DateTime.now;
LiveFix fix() => LiveFix(38.72, -9.14, 12, clock().toUtc());

class Device implements LiveLocationDevice {
  int requests = 0, watches = 0, cancels = 0;
  bool denied = false, brokenStream = false;
  late final stream = StreamController<LiveFix>.broadcast(
    onCancel: () {
      cancels++;
    },
  );
  @override
  Future<LiveFix> requestFix() async {
    requests++;
    if (denied) throw LiveLocationPermissionError();
    return fix();
  }

  @override
  Stream<LiveFix> watch(String title, String text) {
    watches++;
    if (brokenStream) throw LiveLocationPermissionError();
    return stream.stream;
  }
}

class Repository implements LiveLocationRepository {
  int starts = 0, updates = 0, stops = 0, loads = 0;
  int? minutes;
  bool expired = false, offlineStop = false, revoked = false;
  @override
  Future<LiveShareSession> start(int trip, int minutes, LiveFix fix) async {
    starts++;
    this.minutes = minutes;
    return LiveShareSession(
      'token',
      clock().add(
        expired ? const Duration(seconds: -1) : Duration(minutes: minutes),
      ),
    );
  }

  @override
  Future<void> update(int trip, String token, LiveFix fix) async {
    updates++;
    if (revoked) throw const ApiException('Ended', statusCode: 409);
  }

  @override
  Future<void> stop(int trip) async {
    stops++;
    if (offlineStop) throw const ApiException('Offline', isNetworkError: true);
  }

  @override
  Future<LiveMapSnapshot> load(int trip) async {
    loads++;
    return LiveMapSnapshot.fromJson({
      'server_time': clock().millisecondsSinceEpoch ~/ 1000,
      'own_expires_at': null,
      'members': [
        {
          'user_id': 2,
          'name': 'Ruslans',
          'latitude': 38.72,
          'longitude': -9.14,
          'accuracy_m': 12,
          'observed_at': clock().millisecondsSinceEpoch ~/ 1000,
          'expires_at':
              clock().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/
              1000,
        },
      ],
    });
  }
}

void main() {
  late Device device;
  late Repository repo;
  late AccountDataSession account;
  late LiveLocationController controller;
  setUp(() {
    clock = DateTime.now;
    device = Device();
    repo = Repository();
    account = AccountDataSession()..activate(1);
    controller = LiveLocationController(
      repo,
      device,
      account,
      now: () => clock(),
    );
  });
  tearDown(() async {
    controller.dispose();
    unawaited(device.stream.close());
  });
  Future<void> start() =>
      controller.start(9, 15, title: 'Splyto', text: 'Sharing');
  testWidgets(
    'view and cancelled consent never request GPS; confirmation starts timed share',
    (tester) async {
      final base = DateTime.now(), tick = tester.binding.clock.now();
      clock = () => base.add(tester.binding.clock.now().difference(tick));
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LiveMapPage(
            tripId: 9,
            tripName: 'Lisbon',
            controller: controller,
            showTiles: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(device.requests, 0);
      expect(repo.starts, 0);
      await tester.ensureVisible(find.byKey(const ValueKey('live-share')));
      await tester.tap(find.byKey(const ValueKey('live-share')));
      await tester.pumpAndSettle();
      expect(device.requests, 0);
      Navigator.of(
        tester.element(find.byKey(const ValueKey('live-confirm'))),
      ).pop();
      await tester.pumpAndSettle();
      expect(repo.starts, 0);
      await tester.ensureVisible(find.byKey(const ValueKey('live-share')));
      await tester.tap(find.byKey(const ValueKey('live-share')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15 min'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('live-confirm')));
      await tester.pumpAndSettle();
      expect(repo.minutes, 15);
      expect(device.requests, 1);
      expect(device.watches, 1);
      await tester.pumpWidget(
        const SizedBox(),
      ); // Leaving the map keeps the explicit session active.
      await tester.pump(const Duration(seconds: 11));
      expect(repo.updates, greaterThan(0));
      final stopped = controller.stop(9);
      await tester.pump();
      await stopped;
      await tester.pump();
      expect(device.cancels, 1);
      final sent = repo.updates;
      device.stream.add(fix());
      await tester.pump(const Duration(seconds: 20));
      expect(repo.updates, sent);
      expect(controller.sharing(9), isNull);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('expiry cancels tracking automatically', (tester) async {
    final base = DateTime.now(), tick = tester.binding.clock.now();
    clock = () => base.add(tester.binding.clock.now().difference(tick));
    repo.expired = true;
    await start();
    await tester.pump(const Duration(seconds: 1));
    expect(controller.sharing(9), isNull);
    expect(device.cancels, 1);
    expect(repo.updates, 0);
  });
  testWidgets('account switch cannot publish to a new account', (tester) async {
    final base = DateTime.now(), tick = tester.binding.clock.now();
    clock = () => base.add(tester.binding.clock.now().difference(tick));
    await start();
    account.activate(2);
    device.stream.add(fix());
    await tester.pump(const Duration(seconds: 2));
    expect(repo.updates, 0);
    expect(controller.sharing(9), isNull);
    expect(device.cancels, 1);
  });
  test('permission refusal never creates a sharing session', () async {
    device.denied = true;
    await expectLater(start(), throwsA(isA<LiveLocationPermissionError>()));
    expect(repo.starts, 0);
    expect(device.watches, 0);
  });
  testWidgets('offline stop stops native updates and retries removal', (
    tester,
  ) async {
    final base = DateTime.now(), tick = tester.binding.clock.now();
    clock = () => base.add(tester.binding.clock.now().difference(tick));
    await start();
    repo.offlineStop = true;
    final stopped = controller.stop(9);
    await tester.pump();
    expect(await stopped, isFalse);
    expect(device.cancels, 1);
    expect(controller.stopping(9), isTrue);
    repo.offlineStop = false;
    await tester.pump(const Duration(seconds: 11));
    expect(repo.updates, 0);
    expect(repo.stops, 2);
    expect(controller.sharing(9), isNull);
  });
  testWidgets('server revocation stops updates rather than renewing consent', (
    tester,
  ) async {
    final base = DateTime.now(), tick = tester.binding.clock.now();
    clock = () => base.add(tester.binding.clock.now().difference(tick));
    await start();
    repo.revoked = true;
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(repo.updates, 1);
    expect(repo.starts, 1);
    expect(controller.sharing(9), isNull);
    expect(device.cancels, 1);
  });
  test('native stream start failure removes remote consent', () async {
    device.brokenStream = true;
    await expectLater(start(), throwsA(isA<LiveLocationPermissionError>()));
    expect(repo.starts, 1);
    expect(repo.stops, 1);
    expect(controller.sharing(9), isNull);
  });
  testWidgets('small screen and large text fit map, member card and consent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: LiveMapPage(
          tripId: 9,
          tripName: 'Lisbon with friends',
          controller: controller,
          showTiles: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('live-member-2')));
    await tester.pumpAndSettle();
    expect(find.text('Ruslans'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('live-share')));
    await tester.tap(find.byKey(const ValueKey('live-share')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('live-confirm')));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  test('logout stops all active shares', () async {
    await start();
    await controller.start(10, 60, title: 'Splyto', text: 'Sharing');
    await controller.stopAll();
    expect(repo.stops, 2);
    expect(controller.sharing(9), isNull);
    expect(controller.sharing(10), isNull);
    expect(device.cancels, 1);
  });
}
