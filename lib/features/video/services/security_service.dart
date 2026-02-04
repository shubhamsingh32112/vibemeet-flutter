import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';

/// Service for platform-specific security features
/// 
/// - Android: FLAG_SECURE to block screenshots/recording
/// - iOS: Screen capture detection with blur/disconnect
class SecurityService {
  static const MethodChannel _channel = MethodChannel('com.zztherapy/security');
  static Function(bool)? _onScreenCaptureChanged;

  /// Enable security for video calls (block screenshots/recording)
  /// 
  /// Android: Sets FLAG_SECURE on window
  /// iOS: Starts screen capture detection
  static Future<void> enableCallSecurity() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('setSecureFlag', {'enable': true});
        debugPrint('🔒 [SECURITY] Android FLAG_SECURE enabled');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('startScreenCaptureDetection');
        debugPrint('🔒 [SECURITY] iOS screen capture detection started');
        
        // Listen for screen capture changes
        _channel.setMethodCallHandler((call) async {
          if (call.method == 'onScreenCaptureChanged') {
            final isCaptured = call.arguments as bool;
            debugPrint('🔒 [SECURITY] Screen capture changed: $isCaptured');
            _onScreenCaptureChanged?.call(isCaptured);
          }
        });
      }
    } catch (e) {
      debugPrint('❌ [SECURITY] Error enabling security: $e');
    }
  }

  /// Disable security (restore normal behavior)
  static Future<void> disableCallSecurity() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('setSecureFlag', {'enable': false});
        debugPrint('🔒 [SECURITY] Android FLAG_SECURE disabled');
      } else if (Platform.isIOS) {
        await _channel.invokeMethod('stopScreenCaptureDetection');
        debugPrint('🔒 [SECURITY] iOS screen capture detection stopped');
      }
    } catch (e) {
      debugPrint('❌ [SECURITY] Error disabling security: $e');
    }
  }

  /// Set callback for screen capture detection (iOS)
  /// 
  /// Called when screen recording starts/stops
  /// Should blur UI or disconnect call when isCaptured is true
  static void setOnScreenCaptureChanged(Function(bool isCaptured) callback) {
    _onScreenCaptureChanged = callback;
  }
}
