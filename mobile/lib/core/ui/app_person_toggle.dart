import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

/// A person to include: their photo with a ring and check when included,
/// dimmed when not, and their name below. No chip outline.
class AppPersonToggle extends StatelessWidget {
  const AppPersonToggle({
    super.key,
    required this.name,
    required this.avatar,
    required this.selected,
    required this.onChanged,
  });
  final String name;
  final Widget avatar;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final muted = AppDesign.mutedColor(context);
    return Semantics(
      button: true,
      toggled: selected,
      label: name,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? colors.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 160),
                          opacity: selected ? 1 : 0.4,
                          child: SizedBox.expand(
                            child: FittedBox(child: avatar),
                          ),
                        ),
                      ),
                      if (selected)
                        PositionedDirectional(
                          end: -2,
                          bottom: -2,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: selected ? AppDesign.titleColor(context) : muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
