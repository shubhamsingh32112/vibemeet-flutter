import 'package:shared_preferences/shared_preferences.dart';

class WelcomeService {
  static const String _keyHasSeenWelcome = 'has_seen_welcome';

  /// Check if user has seen the welcome dialog
  static Future<bool> hasSeenWelcome() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasSeenWelcome) ?? false;
    } catch (e) {
      // If there's an error, assume they haven't seen it
      return false;
    }
  }

  /// Mark that user has seen the welcome dialog
  static Future<void> markWelcomeAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasSeenWelcome, true);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Reset welcome status (useful for testing)
  static Future<void> resetWelcomeStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasSeenWelcome);
    } catch (e) {
      // Ignore errors
    }
  }
}
