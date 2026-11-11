import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_theme.dart';
import 'package:tripsplit/features/trips/domain/entities/pending_trip_invitation.dart';
import 'package:tripsplit/features/trips/domain/entities/trip_user.dart';
import 'package:tripsplit/features/trips/presentation/widgets/trip_invite_members_page.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

// Review images only: run with
// flutter test --dart-define=INVITE_MEMBERS_PREVIEWS=<label> <this file>
void main() {
  testWidgets('invite members review images', (tester) async {
    const label = String.fromEnvironment('INVITE_MEMBERS_PREVIEWS');
    if (label.isEmpty) return;
    await (FontLoader(
      'Inter',
    )..addFont(rootBundle.load('assets/fonts/Inter.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const names = ['Anna', 'Jānis', 'Līga', 'Mārtiņš', 'Elīna', 'Kristaps'];
    for (final dark in [false, true]) {
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            locale: const Locale('lv'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: TripInviteMembersPage(
              tripName: 'Albania',
              loadFriends: () async => [
                for (var i = 0; i < names.length; i++)
                  TripUser(id: i + 1, nickname: names[i]),
              ],
              loadPending: () async => const <PendingTripInvitation>[],
              revoke: (_) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Anna'));
      await tester.tap(find.text('Līga'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File(
          '../output/design/invite-members/$label-${dark ? 'dark' : 'light'}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    }
  });
}
