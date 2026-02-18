import 'package:flutter/material.dart';

/// Centralized color tokens for the shared design system.
abstract class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryHover = Color(0xFF6366F1); // Indigo 500
  static const Color primaryPressed = Color(0xFF4338CA); // Indigo 700

  static const Color accent = Color(0xFF10B981); // Emerald 500

  // Status
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color success = Color(0xFF10B981); // Emerald 500

  // Neutral palette
  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E7EB);

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  // Text
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // Contrast / utility
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSurfaceTint = Color(0xFFEEF2FF);
  static const Color darkSurfaceTint = Color(0xFF1E293B);
}
