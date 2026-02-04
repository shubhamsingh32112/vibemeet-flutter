import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:flutter/foundation.dart';

/// Service for requesting camera and microphone permissions
/// 
/// 🔥 CRITICAL: Request permissions BEFORE starting calls
/// Stream SDK does NOT auto-request permissions
/// 
/// Must be called BEFORE:
/// - call.getOrCreate()
/// - call.accept()
/// - call.join()
class PermissionService {
  /// Request permissions for video calls
  /// 
  /// [video] - If true, requests camera + microphone. If false, only microphone (for audio-only calls)
  /// 
  /// Returns true if all requested permissions are granted, false otherwise
  /// Throws exception if permissions are permanently denied
  static Future<bool> ensurePermissions({required bool video}) async {
    try {
      debugPrint('📷 [PERMISSIONS] Requesting permissions (video: $video)...');
      
      // Build permission list based on call type
      final permissions = <permission_handler.Permission>[
        permission_handler.Permission.microphone, // Always needed
      ];
      
      if (video) {
        permissions.add(permission_handler.Permission.camera);
      }
      
      // Request permissions
      final statuses = await permissions.request();

      // Check microphone (always required)
      final micStatus = statuses[permission_handler.Permission.microphone];
      if (micStatus?.isGranted != true) {
        debugPrint('❌ [PERMISSIONS] Microphone permission denied');
        if (micStatus?.isPermanentlyDenied == true) {
          throw Exception(
            'Microphone permission is required for calls. '
            'Please enable it in app settings.',
          );
        }
        return false;
      }

      // Check camera (only if video call)
      if (video) {
        final cameraStatus = statuses[permission_handler.Permission.camera];
        if (cameraStatus?.isGranted != true) {
          debugPrint('❌ [PERMISSIONS] Camera permission denied');
          if (cameraStatus?.isPermanentlyDenied == true) {
            throw Exception(
              'Camera permission is required for video calls. '
              'Please enable it in app settings.',
            );
          }
          return false;
        }
      }

      debugPrint('✅ [PERMISSIONS] All requested permissions granted');
      return true;
    } catch (e) {
      debugPrint('❌ [PERMISSIONS] Error requesting permissions: $e');
      rethrow;
    }
  }

  /// Request camera and microphone permissions (for video calls)
  /// 
  /// Convenience method that calls ensurePermissions(video: true)
  /// 
  /// Returns true if both permissions are granted, false otherwise
  /// Throws exception if permissions are permanently denied
  static Future<bool> ensureCameraAndMicrophonePermissions() async {
    return ensurePermissions(video: true);
  }

  /// Check if camera and microphone permissions are granted
  static Future<bool> hasCameraAndMicrophonePermissions() async {
    final cameraStatus = await permission_handler.Permission.camera.status;
    final micStatus = await permission_handler.Permission.microphone.status;
    
    return cameraStatus.isGranted && micStatus.isGranted;
  }

  /// Check if microphone permission is granted (for audio-only calls)
  static Future<bool> hasMicrophonePermission() async {
    final micStatus = await permission_handler.Permission.microphone.status;
    return micStatus.isGranted;
  }

  /// Open app settings so user can manually enable permissions
  /// Useful when permissions are permanently denied
  static Future<bool> openAppSettings() async {
    try {
      // Use permission_handler's top-level openAppSettings function
      return await permission_handler.openAppSettings();
    } catch (e) {
      debugPrint('❌ [PERMISSIONS] Error opening app settings: $e');
      return false;
    }
  }
}
