import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/router/app_router.dart';
import '../../../core/deeplink/invite_deep_link_controller.dart';
import '../data/quick_start_seen_store.dart';
import 'quick_start_sheet.dart';

// Matches the launch screen, so the guide fades in from it rather than cutting.
const _launchColor = Color(0xFF141E30);

/// The guide on a new install, before there is an account. Skipping and finishing
/// both lead to the sign-in page, and so does a link opened while it's showing.
class QuickStartWelcomePage extends StatefulWidget {
  const QuickStartWelcomePage({
    super.key,
    required this.seenStore,
    required this.deepLinks,
  });

  final QuickStartSeenStore seenStore;
  final InviteDeepLinkController deepLinks;

  @override
  State<QuickStartWelcomePage> createState() => _QuickStartWelcomePageState();
}

class _QuickStartWelcomePageState extends State<QuickStartWelcomePage> {
  final _subscriptions = <StreamSubscription<Object?>>[];
  bool _left = false;

  @override
  void initState() {
    super.initState();
    // Set on opening, so closing the app halfway doesn't bring the guide back.
    unawaited(widget.seenStore.markSeen());
    final links = widget.deepLinks;
    _subscriptions.addAll([
      links.inviteCodeStream.listen((_) => _leave()),
      links.friendTargetStream.listen((_) => _leave()),
      links.friendLinkTokenStream.listen((_) => _leave()),
    ]);
    if (links.hasPendingLink) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _leave());
    }
  }

  void _leave() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pushReplacementNamed(AppRouter.authIntro);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animate = !MediaQuery.disableAnimationsOf(context);
    return ColoredBox(
      color: _launchColor,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: animate ? 0 : 1, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        builder: (context, opacity, child) =>
            Opacity(opacity: opacity, child: child),
        child: QuickStartSheet(onLeaveToSignUp: _leave),
      ),
    );
  }
}
