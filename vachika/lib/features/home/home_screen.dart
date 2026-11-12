import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Home screen — two primary actions + Conversation Mode.
///
/// Per DESIGN.md §5: Sign to Speech, Speech to Sign, prominent
/// Conversation Mode, optional recent activity, dictionary shortcut.
/// No statistics or promo cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: AppTypography.screenHeading.copyWith(
            color: AppColors.forestSage,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.dictionary),
            icon: const Icon(Icons.menu_book_rounded),
            tooltip: 'Dictionary',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Tagline ──────────────────────────────────
              Text(
                AppConstants.tagline,
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Primary Actions ──────────────────────────
              _ActionCard(
                icon: Icons.videocam_rounded,
                title: 'Sign to Speech',
                subtitle: 'Record a sign and hear it spoken',
                color: AppColors.forestSage,
                onTap: () => context.push(AppRoutes.signToSpeech),
              ),
              const SizedBox(height: AppSpacing.md),
              _ActionCard(
                icon: Icons.mic_rounded,
                title: 'Speech to Sign',
                subtitle: 'Speak or type to see ISL sign videos',
                color: AppColors.forestSage,
                onTap: () => context.push(AppRoutes.speechToSign),
              ),

              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),

              // ── Conversation Mode ────────────────────────
              _ActionCard(
                icon: Icons.people_rounded,
                title: 'Conversation Mode',
                subtitle: 'Two people, one phone — take turns',
                color: AppColors.softSage,
                onTap: () => context.push(AppRoutes.conversation),
                isProminent: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Action Card ───────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isProminent = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isProminent;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title: $subtitle',
      child: Material(
        color: isProminent ? color.withValues(alpha: 0.12) : AppColors.stone,
        borderRadius: AppSpacing.borderRadiusCard,
        child: InkWell(
          borderRadius: AppSpacing.borderRadiusCard,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: AppSpacing.borderRadiusSmall,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.cardHeading),
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle, style: AppTypography.supporting),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
