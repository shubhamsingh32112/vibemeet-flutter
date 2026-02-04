import 'package:flutter/foundation.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';
import '../../../app/router/app_router.dart';

/// Single source of truth for call navigation
/// 
/// 🔥 CRITICAL: Only ONE place navigates to /call
/// Prevents navigation race conditions and duplicate routes
class CallNavigationService {
  static bool _isOnCallScreen = false;
  static Call? _currentCall;

  /// Navigate to call screen (single authority)
  /// 
  /// Returns true if navigation succeeded, false if already on call screen
  static bool navigateToCall(Call call) {
    if (_isOnCallScreen && _currentCall?.id == call.id) {
      debugPrint('⏭️  [CALL NAV] Already on call screen for call: ${call.id}');
      return false;
    }

    debugPrint('✅ [CALL NAV] Navigating to call screen: ${call.id}');
    _isOnCallScreen = true;
    _currentCall = call;
    
    // Navigate using global router (works from anywhere)
    appRouter.push('/call');
    
    return true;
  }

  /// Mark call screen as exited
  static void onCallScreenExited() {
    debugPrint('✅ [CALL NAV] Call screen exited');
    _isOnCallScreen = false;
    _currentCall = null;
  }

  /// Check if currently on call screen
  static bool get isOnCallScreen => _isOnCallScreen;

  /// Get current call (if any)
  static Call? get currentCall => _currentCall;
}
