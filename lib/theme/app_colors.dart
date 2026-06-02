import 'package:flutter/material.dart';

// Static brand colors — same in both themes
abstract final class AppColors {
  static const Color primary = Color(0xFF4F7CFF);
  static const Color primaryHover = Color(0xFF6C92FF);
  static const Color primaryDark = Color(0xFF2D5BFF);
  static const Color premium = Color(0xFFF4B942);
  static const Color premiumDark = Color(0xFFD99A22);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

// Theme-adaptive colors via ThemeExtension
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.textPrimary,
    required this.textSecondary,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color textPrimary;
  final Color textSecondary;

  static const dark = AppColorsExtension(
    background: Color(0xFF0B1020),
    surface: Color(0xFF131B2E),
    surfaceElevated: Color(0xFF1A233A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0BACF),
  );

  static const light = AppColorsExtension(
    background: Color(0xFFF0F2FF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE4E8F5),
    textPrimary: Color(0xFF1A1F36),
    textSecondary: Color(0xFF6B7280),
  );

  @override
  AppColorsExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? textPrimary,
    Color? textSecondary,
  }) => AppColorsExtension(
        background: background ?? this.background,
        surface: surface ?? this.surface,
        surfaceElevated: surfaceElevated ?? this.surfaceElevated,
        textPrimary: textPrimary ?? this.textPrimary,
        textSecondary: textSecondary ?? this.textSecondary,
      );

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.dark;
}
