import 'package:flutter/material.dart';

/// VACHIKA design-system colour palette.
///
/// Sourced from `docs/DESIGN.md` §2.
/// Rules: no gradients, never colour alone to convey meaning,
/// keep sufficient contrast.
class AppColors {
  AppColors._();

  // ── Brand Palette ────────────────────────────────────────
  static const Color porcelain  = Color(0xFFF7F6F2); // App background
  static const Color graphite   = Color(0xFF202522); // Text, dark surfaces
  static const Color forestSage = Color(0xFF344C43); // Primary buttons, brand
  static const Color softSage   = Color(0xFFA8B5A2); // Secondary accents
  static const Color stone      = Color(0xFFE7E5DC); // Cards, inputs, dividers

  // ── Semantic Colours (always paired with icon + text) ────
  static const Color success    = Color(0xFF2E7D32);
  static const Color warning    = Color(0xFFE65100);
  static const Color error      = Color(0xFFC62828);
  static const Color info       = Color(0xFF1565C0);

  // ── Neutral helpers ──────────────────────────────────────
  static const Color white      = Color(0xFFFFFFFF);
  static const Color black      = Color(0xFF000000);
  static const Color disabled   = Color(0xFFBDBDBD);
  static const Color divider    = Color(0xFFE0E0E0);

  // ── Text on surfaces ─────────────────────────────────────
  static const Color textPrimary   = graphite;
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textOnPrimary = white;
  static const Color textHint      = Color(0xFF9E9E9E);

  // ── High-contrast overrides (accessibility) ──────────────
  static const Color highContrastBg   = black;
  static const Color highContrastText = white;
}
