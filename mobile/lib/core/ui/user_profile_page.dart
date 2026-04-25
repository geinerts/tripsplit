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
    this.avatarUrl,
    this.badges = const <String>[],
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
  final String? avatarUrl;
  final List<String> badges;
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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _UserProfileHeroCard(
              name: name,
              nickname: visibleNickname,
              avatarUrl: avatarUrl,
              badges: badges,
              enableNameCopy: enableNameCopy,
              copyNameTooltip: copyNameTooltip,
              copyNameSuccessText: copyNameSuccessText,
              copyNameFailureText: copyNameFailureText,
            ),
            for (final section in sections) ...[
              const SizedBox(height: 12),
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
                              ?.copyWith(fontWeight: FontWeight.w800),
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
  const UserProfileSectionCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(color: AppDesign.cardStroke(context)),
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
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.28),
        ),
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppDesign.mutedColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _UserProfileHeroCard extends StatelessWidget {
  const _UserProfileHeroCard({
    required this.name,
    this.nickname,
    this.avatarUrl,
    this.badges = const <String>[],
    this.enableNameCopy = false,
    this.copyNameTooltip,
    this.copyNameSuccessText,
    this.copyNameFailureText,
  });

  final String name;
  final String? nickname;
  final String? avatarUrl;
  final List<String> badges;
  final bool enableNameCopy;
  final String? copyNameTooltip;
  final String? copyNameSuccessText;
  final String? copyNameFailureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          ],
        ),
      ),
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
                    fontWeight: FontWeight.w800,
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
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [for (final badge in badges) UserProfileBadge(badge)],
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
      visualDensity: VisualDensity.compact,
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
        : name.trim().substring(0, 1).toUpperCase();

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
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppDesign.brandGradient,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 32,
        ),
      ),
    );
  }
}
