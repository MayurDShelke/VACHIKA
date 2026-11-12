/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // ── App Identity ─────────────────────────────────────────
  static const String appName    = 'VACHIKA';
  static const String tagline    = 'Every Expression Deserves a Voice.';
  static const String appVersion = '1.0.0';

  // ── Backend ──────────────────────────────────────────────
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator → host
  static const Duration apiTimeout = Duration(seconds: 10);

  // ── Sign Recognition ─────────────────────────────────────
  static const int clipMaxDurationSec = 5;
  static const int clipMinDurationSec = 2;
  static const double confidenceThreshold = 0.60;

  // ── Speech ───────────────────────────────────────────────
  static const int audioMaxDurationSec = 30;

  // ── Supported Languages ──────────────────────────────────
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'hi', 'mr'];
  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिन्दी',
    'mr': 'मराठी',
  };

  // ── Animation Durations ──────────────────────────────────
  static const Duration animFast   = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow   = Duration(milliseconds: 500);

  // ── Dictionary ───────────────────────────────────────────
  static const int dictionaryPageSize = 20;
}
