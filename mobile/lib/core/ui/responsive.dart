import 'package:flutter/material.dart';

enum ResponsiveSize { compact, medium, expanded }

class ResponsiveSpec {
  const ResponsiveSpec(this.width);

  final double width;

  static const double compactMaxWidth = 599;
  static const double mediumMaxWidth = 1023;

  ResponsiveSize get size {
    if (width <= compactMaxWidth) {
      return ResponsiveSize.compact;
    }
    if (width <= mediumMaxWidth) {
      return ResponsiveSize.medium;
    }
    return ResponsiveSize.expanded;
  }

  bool get isCompact => size == ResponsiveSize.compact;
  bool get isMedium => size == ResponsiveSize.medium;
  bool get isExpanded => size == ResponsiveSize.expanded;

  double pick({
    required double compact,
    required double medium,
    required double expanded,
  }) {
    switch (size) {
      case ResponsiveSize.compact:
        return compact;
      case ResponsiveSize.medium:
        return medium;
      case ResponsiveSize.expanded:
        return expanded;
    }
  }

  double get pageMaxWidth {
    return pick(compact: 560, medium: 760, expanded: 980);
  }

  double get pageHorizontalPadding {
    return pick(compact: 16, medium: 24, expanded: 32);
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveSpec get responsive {
    return ResponsiveSpec(MediaQuery.sizeOf(this).width);
  }
}
