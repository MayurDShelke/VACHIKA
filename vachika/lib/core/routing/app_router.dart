import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/screens/cover_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/sign_to_speech/sign_to_speech_screen.dart';
import '../../features/speech_to_sign/speech_to_sign_screen.dart';
import '../../features/conversation/conversation_screen.dart';
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
  static const String home         = '/home';
  static const String signToSpeech = '/sign-to-speech';
  static const String speechToSign = '/speech-to-sign';
  static const String conversation = '/conversation';
  static const String dictionary   = '/dictionary';
  static const String history      = '/history';
  static const String settings     = '/settings';
}

/// Application router configuration using GoRouter.
///
/// Navigation is shallow (per DESIGN.md §4):
/// Bottom bar: Home · Dictionary · History · Settings
/// Feature screens are pushed from Home.
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

    // ── Shell with Bottom Navigation ─────────────────────────
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNav(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomeScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.dictionary,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DictionaryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.history,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HistoryScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),

    // ── Feature screens (pushed on top of shell) ─────────────
    GoRoute(
      path: AppRoutes.signToSpeech,
      builder: (context, state) => const SignToSpeechScreen(),
    ),
    GoRoute(
      path: AppRoutes.speechToSign,
      builder: (context, state) => const SpeechToSignScreen(),
    ),
    GoRoute(
      path: AppRoutes.conversation,
      builder: (context, state) => const ConversationScreen(),
    ),
  ],
);

// ── Bottom Navigation Shell ─────────────────────────────────

class _ScaffoldWithNav extends StatelessWidget {
  const _ScaffoldWithNav({required this.child});

  final Widget child;

  static const _tabs = [
    (route: AppRoutes.home,       icon: Icons.home_rounded,          label: 'Home'),
    (route: AppRoutes.dictionary, icon: Icons.menu_book_rounded,     label: 'Dictionary'),
    (route: AppRoutes.history,    icon: Icons.history_rounded,       label: 'History'),
    (route: AppRoutes.settings,   icon: Icons.settings_rounded,     label: 'Settings'),
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
