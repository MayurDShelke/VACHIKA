import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/auth_provider.dart';

/// Sign Up Screen for VACHIKA.
///
/// Features:
/// - Same splash screen brand gradient and ambient lighting orbs.
/// - Official VACHIKA logo badge at top center.
/// - Direct Google & X (Twitter) social sign-in buttons side-by-side.
/// - Crystal-clear, high-contrast frosted white card inputs with live validation.
/// - Glowing Forest Sage pill action button.
/// - Balanced vertical layout with anchored trust badge and footer.
/// - Full integration with Riverpod AuthNotifier & Firebase Authentication.
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

  bool _obscurePassword = true;
  bool _agreedToTerms = true;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
    if (_isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.graphite,
          content: const Text(
            'Please accept the Terms & Conditions to proceed.',
            style: TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref.read(authNotifierProvider.notifier).signUp(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          preferredLanguage: 'en',
          role: 'deaf',
        );

    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success =
        await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _handleTwitterSignIn() async {
    final success =
        await ref.read(authNotifierProvider.notifier).signInWithTwitter();
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        // ── Same Brand Gradient from Cover / Splash Page ──
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 0.68, 1.0],
            colors: [
              Color(0xFFD6E8DE), // Fresh luminous pastel sage (top)
              Color(0xFFEAF2ED), // Soft porcelain mist (middle)
              Color(0xFF638079), // Atmospheric mineral transition
              Color(0xFF384E49), // Deep slate-sage (bottom)
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Glowing Ambient Orb 1 (Top Left) ─────────────
            Positioned(
              top: -60,
              left: -50,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA5CDB6).withValues(alpha: 0.45),
                      const Color(0xFFA5CDB6).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Glowing Ambient Orb 2 (Mid Right) ────────────
            Positioned(
              top: 200,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.forestSage.withValues(alpha: 0.20),
                      AppColors.forestSage.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Main Content Layout ───────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // ── Top Navigation Bar (Back Button) ──────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.65),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.90),
                                width: 1.4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: AppColors.graphite,
                              size: 16,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  // ── Form Body with Balanced Vertical Distribution ──
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // ── Top Cluster: Logo, Headings, Social, Inputs & Button ──
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 6),

                                        // ── Official VACHIKA Logo Badge ─────
                                        Container(
                                          width: 84,
                                          height: 84,
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.92),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.6,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.08),
                                                blurRadius: 18,
                                                offset: const Offset(0, 8),
                                              ),
                                              BoxShadow(
                                                color: Colors.white
                                                    .withValues(alpha: 0.6),
                                                blurRadius: 8,
                                                offset: const Offset(0, -1),
                                              ),
                                            ],
                                          ),
                                          padding: const EdgeInsets.all(15),
                                          child: Image.asset(
                                            'assets/images/vachika_logo.png',
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                              Icons.sign_language_rounded,
                                              color: AppColors.forestSage,
                                              size: 40,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 18),

                                        // ── Headline: "Sign Up" ───────────
                                        const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.graphite,
                                            letterSpacing: -0.5,
                                          ),
                                        ),

                                        const SizedBox(height: 5),

                                        // ── Subtitle: "Let's create your account" ──
                                        Text(
                                          "Let's create your account",
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.graphite
                                                .withValues(alpha: 0.72),
                                            letterSpacing: 0.1,
                                          ),
                                        ),

                                        const SizedBox(height: 22),

                                        // ── Direct Social Buttons: Google & X (Twitter) ──
                                        Row(
                                          children: [
                                            // Google Button
                                            Expanded(
                                              child: _buildSocialButton(
                                                onTap: isLoading
                                                    ? null
                                                    : _handleGoogleSignIn,
                                                iconWidget:
                                                    const _GoogleLogoIcon(),
                                                label: 'Google',
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // X (Twitter) Button
                                            Expanded(
                                              child: _buildSocialButton(
                                                onTap: isLoading
                                                    ? null
                                                    : _handleTwitterSignIn,
                                                iconWidget: const Text(
                                                  '𝕏',
                                                  style: TextStyle(
                                                    color: AppColors.graphite,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                label: 'Twitter',
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        // ── "or with email" Divider ─────────
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.white
                                                    .withValues(alpha: 0.40),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                              ),
                                              child: Text(
                                                'or with email',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.85),
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                height: 1,
                                                color: Colors.white
                                                    .withValues(alpha: 0.40),
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 20),

                                        // ── Error Banner (if any) ─────────
                                        if (authState.status ==
                                                AuthStatus.error &&
                                            authState.errorMessage !=
                                                null) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            margin: const EdgeInsets.only(
                                                bottom: 18),
                                            decoration: BoxDecoration(
                                              color: AppColors.error
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: AppColors.error
                                                    .withValues(alpha: 0.35),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error_outline_rounded,
                                                  color: AppColors.error,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    authState.errorMessage!,
                                                    style: const TextStyle(
                                                      color: AppColors.error,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],

                                        // ── Field 1: Full Name ────────────
                                        _buildFrostedInput(
                                          controller: _nameController,
                                          hintText: 'Full Name',
                                          prefixIcon:
                                              Icons.person_outline_rounded,
                                          textInputAction: TextInputAction.next,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Please enter your name';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // ── Field 2: Email Address ────────
                                        _buildFrostedInput(
                                          controller: _emailController,
                                          hintText: 'name@example.com',
                                          prefixIcon:
                                              Icons.mail_outline_rounded,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          suffixWidget: _isEmailValid
                                              ? Container(
                                                  margin: const EdgeInsets.only(
                                                      right: 14),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF2E7D32),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(3),
                                                  child: const Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                )
                                              : null,
                                          validator: (val) {
                                            if (val == null ||
                                                val.trim().isEmpty) {
                                              return 'Please enter your email';
                                            }
                                            if (!val.contains('@') ||
                                                !val.contains('.')) {
                                              return 'Please enter a valid email address';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 16),

                                        // ── Field 3: Password ─────────────
                                        _buildFrostedInput(
                                          controller: _passwordController,
                                          hintText: 'Password',
                                          prefixIcon: Icons.lock_outline_rounded,
                                          obscureText: _obscurePassword,
                                          textInputAction: TextInputAction.done,
                                          suffixWidget: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                      .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: AppColors.graphite
                                                  .withValues(alpha: 0.60),
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                            tooltip: _obscurePassword
                                                ? 'Show'
                                                : 'Hide',
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

                                        const SizedBox(height: 18),

                                        // ── Terms & Conditions Checkbox Row ──
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _agreedToTerms = !_agreedToTerms;
                                            });
                                          },
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 22,
                                                height: 22,
                                                decoration: BoxDecoration(
                                                  color: _agreedToTerms
                                                      ? AppColors.forestSage
                                                      : Colors.white.withValues(
                                                          alpha: 0.50),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: _agreedToTerms
                                                        ? AppColors.forestSage
                                                        : AppColors.graphite
                                                            .withValues(
                                                                alpha: 0.35),
                                                    width: 1.5,
                                                  ),
                                                ),
                                                child: _agreedToTerms
                                                    ? const Icon(
                                                        Icons.check_rounded,
                                                        color: Colors.white,
                                                        size: 16,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: TextStyle(
                                                      fontSize: 12.5,
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.90),
                                                      height: 1.35,
                                                    ),
                                                    children: const [
                                                      TextSpan(
                                                        text:
                                                            'By tapping here you agree to our ',
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            'Terms and Conditions',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      TextSpan(text: ' & '),
                                                      TextSpan(
                                                        text: 'Privacy Policy',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        const SizedBox(height: 24),

                                        // ── Sign Up Glowing Pill Button ───
                                        _buildGlowingSignUpButton(
                                          label: 'Sign Up',
                                          isLoading: isLoading,
                                          onPressed: _handleSignUp,
                                        ),
                                      ],
                                    ),

                                    // ── Bottom Cluster: Trust Badge & Footer Link ──
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 32,
                                        bottom: 22,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // ── Privacy & Trust Pill ─────────
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withValues(alpha: 0.22),
                                                width: 1.0,
                                              ),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .verified_user_outlined,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Private In-Memory ISL Processing',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    letterSpacing: 0.2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 18),

                                          // ── Already have an account? Sign In ─
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Already have an account? ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.85),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () => context.pop(),
                                                child: const Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helper: Social Sign-In Button ────────────────────────────
  Widget _buildSocialButton({
    required VoidCallback? onTap,
    required Widget iconWidget,
    required String label,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: AppColors.forestSage.withValues(alpha: 0.12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.graphite,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper: Crisp High-Contrast Frosted Input Field ─────────
  Widget _buildFrostedInput({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool obscureText = false,
    Widget? suffixWidget,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: const TextStyle(
          color: AppColors.graphite,
          fontSize: 15.5,
          fontWeight: FontWeight.w600,
        ),
        cursorColor: AppColors.forestSage,
        decoration: InputDecoration(
          filled: false,
          fillColor: Colors.transparent,
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.graphite.withValues(alpha: 0.45),
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: AppColors.forestSage,
            size: 21,
          ),
          suffixIcon: suffixWidget,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.forestSage,
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.4,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.8,
            ),
          ),
          errorStyle: const TextStyle(
            color: Color(0xFFD32F2F),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // ── Helper: Glowing Gradient Pill Button ────────────────────
  Widget _buildGlowingSignUpButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4C7566), // Luminous Forest Sage
            Color(0xFF345448), // Core brand tone
            Color(0xFF243D34), // Deep rooted anchor
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.30),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: isLoading ? null : onPressed,
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Official colored Google "G" emblem painter.
class _GoogleLogoIcon extends StatelessWidget {
  const _GoogleLogoIcon({this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.80);

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.4, false, paint);

    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.0, 1.6, false, paint);

    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.6, 1.5, false, paint);

    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 4.1, 1.3, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.45, h * 0.40, w * 0.50, h * 0.20),
        const Radius.circular(2),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
