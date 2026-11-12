import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VachikaApp()));
}

/// Root application widget.
///
/// Wraps the app in [ProviderScope] for Riverpod state management,
/// applies the VACHIKA design-system theme, and uses GoRouter
/// for declarative navigation.
class VachikaApp extends StatelessWidget {
  const VachikaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VACHIKA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      highContrastTheme: AppTheme.highContrast,
      routerConfig: appRouter,
    );
  }
}
