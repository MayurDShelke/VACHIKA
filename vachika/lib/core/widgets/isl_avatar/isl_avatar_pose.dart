import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Hand shape categories for ISL avatar gestures.
enum AvatarHandShape {
  relaxed,
  openPalm,
  fist,
  pointingIndex,
  vShape,
  pinchO,
  flatHand,
  wShape,
  yShape,
  cShape,
  lShape,
}

/// Represents the full upper-body kinematic pose of the ISL Avatar.
class AvatarPose {
  // Head & Face
  final double headTilt; // In radians
  final double eyebrows; // 0.0 (neutral) to 1.0 (raised)
  final double eyeOpen; // 0.0 (closed) to 1.0 (fully open)
  final double mouthSmile; // 0.0 to 1.0

  // Right Arm (Primary signing arm)
  // Positions are normalized offsets from the neck center (0, 0)
  // where +X is screen right, +Y is downward.
  final Offset rightHandTarget;
  final double rightArmElevation;
  final double rightElbowAngle;
  final double rightWristRotation; // In radians
  final AvatarHandShape rightHandShape;

  // Left Arm (Secondary / complementary signing arm)
  final Offset leftHandTarget;
  final double leftArmElevation;
  final double leftElbowAngle;
  final double leftWristRotation;
  final AvatarHandShape leftHandShape;

  const AvatarPose({
    this.headTilt = 0.0,
    this.eyebrows = 0.0,
    this.eyeOpen = 1.0,
    this.mouthSmile = 0.2,
    required this.rightHandTarget,
    this.rightArmElevation = 0.0,
    this.rightElbowAngle = 0.0,
    this.rightWristRotation = 0.0,
    this.rightHandShape = AvatarHandShape.relaxed,
    required this.leftHandTarget,
    this.leftArmElevation = 0.0,
    this.leftElbowAngle = 0.0,
    this.leftWristRotation = 0.0,
    this.leftHandShape = AvatarHandShape.relaxed,
  });

  /// Natural idle rest pose (hands resting at mid-torso ready to sign)
  static const AvatarPose rest = AvatarPose(
    headTilt: 0.0,
    eyebrows: 0.0,
    eyeOpen: 1.0,
    mouthSmile: 0.25,
    rightHandTarget: Offset(54, 126),
    rightArmElevation: 0.2,
    rightElbowAngle: 0.7,
    rightWristRotation: 0.1,
    rightHandShape: AvatarHandShape.relaxed,
    leftHandTarget: Offset(-54, 126),
    leftArmElevation: 0.2,
    leftElbowAngle: 0.7,
    leftWristRotation: -0.1,
    leftHandShape: AvatarHandShape.relaxed,
  );

  /// Linearly interpolate between two poses for silky-smooth motion blending.
  static AvatarPose lerp(AvatarPose a, AvatarPose b, double t) {
    return AvatarPose(
      headTilt: a.headTilt + (b.headTilt - a.headTilt) * t,
      eyebrows: a.eyebrows + (b.eyebrows - a.eyebrows) * t,
      eyeOpen: a.eyeOpen + (b.eyeOpen - a.eyeOpen) * t,
      mouthSmile: a.mouthSmile + (b.mouthSmile - a.mouthSmile) * t,
      rightHandTarget: Offset.lerp(a.rightHandTarget, b.rightHandTarget, t)!,
      rightArmElevation:
          a.rightArmElevation + (b.rightArmElevation - a.rightArmElevation) * t,
      rightElbowAngle:
          a.rightElbowAngle + (b.rightElbowAngle - a.rightElbowAngle) * t,
      rightWristRotation: a.rightWristRotation +
          (b.rightWristRotation - a.rightWristRotation) * t,
      rightHandShape: t < 0.5 ? a.rightHandShape : b.rightHandShape,
      leftHandTarget: Offset.lerp(a.leftHandTarget, b.leftHandTarget, t)!,
      leftArmElevation:
          a.leftArmElevation + (b.leftArmElevation - a.leftArmElevation) * t,
      leftElbowAngle:
          a.leftElbowAngle + (b.leftElbowAngle - a.leftElbowAngle) * t,
      leftWristRotation:
          a.leftWristRotation + (b.leftWristRotation - a.leftWristRotation) * t,
      leftHandShape: t < 0.5 ? a.leftHandShape : b.leftHandShape,
    );
  }
}

/// Library of animated poses for ISL signs and manual alphabet.
class IslPoseLibrary {
  IslPoseLibrary._();

