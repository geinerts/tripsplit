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
