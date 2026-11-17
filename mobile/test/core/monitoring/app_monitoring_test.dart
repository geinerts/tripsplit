import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tripsplit/core/monitoring/app_monitoring.dart';

void main() {
  test('console lines never become breadcrumbs', () {
    for (final category in ['console', 'print', 'log']) {
      expect(
        AppMonitoring.scrubBreadcrumb(
          Breadcrumb(message: 'email a@b.c', category: category),
        ),
        isNull,
      );
    }
  });

  test('route arguments and URL queries are removed', () {
    final crumb = AppMonitoring.scrubBreadcrumb(
      Breadcrumb(
        category: 'navigation',
        data: {
          'from': '/trip',
          'to': '/expense',
          'arguments': {'note': 'Dinner with Anna'},
          'url': 'https://splyto.eu/invite?token=secret#x',
        },
      ),
    )!;
    expect(crumb.data, {
      'from': '/trip',
      'to': '/expense',
      'url': 'https://splyto.eu/invite',
    });
  });

  test('events keep only the account number', () {
    final event = AppMonitoring.scrubEvent(
      SentryEvent(
        user: SentryUser(
          id: '42',
          email: 'a@b.c',
          ipAddress: '1.2.3.4',
          username: 'Anna',
        ),
        request: SentryRequest(url: 'https://splyto.eu/api?token=x'),
        serverName: 'Annas-iPhone',
      ),
    );
    expect(event.user?.id, '42');
    expect(event.user?.email, isNull);
    expect(event.user?.ipAddress, isNull);
    expect(event.user?.username, isNull);
    expect(event.request, isNull);
    expect(event.serverName, isNull);
  });
}
