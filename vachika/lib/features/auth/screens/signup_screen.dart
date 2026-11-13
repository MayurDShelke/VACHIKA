import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/language_selector.dart';
import '../providers/auth_provider.dart';

/// Sign Up / Account Creation screen for VACHIKA.
class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedLanguage = 'en';
  String _selectedRole = 'deaf'; // 'deaf', 'hearing', 'learner'

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).signUp(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          preferredLanguage: _selectedLanguage,
          role: _selectedRole,
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.porcelain,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: AppTypography.mainHeading,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Personalize your VACHIKA experience and sync your conversations.',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Error Banner ────────────────────────────
                if (authState.status == AuthStatus.error &&
                    authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSmall,
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: AppTypography.supporting.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Full Name ───────────────────────────────
                AppTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'e.g. Aarav Sharma',
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Email ───────────────────────────────────
                AppTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!val.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Password ────────────────────────────────
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Create a password (min. 6 characters)',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    tooltip: _obscurePassword ? 'Show' : 'Hide',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Confirm Password ────────────────────────
                AppTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter your password',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    tooltip: _obscureConfirmPassword ? 'Show' : 'Hide',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Preferred Language ──────────────────────
                Text(
                  'Preferred Language',
                  style: AppTypography.cardHeading.copyWith(fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Used for translation and speech output',
                  style: AppTypography.supporting,
                ),
                const SizedBox(height: AppSpacing.sm),
                LanguageSelector(
                  selected: _selectedLanguage,
                  onChanged: (lang) => setState(() => _selectedLanguage = lang),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Primary Communication Role ──────────────
                Text(
                  'I primarily use VACHIKA as',
                  style: AppTypography.cardHeading.copyWith(fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Helps configure the default screen order for you',
                  style: AppTypography.supporting,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _RoleChoiceChip(
                      icon: Icons.sign_language_rounded,
                      label: 'Deaf / Hard of Hearing',
                      isSelected: _selectedRole == 'deaf',
                      onSelected: () => setState(() => _selectedRole = 'deaf'),
                    ),
                    _RoleChoiceChip(
                      icon: Icons.record_voice_over_rounded,
                      label: 'Hearing Person',
                      isSelected: _selectedRole == 'hearing',
                      onSelected: () =>
                          setState(() => _selectedRole = 'hearing'),
                    ),
                    _RoleChoiceChip(
                      icon: Icons.school_rounded,
                      label: 'Educator / Learner',
                      isSelected: _selectedRole == 'learner',
                      onSelected: () =>
                          setState(() => _selectedRole = 'learner'),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Privacy Assurance ───────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.stone.withValues(alpha: 0.5),
                    borderRadius: AppSpacing.borderRadiusSmall,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppColors.forestSage, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Privacy guarantee: Video clips & audio are processed strictly in memory and deleted immediately.',
                          style: AppTypography.supporting.copyWith(
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── Create Account Button ───────────────────
                PrimaryButton(
                  label: 'Create Account',
                  icon: Icons.person_add_rounded,
                  isLoading: isLoading,
                  onPressed: _handleSignUp,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Existing Account Link ───────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.supporting,
                    ),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Sign In',
                        style: AppTypography.supporting.copyWith(
                          color: AppColors.forestSage,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChoiceChip extends StatelessWidget {
  const _RoleChoiceChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? AppColors.white : AppColors.forestSage,
      ),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.forestSage,
      labelStyle: AppTypography.label.copyWith(
        color: isSelected ? AppColors.white : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSmall,
      ),
      showCheckmark: false,
    );
  }
}
