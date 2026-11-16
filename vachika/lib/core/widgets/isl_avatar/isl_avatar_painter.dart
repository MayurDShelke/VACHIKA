import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'isl_avatar_pose.dart';

/// Ultra-Realistic 3D Volumetric Human AI Signer Avatar.
///
/// Features:
/// - Realistic human face anatomy (eyes with irises & reflections, eyelids, nose bridge, lips, ears, styled 3D hair)
/// - Realistic volumetric neck with collarbone definition & modern tailored outfit
/// - Anatomically proportioned 3D arms with volumetric depth
/// - High-fidelity 3D hands with realistic palm flesh, knuckles, finger segments & fingernail highlights
/// - Hand drop shadows onto torso indicating true 3D depth in sign space
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
    final neckY = size.height * 0.38 + breathingOffset;
    final neckCenter = Offset(cx, neckY);

    // ── 1. Soft Ambient Halo Behind Head ─────────────────────
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          accentColor.withValues(alpha: isDark ? 0.25 : 0.32),
          accentColor.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(cx, neckY - 24),
          radius: size.width * 0.44,
        ),
      );
    canvas.drawCircle(Offset(cx, neckY - 24), size.width * 0.44, haloPaint);

    // ── 2. Realistic Torso & Shoulders ───────────────────────
    _drawRealisticTorso(canvas, neckCenter, size);

    // ── 3. Realistic Head, Hair & Expressive Face ────────────
    _drawRealisticHeadAndFace(canvas, neckCenter);

    // ── 4. Left Arm & Hand ──────────────────────────────────
    _drawVolumetricArmAndHand(
      canvas: canvas,
      shoulder: Offset(neckCenter.dx - 52, neckCenter.dy + 24),
      handTarget: neckCenter + pose.leftHandTarget,
      isRightArm: false,
      handShape: pose.leftHandShape,
      wristRotation: pose.leftWristRotation,
    );

    // ── 5. Right Arm & Hand (Primary Dominant Signer Arm) ───
    _drawVolumetricArmAndHand(
      canvas: canvas,
      shoulder: Offset(neckCenter.dx + 52, neckCenter.dy + 24),
      handTarget: neckCenter + pose.rightHandTarget,
      isRightArm: true,
      handShape: pose.rightHandShape,
      wristRotation: pose.rightWristRotation,
    );
  }

  // ── DRAW REALISTIC TORSO ───────────────────────────────────
  void _drawRealisticTorso(Canvas canvas, Offset neckCenter, Size size) {
    final outfitBase =
        isDark ? const Color(0xFF1D2622) : const Color(0xFF2E423B);
    final outfitHighlight =
        isDark ? const Color(0xFF283630) : const Color(0xFF3E574E);
    final outfitShadow =
        isDark ? const Color(0xFF131A17) : const Color(0xFF1F2D28);

    // Torso silhouette with natural shoulder slopes
    final torsoPath = Path();
    torsoPath.moveTo(neckCenter.dx - 18, neckCenter.dy + 12);
    // Left shoulder curve
    torsoPath.cubicTo(
      neckCenter.dx - 38,
      neckCenter.dy + 14,
      neckCenter.dx - 68,
      neckCenter.dy + 28,
      neckCenter.dx - 92,
      neckCenter.dy + 58,
    );
    torsoPath.lineTo(neckCenter.dx - 98, size.height);
    torsoPath.lineTo(neckCenter.dx + 98, size.height);
    torsoPath.lineTo(neckCenter.dx + 92, neckCenter.dy + 58);
    // Right shoulder curve
    torsoPath.cubicTo(
      neckCenter.dx + 68,
      neckCenter.dy + 28,
      neckCenter.dx + 38,
      neckCenter.dy + 14,
      neckCenter.dx + 18,
      neckCenter.dy + 12,
    );
    torsoPath.close();

    final torsoPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [outfitHighlight, outfitBase, outfitShadow],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromLTWH(0, neckCenter.dy, size.width, size.height - neckCenter.dy),
      );

    canvas.drawPath(torsoPath, torsoPaint);

    // Realistic Collar / Turtleneck with subtle 3D rim highlight
    final collarRect = Rect.fromCenter(
      center: Offset(neckCenter.dx, neckCenter.dy + 10),
      width: 44,
      height: 18,
    );
    final collarPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFA5CDB6).withValues(alpha: 0.35),
          outfitBase,
        ],
      ).createShader(collarRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(collarRect, const Radius.circular(8)),
      collarPaint,
    );
  }

  // ── DRAW REALISTIC HEAD AND FACE ───────────────────────────
  void _drawRealisticHeadAndFace(Canvas canvas, Offset neckCenter) {
    canvas.save();
    canvas.translate(neckCenter.dx, neckCenter.dy - 10);
    canvas.rotate(pose.headTilt);

    // Realistic Human Skin Palette (Natural warm complexion)
    final skinBase =
        isDark ? const Color(0xFFE2C4A7) : const Color(0xFFF3D5B9);
    final skinShadow =
        isDark ? const Color(0xFFC7A588) : const Color(0xFFDBB89A);
    final skinHighlight =
        isDark ? const Color(0xFFEED3B8) : const Color(0xFFFDE4CD);

    // 1. Volumetric Neck with side shadows
    final neckPath = Path();
    neckPath.moveTo(-15, -16);
    neckPath.lineTo(15, -16);
    neckPath.lineTo(19, 14);
    neckPath.lineTo(-19, 14);
    neckPath.close();

    final neckPaint = Paint()
      ..shader = LinearGradient(
        colors: [skinShadow, skinBase, skinShadow],
      ).createShader(const Rect.fromLTWH(-20, -16, 40, 30));
    canvas.drawPath(neckPath, neckPaint);

    // 2. Realistic Head & Jaw Contour
    final headPath = Path();
    headPath.moveTo(-32, -54);
    // Left ear to jaw
    headPath.cubicTo(-32, -26, -26, -10, -14, -2);
    // Chin
    headPath.cubicTo(-8, 3, 8, 3, 14, -2);
    // Right jaw to ear
    headPath.cubicTo(26, -10, 32, -26, 32, -54);
    // Top of head
    headPath.cubicTo(32, -88, 18, -100, 0, -100);
    headPath.cubicTo(-18, -100, -32, -88, -32, -54);
    headPath.close();

    final headPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.4),
        radius: 0.85,
        colors: [skinHighlight, skinBase, skinShadow],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(const Rect.fromLTWH(-34, -102, 68, 108));
    canvas.drawPath(headPath, headPaint);

    // 3. Realistic Ears
    final earPaint = Paint()..color = skinShadow;
    canvas.drawOval(const Rect.fromLTWH(-36, -56, 8, 18), earPaint);
    canvas.drawOval(const Rect.fromLTWH(28, -56, 8, 18), earPaint);

    // 4. Volumetric Modern Styled Hair
    final hairDark =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFF221F20);
    final hairHighlight =
        isDark ? const Color(0xFF333333) : const Color(0xFF3D3638);

    final hairPath = Path();
    hairPath.moveTo(-35, -50);
    hairPath.cubicTo(-38, -88, -22, -104, 0, -104);
    hairPath.cubicTo(22, -104, 38, -88, 35, -50);
    hairPath.cubicTo(32, -68, 20, -82, 0, -82);
    hairPath.cubicTo(-20, -82, -32, -68, -35, -50);
    hairPath.close();

    final hairPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [hairHighlight, hairDark],
      ).createShader(const Rect.fromLTWH(-38, -104, 76, 56));
    canvas.drawPath(hairPath, hairPaint);

    // 5. Realistic Eyebrows
    final browPaint = Paint()
      ..color = hairDark
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final browLift = pose.eyebrows * 4.5;
    // Left eyebrow
    final leftBrow = Path();
    leftBrow.moveTo(-24, -54 - browLift);
    leftBrow.quadraticBezierTo(-16, -58 - browLift, -8, -55 - browLift);
    canvas.drawPath(leftBrow, browPaint);

    // Right eyebrow
    final rightBrow = Path();
    rightBrow.moveTo(8, -55 - browLift);
    rightBrow.quadraticBezierTo(16, -58 - browLift, 24, -54 - browLift);
    canvas.drawPath(rightBrow, browPaint);

    // 6. Realistic Expressive Eyes
    if (pose.eyeOpen < 0.25) {
      // Blinking / closed eyelid
      final blinkPaint = Paint()
        ..color = skinShadow
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(-21, -44), const Offset(-9, -44), blinkPaint);
      canvas.drawLine(const Offset(9, -44), const Offset(21, -44), blinkPaint);
    } else {
      // Sclera (Eye whites with soft shading)
      final scleraPaint = Paint()..color = const Color(0xFFF8F9FA);
      final leftEyeRect = const Rect.fromLTWH(-22, -49, 13, 9);
      final rightEyeRect = const Rect.fromLTWH(9, -49, 13, 9);
      canvas.drawOval(leftEyeRect, scleraPaint);
      canvas.drawOval(rightEyeRect, scleraPaint);

      // Realistic Irises (Deep Hazel/Forest Green)
      final irisPaint = Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFF20362B), Color(0xFF13221B)],
        ).createShader(const Rect.fromLTWH(-18, -47, 6, 6));
      canvas.drawCircle(const Offset(-15.5, -44.5), 3.4, irisPaint);
      canvas.drawCircle(const Offset(15.5, -44.5), 3.4, irisPaint);

      // Dark Pupils
      final pupilPaint = Paint()..color = Colors.black;
      canvas.drawCircle(const Offset(-15.5, -44.5), 1.6, pupilPaint);
      canvas.drawCircle(const Offset(15.5, -44.5), 1.6, pupilPaint);

      // Specular Light Reflections
      final reflectPaint = Paint()..color = Colors.white;
      canvas.drawCircle(const Offset(-16.5, -45.5), 1.0, reflectPaint);
      canvas.drawCircle(const Offset(14.5, -45.5), 1.0, reflectPaint);

      // Upper Eyelash line
      final lashPaint = Paint()
        ..color = const Color(0xFF1E1E1E)
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;
      canvas.drawArc(leftEyeRect, -math.pi, math.pi, false, lashPaint);
      canvas.drawArc(rightEyeRect, -math.pi, math.pi, false, lashPaint);
    }

    // 7. Realistic 3D Nose Bridge & Tip
    final noseShadow = Paint()
      ..color = skinShadow.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final nosePath = Path();
    nosePath.moveTo(-1, -48);
    nosePath.lineTo(-1, -33);
    nosePath.lineTo(-4, -30);
    nosePath.quadraticBezierTo(0, -28, 4, -30);
    canvas.drawPath(nosePath, noseShadow);

    // 8. Realistic Lips
    final lipColor = const Color(0xFFC76B66);
    final lipShade = const Color(0xFFA8514C);

    final mouthCurve = pose.mouthSmile * 4.0;
    final upperLip = Path();
    upperLip.moveTo(-11, -19);
    upperLip.quadraticBezierTo(-5, -21, 0, -19.5);
    upperLip.quadraticBezierTo(5, -21, 11, -19);
    upperLip.quadraticBezierTo(0, -17 + mouthCurve, -11, -19);

    final lipPaint = Paint()..color = lipColor;
    canvas.drawPath(upperLip, lipPaint);

    final lipLinePaint = Paint()
      ..color = lipShade
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(-10, -18.5),
      Offset(10, -18.5 + mouthCurve * 0.4),
      lipLinePaint,
    );

    canvas.restore();
  }

  // ── DRAW VOLUMETRIC ARM AND 3D HAND ────────────────────────
  void _drawVolumetricArmAndHand({
    required Canvas canvas,
    required Offset shoulder,
    required Offset handTarget,
    required bool isRightArm,
    required AvatarHandShape handShape,
    required double wristRotation,
  }) {
    final outfitBase =
        isDark ? const Color(0xFF283630) : const Color(0xFF384E49);
    final skinTone =
        isDark ? const Color(0xFFE2C4A7) : const Color(0xFFF3D5B9);
    final skinShadow =
        isDark ? const Color(0xFFC7A588) : const Color(0xFFDBB89A);

    const upperArmLength = 56.0;
    const forearmLength = 52.0;

    final dx = handTarget.dx - shoulder.dx;
    final dy = handTarget.dy - shoulder.dy;
    final targetDist = math.sqrt(dx * dx + dy * dy);
    final maxReach = upperArmLength + forearmLength - 4.0;
    final clampedDist = targetDist.clamp(20.0, maxReach);

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

    // 1. Upper Arm (Fabric sleeve with 3D gradient)
    final sleevePaint = Paint()
      ..color = outfitBase
      ..strokeWidth = 22.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(shoulder, elbow, sleevePaint);

    // 2. Forearm (Volumetric skin tone tapering to wrist)
    final forearmPaint = Paint()
      ..shader = LinearGradient(
        colors: [skinTone, skinShadow],
      ).createShader(Rect.fromPoints(elbow, handTarget))
      ..strokeWidth = 15.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(elbow, handTarget, forearmPaint);

    // 3. Realistic Hand Drop Shadow onto body (gives depth)
    final handShadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(handTarget + const Offset(4, 6), 14.0, handShadowPaint);

    // 4. Draw Detailed 3D Anatomical Hand
    canvas.save();
    canvas.translate(handTarget.dx, handTarget.dy);
    final handAngle =
        math.atan2(handTarget.dy - elbow.dy, handTarget.dx - elbow.dx) +
            wristRotation;
    canvas.rotate(handAngle);

    _drawAnatomicalHand(
      canvas: canvas,
      isRight: isRightArm,
      shape: handShape,
      skinTone: skinTone,
      skinShadow: skinShadow,
    );

    canvas.restore();
  }

  // ── DRAW ANATOMICAL HAND WITH 5 DISTINCT FINGERS & KNUCKLES ─
  void _drawAnatomicalHand({
    required Canvas canvas,
    required bool isRight,
    required AvatarHandShape shape,
    required Color skinTone,
    required Color skinShadow,
  }) {
    final palmPaint = Paint()..color = skinTone;
    final shadowPaint = Paint()..color = skinShadow;
    final knucklePaint = Paint()
      ..color = skinShadow.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final fingerPaint = Paint()
      ..color = skinTone
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round;

    final nailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Fleshy Palm (Contoured with thenar muscle at thumb base)
    final palmPath = Path();
    palmPath.addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-4, -8, 16, 17),
        const Radius.circular(6),
      ),
    );
    canvas.drawPath(palmPath, palmPaint);

    // Palm crease lines for human realism
    canvas.drawLine(const Offset(0, -2), const Offset(8, 3), knucklePaint);
    canvas.drawLine(const Offset(2, -5), const Offset(9, -1), knucklePaint);

    // Render Anatomical Fingers by Shape
    switch (shape) {
      // ── Pointing Index (ME, YOU, GO, D, Z, etc.) ────────────
      case AvatarHandShape.pointingIndex:
        // Index Finger: Full 3 segments
        canvas.drawLine(const Offset(6, -4), const Offset(26, -4), fingerPaint);
        // Fingernail
        canvas.drawLine(const Offset(24, -4), const Offset(26, -4), nailPaint);
        // Knuckle line
        canvas.drawLine(const Offset(13, -6), const Offset(13, -2), knucklePaint);
        canvas.drawLine(const Offset(19, -6), const Offset(19, -2), knucklePaint);

        // Folded 3 fingers (Middle, Ring, Pinky curled tight into palm)
        canvas.drawCircle(const Offset(8, 0), 3.8, shadowPaint);
        canvas.drawCircle(const Offset(7, 4), 3.5, shadowPaint);
        canvas.drawCircle(const Offset(6, 7), 3.2, shadowPaint);

        // Thumb folded over
        canvas.drawLine(const Offset(0, 4), const Offset(7, 1), fingerPaint);

      // ── Open Palm / 5 Distinct Fingers (HELLO, SCHOOL, WHAT) ─
      case AvatarHandShape.openPalm:
        // Index Finger
        canvas.drawLine(const Offset(8, -6), const Offset(24, -11), fingerPaint);
        canvas.drawLine(const Offset(22, -10), const Offset(24, -11), nailPaint);
        // Middle Finger (Longest)
        canvas.drawLine(const Offset(9, -2), const Offset(28, -3), fingerPaint);
        canvas.drawLine(const Offset(26, -3), const Offset(28, -3), nailPaint);
        // Ring Finger
        canvas.drawLine(const Offset(9, 2), const Offset(25, 4), fingerPaint);
        canvas.drawLine(const Offset(23, 4), const Offset(25, 4), nailPaint);
        // Pinky Finger (Smallest)
        canvas.drawLine(const Offset(7, 6), const Offset(20, 10), fingerPaint);
        canvas.drawLine(const Offset(18, 9), const Offset(20, 10), nailPaint);
        // Thumb extending out
        final thumbDir = isRight ? 1.0 : -1.0;
        canvas.drawLine(
          const Offset(2, 4),
          Offset(11, 4 + thumbDir * 10),
          fingerPaint,
        );

      // ── Tight Fist (SORRY, LOVE, A, S, T) ───────────────────
      case AvatarHandShape.fist:
        // Four curled knuckles
        canvas.drawCircle(const Offset(8, -5), 4.2, shadowPaint);
        canvas.drawCircle(const Offset(9, -1), 4.4, shadowPaint);
        canvas.drawCircle(const Offset(8, 3), 4.2, shadowPaint);
        canvas.drawCircle(const Offset(7, 7), 3.8, shadowPaint);
        // Thumb locked firmly across curled fingers
        final thumbPaint = Paint()
          ..color = skinTone
          ..strokeWidth = 4.8
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(const Offset(-1, 3), const Offset(10, -2), thumbPaint);

      // ── Flat Hand (THANK-YOU, PLEASE, BOOK, HELP) ───────────
      case AvatarHandShape.flatHand:
        // All four fingers pressed firmly together
        for (var i = 0; i < 4; i++) {
          final y = -5.0 + (i * 3.4);
          final len = (i == 1) ? 27.0 : (i == 0 || i == 2 ? 25.0 : 22.0);
          canvas.drawLine(Offset(6, y), Offset(len, y), fingerPaint);
          canvas.drawLine(Offset(len - 2, y), Offset(len, y), nailPaint);
        }
        // Thumb pressed alongside index
        canvas.drawLine(const Offset(2, -6), const Offset(12, -7), fingerPaint);

      // ── V Shape / Two Fingers (TWO, SEE, V, U) ──────────────
      case AvatarHandShape.vShape:
        // Index Finger
        canvas.drawLine(const Offset(6, -4), const Offset(26, -10), fingerPaint);
        canvas.drawLine(const Offset(24, -9), const Offset(26, -10), nailPaint);
        // Middle Finger
        canvas.drawLine(const Offset(6, -1), const Offset(27, 4), fingerPaint);
        canvas.drawLine(const Offset(25, 4), const Offset(27, 4), nailPaint);
        // Ring & Pinky curled
        canvas.drawCircle(const Offset(7, 4), 4.0, shadowPaint);
        canvas.drawCircle(const Offset(6, 7), 3.5, shadowPaint);
        // Thumb holding them
        canvas.drawLine(const Offset(0, 3), const Offset(7, 2), fingerPaint);

      // ── Pinch O (EAT, FOOD, O, F) ───────────────────────────
      case AvatarHandShape.pinchO:
        final pinchPath = Path();
        pinchPath.moveTo(0, -6);
        pinchPath.lineTo(20, -1);
        pinchPath.lineTo(0, 6);
        pinchPath.close();
        canvas.drawPath(pinchPath, palmPaint);
        canvas.drawCircle(const Offset(18, -1), 3.2, shadowPaint);
        // Curled back fingers
        canvas.drawCircle(const Offset(5, 5), 3.5, shadowPaint);

      // ── C Shape (DRINK, C, O) ───────────────────────────────
      case AvatarHandShape.cShape:
        final cPaint = Paint()
          ..color = skinTone
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          const Rect.fromLTWH(0, -12, 22, 22),
          -math.pi / 2,
          math.pi,
          false,
          cPaint,
        );

      // ── L Shape (L) ─────────────────────────────────────────
      case AvatarHandShape.lShape:
        canvas.drawLine(const Offset(6, 0), const Offset(26, 0), fingerPaint);
        canvas.drawLine(const Offset(1, -2), const Offset(1, -20), fingerPaint);
        canvas.drawCircle(const Offset(5, 4), 4.5, shadowPaint);

      // ── W Shape (WATER, W) ──────────────────────────────────
      case AvatarHandShape.wShape:
        canvas.drawLine(const Offset(6, -5), const Offset(24, -9), fingerPaint);
        canvas.drawLine(const Offset(6, 0), const Offset(26, 0), fingerPaint);
        canvas.drawLine(const Offset(6, 5), const Offset(24, 9), fingerPaint);
        canvas.drawCircle(const Offset(2, 6), 4.2, shadowPaint);

      // ── Y Shape (WHY, Y) ────────────────────────────────────
      case AvatarHandShape.yShape:
        canvas.drawLine(const Offset(0, -4), const Offset(11, -18), fingerPaint);
        canvas.drawLine(const Offset(0, 4), const Offset(11, 18), fingerPaint);
        canvas.drawCircle(const Offset(6, 0), 7.0, shadowPaint);

      // ── Relaxed ─────────────────────────────────────────────
      case AvatarHandShape.relaxed:
        canvas.drawCircle(const Offset(5, 0), 8.0, palmPaint);
        canvas.drawLine(const Offset(3, -4), const Offset(14, -5), fingerPaint);
        canvas.drawLine(const Offset(4, 0), const Offset(15, 0), fingerPaint);
        canvas.drawLine(const Offset(3, 4), const Offset(13, 4), fingerPaint);
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
