import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'isl_avatar_painter.dart';
import 'isl_avatar_pose.dart';

/// Full Interactive AI Human Avatar for Indian Sign Language.
///
/// Features:
/// - Real-time skeletal kinematics driven by ISL vocabulary
/// - Articulated arms and hands executing the exact gesture
/// - Natural breathing sway and lifelike eye blinking
/// - Smooth blending transitions between consecutive signs
/// - Focus mode toggle (Torso View vs Hand Focus)
/// - "AI SIGNER • LIVE" indicator badge
class IslHumanAvatar extends StatefulWidget {
  final String gloss;
  final bool isFingerspelled;
  final Color accentColor;
  final bool isPlaying;
  final double speed;
  final double height;

  const IslHumanAvatar({
    super.key,
    required this.gloss,
    this.isFingerspelled = false,
    this.accentColor = const Color(0xFF344C43),
    this.isPlaying = true,
    this.speed = 1.0,
    this.height = 250,
  });

  @override
  State<IslHumanAvatar> createState() => _IslHumanAvatarState();
}

class _IslHumanAvatarState extends State<IslHumanAvatar>
    with TickerProviderStateMixin {
  late final AnimationController _gestureController;
  late final AnimationController _breathingController;
  late final AnimationController _transitionController;

  AvatarPose _previousPose = AvatarPose.rest;
  AvatarPose _currentBasePose = AvatarPose.rest;

  Timer? _blinkTimer;
  double _eyeOpenState = 1.0;
  bool _handFocusMode = false;

  @override
  void initState() {
    super.initState();

    // 1. Gesture Kinematic Controller (cycles through sign motion)
    _gestureController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // 2. Subtle Natural Breathing Controller
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
      lowerBound: -1.8,
      upperBound: 1.8,
    )..repeat(reverse: true);

    // 3. Smooth Pose Transition Controller
    _transitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..value = 1.0;

    _scheduleNextBlink();
    _updateSpeed();
  }

  @override
  void didUpdateWidget(covariant IslHumanAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.speed != widget.speed) {
      _updateSpeed();
    }

    if (oldWidget.isPlaying != widget.isPlaying) {
      if (widget.isPlaying) {
        if (!_gestureController.isAnimating) _gestureController.repeat();
      } else {
        _gestureController.stop();
      }
    }

    if (oldWidget.gloss != widget.gloss ||
        oldWidget.isFingerspelled != widget.isFingerspelled) {
      // Smoothly blend from previous gesture pose to new sign
      _previousPose = _currentBasePose;
      _transitionController.forward(from: 0.0);
    }
  }

  void _updateSpeed() {
    final baseDurationMs = widget.isFingerspelled ? 1300 : 1800;
    _gestureController.duration = Duration(
      milliseconds: (baseDurationMs / widget.speed).round(),
    );
    if (widget.isPlaying && !_gestureController.isAnimating) {
      _gestureController.repeat();
    }
  }

  void _scheduleNextBlink() {
    _blinkTimer?.cancel();
    final delay = 2500 + math.Random().nextInt(2000);
    _blinkTimer = Timer(Duration(milliseconds: delay), () {
      if (!mounted) return;
      setState(() => _eyeOpenState = 0.0);
      Future.delayed(const Duration(milliseconds: 140), () {
        if (!mounted) return;
        setState(() => _eyeOpenState = 1.0);
        _scheduleNextBlink();
      });
    });
  }

  @override
  void dispose() {
    _gestureController.dispose();
    _breathingController.dispose();
    _transitionController.dispose();
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _toggleFocusMode() {
    setState(() => _handFocusMode = !_handFocusMode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A17) : const Color(0xFFF2F6F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // ── Radial Gradient Stage Lighting ─────────────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.2),
                  radius: 0.85,
                  colors: [
                    widget.accentColor.withValues(alpha: isDark ? 0.18 : 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── The Kinematic AI Avatar Canvas ──────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _gestureController,
                _breathingController,
                _transitionController,
              ]),
              builder: (context, _) {
                // Get target kinematic pose for current sign
                final targetPose = IslPoseLibrary.getPoseForSign(
                  gloss: widget.gloss,
                  t: _gestureController.value,
                  isFingerspelled: widget.isFingerspelled,
                );

                // Blend with previous pose if transitioning
                final blendT = Curves.easeOutCubic.transform(
                  _transitionController.value,
                );
                final blendedPose =
                    AvatarPose.lerp(_previousPose, targetPose, blendT);
                _currentBasePose = blendedPose;

                // Inject dynamic eye blink state
                final finalPose = AvatarPose(
                  headTilt: blendedPose.headTilt,
                  eyebrows: blendedPose.eyebrows,
                  eyeOpen: _eyeOpenState,
                  mouthSmile: blendedPose.mouthSmile,
                  rightHandTarget: blendedPose.rightHandTarget,
                  rightArmElevation: blendedPose.rightArmElevation,
                  rightElbowAngle: blendedPose.rightElbowAngle,
                  rightWristRotation: blendedPose.rightWristRotation,
                  rightHandShape: blendedPose.rightHandShape,
                  leftHandTarget: blendedPose.leftHandTarget,
                  leftArmElevation: blendedPose.leftArmElevation,
                  leftElbowAngle: blendedPose.leftElbowAngle,
                  leftWristRotation: blendedPose.leftWristRotation,
                  leftHandShape: blendedPose.leftHandShape,
                );

                return Transform.scale(
                  scale: _handFocusMode ? 1.32 : 1.0,
                  alignment: const Alignment(0.0, 0.2),
                  child: CustomPaint(
                    painter: IslAvatarPainter(
                      pose: finalPose,
                      isDark: isDark,
                      breathingOffset: _breathingController.value,
                      accentColor: widget.accentColor,
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Top Left: Live AI Signer Badge ──────────────────
          Positioned(
            top: 12,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2623).withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF384E49)
                      : const Color(0xFFE5EAE7),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isPlaying
                          ? const Color(0xFF10B981) // Emerald Green
                          : const Color(0xFFF59E0B), // Amber Paused
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isPlaying
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B))
                              .withValues(alpha: 0.6),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isPlaying ? 'AI SIGNER • LIVE' : 'AI SIGNER • PAUSED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Top Right: Focus / Zoom Toggle ──────────────────
          Positioned(
            top: 10,
            right: 12,
            child: InkWell(
              onTap: _toggleFocusMode,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2623).withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF384E49)
                        : const Color(0xFFE5EAE7),
                  ),
                ),
                child: Icon(
                  _handFocusMode
                      ? Icons.zoom_out_map_rounded
                      : Icons.zoom_in_rounded,
                  size: 16,
                  color: isDark
                      ? const Color(0xFFA5CDB6)
                      : const Color(0xFF344C43),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
