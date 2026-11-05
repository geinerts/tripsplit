import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/core/deeplink/invite_deep_link_controller.dart';

void main() {
  group('isWebOnlyAccountLink', () {
    test('recognizes email action pages on the production hosts', () {
      for (final raw in [
        'https://splyto.eu/reset-password.php?token=abc',
        'https://splyto.eu/api/verify-email.php?token=abc',
        'https://www.splyto.eu/api/delete-account.php?token=abc',
      ]) {
        expect(
          InviteDeepLinkParser.isWebOnlyAccountLink(Uri.parse(raw)),
          isTrue,
          reason: raw,
        );
      }
    });

    test('leaves invite and friend links to the app', () {
      for (final raw in [
        'https://splyto.eu/invite/summer-trip-abcde12345',
        'https://splyto.eu/friend?uid=7',
        'https://splyto.eu/?invite=abcde12345',
        'tripsplit://invite/abcde12345',
        'https://example.com/reset-password.php?token=abc',
      ]) {
        expect(
          InviteDeepLinkParser.isWebOnlyAccountLink(Uri.parse(raw)),
          isFalse,
          reason: raw,
        );
      }
    });
  });

  group('InviteDeepLinkController', () {
    test('hands account links to the browser and does not treat them as '
        'invites', () async {
      final opened = <Uri>[];
      final controller = InviteDeepLinkController(
        openInBrowser: (uri) async {
          opened.add(uri);
          return true;
        },
      );
      final invites = <String>[];
      controller.inviteCodeStream.listen(invites.add);

      controller.handleIncomingUri(
        Uri.parse('https://splyto.eu/reset-password.php?token=abc'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(opened, hasLength(1));
      expect(opened.single.path, '/reset-password.php');
      expect(invites, isEmpty);
      expect(controller.consumePendingInviteCode(), isNull);
      await controller.dispose();
    });

    test('still routes invite links inside the app', () async {
      final opened = <Uri>[];
      final controller = InviteDeepLinkController(
        openInBrowser: (uri) async {
          opened.add(uri);
          return true;
        },
      );
      controller.handleIncomingUri(
        Uri.parse('https://splyto.eu/?invite=abcde12345'),
      );
      await Future<void>.delayed(Duration.zero);

      expect(opened, isEmpty);
      expect(controller.consumePendingInviteCode(), isNotNull);
      await controller.dispose();
    });
  });
}
