import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'isl_avatar_pose.dart';

/// Custom Painter that renders the 2.5D Human AI Signer Avatar.
///
/// Draws:
/// - Luminous backlit stage
/// - Head, hair, facial expressions (eyes blink, eyebrows lift, mouth moves)
/// - Modern stylized outfit (Forest Sage collar & upper body)
/// - Left & Right articulated arms with inverse kinematics
/// - High-fidelity hands with dynamic finger positioning
class IslAvatarPainter extends CustomPainter {
  final AvatarPose pose;
  final bool isDark;
  final double breathingOffset;
  final Color accentColor;

  const IslAvatarPainter({
    required this.pose,
    required this.isDark,
    required this.breathingOffset,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Anchor neck / center of chest
    final neckY = size.height * 0.36 + breathingOffset;
    final neckCenter = Offset(cx, neckY);

    // ── 1. Soft Ambient Halo Behind Avatar ───────────────────
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: isDark ? 0.22 : 0.35),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, neckY - 20), radius: size.width * 0.46),
      );
    canvas.drawCircle(Offset(cx, neckY - 20), size.width * 0.46, haloPaint);

    // ── 2. Torso / Outfit ───────────────────────────────────
    _drawTorso(canvas, neckCenter, size);

    // ── 3. Head, Hair & Facial Features ─────────────────────
    _drawHeadAndFace(canvas, neckCenter);

    // ── 4. Arms & Hands ─────────────────────────────────────
    // Draw left arm (behind or to left)
    _drawArmAndHand(
      canvas: canvas,
      shoulder: Offset(neckCenter.dx - 48, neckCenter.dy + 20),
      handTarget: neckCenter + pose.leftHandTarget,
      isRightArm: false,
      handShape: pose.leftHandShape,
      wristRotation: pose.leftWristRotation,
    );

    // Draw right arm (prominent signing arm)
    _drawArmAndHand(
      canvas: canvas,
      shoulder: Offset(neckCenter.dx + 48, neckCenter.dy + 20),
      handTarget: neckCenter + pose.rightHandTarget,
      isRightArm: true,
      handShape: pose.rightHandShape,
      wristRotation: pose.rightWristRotation,
    );
  }

  // ── DRAW TORSO ─────────────────────────────────────────────
  void _drawTorso(Canvas canvas, Offset neckCenter, Size size) {
    final outfitColor =
        isDark ? const Color(0xFF1E2824) : const Color(0xFF344C43);
    final outfitShadow =
        isDark ? const Color(0xFF151C19) : const Color(0xFF263731);

    final torsoPath = Path();
    torsoPath.moveTo(neckCenter.dx - 18, neckCenter.dy + 8);
    // Left shoulder slope
    torsoPath.cubicTo(
      neckCenter.dx - 38,
      neckCenter.dy + 12,
      neckCenter.dx - 64,
      neckCenter.dy + 26,
      neckCenter.dx - 82,
      neckCenter.dy + 56,
    );
    // Left torso side down
    torsoPath.lineTo(neckCenter.dx - 90, size.height);
    // Bottom
    torsoPath.lineTo(neckCenter.dx + 90, size.height);
    // Right torso side up
    torsoPath.lineTo(neckCenter.dx + 82, neckCenter.dy + 56);
    // Right shoulder slope
    torsoPath.cubicTo(
      neckCenter.dx + 64,
      neckCenter.dy + 26,
      neckCenter.dx + 38,
      neckCenter.dy + 12,
      neckCenter.dx + 18,
      neckCenter.dy + 8,
    );
    torsoPath.close();

    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [outfitColor, outfitShadow],
      ).createShader(Rect.fromLTWH(0, neckCenter.dy, size.width, size.height));

    canvas.drawPath(torsoPath, torsoPaint);

    // Elegant Collar / Lapel line
    final collarPaint = Paint()
      ..color = const Color(0xFFA5CDB6).withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final collarPath = Path();
    collarPath.moveTo(neckCenter.dx - 18, neckCenter.dy + 8);
    collarPath.lineTo(neckCenter.dx, neckCenter.dy + 34);
    collarPath.lineTo(neckCenter.dx + 18, neckCenter.dy + 8);
    canvas.drawPath(collarPath, collarPaint);
  }

  // ── DRAW HEAD AND FACE ─────────────────────────────────────
  void _drawHeadAndFace(Canvas canvas, Offset neckCenter) {
    canvas.save();
    canvas.translate(neckCenter.dx, neckCenter.dy - 12);
    canvas.rotate(pose.headTilt);

    // Neck
    final skinTone = isDark ? const Color(0xFFE2C4A7) : const Color(0xFFF3D5B9);
    final skinShadow = isDark ? const Color(0xFFCAAA8E) : const Color(0xFFDCBEA3);

    final neckPaint = Paint()..color = skinShadow;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-14, -14, 28, 28),
        const Radius.circular(8),
      ),
      neckPaint,
    );

    // Head Base Oval
    final headRect = const Rect.fromLTWH(-32, -88, 64, 82);
    final headPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [skinTone, skinShadow],
      ).createShader(headRect);

    canvas.drawOval(headRect, headPaint);

    // Ears
    final earPaint = Paint()..color = skinShadow;
    canvas.drawOval(const Rect.fromLTWH(-37, -56, 10, 16), earPaint);
    canvas.drawOval(const Rect.fromLTWH(27, -56, 10, 16), earPaint);

    // Hair (Modern chic silhouette with glossy volume)
    final hairColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFF231F20);
    final hairPaint = Paint()..color = hairColor;

    final hairPath = Path();
    hairPath.moveTo(-35, -54);
    hairPath.cubicTo(-38, -88, -20, -104, 0, -104);
    hairPath.cubicTo(20, -104, 38, -88, 35, -54);
    hairPath.cubicTo(32, -68, 22, -82, 4, -84);
    hairPath.cubicTo(-14, -84, -28, -72, -35, -54);
    hairPath.close();
    canvas.drawPath(hairPath, hairPaint);

    // Side hair sweeps
    canvas.drawOval(const Rect.fromLTWH(-36, -80, 16, 32), hairPaint);
    canvas.drawOval(const Rect.fromLTWH(20, -80, 16, 32), hairPaint);

    // Eyebrows (Dynamic lift based on pose.eyebrows)
    final browPaint = Paint()
      ..color = hairColor
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final browLift = pose.eyebrows * 4.5;
    // Left eyebrow
    canvas.drawLine(
      Offset(-22, -54 - browLift),
      Offset(-8, -56 - browLift),
      browPaint,
    );
    // Right eyebrow
    canvas.drawLine(
      Offset(8, -56 - browLift),
      Offset(22, -54 - browLift),
      browPaint,
    );

    // Eyes (Animated Blinking)
    final eyePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0;

    if (pose.eyeOpen < 0.2) {
      // Closed / Blinking eye line
      canvas.drawLine(const Offset(-20, -44), const Offset(-10, -44), eyePaint);
      canvas.drawLine(const Offset(10, -44), const Offset(20, -44), eyePaint);
    } else {
      // Open Almond Eyes
      final leftEyeRect = const Rect.fromLTWH(-22, -49, 12, 10);
      final rightEyeRect = const Rect.fromLTWH(10, -49, 12, 10);

      final scleraPaint = Paint()..color = Colors.white;
      canvas.drawOval(leftEyeRect, scleraPaint);
      canvas.drawOval(rightEyeRect, scleraPaint);

      // Irises
      final irisPaint = Paint()..color = const Color(0xFF2C3E35);
      canvas.drawCircle(const Offset(-16, -44), 3.4, irisPaint);
      canvas.drawCircle(const Offset(16, -44), 3.4, irisPaint);

      // Eye reflections
      final reflectPaint = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(-17, -45), 1.2, reflectPaint);
      canvas.drawCircle(const Offset(15, -45), 1.2, reflectPaint);
    }

    // Nose
    final nosePaint = Paint()
      ..color = skinShadow.withValues(alpha: 0.9)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final nosePath = Path();
    nosePath.moveTo(0, -46);
    nosePath.lineTo(1, -34);
    nosePath.lineTo(-3, -32);
    canvas.drawPath(nosePath, nosePaint);

    // Mouth / Smile
    final mouthPaint = Paint()
      ..color = const Color(0xFFC76B66)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final mouthCurve = pose.mouthSmile * 4.0;
    final mouthPath = Path();
    mouthPath.moveTo(-10, -20);
    mouthPath.quadraticBezierTo(0, -20 + mouthCurve, 10, -20);
    canvas.drawPath(mouthPath, mouthPaint);

    canvas.restore();
  }

  // ── DRAW ARTICULATED ARM AND HAND ──────────────────────────
  void _drawArmAndHand({
    required Canvas canvas,
    required Offset shoulder,
    required Offset handTarget,
    required bool isRightArm,
    required AvatarHandShape handShape,
    required double wristRotation,
  }) {
    final outfitColor =
        isDark ? const Color(0xFF283630) : const Color(0xFF384E49);
    final skinTone = isDark ? const Color(0xFFE2C4A7) : const Color(0xFFF3D5B9);
    final skinShadow = isDark ? const Color(0xFFCAAA8E) : const Color(0xFFDCBEA3);

    // Inverse Kinematics (2-bone arm: Upper arm + Forearm)
    const upperArmLength = 54.0;
    const forearmLength = 50.0;

    final dx = handTarget.dx - shoulder.dx;
    final dy = handTarget.dy - shoulder.dy;
    final targetDist = math.sqrt(dx * dx + dy * dy);

    // Clamp distance to arm span
    final maxReach = upperArmLength + forearmLength - 4.0;
    final clampedDist = targetDist.clamp(20.0, maxReach);

    // Law of cosines for elbow angle
    final cosElbow = (upperArmLength * upperArmLength +
            forearmLength * forearmLength -
            clampedDist * clampedDist) /
        (2 * upperArmLength * forearmLength);
    final elbowAngle = math.acos(cosElbow.clamp(-1.0, 1.0));

    final baseAngle = math.atan2(dy, dx);
    final cosBase = (upperArmLength * upperArmLength +
            clampedDist * clampedDist -
            forearmLength * forearmLength) /
        (2 * upperArmLength * clampedDist);
    final shoulderAngle =
        baseAngle + (isRightArm ? 1 : -1) * math.acos(cosBase.clamp(-1.0, 1.0));

    final elbow = Offset(
      shoulder.dx + math.cos(shoulderAngle) * upperArmLength,
      shoulder.dy + math.sin(shoulderAngle) * upperArmLength,
    );

    // 1. Draw Upper Arm (Sleeve)
    final sleevePaint = Paint()
      ..color = outfitColor
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(shoulder, elbow, sleevePaint);

    // 2. Draw Forearm
    final armPaint = Paint()
      ..color = skinTone
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(elbow, handTarget, armPaint);

    // 3. Draw Articulated Hand at handTarget
    canvas.save();
    canvas.translate(handTarget.dx, handTarget.dy);
    // Orient hand along forearm angle + wristRotation
    final handAngle =
        math.atan2(handTarget.dy - elbow.dy, handTarget.dx - elbow.dx) +
            wristRotation;
    canvas.rotate(handAngle);

    _drawDetailedHand(
      canvas: canvas,
      isRight: isRightArm,
      shape: handShape,
      skinTone: skinTone,
      skinShadow: skinShadow,
    );

    canvas.restore();
  }

  // ── DRAW DETAILED HAND WITH INDIVIDUAL FINGERS ─────────────
  void _drawDetailedHand({
    required Canvas canvas,
    required bool isRight,
    required AvatarHandShape shape,
    required Color skinTone,
    required Color skinShadow,
  }) {
    final handBasePaint = Paint()..color = skinTone;
    final shadowPaint = Paint()..color = skinShadow;
    final fingerPaint = Paint()
      ..color = skinTone
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;

    // Palm base circle
    canvas.drawCircle(Offset.zero, 8.5, handBasePaint);
    canvas.drawCircle(const Offset(0, 2), 7.0, shadowPaint.withValues(alpha: 0.3));

    // Specific Hand Shapes
    switch (shape) {
      // ── Pointing Index Finger (ME, YOU, GO, D, Z, etc.) ────
      case AvatarHandShape.pointingIndex:
        // Index finger extended straight out
        canvas.drawLine(const Offset(4, -2), const Offset(24, -2), fingerPaint);
        // Thumb tucked
        canvas.drawCircle(const Offset(2, 5), 3.5, handBasePaint);
        // Curled other fingers (fist bump)
        canvas.drawOval(const Rect.fromLTWH(0, -6, 8, 12), shadowPaint);

      // ── Open Palm / Five Fingers (HELLO, SCHOOL, B, WHAT) ──
      case AvatarHandShape.openPalm:
        // 4 fingers spread
        canvas.drawLine(const Offset(4, -6), const Offset(20, -10), fingerPaint); // Index
        canvas.drawLine(const Offset(6, -2), const Offset(23, -3), fingerPaint); // Middle
        canvas.drawLine(const Offset(6, 2), const Offset(21, 4), fingerPaint); // Ring
        canvas.drawLine(const Offset(4, 6), const Offset(17, 10), fingerPaint); // Pinky
        // Thumb extended outward
        final thumbY = isRight ? 8.0 : -8.0;
        canvas.drawLine(Offset(0, thumbY), Offset(10, thumbY * 1.5), fingerPaint);

      // ── Fist / S / A Handshape (SORRY, LOVE, S, A, T) ──────
      case AvatarHandShape.fist:
        // Tight closed fist
        canvas.drawCircle(const Offset(4, 0), 9.0, handBasePaint);
        canvas.drawOval(const Rect.fromLTWH(2, -5, 6, 10), shadowPaint);
        // Thumb crossed over
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, -4, 9, 7),
            const Radius.circular(3),
          ),
          handBasePaint,
        );

      // ── Flat Hand (THANK-YOU, PLEASE, BOOK, HELP) ──────────
      case AvatarHandShape.flatHand:
        // Fingers straight together like a paddle
        canvas.drawLine(const Offset(4, -4), const Offset(22, -4), fingerPaint);
        canvas.drawLine(const Offset(5, -1), const Offset(23, -1), fingerPaint);
        canvas.drawLine(const Offset(5, 2), const Offset(22, 2), fingerPaint);
        canvas.drawLine(const Offset(4, 5), const Offset(19, 5), fingerPaint);
        // Thumb along index
        canvas.drawLine(const Offset(0, -5), const Offset(12, -7), fingerPaint);

      // ── V Shape / Two Fingers (SEE, TWO, V, U, H) ──────────
      case AvatarHandShape.vShape:
        // Index and Middle in V
        canvas.drawLine(const Offset(4, -4), const Offset(22, -9), fingerPaint);
        canvas.drawLine(const Offset(4, 0), const Offset(22, 5), fingerPaint);
        // Thumb holding ring & pinky down
        canvas.drawCircle(const Offset(2, 4), 4.5, shadowPaint);

      // ── Pinch O / Small Grip (EAT, FOOD, O, F) ─────────────
      case AvatarHandShape.pinchO:
        // Fingertips meet thumb forming a teardrop/point
        final pinchPath = Path();
        pinchPath.moveTo(0, -5);
        pinchPath.lineTo(16, 0);
        pinchPath.lineTo(0, 5);
        pinchPath.close();
        canvas.drawPath(pinchPath, handBasePaint);
        canvas.drawCircle(const Offset(14, 0), 2.5, shadowPaint);

      // ── C Shape (DRINK, C, O) ──────────────────────────────
      case AvatarHandShape.cShape:
        final cPath = Path();
        cPath.addArc(const Rect.fromLTWH(-2, -10, 20, 20), -math.pi / 2, math.pi);
        final cPaint = Paint()
          ..color = skinTone
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(cPath, cPaint);

      // ── L Shape (L) ────────────────────────────────────────
      case AvatarHandShape.lShape:
        // Index pointing straight
        canvas.drawLine(const Offset(2, 0), const Offset(22, 0), fingerPaint);
        // Thumb pointing up 90 deg
        canvas.drawLine(const Offset(0, 0), const Offset(0, -18), fingerPaint);
        // Other 3 curled
        canvas.drawCircle(const Offset(2, 4), 4.0, shadowPaint);

      // ── W Shape (WATER, W) ─────────────────────────────────
      case AvatarHandShape.wShape:
        // 3 fingers extended (Index, Middle, Ring)
        canvas.drawLine(const Offset(4, -5), const Offset(21, -8), fingerPaint);
        canvas.drawLine(const Offset(4, 0), const Offset(22, 0), fingerPaint);
        canvas.drawLine(const Offset(4, 5), const Offset(21, 8), fingerPaint);
        // Thumb on pinky
        canvas.drawCircle(const Offset(0, 6), 4.0, shadowPaint);

      // ── Y Shape (WHY, PHONE, Y) ────────────────────────────
      case AvatarHandShape.yShape:
        // Thumb and pinky extended out
        canvas.drawLine(const Offset(0, -4), const Offset(10, -16), fingerPaint);
        canvas.drawLine(const Offset(0, 4), const Offset(10, 16), fingerPaint);
        // Middle 3 curled
        canvas.drawCircle(const Offset(4, 0), 6.5, shadowPaint);

      // ── Relaxed / Default ──────────────────────────────────
      case AvatarHandShape.relaxed:
      default:
        canvas.drawCircle(const Offset(4, 0), 7.5, handBasePaint);
        canvas.drawLine(const Offset(2, -3), const Offset(12, -4), fingerPaint);
        canvas.drawLine(const Offset(2, 0), const Offset(13, 0), fingerPaint);
        canvas.drawLine(const Offset(2, 3), const Offset(11, 3), fingerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant IslAvatarPainter oldDelegate) {
    return oldDelegate.pose != pose ||
        oldDelegate.breathingOffset != breathingOffset ||
        oldDelegate.isDark != isDark ||
        oldDelegate.accentColor != accentColor;
  }
}
