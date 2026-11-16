import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/slide_action_slider.dart';
import '../widgets/cover_collage_header.dart';

/// Cover page / Landing screen for VACHIKA.
///
/// Features:
/// - Horizontal marquee cards continuously moving from left to right.
/// - Clean, harmonious spacing between header, typography, and slider.
/// - Large, hyper-realistic Apple Liquid Glass slider with circular glass lens puck.
/// - Zero overflow on all screen sizes and aspect ratios.
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
        // ── Brand Gradient transitioning to Moody Slate-Sage at Bottom ──
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 0.68, 1.0],
            colors: [
              Color(0xFFD6E8DE), // Fresh luminous pastel sage (top)
              Color(0xFFEAF2ED), // Soft porcelain mist (middle)
              Color(0xFF638079), // Atmospheric mineral transition
              Color(0xFF384E49), // Deep slate-sage (bottom backdrop for glass)
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

            // ── Glowing Ambient Orb 3 (Bottom Ambient Specular Glow) ──
            Positioned(
              bottom: 25,
              left: 20,
              right: 20,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  gradient: RadialGradient(
                    radius: 1.2,
                    colors: [
                      const Color(0xFF6C8C84).withValues(alpha: 0.60),
                      const Color(0xFF6C8C84).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Main Content Layout ───────────────────────────
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // 1. Diagonal cards marquee ascending from left-mid-bottom to top-right
                  const CoverCollageHeader(height: 260),

                  // 2. Middle Content (Typography & Tagline) flexibly centered
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Headline: "Welcome to VACHIKA"
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTypography.mainHeading.copyWith(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
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

                            const SizedBox(height: 12),

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

                            const SizedBox(height: 8),

                            // Supporting subtitle
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Text(
                                'Your AI companion for seamless two-way\nIndian Sign Language communication.',
                                style: AppTypography.supporting.copyWith(
                                  color: AppColors.graphite
                                      .withValues(alpha: 0.72),
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Large Apple Liquid Glass Slider docked cleanly at bottom
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      8,
                      AppSpacing.lg,
                      24,
                    ),
                    child: SlideActionSlider(
                      text: 'Slide to Sign In',
                      thumbIcon: Icons.arrow_forward_rounded,
                      sliderColor: AppColors.forestSage,
                      textColor: Colors.white,
                      isGlass: true,
                      height: 74,
                      onSlideComplete: _navigateToLogin,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
