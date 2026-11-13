import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/language_selector.dart';
import '../auth/providers/auth_provider.dart';

/// Settings screen.
///
/// Per DESIGN.md §5: language, text size, accessibility,
/// notifications, haptics, motion, camera/mic permissions,
/// privacy, history, account.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'en';
  bool _highContrast = false;
  bool _haptics = true;
  bool _reducedMotion = false;
  bool _historyEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isGuest = authState.isGuest;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          // ── Account / Profile ─────────────────────────────
          Text('Account', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.stone,
              borderRadius: AppSpacing.borderRadiusCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.forestSage,
                      child: Text(
                        (user?.name.isNotEmpty ?? false)
                            ? user!.name[0].toUpperCase()
                            : 'G',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Guest User',
                            style: AppTypography.cardHeading,
                          ),
                          Text(
                            isGuest ? 'Temporary guest session' : (user?.email ?? ''),
                            style: AppTypography.supporting,
                          ),
                        ],
                      ),
                    ),
                    if (user != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forestSage.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isGuest ? 'GUEST' : user.role.toUpperCase(),
                          style: AppTypography.label.copyWith(
                            color: AppColors.forestSage,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (isGuest) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.push(AppRoutes.login),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.forestSage),
                      ),
                      child: const Text('Sign In or Register'),
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go(AppRoutes.cover);
                        }
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: AppSpacing.xl),

          // ── Language ──────────────────────────────────────
          Text('Language', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.sm),
          LanguageSelector(
            selected: _language,
            onChanged: (lang) => setState(() => _language = lang),
          ),
          const Divider(height: AppSpacing.xl),

          // ── Accessibility ─────────────────────────────────
          Text('Accessibility', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.sm),

          _SettingsToggle(
            icon: Icons.contrast_rounded,
            title: 'High contrast',
            subtitle: 'Increase contrast for better visibility',
            value: _highContrast,
            onChanged: (v) => setState(() => _highContrast = v),
          ),
          _SettingsToggle(
            icon: Icons.vibration_rounded,
            title: 'Haptic feedback',
            subtitle: 'Vibration for turn changes and alerts',
            value: _haptics,
            onChanged: (v) => setState(() => _haptics = v),
          ),
          _SettingsToggle(
            icon: Icons.animation_rounded,
            title: 'Reduced motion',
            subtitle: 'Minimise animations throughout the app',
            value: _reducedMotion,
            onChanged: (v) => setState(() => _reducedMotion = v),
          ),
          const Divider(height: AppSpacing.xl),

          // ── Privacy ───────────────────────────────────────
          Text('Privacy', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.sm),

          _SettingsToggle(
            icon: Icons.history_rounded,
            title: 'Conversation history',
            subtitle: 'Save past sessions for later review',
            value: _historyEnabled,
            onChanged: (v) => setState(() => _historyEnabled = v),
          ),

          const SizedBox(height: AppSpacing.md),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            title: Text('Delete all history', style: AppTypography.body.copyWith(color: AppColors.error)),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
            tileColor: AppColors.stone,
            onTap: () {
              // TODO: Confirm and delete all conversations
            },
          ),

          const Divider(height: AppSpacing.xl),

          // ── About ─────────────────────────────────────────
          Text('About', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('VACHIKA v1.0.0'),
            subtitle: const Text('Every Expression Deserves a Voice.'),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
            tileColor: AppColors.stone,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Settings Toggle Tile ─────────────────────────────────────

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.forestSage),
      title: Text(title, style: AppTypography.body),
      subtitle: Text(subtitle, style: AppTypography.supporting),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.forestSage,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
    );
  }
}
