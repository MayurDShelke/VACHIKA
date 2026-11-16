import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the Material [ThemeData] for the VACHIKA app.
///
/// Combines all design tokens from `DESIGN.md` into a single theme.
/// No hard-coded styles in screens — everything comes from here.
class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────────────────
  //  Light Theme
  // ──────────────────────────────────────────────────────────

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColors.forestSage,
      onPrimary: AppColors.white,
      secondary: AppColors.softSage,
      onSecondary: AppColors.graphite,
      surface: AppColors.porcelain,
      onSurface: AppColors.graphite,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.stone,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: AppColors.porcelain,

      // ── AppBar ───────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.porcelain,
        foregroundColor: AppColors.graphite,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: AppTypography.screenHeading,
      ),

      // ── Bottom Navigation ────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.forestSage,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.label.copyWith(
          color: AppColors.forestSage,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.label,
      ),

      // ── Cards ────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.stone,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),

      // ── Elevated Button (Primary) ───────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestSage,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
          elevation: 0,
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusButton,
          ),
          textStyle: AppTypography.button,
        ),
      ),

      // ── Outlined Button (Secondary) ─────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.forestSage,
          disabledForegroundColor: AppColors.disabled,
          minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusButton,
          ),
          side: const BorderSide(color: AppColors.forestSage, width: 1.5),
          textStyle: AppTypography.button,
        ),
      ),

      // ── Text Button ─────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.forestSage,
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          textStyle: AppTypography.button,
        ),
      ),

      // ── Input / TextField ───────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stone,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.forestSage, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textHint),
        labelStyle: AppTypography.body,
        errorStyle: AppTypography.supporting.copyWith(color: AppColors.error),
      ),

      // ── Divider ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // ── Dialog ──────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusDialog,
        ),
        titleTextStyle: AppTypography.sectionHeading,
        contentTextStyle: AppTypography.body,
      ),

      // ── Snackbar ────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.graphite,
        contentTextStyle: AppTypography.body.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSmall,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Chip ────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.stone,
        selectedColor: AppColors.forestSage,
        disabledColor: AppColors.disabled,
        labelStyle: AppTypography.label,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSmall,
        ),
        side: BorderSide.none,
      ),

      // ── Icon ────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.graphite,
        size: 24,
      ),

      // ── Progress Indicator ──────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.forestSage,
        linearTrackColor: AppColors.stone,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  Dark Theme
  // ──────────────────────────────────────────────────────────

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: const Color(0xFFA5CDB6), // Luminous sage
      onPrimary: AppColors.graphite,
      secondary: AppColors.softSage,
      onSecondary: AppColors.white,
      surface: const Color(0xFF1E2623),
      onSurface: const Color(0xFFEAF2ED),
      error: AppColors.error,
      onError: AppColors.white,
      outline: const Color(0xFF384E49),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      scaffoldBackgroundColor: const Color(0xFF161C19),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF161C19),
        foregroundColor: Color(0xFFEAF2ED),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1E2623),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  High Contrast Theme (accessibility)
  // ──────────────────────────────────────────────────────────

  static ThemeData get highContrast {
    return light.copyWith(
      scaffoldBackgroundColor: AppColors.highContrastBg,
      colorScheme: light.colorScheme.copyWith(
        surface: AppColors.highContrastBg,
        onSurface: AppColors.highContrastText,
      ),
      appBarTheme: light.appBarTheme.copyWith(
        backgroundColor: AppColors.highContrastBg,
        foregroundColor: AppColors.highContrastText,
      ),
    );
  }
}
