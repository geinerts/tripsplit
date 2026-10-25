import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/app/theme/app_design.dart';
import 'package:tripsplit/app/theme/app_theme.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

void main() {
  for (final brightness in Brightness.values) {
    test('shared $brightness text and action contrast', () {
      final theme = brightness == Brightness.dark
          ? AppTheme.dark()
          : AppTheme.light();
      final canvas = brightness == Brightness.dark
          ? AppDesign.darkCanvas
          : AppDesign.lightCanvas;
      final colors = theme.colorScheme;
      for (final color in [
        colors.onSurface,
        colors.onSurfaceVariant,
        colors.primary,
        colors.error,
      ]) {
        expect(contrast(color, canvas), greaterThanOrEqualTo(4.5));
        expect(contrast(color, colors.surface), greaterThanOrEqualTo(4.5));
      }
      expect(
        contrast(colors.onPrimary, colors.primary),
        greaterThanOrEqualTo(4.5),
      );
      expect(contrast(colors.outline, colors.surface), greaterThanOrEqualTo(3));
      for (final style in [
        theme.textTheme.headlineSmall,
        theme.textTheme.titleLarge,
        theme.textTheme.bodyLarge,
        theme.textTheme.bodyMedium,
        theme.textTheme.labelSmall,
      ]) {
        expect(style!.fontFamily, 'Inter');
        expect(style.letterSpacing, 0);
      }
    });
  }
}
