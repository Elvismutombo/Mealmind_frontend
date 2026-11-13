import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';
import 'app_theme_extensions.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceElevated: AppColors.lightSurface,
    primary: AppColors.lightPrimary,
    primaryDark: AppColors.lightPrimaryDark,
    secondary: AppColors.lightSecondary,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    border: AppColors.lightBorder,
    success: AppColors.lightSuccess,
    error: AppColors.lightError,
    warning: AppColors.lightWarning,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceElevated: AppColors.darkSurfaceElevated,
    primary: AppColors.darkPrimary,
    primaryDark: AppColors.darkPrimaryDark,
    secondary: AppColors.darkSecondary,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    border: AppColors.darkBorder,
    success: AppColors.darkSuccess,
    error: AppColors.darkError,
    warning: AppColors.darkWarning,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceElevated,
    required Color primary,
    required Color primaryDark,
    required Color secondary,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color success,
    required Color error,
    required Color warning,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isDark ? AppColors.darkBackground : AppColors.white,
      primaryContainer: isDark
          ? const Color(0xFF603B2B)
          : const Color(0xFFFBE4D8),
      onPrimaryContainer: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightPrimaryDark,
      secondary: secondary,
      onSecondary: isDark ? AppColors.darkBackground : AppColors.white,
      secondaryContainer: isDark
          ? const Color(0xFF35483E)
          : const Color(0xFFE8EFEA),
      onSecondaryContainer: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightSecondary,
      tertiary: success,
      onTertiary: isDark ? AppColors.darkBackground : AppColors.white,
      tertiaryContainer: isDark
          ? const Color(0xFF244533)
          : const Color(0xFFE2F2E9),
      onTertiaryContainer: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightSecondary,
      error: error,
      onError: AppColors.white,
      errorContainer: isDark
          ? const Color(0xFF512B2A)
          : const Color(0xFFFBE7E5),
      onErrorContainer: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightError,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceElevated,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border,
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: isDark ? AppColors.lightSurface : AppColors.darkSurface,
      onInverseSurface: isDark
          ? AppColors.lightTextPrimary
          : AppColors.darkTextPrimary,
      inversePrimary: isDark ? AppColors.lightPrimary : AppColors.darkPrimary,
      surfaceTint: primary,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.large),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: border,
      fontFamily: AppTextStyles.fontFamily,
      textTheme: AppTextStyles.textTheme(textPrimary, textSecondary),
      extensions: [
        AppThemeExtension(
          background: background,
          surface: surface,
          surfaceElevated: surfaceElevated,
          primary: primary,
          primaryDark: primaryDark,
          secondary: secondary,
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          border: border,
          success: success,
          error: error,
          warning: warning,
        ),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: AppColors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.title.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      iconTheme: IconThemeData(color: textPrimary, size: 22),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: shape,
        shadowColor: AppColors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: textSecondary),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: textSecondary),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: primary,
          disabledBackgroundColor: primary.withValues(alpha: 0.35),
          disabledForegroundColor: colorScheme.onPrimary.withValues(alpha: 0.7),
          textStyle: AppTextStyles.label,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: primary,
          elevation: 0,
          textStyle: AppTextStyles.label,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          textStyle: AppTextStyles.label,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          textStyle: AppTextStyles.label,
          minimumSize: const Size(48, 44),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceElevated,
        selectedColor: isDark
            ? const Color(0xFF603B2B)
            : const Color(0xFFFBE4D8),
        disabledColor: surfaceElevated,
        side: BorderSide(color: border),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: textPrimary),
        secondaryLabelStyle: AppTextStyles.label.copyWith(color: primaryDark),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(color: textPrimary),
        contentTextStyle: AppTextStyles.bodySmall.copyWith(
          color: textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        ),
        shadowColor: AppColors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        modalBackgroundColor: surface,
        showDragHandle: true,
        dragHandleColor: textSecondary.withValues(alpha: 0.45),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.extraLarge),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: AppColors.transparent,
        indicatorColor: isDark
            ? const Color(0xFF603B2B)
            : const Color(0xFFFBE4D8),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.caption.copyWith(color: textSecondary),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        titleTextStyle: AppTextStyles.subtitle.copyWith(color: textPrimary),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSecondary,
        contentTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withValues(alpha: 0.18),
        circularTrackColor: primary.withValues(alpha: 0.18),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
      ),
      shadowColor: AppColors.transparent,
    );
  }
}
