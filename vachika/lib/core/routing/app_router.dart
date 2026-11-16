import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/cover_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/conversation/conversation_screen.dart';
import '../../features/sign_to_speech/sign_to_speech_screen.dart';
import '../../features/speech_to_sign/speech_to_sign_screen.dart';
import '../../features/dictionary/dictionary_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../widgets/split_nav_bar.dart';

/// Route path constants for type-safe navigation.
class AppRoutes {
  AppRoutes._();

  static const String splash       = '/';
  static const String cover        = '/cover';
  static const String login        = '/login';
  static const String signUp       = '/signup';
  static const String onboarding   = '/onboarding';

  // ── Primary App Features (Bottom Navbar Tabs) ─────────────
  static const String conversation = '/conversation';
  static const String signToSpeech = '/sign-to-speech';
  static const String textToSign   = '/text-to-sign';
  static const String profile      = '/profile';

  // ── Standalone & Legacy Aliases ───────────────────────────
  static const String home         = '/home';
  static const String speechToSign = '/speech-to-sign';
  static const String dictionary   = '/dictionary';
  static const String history      = '/history';
  static const String settings     = '/settings';
}

/// Application router configuration using GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.cover,
      builder: (context, state) => const CoverScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── Home redirects directly to Conversation Mode ──────────
    GoRoute(
      path: AppRoutes.home,
      redirect: (context, state) => AppRoutes.conversation,
    ),
    GoRoute(
      path: AppRoutes.speechToSign,
      redirect: (context, state) => AppRoutes.textToSign,
    ),
    GoRoute(
      path: AppRoutes.settings,
      redirect: (context, state) => AppRoutes.profile,
    ),

    // ── Shell with 4 Primary Feature Tabs ────────────────────
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNav(child: child),
      routes: [
        // Tab 0: Conversation Mode
        GoRoute(
          path: AppRoutes.conversation,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ConversationScreen(),
          ),
        ),
        // Tab 1: Sign to Speech
        GoRoute(
          path: AppRoutes.signToSpeech,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SignToSpeechScreen(),
          ),
        ),
        // Tab 2: Text to Sign
        GoRoute(
          path: AppRoutes.textToSign,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SpeechToSignScreen(),
          ),
        ),
        // Tab 3: Profile & Settings
        GoRoute(
          path: AppRoutes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),

    // ── Standalone Feature Pages ──────────────────────────────
    GoRoute(
      path: AppRoutes.dictionary,
      builder: (context, state) => const DictionaryScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);

// ── Bottom Navigation Shell ─────────────────────────────────

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});

  final Widget child;

  static const _tabs = [
    (
      route: AppRoutes.conversation,
      icon: Icons.forum_rounded,
      label: 'Conversation',
    ),
    (
      route: AppRoutes.signToSpeech,
      icon: Icons.back_hand_rounded,
      label: 'Sign → Speech',
    ),
    (
      route: AppRoutes.textToSign,
      icon: Icons.translate_rounded,
      label: 'Text → Sign',
    ),
    (
      route: AppRoutes.profile,
      icon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SplitNavBar(
            currentIndex: index,
            onTap: (i) => context.go(_tabs[i].route),
            items: _tabs
                .map(
                  (tab) => SplitNavItem(
                    icon: tab.icon,
                    label: tab.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
