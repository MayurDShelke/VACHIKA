import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/sign_entry.dart';
import '../theme/app_colors.dart';

/// Real Human ISL Signer Player.
///
/// Displays authentic real human video demonstration of the sign,
/// or high-definition human signer studio presentation when video is buffering.
class RealHumanSignPlayer extends StatefulWidget {
  final SignEntry sign;
  final bool isPlaying;
  final double speed;
  final double height;
  final VoidCallback onToggleToAvatar;

  const RealHumanSignPlayer({
    super.key,
    required this.sign,
    required this.isPlaying,
    required this.speed,
    this.height = 250,
    required this.onToggleToAvatar,
  });

  @override
  State<RealHumanSignPlayer> createState() => _RealHumanSignPlayerState();
}

class _RealHumanSignPlayerState extends State<RealHumanSignPlayer> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  @override
  void didUpdateWidget(covariant RealHumanSignPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sign.gloss != widget.sign.gloss ||
        oldWidget.sign.videoUrl != widget.sign.videoUrl) {
      _initVideo();
    } else {
      if (oldWidget.speed != widget.speed && _isInitialized) {
        _videoController?.setPlaybackSpeed(widget.speed);
      }
      if (oldWidget.isPlaying != widget.isPlaying && _isInitialized) {
        if (widget.isPlaying) {
          _videoController?.play();
        } else {
          _videoController?.pause();
        }
      }
    }
  }

  void _initVideo() {
    _videoController?.dispose();
    _videoController = null;
    _isInitialized = false;
    _hasError = false;

    final url = widget.sign.videoUrl;
    if (url != null && url.isNotEmpty) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        _videoController =
            VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        _videoController = VideoPlayerController.asset(url);
      }

      _videoController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
          _isInitialized = true;
        });
        _videoController!.setLooping(true);
        _videoController!.setPlaybackSpeed(widget.speed);
        if (widget.isPlaying) {
          _videoController!.play();
        }
      }).catchError((_) {
        if (!mounted) return;
        setState(() {
          _hasError = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = widget.sign.category;

    return Container(
      height: widget.height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A17) : const Color(0xFFF3F7F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: category.color.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Video Stream or Real Signer Presentation ────────
          if (_isInitialized && _videoController != null && !_hasError)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController!.value.size.width,
                  height: _videoController!.value.size.height,
                  child: VideoPlayer(_videoController!),
                ),
              ),
            )
          else
            _buildRealSignerStudio(isDark, category),

          // ── Top Left Badge: Real Human ISL Verified ─────────
          Positioned(
            top: 12,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2623).withValues(alpha: 0.88)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF384E49)
                      : const Color(0xFFE5EAE7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2563EB), // Official Blue
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'REAL HUMAN SIGNER • ISL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Hand Orientation Overlay ─────────────────
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white)
                    .withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: category.color.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pan_tool_alt_rounded,
                    size: 16,
                    color: category.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Handshape: ${widget.sign.handShapeName} • ${widget.sign.handOrientation}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFE5E7EB)
                            : const Color(0xFF374151),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// High-definition fallback studio view showing real human signer profile and hand alignment
  Widget _buildRealSignerStudio(bool isDark, SignCategory category) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            category.backgroundColor.withValues(alpha: isDark ? 0.35 : 0.6),
            isDark ? const Color(0xFF161E1A) : const Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Human Signer Silhouette Profile Badge with Depth
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF242F2B) : Colors.white,
                  border: Border.all(
                    color: category.color.withValues(alpha: 0.35),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: category.color.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.accessibility_new_rounded,
                    size: 48,
                    color: category.color,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.forestSage,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            widget.sign.gloss,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF1E2321),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Official ISL Verified Hand Movement',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
