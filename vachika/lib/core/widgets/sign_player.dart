import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/models/sign_entry.dart';
import '../theme/app_colors.dart';
import 'real_human_sign_player.dart';
import 'three_d_avatar_web_view.dart';

/// Interactive Sign Player widget for sequential ISL sign playback.
///
/// Features:
/// - Auto-advance playback with configurable speed (0.5x, 0.75x, 1.0x, 1.5x)
/// - Step forward / backward, play / pause, and replay
/// - Rich visual card displaying gloss name, category, and hand gesture instructions
/// - Interactive sign timeline strip allowing direct scrub/tap to any sign
/// - Clear distinction between standard dictionary signs and letter-by-letter fingerspelling
class SignPlayer extends StatefulWidget {
  final List<SignPlaybackItem> items;
  final String originalText;
  final VoidCallback? onCompleted;

  const SignPlayer({
    super.key,
    required this.items,
    required this.originalText,
    this.onCompleted,
  });

  @override
  State<SignPlayer> createState() => _SignPlayerState();
}

class _SignPlayerState extends State<SignPlayer> {
  int _currentIndex = 0;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Timer? _playbackTimer;
  bool _showRealHuman = false;

  late final ScrollController _timelineScrollController;

  static const List<double> _availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5];

  @override
  void initState() {
    super.initState();
    _timelineScrollController = ScrollController();

    if (widget.items.isNotEmpty) {
      _startPlayback();
    }
  }

  @override
  void didUpdateWidget(covariant SignPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _stopTimer();
      _currentIndex = 0;
      if (widget.items.isNotEmpty) {
        _startPlayback();
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _timelineScrollController.dispose();
    super.dispose();
  }

  void _stopTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _startPlayback() {
    _stopTimer();
    setState(() => _isPlaying = true);
    _scheduleNextStep();
  }

  void _pausePlayback() {
    _stopTimer();
    setState(() => _isPlaying = false);
  }

  void _scheduleNextStep() {
    if (!_isPlaying || widget.items.isEmpty) return;

    // Standard duration per sign: 2200ms for dictionary sign, 1200ms for fingerspelled letter
    final currentItem = widget.items[_currentIndex];
    final baseDurationMs = currentItem.isFingerspelled ? 1300 : 2200;
    final stepDuration = Duration(
      milliseconds: (baseDurationMs / _playbackSpeed).round(),
    );

    _playbackTimer = Timer(stepDuration, () {
      if (!mounted) return;
      if (_currentIndex < widget.items.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _scrollToActiveSign();
        _scheduleNextStep();
      } else {
        setState(() => _isPlaying = false);
        widget.onCompleted?.call();
      }
    });
  }

  void _jumpTo(int index) {
    HapticFeedback.selectionClick();
    _stopTimer();
    setState(() {
      _currentIndex = index.clamp(0, widget.items.length - 1);
    });
    _scrollToActiveSign();
    if (_isPlaying) {
      _scheduleNextStep();
    }
  }

  void _stepForward() {
    if (_currentIndex < widget.items.length - 1) {
      _jumpTo(_currentIndex + 1);
    }
  }

  void _stepBackward() {
    if (_currentIndex > 0) {
      _jumpTo(_currentIndex - 1);
    }
  }

  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    if (_isPlaying) {
      _pausePlayback();
    } else {
      if (_currentIndex >= widget.items.length - 1) {
        _currentIndex = 0;
        _scrollToActiveSign();
      }
      _startPlayback();
    }
  }

  void _replay() {
    HapticFeedback.mediumImpact();
    _jumpTo(0);
    _startPlayback();
  }

  void _cycleSpeed() {
    HapticFeedback.selectionClick();
    final curIdx = _availableSpeeds.indexOf(_playbackSpeed);
    final nextIdx = (curIdx + 1) % _availableSpeeds.length;
    setState(() {
      _playbackSpeed = _availableSpeeds[nextIdx];
    });
    if (_isPlaying) {
      _startPlayback();
    }
  }

  void _scrollToActiveSign() {
    if (!_timelineScrollController.hasClients) return;
    const itemWidth = 84.0;
    final targetOffset = (_currentIndex * itemWidth) - 80.0;
    _timelineScrollController.animateTo(
      targetOffset.clamp(0.0, _timelineScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Container(
        height: 280,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F5F4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5EAE7)),
        ),
        child: const Text(
          'No signs to display',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    final currentItem = widget.items[_currentIndex];
    final sign = currentItem.sign;
    final category = sign.category;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5EAE7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header Bar: Step count & Speed selector ─────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentItem.isFingerspelled
                            ? Icons.text_fields_rounded
                            : Icons.sign_language_rounded,
                        size: 12,
                        color: AppColors.forestSage,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_currentIndex + 1}/${widget.items.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF344C43),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Hybrid Mode Switcher (3D Avatar vs Real Human) ──
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5EAE7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showRealHuman = false);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: !_showRealHuman ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: !_showRealHuman
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 3,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.person_rounded,
                                size: 12,
                                color: !_showRealHuman
                                    ? AppColors.forestSage
                                    : const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '3D',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight:
                                      !_showRealHuman ? FontWeight.w700 : FontWeight.w500,
                                  color: !_showRealHuman
                                      ? const Color(0xFF202522)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showRealHuman = true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _showRealHuman ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: _showRealHuman
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 3,
                                    )
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.videocam_rounded,
                                size: 12,
                                color: _showRealHuman
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF6B7280),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Real',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight:
                                      _showRealHuman ? FontWeight.w700 : FontWeight.w500,
                                  color: _showRealHuman
                                      ? const Color(0xFF1D4ED8)
                                      : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Speed Pill Button
                InkWell(
                  onTap: _cycleSpeed,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.forestSage.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.forestSage.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.speed_rounded,
                          size: 12,
                          color: AppColors.forestSage,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestSage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Main Sign Presentation Card ─────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    category.backgroundColor.withValues(alpha: 0.7),
                    const Color(0xFFF9FBFA),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: category.color.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              child: Column(
                children: [
                  // Fingerspelling Notification if applicable
                  if (currentItem.isFingerspelled) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF638079).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Fingerspelling: "${currentItem.parentWord}" (${(currentItem.letterIndex ?? 0) + 1}/${currentItem.totalLetters ?? 1})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF384E49),
                        ),
                      ),
                    ),
                  ],

                  // Dynamic Hybrid Stage: Real Human Signer vs 3D WebGL Rigged Avatar
                  _showRealHuman
                      ? RealHumanSignPlayer(
                          sign: sign,
                          isPlaying: _isPlaying,
                          speed: _playbackSpeed,
                          height: 250,
                          onToggleToAvatar: () =>
                              setState(() => _showRealHuman = false),
                        )
                      : ThreeDAvatarWebView(
                          key: const ValueKey('three_d_avatar_stage'),
                          gloss: sign.gloss,
                          isPlaying: _isPlaying,
                          speed: _playbackSpeed,
                          height: 250,
                        ),

                  const SizedBox(height: 14),

                  // Gloss Word in Bold Editorial Typography
                  Text(
                    sign.gloss,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: Color(0xFF1E2321),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Meaning / Translation + Category Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sign.meaning,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF55605A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category.label.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: category.color,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Handshape & Palm Orientation Clarity Badge
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: category.color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pan_tool_alt_rounded,
                          size: 13,
                          color: category.color,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${sign.handShapeName} • ${sign.handOrientation}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Step-by-step movement description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFE5EAE7),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sign.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF374151),
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Timeline Scrubbing Strip ────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              height: 46,
              child: ListView.separated(
                controller: _timelineScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.items.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  final isCurrent = index == _currentIndex;

                  return GestureDetector(
                    onTap: () => _jumpTo(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? const Color(0xFFD6E8DE)
                            : const Color(0xFFF3F5F4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF344C43)
                              : const Color(0xFFE5EAE7),
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item.sign.gloss,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                            color: isCurrent
                                ? const Color(0xFF202522)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Control Bar ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFFBFDFB),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Replay
                IconButton(
                  icon: const Icon(Icons.replay_rounded),
                  color: const Color(0xFF55605A),
                  iconSize: 22,
                  tooltip: 'Replay from start',
                  onPressed: _replay,
                ),

                // Step Previous
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded),
                  color: _currentIndex > 0
                      ? const Color(0xFF202522)
                      : const Color(0xFFD1D5DB),
                  iconSize: 28,
                  tooltip: 'Previous sign',
                  onPressed: _currentIndex > 0 ? _stepBackward : null,
                ),

                // Play / Pause FAB
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.forestSage,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.forestSage.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                // Step Next
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded),
                  color: _currentIndex < widget.items.length - 1
                      ? const Color(0xFF202522)
                      : const Color(0xFFD1D5DB),
                  iconSize: 28,
                  tooltip: 'Next sign',
                  onPressed: _currentIndex < widget.items.length - 1
                      ? _stepForward
                      : null,
                ),

                // Status or Clear
                IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  color: const Color(0xFF55605A),
                  iconSize: 20,
                  tooltip: 'Playback settings',
                  onPressed: _cycleSpeed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
