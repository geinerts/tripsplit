import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/l10n/l10n.dart';
import 'quick_start_background.dart';
import 'quick_start_phone_screens.dart';

/// Owns only the guide's route, so an invitation can dismiss it without popping
/// a different dialog. Replay never modifies the account's automatic status.
class QuickStartPresenter {
  MaterialPageRoute<bool>? _route;

  Future<bool?> show(BuildContext context) async {
    if (_route != null) return false;
    final route = MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => const QuickStartSheet(),
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
  const QuickStartSheet({super.key, this.onLeaveToSignUp});

  /// Set before there is an account: skipping and finishing lead to sign-up.
  final VoidCallback? onLeaveToSignUp;

  @override
  State<QuickStartSheet> createState() => _QuickStartSheetState();
}

class _QuickStartSheetState extends State<QuickStartSheet> {
  static const _slideCount = 6;
  static const _titleStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 30,
    height: 1.12,
    fontWeight: FontWeight.w800,
    letterSpacing: -.8,
    color: quickStartInk,
  );
  static const _bodyStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    height: 1.4,
    color: Color(0xFF263654),
  );

  final _pageController = PageController();
  int _step = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double get _page {
    if (_pageController.hasClients && _pageController.position.haveDimensions) {
      return _pageController.page ?? _step.toDouble();
    }
    return _step.toDouble();
  }

  void _onPrimaryPressed() {
    if (_step == _slideCount - 1) {
      _finish(true);
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(_step + 1);
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish(bool create) {
    final leave = widget.onLeaveToSignUp;
    if (leave != null) {
      leave();
    } else {
      Navigator.of(context).pop(create);
    }
  }

  /// All slides reserve the tallest text, so the phone stays still while swiping.
  double _textHeight(
    BuildContext context,
    List<String> titles,
    List<String> bodies,
    double width,
  ) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
        textAlign: TextAlign.center,
      )..layout(maxWidth: width);
      final height = painter.height;
      painter.dispose();
      return height;
    }

    var tallest = 0.0;
    for (var i = 0; i < titles.length; i++) {
      tallest = math.max(
        tallest,
        measure(titles[i], _titleStyle) + 10 + measure(bodies[i], _bodyStyle),
      );
    }
    return tallest;
  }

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    final titles = [
      t.quickStartCreateTitle,
      t.quickStartExpenseTitle,
      t.quickStartSettleTitle,
      t.quickStartAnalyticsTitle,
      t.quickStartMapTitle,
      t.quickStartLiveTitle,
    ];
    final bodies = [
      t.quickStartCreateBody,
      t.quickStartExpenseBody,
      t.quickStartSettleBody,
      t.quickStartAnalyticsBody,
      t.quickStartMapBody,
      t.quickStartLiveBody,
    ];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Theme(
        data: AppTheme.light(),
        child: Scaffold(
          backgroundColor: quickStartCream,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final padding = MediaQuery.paddingOf(context);
              final scaler = MediaQuery.textScalerOf(context);
              final topBar = padding.top + 56;
              final bottomBar =
                  padding.bottom + 56 + math.max(52.0, scaler.scale(30));
              final maxText = math.max(
                0.0,
                constraints.maxHeight - topBar - bottomBar - 16,
              );
              final textHeight = math.min(
                maxText,
                _textHeight(context, titles, bodies, constraints.maxWidth - 48),
              );
              final phoneTop = topBar + textHeight + 20;
              final phoneWidth = math.min(constraints.maxWidth * .74, 300.0);
              final showPhone =
                  constraints.maxHeight - phoneTop - bottomBar > 48;
              return Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, _) =>
                          QuickStartBackground(page: _page),
                    ),
                  ),
                  if (showPhone)
                    Positioned(
                      top: phoneTop,
                      left: (constraints.maxWidth - phoneWidth) / 2,
                      width: phoneWidth,
                      child: IgnorePointer(
                        child: ExcludeSemantics(
                          child: AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, _) => QuickStartPhone(
                              page: _page,
                              slideCount: _slideCount,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: bottomBar + 56,
                    child: const IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, .4],
                            colors: [Color(0x00FFF8EC), quickStartCream],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: PageView.builder(
                      key: const ValueKey('quick-start-pages'),
                      controller: _pageController,
                      itemCount: _slideCount,
                      onPageChanged: (page) => setState(() => _step = page),
                      itemBuilder: (context, page) => Padding(
                        padding: EdgeInsets.fromLTRB(24, topBar, 24, 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            height: textHeight,
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  Semantics(
                                    header: true,
                                    child: Text(
                                      titles[page],
                                      textAlign: TextAlign.center,
                                      style: _titleStyle,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    bodies[page],
                                    textAlign: TextAlign.center,
                                    style: _bodyStyle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: padding.top + 4,
                    left: 24,
                    right: 16,
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/branding/logo_full.png',
                          key: const ValueKey('quick-start-logo'),
                          height: 30,
                          fit: BoxFit.contain,
                          semanticLabel: 'Splyto',
                        ),
                        const Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: quickStartInk,
                            minimumSize: const Size(48, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onPressed: () => _finish(false),
                          child: Text(t.quickStartSkip),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: padding.bottom + 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Semantics(
                          liveRegion: true,
                          label: t.quickStartStep(_step + 1, _slideCount),
                          child: ExcludeSemantics(
                            child: Row(
                              key: const ValueKey('quick-start-dots'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _slideCount,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index == _step
                                        ? quickStartInk
                                        : quickStartInk.withValues(alpha: .22),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(48, 52),
                            shape: const StadiumBorder(),
                            backgroundColor: quickStartInk,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _onPrimaryPressed,
                          child: Text(
                            _step == _slideCount - 1
                                ? (widget.onLeaveToSignUp != null
                                      ? t.quickStartSignUpAction
                                      : t.quickStartCreateAction)
                                : t.quickStartNext,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
