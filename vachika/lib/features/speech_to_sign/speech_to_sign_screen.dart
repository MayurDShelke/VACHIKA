import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/language_selector.dart';

/// Speech to Sign screen.
///
/// Per DESIGN.md §5: large mic button, text input alternative,
/// editable transcript, language selector, sign video player,
/// "Sign unavailable" shown clearly for missing words.
class SpeechToSignScreen extends StatefulWidget {
  const SpeechToSignScreen({super.key});

  @override
  State<SpeechToSignScreen> createState() => _SpeechToSignScreenState();
}

class _SpeechToSignScreenState extends State<SpeechToSignScreen> {
  String _language = 'en';
  bool _isListening = false;
  final _textController = TextEditingController();
  // TODO: Integrate audio recording, transcription, and video player

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech to Sign')),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Language Selector ──────────────────────────
              LanguageSelector(
                selected: _language,
                onChanged: (lang) => setState(() => _language = lang),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Mic Button ─────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _isListening = !_isListening);
                    // TODO: Start/stop audio recording
                  },
                  child: Semantics(
                    button: true,
                    label: _isListening ? 'Stop listening' : 'Start listening',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? AppColors.error
                            : AppColors.forestSage,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        color: AppColors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  _isListening ? 'Listening…' : 'Tap to speak',
                  style: AppTypography.supporting,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Or Type ────────────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text('or type', style: AppTypography.supporting),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              AppTextField(
                controller: _textController,
                hintText: 'Type your message…',
                prefixIcon: Icons.keyboard_rounded,
                maxLines: 2,
                textInputAction: TextInputAction.send,
                semanticsLabel: 'Text input for sign translation',
                onSubmitted: (_) {
                  // TODO: Send text to translation service
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Video Output Placeholder ───────────────────
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.stone,
                    borderRadius: AppSpacing.borderRadiusCard,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 56,
                          color: AppColors.softSage,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sign videos will appear here',
                          style: AppTypography.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
