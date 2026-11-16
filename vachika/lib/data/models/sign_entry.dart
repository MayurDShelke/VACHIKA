import 'package:flutter/material.dart';

/// Represents a single ISL sign entry in the dictionary.
class SignEntry {
  /// Unique ISL gloss identifier (uppercase).
  final String gloss;

  /// English meaning / translation.
  final String meaning;

  /// Category for color-coding and grouping.
  final SignCategory category;

  /// Human-readable description of how to perform the sign.
  final String description;

  /// Material icon code point for placeholder display.
  final IconData icon;

  /// Hand shape name (e.g., "Open 5-Hand", "Index D-Hand", "Fist S-Hand").
  final String handShapeName;

  /// Palm and hand orientation (e.g., "Palm outward towards viewer").
  final String handOrientation;

  /// Optional video demonstration URL or asset path for real human signer.
  final String? videoUrl;

  const SignEntry({
    required this.gloss,
    required this.meaning,
    required this.category,
    required this.description,
    required this.icon,
    this.handShapeName = 'Natural Handshape',
    this.handOrientation = 'Facing forward',
    this.videoUrl,
  });
}

/// Sign categories for color-coding.
enum SignCategory {
  greeting('Greeting', Color(0xFFD97706), Color(0xFFFEF3C7)),
  pronoun('Pronoun', Color(0xFF7C3AED), Color(0xFFEDE9FE)),
  verb('Verb', Color(0xFF344C43), Color(0xFFD6E8DE)),
  noun('Noun', Color(0xFF2563EB), Color(0xFFDBEAFE)),
  adjective('Adjective', Color(0xFFDC2626), Color(0xFFFEE2E2)),
  question('Question', Color(0xFF0D9488), Color(0xFFCCFBF1)),
  number('Number', Color(0xFF202522), Color(0xFFF3F4F6)),
  negation('Negation', Color(0xFFBE123C), Color(0xFFFFE4E6)),
  fingerspell('Fingerspell', Color(0xFF638079), Color(0xFFEAF2ED)),
  other('Other', Color(0xFF6B7280), Color(0xFFF9FAFB));

  final String label;
  final Color color;
  final Color backgroundColor;

  const SignCategory(this.label, this.color, this.backgroundColor);
}

/// A resolved sign ready for playback — either a dictionary sign or fingerspelled letter.
class SignPlaybackItem {
  /// The sign entry (from dictionary or generated for fingerspelling).
  final SignEntry sign;

  /// The original English word this sign represents.
  final String originalWord;

  /// Whether this is a fingerspelled letter.
  final bool isFingerspelled;

  /// If fingerspelled, the full word being spelled.
  final String? parentWord;

  /// Position index in the full word (for fingerspelling progress).
  final int? letterIndex;

  /// Total letters in the parent word (for fingerspelling progress).
  final int? totalLetters;

  const SignPlaybackItem({
    required this.sign,
    required this.originalWord,
    this.isFingerspelled = false,
    this.parentWord,
    this.letterIndex,
    this.totalLetters,
  });
}
