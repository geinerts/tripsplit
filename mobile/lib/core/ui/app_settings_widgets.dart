import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

/// A plain, wrapping settings row shared by profile and its choice sheets.
class AppSettingsRow extends StatelessWidget {
  const AppSettingsRow({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.destructive = false,
    this.selected,
    this.chevron = true,
  });
  final String title;
  final IconData? icon;
  final String? subtitle, value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive, chevron;
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final muted = AppDesign.mutedColor(context);
    final color = destructive
        ? AppDesign.destructiveColor(context)
        : AppDesign.titleColor(context);
    return Semantics(
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: trailing == null ? 12 : 0,
              ),
              child: LayoutBuilder(
                builder: (context, box) {
                  final stackValue =
                      box.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(16) > 22;
                  return Row(
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 24,
                          color: destructive ? color : muted,
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(color: color),
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty)
                              Text(
                                subtitle!,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            if (stackValue && value != null)
                              Text(
                                value!,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(color: muted),
                              ),
                          ],
                        ),
                      ),
                      if (!stackValue && value != null) ...[
                        const SizedBox(width: 12),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Text(
                            value!,
                            textAlign: TextAlign.end,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(color: muted),
                          ),
                        ),
                      ],
                      if (trailing != null) ...[
                        const SizedBox(width: 12),
                        trailing!,
                      ] else if (selected == true) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ] else if (chevron) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right, color: muted),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSettingsSheet extends StatelessWidget {
  const AppSettingsSheet({
    super.key,
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * .75,
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    ),
  );
}
