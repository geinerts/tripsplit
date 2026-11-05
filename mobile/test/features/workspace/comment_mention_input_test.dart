import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/features/workspace/domain/entities/expense_comment_mention.dart';
import 'package:tripsplit/features/workspace/domain/entities/workspace_user.dart';
import 'package:tripsplit/features/workspace/presentation/widgets/comment_mention_input.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

const me = WorkspaceUser(id: 1, nickname: 'Me');
const anna = WorkspaceUser(
  id: 2,
  nickname: 'annab',
  displayName: 'Anna Bērziņa',
);
const longName = WorkspaceUser(
  id: 3,
  nickname: 'long',
  displayName:
      'Wolfeschlegelsteinhausenbergerdorff Wolfeschlegelsteinhausenbergerdorff',
);
const members = [me, anna, longName];

Future<CommentMentionTextController> pumpComposer(
  WidgetTester tester, {
  double scale = 1,
  List<WorkspaceUser> users = members,
  double keyboard = 0,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final controller = CommentMentionTextController(members: users);
  final focus = FocusNode();
  addTearDown(controller.dispose);
  addTearDown(focus.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light(),
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            viewInsets: EdgeInsets.only(bottom: keyboard),
          ),
          child: Scaffold(
            body: ListView(
              children: [
                CommentMentionSuggestions(
                  controller: controller,
                  focusNode: focus,
                  members: users,
                  currentUserId: me.id,
                ),
                TextField(
                  key: const ValueKey('input'),
                  controller: controller,
                  focusNode: focus,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return controller;
}

Future<void> typeText(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(const ValueKey('input')), text);
  await tester.pumpAndSettle();
}

final panel = find.byKey(const ValueKey('comment-mention-suggestions'));
Finder option(int id) => find.byKey(ValueKey('comment-mention-option-$id'));

void main() {
  testWidgets('typing @ lists other members and filters them', (tester) async {
    await pumpComposer(tester);
    expect(panel, findsNothing);
    await typeText(tester, 'Hello');
    expect(panel, findsNothing);
    await typeText(tester, 'Hello @');
    expect(option(2), findsOneWidget);
    expect(option(3), findsOneWidget);
    expect(option(1), findsNothing, reason: 'the author is not listed');
    await typeText(tester, 'Hello @berz');
    expect(option(2), findsOneWidget);
    expect(option(3), findsNothing);
    await typeText(tester, 'Hello @zzz');
    expect(find.text('No matching members'), findsOneWidget);
    await typeText(tester, 'Hello @zzz and more');
    expect(panel, findsNothing);
    await typeText(tester, 'me@example');
    expect(panel, findsNothing);
  });

  testWidgets('picking inserts the name and resolves the member ID', (
    tester,
  ) async {
    final controller = await pumpComposer(tester);
    await typeText(tester, 'Hi @An');
    await tester.tap(option(2));
    await tester.pumpAndSettle();
    expect(controller.text, 'Hi @Anna Bērziņa ');
    expect(controller.selection.baseOffset, controller.text.length);
    expect(controller.mentionedUserIds, [2]);
    expect(panel, findsNothing, reason: 'a finished mention closes the list');
    expect(tester.takeException(), isNull);
    await typeText(tester, 'Hi Anna Bērziņa');
    expect(controller.mentionedUserIds, isEmpty, reason: 'mention removed');
    controller.clear();
    expect(controller.mentionedUserIds, isEmpty);
  });

  testWidgets('a mention that no longer fits cannot be picked', (tester) async {
    final controller = await pumpComposer(tester);
    final text = '${'a' * 276} @';
    await typeText(tester, text);
    await tester.tap(option(2));
    await tester.pumpAndSettle();
    expect(controller.text, text);
  });

  testWidgets('a solo trip never shows the list', (tester) async {
    await pumpComposer(tester, users: const [me]);
    await typeText(tester, '@');
    expect(panel, findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets('fits 320px with large text and a keyboard in $brightness', (
      tester,
    ) async {
      await pumpComposer(
        tester,
        scale: 2,
        keyboard: 260,
        brightness: brightness,
      );
      await typeText(tester, '@');
      expect(panel, findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(panel).width, lessThanOrEqualTo(320));
      expect(tester.getSize(panel).height, lessThanOrEqualTo(336));
    });
  }

  testWidgets('input keeps the highlight while composing text', (tester) async {
    final controller = await pumpComposer(tester);
    await typeText(tester, '@Anna Bērziņa hi');
    final context = tester.element(find.byKey(const ValueKey('input')));
    controller.value = controller.value.copyWith(
      composing: const TextRange(start: 14, end: 16),
    );
    final span = controller.buildTextSpan(
      context: context,
      style: const TextStyle(fontSize: 14),
      withComposing: true,
    );
    expect(span.toPlainText(), '@Anna Bērziņa hi');
    final parts = span.children!.cast<TextSpan>();
    expect(parts.first.text, '@Anna Bērziņa');
    expect(parts.first.style?.fontWeight, FontWeight.w700);
    expect(parts.last.text, 'hi');
    expect(parts.last.style?.decoration, TextDecoration.underline);
  });

  testWidgets('published text highlights only server mentions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Column(
            children: [
              CommentBodyText(
                key: ValueKey('with'),
                body: 'Ask @Old Name about @Other',
                mentions: [ExpenseCommentMention(userId: 2, name: 'Old Name')],
              ),
              CommentBodyText(
                key: ValueKey('without'),
                body: 'Ask @Old Name',
                mentions: [],
              ),
            ],
          ),
        ),
      ),
    );
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('with')),
        matching: find.byType(Text),
      ),
    );
    final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans.map((span) => span.text), [
      'Ask ',
      '@Old Name',
      ' about @Other',
    ]);
    expect(spans[1].style?.fontWeight, FontWeight.w700);
    expect(spans[2].style, isNull);
    expect(find.text('Ask @Old Name'), findsOneWidget);
  });

  testWidgets('an edit keeps a renamed member picked from the old text', (
    tester,
  ) async {
    final controller = CommentMentionTextController(
      text: 'Hi @Old Name',
      members: const [anna],
      existingMentions: const [
        ExpenseCommentMention(userId: 2, name: 'Old Name'),
      ],
    );
    addTearDown(controller.dispose);
    expect(controller.mentionedUserIds, [2]);
  });
}
