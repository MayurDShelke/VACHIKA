import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Authentication repository for VACHIKA.
///
/// Handles session persistence via [SharedPreferences] and supports
/// both authenticated and anonymous/guest modes per ARCHITECTURE.md §7 & §8.
class AuthRepository {
  static const String _userPrefsKey = 'vachika_user_profile';
  static const String _onboardingPrefsKey = 'vachika_onboarding_completed';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Get currently stored user profile, if any
  Future<UserProfile?> getCurrentUser() async {
    try {
      final prefs = await _getPrefs();
      final userJson = prefs.getString(_userPrefsKey);
      if (userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        return UserProfile.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  /// Check if user has completed onboarding
  Future<bool> isOnboardingCompleted() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_onboardingPrefsKey) ?? false;
  }

  /// Mark onboarding as completed
  Future<void> setOnboardingCompleted() async {
    final prefs = await _getPrefs();
    await prefs.setBool(_onboardingPrefsKey, true);
  }

  /// Sign In with Email & Password
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    // Simulated network delay for realistic responsive feedback
    await Future.delayed(const Duration(milliseconds: 600));

    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw 'Please enter a valid email address.';
    }
    if (password.length < 6) {
      throw 'Password must be at least 6 characters.';
    }

    // Generate or derive user profile
    final name = trimmedEmail.split('@').first;
    final formattedName = name.isEmpty
        ? 'User'
        : name[0].toUpperCase() + name.substring(1);

    final user = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: formattedName,
      email: trimmedEmail,
      preferredLanguage: 'en',
      role: 'deaf',
      isGuest: false,
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  /// Sign Up with Email, Password, Name, and Language/Role preferences
  Future<UserProfile> signUp({
    required String name,
    required String email,
    required String password,
    String preferredLanguage = 'en',
    String role = 'deaf',
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw 'Please enter your name.';
    }
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw 'Please enter a valid email address.';
    }
    if (password.length < 6) {
      throw 'Password must be at least 6 characters.';
    }

    final user = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmedName,
      email: trimmedEmail,
      preferredLanguage: preferredLanguage,
      role: role,
      isGuest: false,
      createdAt: DateTime.now(),
    );

    await _saveUser(user);
    return user;
  }

  /// Continue as Guest (Anonymous session)
  Future<UserProfile> continueAsGuest({String preferredLanguage = 'en'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final guest = UserProfile.guest(preferredLanguage: preferredLanguage);
    await _saveUser(guest);
    return guest;
  }

  /// Sign In with Quick Demo Profile
  Future<UserProfile> signInDemo() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final demo = UserProfile.demo();
    await _saveUser(demo);
    return demo;
  }

  /// Send password reset link
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final trimmed = email.trim();
    if (trimmed.isEmpty || !trimmed.contains('@')) {
      throw 'Please enter a valid email address.';
    }
    // Simulation / Supabase integration hook
  }

  /// Sign Out and clear local session
  Future<void> signOut() async {
    final prefs = await _getPrefs();
    await prefs.remove(_userPrefsKey);
  }

  Future<void> _saveUser(UserProfile user) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userPrefsKey, jsonEncode(user.toJson()));
  }
}
