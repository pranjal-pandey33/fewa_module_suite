import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  static TextTheme light() {
    return TextTheme(
      headlineLarge: _h1.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      headlineMedium: _h2.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      titleMedium: _h3.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodyMedium: _body.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodySmall: _caption.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelLarge: _button.copyWith(
        color: AppColors.lightOnPrimary,
      ),
      labelMedium: _button.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      labelSmall: _caption.copyWith(
        color: AppColors.lightTextMuted,
      ),
    ).apply(
      fontFamily: fontFamily,
    );
  }

  static TextTheme dark() {
    return TextTheme(
      headlineLarge: _h1.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      headlineMedium: _h2.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      titleMedium: _h3.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodyMedium: _body.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      bodySmall: _caption.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      labelLarge: _button.copyWith(
        color: AppColors.lightOnPrimary,
      ),
      labelMedium: _button.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      labelSmall: _caption.copyWith(
        color: AppColors.darkTextMuted,
      ),
    ).apply(
      fontFamily: fontFamily,
    );
  }

  static const TextStyle _h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle _h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.35,
  );

  static const TextStyle _h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle _body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle _caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle _button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: 0.1,
  );
}

extension AppTextStyleShortcut on TextTheme {
  TextStyle get h1 => headlineLarge ?? const TextStyle();
  TextStyle get h2 => headlineMedium ?? const TextStyle();
  TextStyle get h3 => titleMedium ?? const TextStyle();
  TextStyle get body => bodyMedium ?? const TextStyle();
  TextStyle get caption => bodySmall ?? const TextStyle();
  TextStyle get button => labelLarge ?? const TextStyle();
}
