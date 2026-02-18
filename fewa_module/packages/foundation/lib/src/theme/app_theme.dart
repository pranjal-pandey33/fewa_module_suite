import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Spacing tokens from the design system.
class AppSpacing {
  AppSpacing._();

  static const double x1 = 8;
  static const double x2 = 16;
  static const double x3 = 24;
  static const double x4 = 32;
  static const double x5 = 40;
  static const double x6 = 48;
}

/// Radius tokens from the design system.
class AppRadius {
  AppRadius._();

  static const double card = 12;
  static const double button = 8;
  static const Radius cardRadius = Radius.circular(card);
  static const Radius buttonRadius = Radius.circular(button);
  static const BorderRadius cardBorderRadius = BorderRadius.all(cardRadius);
  static const BorderRadius buttonBorderRadius = BorderRadius.all(buttonRadius);
}

ThemeData buildTheme({Brightness brightness = Brightness.light}) {
  final bool isDark = brightness == Brightness.dark;

  final ColorScheme colorScheme = isDark
      ? _darkColorScheme
      : _lightColorScheme;
  final TextTheme textTheme = isDark ? AppTypography.dark() : AppTypography.light();

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: textTheme.h1.copyWith(
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorderRadius,
      ),
      side: BorderSide(color: colorScheme.outline),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outline,
      thickness: 1,
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurface),
    popupMenuTheme: PopupMenuThemeData(
      color: colorScheme.surface,
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorderRadius,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.secondaryContainer,
      contentTextStyle: textTheme.body,
      behavior: SnackBarBehavior.floating,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surface,
      side: BorderSide(color: colorScheme.outline),
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.buttonBorderRadius,
      ),
      labelStyle: textTheme.body,
      labelPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x1,
        vertical: AppSpacing.x1 / 2,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorderRadius,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.buttonBorderRadius,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(40),
        foregroundColor: colorScheme.primary,
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
      minLeadingWidth: AppSpacing.x4,
      iconColor: colorScheme.onSurfaceVariant,
      titleTextStyle: textTheme.body,
      subtitleTextStyle: textTheme.caption,
    ),
    dividerColor: colorScheme.outline,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: AppRadius.buttonBorderRadius,
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.buttonBorderRadius,
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.buttonBorderRadius,
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      filled: true,
      fillColor: colorScheme.surface,
    ),
  );
}

final ColorScheme _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.primary,
  onPrimary: AppColors.lightOnPrimary,
  primaryContainer: AppColors.primary.withOpacity(0.12),
  onPrimaryContainer: AppColors.primaryPressed,
  secondary: AppColors.accent,
  onSecondary: AppColors.lightOnPrimary,
  secondaryContainer: AppColors.accent.withOpacity(0.12),
  onSecondaryContainer: AppColors.accent,
  tertiary: AppColors.success,
  onTertiary: AppColors.lightOnPrimary,
  tertiaryContainer: AppColors.success.withOpacity(0.12),
  onTertiaryContainer: AppColors.success,
  error: AppColors.error,
  onError: AppColors.lightOnPrimary,
  errorContainer: AppColors.error.withOpacity(0.12),
  onErrorContainer: AppColors.error,
  background: AppColors.lightBackground,
  onBackground: AppColors.lightTextPrimary,
  surface: AppColors.lightSurface,
  onSurface: AppColors.lightTextPrimary,
  surfaceTint: AppColors.lightSurfaceTint,
  onSurfaceVariant: AppColors.lightTextSecondary,
  outline: AppColors.lightBorder,
  outlineVariant: AppColors.lightBorder.withOpacity(0.65),
  shadow: Colors.black12,
  scrim: Colors.black54,
  inverseSurface: AppColors.darkSurface,
  onInverseSurface: AppColors.darkTextPrimary,
  inversePrimary: AppColors.primaryPressed,
);

final ColorScheme _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: AppColors.primary,
  onPrimary: AppColors.lightOnPrimary,
  primaryContainer: AppColors.primary.withOpacity(0.24),
  onPrimaryContainer: AppColors.lightOnPrimary,
  secondary: AppColors.accent,
  onSecondary: AppColors.lightOnPrimary,
  secondaryContainer: AppColors.accent.withOpacity(0.24),
  onSecondaryContainer: AppColors.lightOnPrimary,
  tertiary: AppColors.warning,
  onTertiary: AppColors.darkTextPrimary,
  tertiaryContainer: AppColors.warning.withOpacity(0.2),
  onTertiaryContainer: AppColors.lightOnPrimary,
  error: AppColors.error,
  onError: AppColors.lightOnPrimary,
  errorContainer: AppColors.error.withOpacity(0.2),
  onErrorContainer: AppColors.lightOnPrimary,
  background: AppColors.darkBackground,
  onBackground: AppColors.darkTextPrimary,
  surface: AppColors.darkSurface,
  onSurface: AppColors.darkTextPrimary,
  surfaceTint: AppColors.darkSurfaceTint,
  onSurfaceVariant: AppColors.darkTextSecondary,
  outline: AppColors.darkBorder,
  outlineVariant: AppColors.darkBorder.withOpacity(0.65),
  shadow: Colors.black87,
  scrim: Colors.black87,
  inverseSurface: AppColors.lightSurface,
  onInverseSurface: AppColors.lightTextPrimary,
  inversePrimary: AppColors.primary,
);
