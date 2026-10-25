import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../../core/ui/splyto_illustration.dart';

import '../../../core/l10n/l10n.dart';

/// Owns only the guide's route, so an invitation can dismiss it without popping
/// a different dialog. Replay never modifies the account's automatic status.
class QuickStartPresenter {
  ModalBottomSheetRoute<bool>? _route;

  Future<bool?> show(BuildContext context) async {
    if (_route != null) return false;
    final route = ModalBottomSheetRoute<bool>(
      builder: (_) => const QuickStartSheet(),
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: Navigator.of(context).context,
      ),
    );
    _route = route;
    try {
      return await Navigator.of(context).push(route);
    } finally {
      if (identical(_route, route)) _route = null;
    }
  }

  void dismiss() {
    final route = _route;
    if (route != null && route.isActive) {
      route.navigator?.removeRoute(route);
    }
  }
}

class QuickStartSheet extends StatefulWidget {
  const QuickStartSheet({super.key});

  @override
  State<QuickStartSheet> createState() => _QuickStartSheetState();
}

class _QuickStartSheetState extends State<QuickStartSheet> {
  int _step = 0;
  static const _assets = [
    'assets/branding/splyto_tutorial_01_create_trip.svg',
    'assets/branding/splyto_tutorial_02_invite_friends.svg',
    'assets/branding/splyto_tutorial_03_add_expense.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final theme = Theme.of(context);
    final titles = [
      t.quickStartCreateTitle,
      t.quickStartInviteTitle,
      t.quickStartExpenseTitle,
    ];
    final descriptions = [
      t.quickStartCreateBody,
      t.quickStartInviteBody,
      t.quickStartExpenseBody,
    ];
    return SizedBox(
      height: math.min(760, MediaQuery.sizeOf(context).height * .94),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurface,
                    minimumSize: const Size(48, 48),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(t.quickStartSkip),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    key: ValueKey(_step),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              children: [
                                if (_step == 0) ...[
                                  Image.asset(
                                    theme.brightness == Brightness.dark
                                        ? 'assets/branding/logo_full_dark.png'
                                        : 'assets/branding/logo_full.png',
                                    key: const ValueKey('quick-start-logo'),
                                    width: 132,
                                    height: 54,
                                    fit: BoxFit.contain,
                                    semanticLabel: 'Splyto',
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                Semantics(
                                  header: true,
                                  child: Text(
                                    titles[_step],
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontSize: 28,
                                          height: 1.15,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -.7,
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 310,
                                  ),
                                  child: Text(
                                    descriptions[_step],
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      height: 1.45,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: SplytoIllustration(
                              _assets[_step],
                              width: 342,
                              height: (constraints.maxHeight * .44).clamp(
                                140.0,
                                260.0,
                              ),
                              fit: BoxFit.contain,
                              excludeFromSemantics: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                label: t.quickStartStep(_step + 1, _assets.length),
                child: ExcludeSemantics(
                  child: Row(
                    key: const ValueKey('quick-start-dots'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _assets.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _step
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: .22,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 52),
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  if (_step == _assets.length - 1) {
                    Navigator.of(context).pop(true);
                  } else {
                    setState(() => _step++);
                  }
                },
                child: Text(
                  _step == _assets.length - 1
                      ? t.createAction
                      : t.quickStartNext,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
