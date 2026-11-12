import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Language selector chip row for English, Hindi, Marathi.
///
/// Provides visual + text indicators (never colour alone).
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  static const _languages = [
    ('en', 'English'),
    ('hi', 'हिन्दी'),
    ('mr', 'मराठी'),
  ];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Language selector',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _languages.map((lang) {
          final isSelected = lang.$1 == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(lang.$2),
              selected: isSelected,
              onSelected: (_) => onChanged(lang.$1),
              selectedColor: AppColors.forestSage,
              labelStyle: AppTypography.label.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.borderRadiusSmall,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
