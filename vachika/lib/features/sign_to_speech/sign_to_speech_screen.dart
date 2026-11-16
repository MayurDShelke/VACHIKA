import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../history/widgets/history_drawer.dart';

/// Sign to Speech screen.
///
/// Per DESIGN.md §5: camera preview with framing guide, record/stop,
/// upload status, top result with confidence, edit/correct, speak button.
/// Never shows uncertain predictions as confirmed.
class SignToSpeechScreen extends StatefulWidget {
  const SignToSpeechScreen({super.key});

  @override
  State<SignToSpeechScreen> createState() => _SignToSpeechScreenState();
}

class _SignToSpeechScreenState extends State<SignToSpeechScreen> {
  String _language = 'en';
  bool _isRecording = false;
  // TODO: Integrate camera, upload, and inference

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const HistoryDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            tooltip: 'Past History',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Sign to Speech'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Camera Preview Placeholder ─────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.graphite,
                    borderRadius: AppSpacing.borderRadiusCard,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera feed will replace this
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_rounded,
                            size: 56,
                            color: AppColors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Camera preview',
                            style: AppTypography.bodySecondary.copyWith(
                              color: AppColors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),

                      // Framing guide overlay
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FramingGuidePainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Record Button ──────────────────────────────
              PrimaryButton(
                label: _isRecording ? 'Stop Recording' : 'Start Recording',
                icon: _isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded,
                onPressed: () {
                  setState(() => _isRecording = !_isRecording);
                  // TODO: Start/stop camera recording
                },
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Result Area (placeholder) ──────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.stone,
                  borderRadius: AppSpacing.borderRadiusCard,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sign_language_rounded, color: AppColors.forestSage),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'Record a sign to see the result here.',
                        style: AppTypography.bodySecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a rounded framing guide for hands + upper body.
class _FramingGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.75,
        height: size.height * 0.80,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
