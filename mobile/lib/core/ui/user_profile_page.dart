import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_design.dart';
import 'app_scaffold.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({
    super.key,
    required this.title,
    required this.name,
    this.nickname,
    this.subtitle,
    this.avatarUrl,
    this.badges = const <String>[],
    this.statusBadge,
    this.sections = const <Widget>[],
    required this.bankTitle,
    required this.bankDescription,
    this.showBankDetails = true,
    this.onRefresh,
    this.enableNameCopy = false,
    this.copyNameTooltip,
    this.copyNameSuccessText,
    this.copyNameFailureText,
    this.appBarActions = const <Widget>[],
  });

  final String title;
  final String name;
  final String? nickname;
  final String? subtitle;
  final String? avatarUrl;
  final List<String> badges;
  final Widget? statusBadge;
  final List<Widget> sections;
  final String bankTitle;
  final String bankDescription;
  final bool showBankDetails;
  final Future<void> Function()? onRefresh;
  final bool enableNameCopy;
  final String? copyNameTooltip;
  final String? copyNameSuccessText;
  final String? copyNameFailureText;
  final List<Widget> appBarActions;

  @override
  Widget build(BuildContext context) {
    final visibleNickname = _visibleNickname(
      name: name.trim(),
      nickname: nickname?.trim() ?? '',
    );

    return AppPageScaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
        actions: appBarActions.isEmpty ? null : appBarActions,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        notificationPredicate: (_) => onRefresh != null,
        child: ListView(
          physics: onRefresh == null
              ? null
              : const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            _UserProfileHeroCard(
              name: name,
              nickname: subtitle ?? visibleNickname,
              avatarUrl: avatarUrl,
              badges: badges,
              statusBadge: statusBadge,
              enableNameCopy: enableNameCopy,
              copyNameTooltip: copyNameTooltip,
              copyNameSuccessText: copyNameSuccessText,
              copyNameFailureText: copyNameFailureText,
            ),
            for (final section in sections) ...[
              const SizedBox(height: 16),
              section,
            ],
            if (showBankDetails) ...[
              const SizedBox(height: 12),
              UserProfileSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bankTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      bankDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppDesign.mutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _visibleNickname({required String name, required String nickname}) {
    if (nickname.isEmpty) {
      return null;
    }
    if (nickname.toLowerCase() == name.toLowerCase()) {
      return null;
    }
    if (nickname.startsWith('@')) {
      return nickname;
    }
    return '@$nickname';
  }
}

class UserProfileSectionCard extends StatelessWidget {
  const UserProfileSectionCard({
    super.key,
    required this.child,
    this.showDivider = true,
  });

  final Widget child;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: showDivider ? 20 : 0),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(top: BorderSide(color: AppDesign.cardStroke(context)))
            : null,
      ),
      child: child,
    );
  }
}

class UserProfileBadge extends StatelessWidget {
  const UserProfileBadge(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class UserProfileMetricTile extends StatelessWidget {
  const UserProfileMetricTile({
    super.key,
    required this.label,
    required this.value,
    this.labelHeight = 0,
  });

  final String label;
  final String value;
  final double labelHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: labelHeight),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppDesign.mutedColor(context),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _UserProfileHeroCard extends StatelessWidget {
  const _UserProfileHeroCard({
    required this.name,
    this.nickname,
    this.avatarUrl,
    this.badges = const <String>[],
    this.statusBadge,
    this.enableNameCopy = false,
    this.copyNameTooltip,
    this.copyNameSuccessText,
    this.copyNameFailureText,
  });

  final String name;
  final String? nickname;
  final String? avatarUrl;
  final List<String> badges;
  final Widget? statusBadge;
  final bool enableNameCopy;
  final String? copyNameTooltip;
  final String? copyNameSuccessText;
  final String? copyNameFailureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
      child: Column(
        children: [
          _UserProfileAvatar(name: name, avatarUrl: avatarUrl),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (enableNameCopy && name.trim().isNotEmpty) ...[
                const SizedBox(width: 4),
                _UserProfileNameCopyButton(
                  value: name.trim(),
                  tooltip: copyNameTooltip,
                  successText: copyNameSuccessText,
                  failureText: copyNameFailureText,
                ),
              ],
            ],
          ),
          if (nickname != null) ...[
            const SizedBox(height: 4),
            Text(
              nickname!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppDesign.mutedColor(context),
              ),
            ),
          ],
          if (badges.isNotEmpty || statusBadge != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final badge in badges) UserProfileBadge(badge),
                ?statusBadge,
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _UserProfileNameCopyButton extends StatelessWidget {
  const _UserProfileNameCopyButton({
    required this.value,
    this.tooltip,
    this.successText,
    this.failureText,
  });

  final String value;
  final String? tooltip;
  final String? successText;
  final String? failureText;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        try {
          await Clipboard.setData(ClipboardData(text: value));
          if (!context.mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(successText ?? 'Name copied.'),
            ),
          );
        } catch (_) {
          if (!context.mounted) {
            return;
          }
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              content: Text(failureText ?? 'Could not copy name.'),
            ),
          );
        }
      },
      tooltip: tooltip ?? MaterialLocalizations.of(context).copyButtonLabel,
      icon: Icon(
        Icons.content_copy_rounded,
        size: 20,
        color: AppDesign.mutedColor(context),
      ),
    );
  }
}

class _UserProfileAvatar extends StatelessWidget {
  const _UserProfileAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    const size = 84.0;
    final imageCacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    final trimmedUrl = (avatarUrl ?? '').trim();
    final initial = name.trim().isEmpty
        ? '?'
        : name
              .trim()
              .split(RegExp(r'\s+'))
              .where((part) => part.isNotEmpty)
              .take(2)
              .map((part) => part.characters.first)
              .join()
              .toUpperCase();

    if (trimmedUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          trimmedUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          gaplessPlayback: true,
          cacheWidth: imageCacheSize,
          cacheHeight: imageCacheSize,
          errorBuilder: (context, error, stackTrace) =>
              _UserProfileAvatarFallback(initial: initial),
        ),
      );
    }
    return _UserProfileAvatarFallback(initial: initial);
  }
}

class _UserProfileAvatarFallback extends StatelessWidget {
  const _UserProfileAvatarFallback({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 32,
        ),
      ),
    );
  }
}
