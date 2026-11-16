import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/language_selector.dart';
import '../../main.dart';
import '../auth/providers/auth_provider.dart';
import '../history/widgets/history_drawer.dart';

/// Editorial Profile Screen matching the reference design.
///
/// Features:
/// - Top App Bar with 3-lines menu icon (opens History drawer) and streak badge.
/// - Center artistic silhouette avatar with glowing backlit halo and sparkle star.
/// - Prominent bold editorial typography for user's name.
/// - Sleek pill "Sign Out" action button.
/// - Middle Account / Communication status card.
/// - Bottom segmented dock with:
///   1) Theme Toggle (Light / Dark mode switch)
///   2) App Settings / Preferences (Language & Audio)
///   3) Sign Out confirmation flow
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'en';
  bool _haptics = true;

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out?'),
        content: const Text(
          'Are you sure you want to sign out from VACHIKA? Your local history will remain saved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.graphite)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (mounted) {
                context.go(AppRoutes.login);
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showPreferencesModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'App Settings & Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF202522),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Preferred Translation Language',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF55605A),
                  ),
                ),
                const SizedBox(height: 8),
                LanguageSelector(
                  selectedLanguage: _language,
                  onChanged: (lang) {
                    setState(() => _language = lang);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.forestSage,
                  title: const Text(
                    'Haptic Feedback',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF202522),
                    ),
                  ),
                  subtitle: const Text(
                    'Subtle vibration on turn switches & actions',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  value: _haptics,
                  onChanged: (val) {
                    setState(() => _haptics = val);
                    setModalState(() {});
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isGuest = authState.isGuest;

    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    // Display Name (split or formatted)
    final rawName = (user?.name != null && user!.name.trim().isNotEmpty)
        ? user.name.trim()
        : 'Maya Lindazerza';

    final nameParts = rawName.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    return Scaffold(
      drawer: const HistoryDrawer(),
      backgroundColor: isDarkMode ? const Color(0xFF161C19) : const Color(0xFFFBFDFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.only(left: 14),
            child: IconButton(
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode
                      ? const Color(0xFF242F2B)
                      : Colors.white,
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF384E49)
                        : const Color(0xFFE5E7EB),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.menu_rounded,
                  size: 18,
                  color: isDarkMode ? Colors.white : const Color(0xFF202522),
                ),
              ),
              tooltip: 'Past History',
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        centerTitle: true,
        title: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 13,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 4),
                Text(
                  'STREAK 104',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: isDarkMode
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '246 Signs Practiced',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isDarkMode
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // ── Sparkle Star & Silhouette Avatar ────────────────
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Luminous Ambient Halo
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFD6E8DE).withValues(alpha: isDarkMode ? 0.25 : 0.65),
                          const Color(0xFFD6E8DE).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),

                  // High-Fashion Editorial Silhouette Portrait
                  CustomPaint(
                    size: const Size(190, 190),
                    painter: _SilhouetteArtworkPainter(isDark: isDarkMode),
                  ),

                  // ✦ Top Sparkle Star
                  Positioned(
                    top: -6,
                    child: Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 22,
                        color: isDarkMode
                            ? const Color(0xFFA5CDB6)
                            : const Color(0xFF202522),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ── Editorial Typography Name ────────────────────────
              Text(
                firstName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                  letterSpacing: -0.8,
                  color: isDarkMode ? Colors.white : const Color(0xFF181C1A),
                ),
              ),
              if (lastName.isNotEmpty)
                Text(
                  lastName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                    letterSpacing: -0.8,
                    color: isDarkMode ? Colors.white : const Color(0xFF181C1A),
                  ),
                ),

              const SizedBox(height: 12),

              // ── Pill Action: Sign Out ───────────────────────────
              GestureDetector(
                onTap: _showSignOutDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF242F2B)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDarkMode
                          ? const Color(0xFF384E49)
                          : const Color(0xFFD1D5DB),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode
                          ? const Color(0xFFE5E7EB)
                          : const Color(0xFF374151),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Middle Card: Account Status & Invites ───────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E2623)
                      : const Color(0xFFF3F5F4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF2C3A35)
                        : const Color(0xFFE5EAE7),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Dual Overlapping Badges
                    SizedBox(
                      width: 52,
                      height: 32,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.forestSage,
                              child: const Icon(
                                Icons.sign_language_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFFA5CDB6),
                              child: const Icon(
                                Icons.mic_rounded,
                                size: 16,
                                color: Color(0xFF202522),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuest ? 'Guest Session' : (user?.role.toUpperCase() ?? 'DEAF PARTICIPANT'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF202522),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'vachika.ai two-way connected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDarkMode
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: isDarkMode
                          ? const Color(0xFF9CA3AF)
                          : const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Bottom Segmented Card: Theme Toggle & Settings ──
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E2623)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF2C3A35)
                        : const Color(0xFFE5EAE7),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ── Left: Theme Change Toggle ─────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isDarkMode ? 'Dark Mode' : 'Light Mode',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDarkMode
                                        ? Colors.white
                                        : const Color(0xFF202522),
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.8,
                                  child: Switch.adaptive(
                                    value: isDarkMode,
                                    activeColor: AppColors.forestSage,
                                    onChanged: (val) {
                                      HapticFeedback.lightImpact();
                                      ref.read(themeModeProvider.notifier).state =
                                          val ? ThemeMode.dark : ThemeMode.light;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              isDarkMode ? 'Active theme: Slate' : 'Active theme: Porcelain',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDarkMode
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF8A9992),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Divider
                    Container(
                      width: 1.2,
                      height: 48,
                      color: isDarkMode
                          ? const Color(0xFF2C3A35)
                          : const Color(0xFFE5EAE7),
                    ),

                    // ── Right: Settings Action ───────────────────
                    Expanded(
                      child: InkWell(
                        onTap: _showPreferencesModal,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Settings',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF202522),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDarkMode
                                          ? const Color(0xFF2C3A35)
                                          : const Color(0xFFF3F5F4),
                                    ),
                                    child: Icon(
                                      Icons.tune_rounded,
                                      size: 15,
                                      color: isDarkMode
                                          ? Colors.white
                                          : const Color(0xFF344C43),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Audio & Language',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDarkMode
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF8A9992),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for the editorial silhouette artwork
class _SilhouetteArtworkPainter extends CustomPainter {
  final bool isDark;

  const _SilhouetteArtworkPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glowing rim / backlit circle behind the head
    final haloPaint = Paint()
      ..color = (isDark ? const Color(0xFFD6E8DE).withValues(alpha: 0.18) : Colors.white)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - 8), 58, haloPaint);

    // Deep artistic silhouette color
    final silhouetteColor = isDark ? const Color(0xFFE2EBE5) : const Color(0xFF181C1A);
    final paint = Paint()
      ..color = silhouetteColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // ── Head & Hair Silhouette Path ──
    final path = Path();

    // Shoulders base
    path.moveTo(cx - 52, cy + 68);
    path.cubicTo(cx - 38, cy + 44, cx - 22, cy + 34, cx - 18, cy + 24);

    // Chin and Jaw contour
    path.cubicTo(cx - 24, cy + 18, cx - 26, cy + 8, cx - 24, cy - 2);

    // Nose & Profile
    path.lineTo(cx - 30, cy - 10);
    path.lineTo(cx - 22, cy - 14);

    // Forehead
    path.cubicTo(cx - 24, cy - 26, cx - 16, cy - 36, cx - 4, cy - 44);

    // Hair top crest
    path.cubicTo(cx + 12, cy - 50, cx + 28, cy - 42, cx + 34, cy - 30);

    // Wavy flowing hair on right
    path.cubicTo(cx + 46, cy - 18, cx + 52, cy + 2, cx + 42, cy + 22);
    path.cubicTo(cx + 36, cy + 34, cx + 26, cy + 40, cx + 22, cy + 48);

    // Right shoulder
    path.cubicTo(cx + 26, cy + 54, cx + 42, cy + 62, cx + 52, cy + 68);

    // Close bottom base
    path.cubicTo(cx + 28, cy + 74, cx - 28, cy + 74, cx - 52, cy + 68);
    path.close();

    canvas.drawPath(path, paint);

    // Left flowing hair curl
    final leftHair = Path();
    leftHair.moveTo(cx - 18, cy - 14);
    leftHair.cubicTo(cx - 36, cy - 20, cx - 48, cy - 8, cx - 46, cy + 6);
    leftHair.cubicTo(cx - 44, cy + 16, cx - 34, cy + 24, cx - 24, cy + 20);
    leftHair.close();
    canvas.drawPath(leftHair, paint);

    // Subtle facial negative space / light reflection
    final lightGlow = Paint()
      ..color = (isDark ? const Color(0xFF1E2623) : Colors.white).withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    final faceHighlight = Path();
    faceHighlight.moveTo(cx - 16, cy - 14);
    faceHighlight.cubicTo(cx - 22, cy - 4, cx - 20, cy + 6, cx - 12, cy + 12);
    faceHighlight.cubicTo(cx - 10, cy + 8, cx - 8, cy - 4, cx - 12, cy - 10);
    faceHighlight.close();
    canvas.drawPath(faceHighlight, lightGlow);
  }

  @override
  bool shouldRepaint(covariant _SilhouetteArtworkPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
