import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/language_selector.dart';

/// Settings screen.
///
/// Per DESIGN.md §5: language, text size, accessibility,
/// notifications, haptics, motion, camera/mic permissions,
/// privacy, history, account.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'en';
  bool _highContrast = false;
  bool _haptics = true;
  bool _reducedMotion = false;
  bool _historyEnabled = true;
  // TODO: Persist settings with shared_preferences via Riverpod

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
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
