part of 'login_page.dart';

extension _LoginPageWidgets on _LoginPageState {
  Widget _buildLoginScaffold(BuildContext context) {
    final responsive = context.responsive;
    final horizontalPadding = responsive.pageHorizontalPadding;

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
                        if (_isRestoringSession)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12),
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
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
                        _buildAuthCard(context),
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
    final isLogin = _mode == _AuthMode.login;
    final heroSize = responsive.pick(compact: 84, medium: 96, expanded: 108);
    final iconSize = responsive.pick(compact: 40, medium: 46, expanded: 52);

    return Column(
      children: [
        Container(
          width: heroSize,
          height: heroSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              responsive.pick(compact: 24, medium: 30, expanded: 34),
            ),
            gradient: AppDesign.brandGradient,
            boxShadow: const [
              BoxShadow(
                color: Color(0x3A5D6DFF),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.flight_takeoff,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Splyto',
          textAlign: TextAlign.center,
          style:
              (responsive.isCompact
                      ? Theme.of(context).textTheme.displaySmall
                      : Theme.of(context).textTheme.displayMedium)
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
        ),
        const SizedBox(height: 8),
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
