import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/primary_button.dart';
import '../history/widgets/history_drawer.dart';

/// Conversation Mode screen.
///
/// Per DESIGN.md §5: two labelled participants (Hearing, Deaf),
/// visual + haptic turn indicator, chronological transcript,
/// only one input active at a time.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  bool _isDeafTurn = true;
  final List<_Message> _messages = [];
  // TODO: Integrate camera, mic, and backend API

  void _switchTurn() {
    setState(() => _isDeafTurn = !_isDeafTurn);
    // TODO: Haptic feedback
  }

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
        title: const Text('Conversation Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Switch turn',
            onPressed: _switchTurn,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Turn Indicator ────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: _isDeafTurn
                  ? AppColors.forestSage.withValues(alpha: 0.12)
                  : AppColors.softSage.withValues(alpha: 0.25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDeafTurn
                        ? Icons.sign_language_rounded
                        : Icons.mic_rounded,
                    color: AppColors.forestSage,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _isDeafTurn ? 'Deaf participant\'s turn' : 'Hearing participant\'s turn',
                    style: AppTypography.label.copyWith(
                      color: AppColors.forestSage,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // ── Transcript ───────────────────────────────────
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'Start a conversation.\nMessages will appear here.',
                        style: AppTypography.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      padding: AppSpacing.screenPadding,
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final msg = _messages[i];
                        return _MessageBubble(message: msg);
                      },
                    ),
            ),

            // ── Action Button ────────────────────────────────
            Padding(
              padding: AppSpacing.screenPadding,
              child: PrimaryButton(
                label: _isDeafTurn ? 'Record Sign' : 'Record Speech',
                icon: _isDeafTurn
                    ? Icons.videocam_rounded
                    : Icons.mic_rounded,
                onPressed: () {
                  // TODO: Open camera or mic based on turn
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────

class _Message {
  final String participant; // "deaf" | "hearing"
  final String text;
  final String timestamp;

  const _Message({
    required this.participant,
    required this.text,
    required this.timestamp,
  });
}

// ── Bubble Widget ─────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final isDeaf = message.participant == 'deaf';
    return Align(
      alignment: isDeaf ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isDeaf ? AppColors.stone : AppColors.forestSage.withValues(alpha: 0.12),
          borderRadius: AppSpacing.borderRadiusCard,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isDeaf ? '🤟 Deaf' : '🗣️ Hearing',
              style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(message.text, style: AppTypography.body),
          ],
        ),
      ),
    );
  }
}
