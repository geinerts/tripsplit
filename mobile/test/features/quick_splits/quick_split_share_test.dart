import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/features/quick_splits/domain/quick_split.dart';
import 'package:tripsplit/features/quick_splits/presentation/quick_splits_views.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

const _channel = MethodChannel('dev.fluttercommunity.plus/share');

QuickSplit _split({
  bool canEdit = true,
  bool receipt = false,
  QuickSplitShare? share,
}) => QuickSplit(
  id: 31,
  note: 'Dinner at Lido',
  category: 'food',
  date: '2026-11-16',
  amount: 35.09,
  currencyCode: 'EUR',
  peopleCount: 2,
  myAmount: 17.55,
  paidByMe: true,
  paidByName: 'Matiss',
  canEdit: canEdit,
  hasReceipt: receipt,
  people: const [
    QuickSplitPerson(
      id: 1,
      name: 'Matiss',
      amount: 17.55,
      isMe: true,
      isPayer: true,
    ),
    QuickSplitPerson(id: 2, name: 'Anna', amount: 17.54),
  ],
  share: share,
);

final _link = QuickSplitShare(
  url: Uri.parse('https://splyto.eu/split?code=Kq3vT8mW1pZx7RbN2cYd4A'),
  expiresAt: DateTime.utc(2027, 2, 26, 12),
);

void main() {
  late List<String> shared;

  setUp(() {
    shared = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          shared.add((call.arguments as Map)['text'] as String? ?? '');
          return 'dev.fluttercommunity.plus/share/success';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  Future<void> open(
    WidgetTester tester,
    QuickSplit split, {
    QuickSplitShareLink? shareLink,
    Future<void> Function()? stopSharing,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                key: const ValueKey('open'),
                onPressed: () => showQuickSplitSheet(
                  context,
                  split: split,
                  shareLink: shareLink,
                  stopSharing: stopSharing,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('open')));
    await tester.pumpAndSettle();
  }

  group('QuickSplitShare.tryParse', () {
    test('accepts only splyto.eu/split links with a code', () {
      final share = QuickSplitShare.tryParse({
        'url': 'https://splyto.eu/split?code=abc',
        'expires_at': '2027-02-26T12:00:00Z',
        'show_receipt': true,
      });
      expect(share?.url.queryParameters['code'], 'abc');
      expect(share?.expiresAt, DateTime.utc(2027, 2, 26, 12));
      expect(share?.showReceipt, isTrue);
      for (final url in [
        'http://splyto.eu/split?code=abc',
        'https://evil.example/split?code=abc',
        'https://splyto.eu/other?code=abc',
        'https://splyto.eu/split',
      ]) {
        expect(QuickSplitShare.tryParse({'url': url}), isNull, reason: url);
      }
      expect(QuickSplitShare.tryParse(null), isNull);
    });

    test('a quick split reads its share, and older servers send none', () {
      final base = {'id': 31, 'note': 'X', 'date': '2026-11-16', 'amount': 10};
      expect(QuickSplit.fromJson(base).share, isNull);
      final withShare = QuickSplit.fromJson({
        ...base,
        'share': {
          'url': 'https://splyto.eu/split?code=abc',
          'show_receipt': false,
        },
      });
      expect(
        withShare.share?.url.toString(),
        'https://splyto.eu/split?code=abc',
      );
    });
  });

  testWidgets('the creator shares a link; without a receipt nothing is asked', (
    tester,
  ) async {
    final calls = <bool>[];
    await open(
      tester,
      _split(),
      shareLink: ({required showReceipt}) async {
        calls.add(showReceipt);
        return _link;
      },
      stopSharing: () async {},
    );
    await tester.tap(find.byKey(const ValueKey('quick-split-share')));
    await tester.pumpAndSettle();

    expect(calls, [false]);
    expect(shared.single, contains('Dinner at Lido · '));
    expect(
      shared.single,
      endsWith('\nhttps://splyto.eu/split?code=Kq3vT8mW1pZx7RbN2cYd4A'),
    );
    expect(
      find.byKey(const ValueKey('quick-split-shared-link')),
      findsOneWidget,
    );
  });

  testWidgets('with a receipt the photo stays out unless switched on', (
    tester,
  ) async {
    final calls = <bool>[];
    await open(
      tester,
      _split(receipt: true),
      shareLink: ({required showReceipt}) async {
        calls.add(showReceipt);
        return _link;
      },
    );
    await tester.tap(find.byKey(const ValueKey('quick-split-share')));
    await tester.pumpAndSettle();
    final toggle = find.byKey(const ValueKey('quick-split-share-receipt'));
    expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
    await tester.tap(find.byKey(const ValueKey('quick-split-share-link')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quick-split-share')));
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('quick-split-share-link')));
    await tester.pumpAndSettle();

    expect(calls, [false, true]);
    expect(shared, hasLength(2));
  });

  testWidgets('when the link fails, the plain text is shared as before', (
    tester,
  ) async {
    await open(
      tester,
      _split(),
      shareLink: ({required showReceipt}) async => throw Exception('offline'),
    );
    await tester.tap(find.byKey(const ValueKey('quick-split-share')));
    await tester.pumpAndSettle();

    expect(shared.single, contains('Anna'));
    expect(shared.single, isNot(contains('https://')));
    expect(find.byKey(const ValueKey('quick-split-shared-link')), findsNothing);
  });

  testWidgets('people in the quick split share plain text', (tester) async {
    await open(
      tester,
      _split(canEdit: false),
      shareLink: ({required showReceipt}) async => fail('not the creator'),
    );
    await tester.tap(find.byKey(const ValueKey('quick-split-share')));
    await tester.pumpAndSettle();
    expect(shared.single, isNot(contains('https://')));
  });

  testWidgets('stop sharing removes the link row', (tester) async {
    var stopped = 0;
    await open(
      tester,
      _split(share: _link),
      shareLink: ({required showReceipt}) async => _link,
      stopSharing: () async => stopped++,
    );
    expect(
      find.byKey(const ValueKey('quick-split-shared-link')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('quick-split-stop-sharing')));
    await tester.pumpAndSettle();

    expect(stopped, 1);
    expect(find.byKey(const ValueKey('quick-split-shared-link')), findsNothing);
  });
}
