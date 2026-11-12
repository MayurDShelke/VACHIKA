import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// VACHIKA typography scale.
///
/// Sourced from `docs/DESIGN.md` §3.
/// Font: Inter (via Google Fonts, with bundled fallback).
/// All sizes in logical pixels (sp-equivalent on Android).
class AppTypography {
  AppTypography._();

  static String? _fontFamily;

  /// Lazily resolved Inter font family name.
  static String get fontFamily =>
      _fontFamily ??= GoogleFonts.inter().fontFamily ?? 'Inter';

  // ── Headings ─────────────────────────────────────────────

  /// Main heading — 28-32 sp, Bold
  static TextStyle get mainHeading => GoogleFonts.inter(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
      );

  /// Screen heading — 24 sp, SemiBold
  static TextStyle get screenHeading => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  /// Section heading — 20 sp, SemiBold
  static TextStyle get sectionHeading => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.35,
      );

  /// Card heading — 16-18 sp, Medium
  static TextStyle get cardHeading => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ── Body ─────────────────────────────────────────────────

  /// Body text — 14-16 sp, Regular
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  /// Body secondary (muted)
  static TextStyle get bodySecondary => body.copyWith(
        color: AppColors.textSecondary,
      );

  // ── Button / Label ───────────────────────────────────────

  /// Button label — 15-16 sp, SemiBold
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // ── Supporting ───────────────────────────────────────────

  /// Supporting / caption — 12-14 sp, Regular
  static TextStyle get supporting => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  /// Small label — 12 sp, Medium
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: 1.3,
        letterSpacing: 0.3,
      );
}
