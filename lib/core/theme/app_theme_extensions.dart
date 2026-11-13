import 'package:flutter/material.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.success,
    required this.error,
    required this.warning,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color success;
  final Color error;
  final Color warning;

  @override
  AppThemeExtension copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? success,
    Color? error,
    Color? warning,
  }) => AppThemeExtension(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    primary: primary ?? this.primary,
    primaryDark: primaryDark ?? this.primaryDark,
    secondary: secondary ?? this.secondary,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    border: border ?? this.border,
    success: success ?? this.success,
    error: error ?? this.error,
    warning: warning ?? this.warning,
  );

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeExtension get appColors =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
