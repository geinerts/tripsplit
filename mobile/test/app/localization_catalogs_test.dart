import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

void main() {
  test(
    'all 15 catalogs contain every message and preserve interpolation arguments',
    () {
      final source =
          jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
              as Map<String, dynamic>;
      final keys = source.keys.where((key) => !key.startsWith('@')).toSet();
      final args = RegExp(r'\{(\w+)(?:\}|,)');
      expect(AppLocalizations.supportedLocales, hasLength(15));
      for (final locale in AppLocalizations.supportedLocales) {
        final catalog =
            jsonDecode(
                  File(
                    'lib/l10n/app_${locale.languageCode}.arb',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>;
        expect(
          catalog.keys.where((key) => !key.startsWith('@')).toSet(),
          keys,
          reason: '$locale missing messages',
        );
        for (final key in keys) {
          expect(catalog[key], isA<String>());
          expect(
            (catalog[key] as String).trim(),
            isNotEmpty,
            reason: '$locale:$key',
          );
          expect(
            args.allMatches(catalog[key]).map((m) => m[1]).toSet(),
            args.allMatches(source[key]).map((m) => m[1]).toSet(),
            reason: '$locale:$key arguments',
          );
        }
      }
    },
  );
  test('activity events continue a sentence after the actor name', () {
    // These two read as complete sentences and are shown without a name.
    const standalone = {
      'activityEventTripAllMembersReady',
      'activityEventTripSettled',
    };
    for (final locale in AppLocalizations.supportedLocales) {
      final catalog =
          jsonDecode(
                File(
                  'lib/l10n/app_${locale.languageCode}.arb',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      for (final entry in catalog.entries) {
        if (!entry.key.startsWith('activityEvent') ||
            standalone.contains(entry.key)) {
          continue;
        }
        final text = entry.value as String;
        final first = text.characters.first;
        expect(
          first,
          first.toLowerCase(),
          reason: '$locale:${entry.key} starts like a standalone title: $text',
        );
      }
    }
  });

  test('Slavic counts use different forms for 1, 2 and 5', () async {
    for (final code in ['pl', 'uk', 'cs']) {
      final t = await AppLocalizations.delegate.load(Locale(code));
      expect(t.expensesCount(1), isNot(t.expensesCount(2)));
      expect(
        t.expensesCount(2).replaceAll('2', ''),
        isNot(t.expensesCount(5).replaceAll('5', '')),
      );
    }
  });
  test('every locale preserves actual counts across plural branches', () async {
    final numbers = RegExp(r'\d+');
    for (final locale in AppLocalizations.supportedLocales) {
      final t = await AppLocalizations.delegate.load(locale);
      for (final count in [0, 1, 2, 5, 11, 21, 101]) {
        final messages = {
          'people': t.homePeople(count),
          'invitations': t.addedMembersCount(count),
          'expenses': t.expensesCount(count),
          'analytics expenses': t.analyticsExpenseCount(count),
          'offline changes': t.offlineQueuePendingChanges(count),
          'transfers': t.suggestedTransferRows(count),
          'updates': t.unreadUpdates(count),
          'visits': t.travelMapVisits(count),
        };
        for (final entry in messages.entries) {
          expect(
            numbers.allMatches(entry.value).map((match) => match[0]).toList(),
            ['$count'],
            reason: '$locale ${entry.key}: $count must not become 1',
          );
        }
        expect(
          numbers
              .allMatches(t.travelMapCounts(count, count + 10))
              .map((match) => match[0])
              .toList(),
          ['$count', '${count + 10}'],
          reason: '$locale map totals must preserve countries and cities',
        );
      }
    }
  });
}
