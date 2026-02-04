import 'package:shared_preferences/shared_preferences.dart';

/// Service to track if permission prompt has been shown to user
/// 
/// Prevents showing permission dialog on every home screen rebuild
/// Uses SharedPreferences for persistence across app sessions
class PermissionPromptService {
  static const String _keyHasShownPermissionPrompt = 'has_shown_permission_prompt';

  /// Check if permission prompt has been shown
  static Future<bool> hasShownPermissionPrompt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyHasShownPermissionPrompt) ?? false;
    } catch (e) {
      // If there's an error, assume it hasn't been shown
      return false;
    }
  }

  /// Mark that permission prompt has been shown
  static Future<void> markPermissionPromptAsShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasShownPermissionPrompt, true);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Reset permission prompt status (useful for testing)
  static Future<void> resetPermissionPromptStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasShownPermissionPrompt);
    } catch (e) {
      // Ignore errors
    }
  }
}
