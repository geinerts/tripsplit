import 'package:flutter/material.dart';

import '../../app/theme/app_design.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool showDragHandle = true,
  bool wrapWithSurface = true,
  bool useRootNavigator = false,
  bool useSafeArea = true,
  bool enableDrag = true,
  Color? barrierColor,
  BoxConstraints? constraints,
}) {
  final isDark = AppDesign.isDark(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    useSafeArea: false,
    enableDrag: enableDrag,
    showDragHandle: false,
    backgroundColor: Colors.transparent,
    barrierColor:
        barrierColor ?? Colors.black.withValues(alpha: isDark ? 0.62 : 0.38),
    constraints: constraints,
    builder: (sheetContext) {
      if (!wrapWithSurface) {
        return builder(sheetContext);
      }
      return AppBottomSheetSurface(
        showDragHandle: showDragHandle,
        useSafeArea: useSafeArea,
        child: builder(sheetContext),
      );
    },
  );
}

class AppBottomSheetSurface extends StatelessWidget {
  const AppBottomSheetSurface({
    super.key,
    required this.child,
    this.showDragHandle = true,
    this.useSafeArea = true,
  });

  final Widget child;
  final bool showDragHandle;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final bottomSafePadding = useSafeArea
        ? MediaQuery.paddingOf(context).bottom
        : 0.0;
    final radius = BorderRadius.vertical(
      top: Radius.circular(AppDesign.radiusLg),
    );
    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: AppDesign.modalSurface(context),
        borderRadius: radius,
        border: Border(
          top: BorderSide(color: AppDesign.cardStroke(context)),
          left: BorderSide(color: AppDesign.cardStroke(context)),
          right: BorderSide(color: AppDesign.cardStroke(context)),
        ),
        boxShadow: [
          if (!AppDesign.isDark(context))
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.34),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const SizedBox(width: 42, height: 4),
                ),
              ),
            child,
            if (bottomSafePadding > 0) SizedBox(height: bottomSafePadding),
          ],
        ),
      ),
    );

    return surface;
  }
}
