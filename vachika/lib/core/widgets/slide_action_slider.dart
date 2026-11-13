import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// An interactive slide-to-action slider with Apple-style frosted glass effect.
///
/// Features real-time [BackdropFilter] blur, specular glass border highlights,
/// smooth drag physics, haptic feedback, and a tactile puck.
class SlideActionSlider extends StatefulWidget {
  const SlideActionSlider({
    super.key,
    required this.onSlideComplete,
    this.text = 'Slide to Sign In',
    this.sliderColor = AppColors.forestSage,
    this.backgroundColor = Colors.white,
    this.textColor = AppColors.graphite,
    this.thumbIcon = Icons.arrow_forward_rounded,
    this.height = 62,
    this.enabled = true,
    this.isGlass = true,
  });

  final VoidCallback onSlideComplete;
  final String text;
  final Color sliderColor;
  final Color backgroundColor;
  final Color textColor;
  final IconData thumbIcon;
  final double height;
  final bool enabled;
  final bool isGlass;

  @override
  State<SlideActionSlider> createState() => _SlideActionSliderState();
}

class _SlideActionSliderState extends State<SlideActionSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _resetController;
  late Animation<double> _resetAnimation;

  double _dragPosition = 0.0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _resetAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _dragPosition = _resetAnimation.value;
        });
      });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (!widget.enabled || _isCompleted) return;

    setState(() {
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxDrag) {
    if (!widget.enabled || _isCompleted) return;

    // Trigger on dragging past 75%
    if (_dragPosition >= maxDrag * 0.75) {
      setState(() {
        _dragPosition = maxDrag;
        _isCompleted = true;
      });
      HapticFeedback.mediumImpact();
      widget.onSlideComplete();

      // Reset after brief delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _dragPosition = 0.0;
            _isCompleted = false;
          });
        }
      });
    } else {
      HapticFeedback.lightImpact();
      _resetAnimation = Tween<double>(
        begin: _dragPosition,
        end: 0.0,
      ).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOutCubic),
      );
      _resetController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = widget.height - 8.0;

    return Semantics(
      button: true,
      label: widget.text,
      onTap: widget.enabled
          ? () {
              HapticFeedback.mediumImpact();
              widget.onSlideComplete();
            }
          : null,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxDrag = constraints.maxWidth - thumbSize - 8.0;
          final progress =
              maxDrag > 0 ? (_dragPosition / maxDrag).clamp(0.0, 1.0) : 0.0;

          final radius = BorderRadius.circular(widget.height / 2);

          return Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                // Soft ambient depth shadow
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                // Crisp top-light specular reflection
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: widget.isGlass
                    ? ImageFilter.blur(sigmaX: 20, sigmaY: 20)
                    : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    // Apple Liquid Glass multi-stop gradient tint
                    gradient: widget.isGlass
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.45),
                              Colors.white.withValues(alpha: 0.20),
                              Colors.white.withValues(alpha: 0.28),
                            ],
                            stops: const [0.0, 0.60, 1.0],
                          )
                        : null,
                    color: widget.isGlass ? null : widget.backgroundColor,
                    // Specular glass border highlight
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.65),
                      width: 1.4,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // ── Interactive Drag Trail (Glowing Sage Tint) ────
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        width: _dragPosition + thumbSize + 8.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                widget.sliderColor.withValues(alpha: 0.28),
                                widget.sliderColor.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: radius,
                          ),
                        ),
                      ),

                      // ── Centered Prompt Text ──────────────────────────
                      Center(
                        child: Opacity(
                          opacity: (1.0 - (progress * 1.6)).clamp(0.0, 1.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.text,
                                style: AppTypography.button.copyWith(
                                  color: widget.textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.5,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(
                                Icons.keyboard_double_arrow_right_rounded,
                                size: 20,
                                color: widget.textColor.withValues(alpha: 0.65),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Tactile Glass Puck (Sliding Thumb) ────────────
                      Positioned(
                        left: 4.0 + _dragPosition,
                        child: GestureDetector(
                          onHorizontalDragUpdate: (details) =>
                              _onHorizontalDragUpdate(details, maxDrag),
                          onHorizontalDragEnd: (details) =>
                              _onHorizontalDragEnd(details, maxDrag),
                          child: Container(
                            width: thumbSize,
                            height: thumbSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.sliderColor,
                                  Color.lerp(widget.sliderColor, Colors.black,
                                      0.25)!,
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.sliderColor
                                      .withValues(alpha: 0.40),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: _isCompleted
                                    ? const Icon(
                                        Icons.check_rounded,
                                        key: ValueKey('done'),
                                        color: AppColors.white,
                                        size: 26,
                                      )
                                    : Icon(
                                        widget.thumbIcon,
                                        key: const ValueKey('arrow'),
                                        color: AppColors.white,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
