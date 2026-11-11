import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/network/network_connection.dart';

void main() {
  test(
    'offline actions reuse transport state, reconnect permits requests',
    () async {
      final changes = StreamController<List<ConnectivityResult>>(sync: true);
      var checks = 0;
      var probes = 0;
      final network = NetworkConnection(
        check: () async {
          checks++;
          return [ConnectivityResult.none];
        },
        changes: changes.stream,
        probe: () async {
          probes++;
          return true;
        },
      );
      for (var i = 0; i < 10; i++) {
        expect(await network.isOffline(), isTrue);
      }
      expect(checks, 1);
      expect(probes, 0);
      changes.add([ConnectivityResult.wifi]);
      expect(await network.isOffline(), isFalse);
      await network.dispose();
      await changes.close();
    },
  );

  test(
    'Wi-Fi outage probes once in background without blocking actions',
    () async {
      final recovery = Completer<bool>();
      var probes = 0;
      final network = NetworkConnection(
        check: () async => [ConnectivityResult.wifi],
        changes: const Stream.empty(),
        probe: () {
          probes++;
          return recovery.future;
        },
      );
      expect(await network.isOffline(), isFalse);
      network.markNetworkFailure();
      for (var i = 0; i < 10; i++) {
        expect(await network.isOffline(), isTrue);
      }
      expect(probes, 1);
      expect(recovery.isCompleted, isFalse);
      recovery.complete(true);
      await Future<void>.delayed(Duration.zero);
      expect(await network.isOffline(), isFalse);
      await network.dispose();
    },
  );

  test(
    'failed recovery is throttled and a new outage defeats an old probe',
    () async {
      var now = DateTime(2026);
      var probes = 0;
      final recovery = Completer<bool>();
      final network = NetworkConnection(
        check: () async => [ConnectivityResult.wifi],
        changes: const Stream.empty(),
        now: () => now,
        probe: () async {
          probes++;
          return probes == 1 ? false : recovery.future;
        },
      );
      await network.isOffline();
      network.markNetworkFailure();
      expect(await network.isOffline(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(await network.isOffline(), isTrue);
      expect(probes, 1);
      now = now.add(const Duration(seconds: 6));
      expect(await network.isOffline(), isTrue);
      network.markNetworkFailure();
      recovery.complete(true);
      await Future<void>.delayed(Duration.zero);
      expect(await network.isOffline(), isTrue);
      await network.dispose();
    },
  );

  test(
    'late initial transport check cannot overwrite an airplane-mode event',
    () async {
      final initial = Completer<List<ConnectivityResult>>();
      final changes = StreamController<List<ConnectivityResult>>(sync: true);
      final network = NetworkConnection(
        check: () => initial.future,
        changes: changes.stream,
        probe: () async => true,
      );
      changes.add([ConnectivityResult.none]);
      initial.complete([ConnectivityResult.wifi]);
      expect(await network.isOffline(), isTrue);
      await network.dispose();
      await changes.close();
    },
  );
}
