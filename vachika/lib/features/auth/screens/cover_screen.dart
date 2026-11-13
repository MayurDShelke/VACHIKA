import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/slide_action_slider.dart';
import '../providers/auth_provider.dart';
import '../widgets/cover_collage_header.dart';

/// Cover page / Landing screen for VACHIKA.
///
/// Features:
/// - Rich multi-stop ambient gradient background.
/// - Angled isometric cards collage dissolving via ShaderMask into the gradient.
/// - Prominent, well-spaced typography with the official tagline.
/// - Strictly bottom-docked slide-to-action slider.
class CoverScreen extends ConsumerStatefulWidget {
  const CoverScreen({super.key});

  @override
  ConsumerState<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends ConsumerState<CoverScreen> {
  void _navigateToLogin() {
    context.push(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // ── Rich, Clearly Visible Multi-Stop Brand Gradient ──
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.32, 0.68, 1.0],
            colors: [
              Color(0xFFC7E2D3), // Fresh pastel sage mint
              Color(0xFFDBEBE0), // Luminous jade tone
              Color(0xFFF3F6F2), // Light crisp porcelain
              Color(0xFFE9E0D0), // Warm pearl champagne ivory
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Glowing Ambient Orb 1 (Top Left) ─────────────
            Positioned(
              top: -50,
              left: -40,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA5CDB6).withValues(alpha: 0.45),
                      const Color(0xFFA5CDB6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Glowing Ambient Orb 2 (Mid Right) ────────────
            Positioned(
              top: 180,
              right: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.forestSage.withValues(alpha: 0.20),
                      AppColors.forestSage.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Glowing Ambient Orb 3 (Bottom Left) ──────────
            Positioned(
              bottom: 40,
              left: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFDECDB5).withValues(alpha: 0.40),
                      const Color(0xFFDECDB5).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Main Layout: Content + Bottom Docked Slider ───
            Column(
              children: [
                // ── Top & Middle Content (Scrollable if needed) ─
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Tilted visual collage header (fades to transparent)
                        const CoverCollageHeader(),

                        // Spacing pushing the text downward as requested
                        const SizedBox(height: 38),

                        // Typography & Branding
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            children: [
                              // "Welcome to VACHIKA"
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTypography.mainHeading.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                    height: 1.18,
                                    color: AppColors.graphite,
                                    letterSpacing: -0.5,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Welcome to\n'),
                                    TextSpan(
                                      text: AppConstants.appName,
                                      style: TextStyle(
                                        color: AppColors.forestSage,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Official Tagline
                              Text(
                                AppConstants.tagline,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.graphite,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  letterSpacing: 0.1,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: AppSpacing.xs),

                              // Supporting description
                              Text(
                                'Your AI companion for seamless two-way Indian Sign Language communication.',
                                style: AppTypography.supporting.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Bottom Docked Slider & Actions ─────────────
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xs,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: SlideActionSlider(
                      text: 'Slide to Sign In',
                      thumbIcon: Icons.arrow_forward_rounded,
                      sliderColor: AppColors.forestSage,
                      textColor: AppColors.graphite,
                      isGlass: true,
                      height: 62,
                      onSlideComplete: _navigateToLogin,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
