part of 'login_page.dart';

extension _LoginPageWidgets on _LoginPageState {
  Widget _buildLoginScaffold(BuildContext context) {
    final responsive = context.responsive;
    final horizontalPadding = responsive.pageHorizontalPadding;

    if (widget.compactSheet) {
      final semantic =
          Theme.of(context).extension<AppSemanticColors>() ??
          AppSemanticColors.dark;
      final colorScheme = Theme.of(context).colorScheme;
      final bottomSafe = MediaQuery.viewPaddingOf(context).bottom;
      final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
      return Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Form(
          key: _formKey,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppDesign.authCanvasSoft,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.22),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    10,
                    horizontalPadding,
                    bottomSafe + (keyboardInset > 0 ? 14 : 10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: semantic.cardGlassBorder.withValues(
                            alpha: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildAuthCard(context, asStandaloneContent: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: responsive.pageMaxWidth,
                      minHeight: constraints.maxHeight,
                    ),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        24,
                      ),
                      children: [
                        _buildTopActions(context),
                        SizedBox(
                          height: responsive.pick(
                            compact: 14,
                            medium: 18,
                            expanded: 22,
                          ),
                        ),
                        _buildBrandSection(context),
                        const SizedBox(height: 26),
                        _buildAuthCard(context, asStandaloneContent: false),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopActions(BuildContext context) {
    final t = context.l10n;
    return Row(
      children: [
        if (widget.showSheetClose)
          IconButton(
            tooltip: _authText(en: 'Close', lv: 'Aizvērt'),
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close_rounded),
          )
        else
          const SizedBox(width: 48),
        const Spacer(),
        IconButton(
          tooltip: t.languageAction,
          onPressed: () => showAppLocalePicker(context),
          icon: const Icon(Icons.translate_outlined),
        ),
        IconButton(
          tooltip: t.appearance,
          onPressed: () => showThemeModePicker(context),
          icon: const Icon(Icons.brightness_6_outlined),
        ),
      ],
    );
  }

  Widget _buildBrandSection(BuildContext context) {
    final t = context.l10n;
    final responsive = context.responsive;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLogin = _mode == _AuthMode.login;
    final logoWidth = responsive.pick(
      compact: 220.0,
      medium: 260.0,
      expanded: 300.0,
    );

    return Column(
      children: [
        Image.asset(
          isDark
              ? 'assets/branding/logo_full_dark.png'
              : 'assets/branding/logo_full.png',
          width: logoWidth,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
        const SizedBox(height: 16),
        Text(
          isLogin ? t.authSubtitleLogin : t.authSubtitleRegister,
          textAlign: TextAlign.center,
          style:
              (responsive.isCompact
                      ? Theme.of(context).textTheme.titleMedium
                      : Theme.of(context).textTheme.titleLarge)
                  ?.copyWith(
                    color: colorScheme.outline,
                    fontWeight: FontWeight.w500,
                  ),
        ),
      ],
    );
  }
}
