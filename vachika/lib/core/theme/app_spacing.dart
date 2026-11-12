import 'package:flutter/material.dart';

/// VACHIKA spacing and radius tokens.
///
/// Sourced from `docs/DESIGN.md` §3.
/// 8-pt base grid. Radius rules: buttons/inputs 12, cards 16,
/// dialogs 20, small elements 8.
class AppSpacing {
  AppSpacing._();

  // ── Spacing (8-pt grid) ──────────────────────────────────
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 40;

  // ── Screen padding ───────────────────────────────────────
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: md);

  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: md);

  // ── Radius ───────────────────────────────────────────────
  static const double radiusSmall  = 8;
  static const double radiusButton = 12;
  static const double radiusInput  = 12;
  static const double radiusCard   = 16;
  static const double radiusDialog = 20;

  static BorderRadius get borderRadiusSmall  => BorderRadius.circular(radiusSmall);
  static BorderRadius get borderRadiusButton => BorderRadius.circular(radiusButton);
  static BorderRadius get borderRadiusInput  => BorderRadius.circular(radiusInput);
  static BorderRadius get borderRadiusCard   => BorderRadius.circular(radiusCard);
  static BorderRadius get borderRadiusDialog => BorderRadius.circular(radiusDialog);

  // ── Touch targets (≥ 48 dp) ──────────────────────────────
  static const double minTouchTarget = 48;

  // ── Common gaps (for Gap widget) ─────────────────────────
  static const double gapXs  = xs;
  static const double gapSm  = sm;
  static const double gapMd  = md;
  static const double gapLg  = lg;
  static const double gapXl  = xl;
  static const double gapXxl = xxl;
}
