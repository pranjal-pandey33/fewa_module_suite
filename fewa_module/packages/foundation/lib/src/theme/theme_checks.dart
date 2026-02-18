import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Manual debug-only helper for auditing module widgets.
///
/// Usage:
/// ```dart
/// if (kDebugMode) {
///   assertNoHardcodedColors(
///     context: context,
///     location: 'TodoHome/TaskItem',
///     colors: [myTextStyle.color, myBorderColor],
///   );
/// }
/// ```
///
/// It validates incoming colors against:
/// - The active ThemeData color entries
/// - Shared AppColors tokens from the design system
@pragma('vm:entry-point')
void assertNoHardcodedColors({
  required BuildContext context,
  required String location,
  required Iterable<Color> colors,
  Set<Color> allowedOverrides = const {},
}) {
  if (!kDebugMode) return;

  final theme = Theme.of(context);
  final tokens = <Color>{
    ..._themeColorSet(theme),
    ...allowedOverrides,
    AppColors.primary,
    AppColors.primaryHover,
    AppColors.primaryPressed,
    AppColors.accent,
    AppColors.error,
    AppColors.warning,
    AppColors.success,
    AppColors.lightBackground,
    AppColors.lightSurface,
    AppColors.lightBorder,
    AppColors.lightTextPrimary,
    AppColors.lightTextSecondary,
    AppColors.lightTextMuted,
    AppColors.darkBackground,
    AppColors.darkSurface,
    AppColors.darkBorder,
    AppColors.darkTextPrimary,
    AppColors.darkTextSecondary,
    AppColors.darkTextMuted,
  };

  for (final color in colors) {
    assert(
      tokens.contains(color),
      'Hardcoded or unknown color at $location. '
      'Use theme tokens via Theme.of(context).colorScheme or AppColors.',
    );
  }
}

Set<Color> _themeColorSet(ThemeData theme) {
  return <Color>{
    theme.colorScheme.primary,
    theme.colorScheme.onPrimary,
    theme.colorScheme.primaryContainer,
    theme.colorScheme.onPrimaryContainer,
    theme.colorScheme.secondary,
    theme.colorScheme.onSecondary,
    theme.colorScheme.secondaryContainer,
    theme.colorScheme.onSecondaryContainer,
    theme.colorScheme.tertiary,
    theme.colorScheme.onTertiary,
    theme.colorScheme.tertiaryContainer,
    theme.colorScheme.onTertiaryContainer,
    theme.colorScheme.error,
    theme.colorScheme.onError,
    theme.colorScheme.errorContainer,
    theme.colorScheme.onErrorContainer,
    theme.colorScheme.surface,
    theme.colorScheme.onSurface,
    theme.colorScheme.surfaceContainerHighest,
    theme.colorScheme.onSurfaceVariant,
    theme.colorScheme.outline,
    theme.colorScheme.outlineVariant,
    theme.colorScheme.shadow,
    theme.colorScheme.scrim,
    theme.colorScheme.inverseSurface,
    theme.colorScheme.onInverseSurface,
    theme.colorScheme.inversePrimary,
    theme.colorScheme.surfaceTint,
    theme.scaffoldBackgroundColor,
    theme.colorScheme.surface,
    theme.disabledColor,
    theme.dividerColor,
    theme.cardColor,
    theme.canvasColor,
    theme.dividerTheme.color ?? Colors.transparent,
    theme.hintColor,
    theme.highlightColor,
    theme.focusColor,
    theme.hoverColor,
    theme.splashColor,
    theme.shadowColor,
  };
}