  /// Calculates the active avatar pose for a specific sign and animation progress `t` (0.0 .. 1.0).
  static AvatarPose getPoseForSign({
    required String gloss,
    required double t,
    bool isFingerspelled = false,
  }) {
    final upper = gloss.toUpperCase();

    // If fingerspelling a letter
    if (isFingerspelled || upper.length == 1) {
      return _getFingerspellPose(upper, t);
    }

    switch (upper) {
      // ── HELLO (Wave near temple) ───────────────────────────
      case 'HELLO':
      case 'HI':
        // Right hand moves to right temple and waves side to side
        final wave = math.sin(t * math.pi * 4) * 16;
        final waveTilt = math.sin(t * math.pi * 4) * 0.25;
        return AvatarPose(
          headTilt: -0.05,
          eyebrows: 0.3,
          mouthSmile: 0.5,
          rightHandTarget: Offset(46 + wave, -32),
          rightArmElevation: 0.85,
          rightElbowAngle: 1.3,
          rightWristRotation: 0.3 + waveTilt,
          rightHandShape: AvatarHandShape.openPalm,
          leftHandTarget: const Offset(-52, 120),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── THANK-YOU (Chin to forward palm) ───────────────────
      case 'THANK-YOU':
      case 'THANKS':
        // Starts at chin (y=16), arcs forward/down to y=72
        final progress = (math.sin((t - 0.25) * math.pi * 2) + 1) / 2;
        return AvatarPose(
          headTilt: 0.08 * (1.0 - progress),
          eyebrows: 0.2,
          mouthSmile: 0.45,
          rightHandTarget: Offset(10 + progress * 24, 18 + progress * 56),
          rightArmElevation: 0.7 - progress * 0.2,
          rightElbowAngle: 1.2 - progress * 0.4,
          rightWristRotation: -0.2 + progress * 0.4,
          rightHandShape: AvatarHandShape.flatHand,
          leftHandTarget: const Offset(-52, 120),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── ME / I (Point to chest) ─────────────────────────────
      case 'ME':
      case 'MY':
        final dip = math.sin(t * math.pi * 2) * 4;
        return AvatarPose(
          headTilt: 0.04,
          eyebrows: 0.1,
          mouthSmile: 0.3,
          rightHandTarget: Offset(0, 48 + dip),
          rightArmElevation: 0.5,
          rightElbowAngle: 1.1,
          rightWristRotation: 0.1,
          rightHandShape: AvatarHandShape.pointingIndex,
          leftHandTarget: const Offset(-50, 122),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── YOU / YOUR (Point forward toward camera) ────────────
      case 'YOU':
      case 'YOUR':
        final thrust = math.sin(t * math.pi * 2) * 6;
        return AvatarPose(
          headTilt: -0.02,
          eyebrows: 0.2,
          mouthSmile: 0.35,
          rightHandTarget: Offset(26, 68 + thrust),
          rightArmElevation: 0.55,
          rightElbowAngle: 0.85,
          rightWristRotation: -0.15,
          rightHandShape: AvatarHandShape.pointingIndex,
          leftHandTarget: const Offset(-50, 122),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── SCHOOL (Both hands clap rhythmically) ────────────────
      case 'SCHOOL':
        final clap = (math.sin(t * math.pi * 4).abs()) * 18;
        return AvatarPose(
          headTilt: 0.0,
          eyebrows: 0.2,
          mouthSmile: 0.3,
          rightHandTarget: Offset(clap, 72),
          rightArmElevation: 0.55,
          rightElbowAngle: 0.9,
          rightWristRotation: 0.1,
          rightHandShape: AvatarHandShape.openPalm,
          leftHandTarget: Offset(-clap, 72),
          leftArmElevation: 0.55,
          leftElbowAngle: 0.9,
          leftWristRotation: -0.1,
          leftHandShape: AvatarHandShape.openPalm,
        );

      // ── GO (Both hands point forward and push away) ─────────
      case 'GO':
        final push = math.sin(t * math.pi * 2) * 20;
        return AvatarPose(
          headTilt: -0.05,
          eyebrows: 0.15,
          mouthSmile: 0.25,
          rightHandTarget: Offset(32, 60 - push),
          rightArmElevation: 0.6,
          rightElbowAngle: 0.75,
          rightWristRotation: -0.1,
          rightHandShape: AvatarHandShape.pointingIndex,
          leftHandTarget: Offset(-32, 60 - push),
          leftArmElevation: 0.6,
          leftElbowAngle: 0.75,
          leftWristRotation: 0.1,
          leftHandShape: AvatarHandShape.pointingIndex,
        );

      // ── COME (Beckon toward chest) ──────────────────────────
      case 'COME':
        final pull = math.sin(t * math.pi * 2) * 16;
        return AvatarPose(
          headTilt: 0.04,
          eyebrows: 0.2,
          mouthSmile: 0.35,
          rightHandTarget: Offset(24, 76 + pull),
          rightArmElevation: 0.55,
          rightElbowAngle: 1.0,
          rightWristRotation: 0.2,
          rightHandShape: AvatarHandShape.pointingIndex,
          leftHandTarget: Offset(-24, 76 + pull),
          leftArmElevation: 0.55,
          leftElbowAngle: 1.0,
          leftWristRotation: -0.2,
          leftHandShape: AvatarHandShape.pointingIndex,
        );

      // ── WANT (Palms up pull in, fingers curling) ────────────
      case 'WANT':
        final reach = (math.sin(t * math.pi * 2) + 1) * 12;
        return AvatarPose(
          headTilt: 0.03,
          eyebrows: 0.3,
          mouthSmile: 0.2,
          rightHandTarget: Offset(34, 96 - reach),
          rightArmElevation: 0.5,
          rightElbowAngle: 0.9,
          rightWristRotation: -0.3,
          rightHandShape:
              reach > 8 ? AvatarHandShape.fist : AvatarHandShape.openPalm,
          leftHandTarget: Offset(-34, 96 - reach),
          leftArmElevation: 0.5,
          leftElbowAngle: 0.9,
          leftWristRotation: 0.3,
          leftHandShape:
              reach > 8 ? AvatarHandShape.fist : AvatarHandShape.openPalm,
        );

      // ── EAT / FOOD (Fingertips to mouth) ────────────────────
      case 'EAT':
      case 'FOOD':
        final mouthTap = (math.sin(t * math.pi * 4).abs()) * 16;
        return AvatarPose(
          headTilt: 0.06,
          eyebrows: 0.1,
          mouthSmile: 0.2,
          rightHandTarget: Offset(10, 6 + mouthTap),
          rightArmElevation: 0.8,
          rightElbowAngle: 1.25,
          rightWristRotation: 0.1,
          rightHandShape: AvatarHandShape.pinchO,
          leftHandTarget: const Offset(-50, 122),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── DRINK (Mime cup tilt to mouth) ──────────────────────
      case 'DRINK':
        final tilt = math.sin(t * math.pi * 2) * 0.4;
        return AvatarPose(
          headTilt: 0.08,
          eyebrows: 0.1,
          mouthSmile: 0.25,
          rightHandTarget: const Offset(14, 10),
          rightArmElevation: 0.8,
          rightElbowAngle: 1.2,
          rightWristRotation: -0.2 + tilt,
          rightHandShape: AvatarHandShape.cShape,
          leftHandTarget: const Offset(-50, 122),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── PLEASE (Circular motion on chest) ───────────────────
      case 'PLEASE':
        final angle = t * math.pi * 2;
        final cx = math.cos(angle) * 16;
        final cy = math.sin(angle) * 16;
        return AvatarPose(
          headTilt: 0.06,
          eyebrows: 0.25,
          mouthSmile: 0.4,
          rightHandTarget: Offset(cx, 60 + cy),
          rightArmElevation: 0.5,
          rightElbowAngle: 1.1,
          rightWristRotation: 0.0,
          rightHandShape: AvatarHandShape.flatHand,
          leftHandTarget: const Offset(-50, 122),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── SORRY (Fist rub on chest) ───────────────────────────
      case 'SORRY':
        final angle = t * math.pi * 2;
        final cx = math.cos(angle) * 12;
        final cy = math.sin(angle) * 12;
        return AvatarPose(
          headTilt: 0.1,
          eyebrows: 0.4, // apologetic raised inner eyebrows
          mouthSmile: 0.1,
          rightHandTarget: Offset(cx, 62 + cy),
          rightArmElevation: 0.5,
          rightElbowAngle: 1.1,
          rightWristRotation: 0.1,
          rightHandShape: AvatarHandShape.fist,
          leftHandTarget: const Offset(-50, 122),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── WHAT (Palms up side wobble) ─────────────────────────
      case 'WHAT':
      case 'WHERE':
        final wobble = math.sin(t * math.pi * 4) * 10;
        return AvatarPose(
          headTilt: 0.08 * math.sin(t * math.pi * 2),
          eyebrows: 0.6, // Inquiring expression
          mouthSmile: 0.15,
          rightHandTarget: Offset(48 + wobble, 92),
          rightArmElevation: 0.4,
          rightElbowAngle: 0.85,
          rightWristRotation: -0.2,
          rightHandShape: AvatarHandShape.openPalm,
          leftHandTarget: Offset(-48 - wobble, 92),
          leftArmElevation: 0.4,
          leftElbowAngle: 0.85,
          leftWristRotation: 0.2,
          leftHandShape: AvatarHandShape.openPalm,
        );

      // ── LOVE (Cross fists over chest) ───────────────────────
      case 'LOVE':
        return AvatarPose(
          headTilt: 0.08,
          eyebrows: 0.2,
          mouthSmile: 0.5,
          rightHandTarget: const Offset(-16, 56),
          rightArmElevation: 0.55,
          rightElbowAngle: 1.15,
          rightWristRotation: 0.3,
          rightHandShape: AvatarHandShape.fist,
          leftHandTarget: const Offset(16, 62),
          leftArmElevation: 0.55,
          leftElbowAngle: 1.15,
          leftWristRotation: -0.3,
          leftHandShape: AvatarHandShape.fist,
        );

      // ── HELP (Fist on flat palm lifting) ────────────────────
      case 'HELP':
        final lift = (math.sin(t * math.pi * 2) + 1) * 10;
        return AvatarPose(
          headTilt: 0.03,
          eyebrows: 0.3,
          mouthSmile: 0.35,
          rightHandTarget: Offset(4, 76 - lift),
          rightArmElevation: 0.5,
          rightElbowAngle: 0.95,
          rightWristRotation: 0.0,
          rightHandShape: AvatarHandShape.fist,
          leftHandTarget: Offset(0, 86 - lift),
          leftArmElevation: 0.5,
          leftElbowAngle: 0.9,
          leftWristRotation: 0.0,
          leftHandShape: AvatarHandShape.flatHand,
        );

      // ── WATER (W shape taps chin) ───────────────────────────
      case 'WATER':
        final tap = (math.sin(t * math.pi * 4).abs()) * 12;
        return AvatarPose(
          headTilt: 0.04,
          eyebrows: 0.2,
          mouthSmile: 0.3,
          rightHandTarget: Offset(6, 12 + tap),
          rightArmElevation: 0.75,
          rightElbowAngle: 1.2,
          rightWristRotation: 0.1,
          rightHandShape: AvatarHandShape.wShape,
          leftHandTarget: const Offset(-50, 122),
          leftHandShape: AvatarHandShape.relaxed,
        );

      // ── BOOK (Hands open like book) ─────────────────────────
      case 'BOOK':
        final open = (math.sin(t * math.pi * 2) + 1) * 16;
        return AvatarPose(
          headTilt: 0.05,
          eyebrows: 0.2,
          mouthSmile: 0.35,
          rightHandTarget: Offset(6 + open, 84),
          rightArmElevation: 0.5,
          rightElbowAngle: 0.9,
          rightWristRotation: 0.2,
          rightHandShape: AvatarHandShape.flatHand,
          leftHandTarget: Offset(-6 - open, 84),
          leftArmElevation: 0.5,
          leftElbowAngle: 0.9,
          leftWristRotation: -0.2,
          leftHandShape: AvatarHandShape.flatHand,
        );

      // ── DEFAULT SIGN GESTURE ────────────────────────────────
      default:
        // Graceful expressive signing gesture
        final sway = math.sin(t * math.pi * 2) * 10;
        return AvatarPose(
          headTilt: 0.03 * math.sin(t * math.pi),
          eyebrows: 0.2,
          mouthSmile: 0.3,
          rightHandTarget: Offset(36 + sway, 76),
          rightArmElevation: 0.55,
          rightElbowAngle: 0.95,
          rightWristRotation: 0.1,
          rightHandShape: AvatarHandShape.openPalm,
          leftHandTarget: Offset(-36 - sway, 82),
          leftArmElevation: 0.5,
          leftElbowAngle: 0.9,
          leftWristRotation: -0.1,
          leftHandShape: AvatarHandShape.flatHand,
        );
    }
  }

  /// Calculates pose for fingerspelling a letter A-Z.
  static AvatarPose _getFingerspellPose(String letter, double t) {
    AvatarHandShape shape;
    switch (letter.toUpperCase()) {
      case 'A':
      case 'E':
      case 'S':
      case 'T':
      case 'M':
      case 'N':
        shape = AvatarHandShape.fist;
      case 'B':
        shape = AvatarHandShape.openPalm;
      case 'C':
      case 'O':
        shape = AvatarHandShape.cShape;
      case 'D':
      case 'G':
      case 'X':
      case 'Z':
        shape = AvatarHandShape.pointingIndex;
      case 'H':
      case 'K':
      case 'P':
      case 'U':
      case 'V':
        shape = AvatarHandShape.vShape;
      case 'L':
        shape = AvatarHandShape.lShape;
      case 'W':
        shape = AvatarHandShape.wShape;
      case 'Y':
      case 'I':
      case 'J':
        shape = AvatarHandShape.yShape;
      default:
        shape = AvatarHandShape.openPalm;
    }

    // Hand held at chest level prominently displayed to camera
    final subtleHover = math.sin(t * math.pi * 2) * 4;
    return AvatarPose(
      headTilt: 0.02,
      eyebrows: 0.2,
      mouthSmile: 0.35,
      rightHandTarget: Offset(32, 58 + subtleHover),
      rightArmElevation: 0.65,
      rightElbowAngle: 1.05,
      rightWristRotation: 0.15,
      rightHandShape: shape,
      leftHandTarget: const Offset(-52, 120),
      leftHandShape: AvatarHandShape.relaxed,
    );
  }
}
