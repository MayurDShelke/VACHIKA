import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../theme/app_colors.dart';

/// 3D WebGL Rigged Avatar powered by Three.js (`avatar.html`).
///
/// Features:
/// - Real 3D Humanoid skeleton with articulated upper body & all 10 fingers
/// - Full 360-degree orbit rotation and zoom
/// - JavaScript bidirectional bridge syncing timeline playback, speed, play/pause
/// - Support for custom .glb rigged avatars
class ThreeDAvatarWebView extends StatefulWidget {
  final String gloss;
  final bool isPlaying;
  final double speed;
  final double height;
  final VoidCallback? onSignCompleted;

  const ThreeDAvatarWebView({
    super.key,
    required this.gloss,
    required this.isPlaying,
    required this.speed,
    this.height = 250,
    this.onSignCompleted,
  });

  @override
  State<ThreeDAvatarWebView> createState() => _ThreeDAvatarWebViewState();
}

class _ThreeDAvatarWebViewState extends State<ThreeDAvatarWebView> {
  late final WebViewController _controller;
  bool _isLoaded = false;
  String _lastGloss = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'FlutterSignChannel',
        onMessageReceived: (message) {
          try {
            final data = jsonDecode(message.message) as Map<String, dynamic>;
            if (data['event'] == 'sign_finished') {
              widget.onSignCompleted?.call();
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            if (!mounted) return;
            setState(() => _isLoaded = true);
            _syncWithSign(widget.gloss, widget.speed, widget.isPlaying);
          },
        ),
      );

    _loadHtmlAsset();
  }

  Future<void> _loadHtmlAsset() async {
    try {
      final htmlContent =
          await rootBundle.loadString('assets/avatar/avatar.html');
      await _controller.loadHtmlString(
        htmlContent,
        baseUrl: 'https://vachika.local/',
      );
    } catch (_) {
      // Fallback: load directly from asset path
      await _controller.loadFlutterAsset('assets/avatar/avatar.html');
    }
  }

  @override
  void didUpdateWidget(covariant ThreeDAvatarWebView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_isLoaded) return;

    if (oldWidget.gloss != widget.gloss ||
        oldWidget.speed != widget.speed ||
        oldWidget.isPlaying != widget.isPlaying) {
      _syncWithSign(widget.gloss, widget.speed, widget.isPlaying);
    }
  }

  void _syncWithSign(String gloss, double speed, bool isPlaying) {
    final cleanGloss = gloss.toLowerCase().replaceAll(' ', '_');

    // Sync speed
    _controller.runJavaScript('window.avatar && window.avatar.setSpeed($speed);');

    // Sync play/pause
    if (isPlaying) {
      _controller.runJavaScript('window.avatar && window.avatar.resume();');
    } else {
      _controller.runJavaScript('window.avatar && window.avatar.pause();');
    }

    // Trigger sign animation
    if (cleanGloss != _lastGloss || isPlaying) {
      _lastGloss = cleanGloss;
      _controller.runJavaScript(
        "window.avatar && window.avatar.playSign('$cleanGloss', $speed);",
      );
    }
  }

  void _resetCamera() {
    HapticFeedback.lightImpact();
    _controller.runJavaScript('window.avatar && window.avatar.resetCamera();');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A17) : const Color(0xFFF4F6F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.forestSage.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // ── Three.js 3D WebGL Canvas ────────────────────────
          WebViewWidget(controller: _controller),

          // ── Loading Placeholder while WebGL boots ───────────
          if (!_isLoaded)
            Container(
              color: isDark ? const Color(0xFF141A17) : const Color(0xFFF4F6F4),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.forestSage,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading 3D Signing Avatar…',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF9CA3AF)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Top Left: Live 3D Rigged Status ─────────────────
          Positioned(
            top: 10,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF1E2623) : Colors.white)
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF384E49)
                      : const Color(0xFFE5EAE7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
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
                          ? const Color(0xFF10B981) // Emerald
                          : const Color(0xFFF59E0B), // Amber
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '3D RIGGED • 360°',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: isDark
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Top Right: 360° Reset Camera Button ─────────────
          Positioned(
            top: 10,
            right: 12,
            child: InkWell(
              onTap: _resetCamera,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF1E2623) : Colors.white)
                      .withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF384E49)
                        : const Color(0xFFE5EAE7),
                  ),
                ),
                child: const Icon(
                  Icons.threed_rotation_rounded,
                  size: 16,
                  color: AppColors.forestSage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
