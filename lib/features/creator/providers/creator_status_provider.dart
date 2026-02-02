import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../auth/providers/auth_provider.dart';

enum CreatorStatus {
  online,
  offline,
}

/// Provider to manage creator online/offline status
/// 
/// This provider is accessible everywhere in the app via Riverpod.
/// 
/// Usage example:
/// ```dart
/// // Watch the status
/// final status = ref.watch(creatorStatusProvider);
/// final isOnline = status == CreatorStatus.online;
/// 
/// // Toggle status
/// ref.read(creatorStatusProvider.notifier).toggleStatus();
/// 
/// // Set specific status
/// ref.read(creatorStatusProvider.notifier).setStatus(CreatorStatus.online);
/// 
/// // Check if online
/// final isOnline = ref.read(creatorStatusProvider.notifier).isOnline;
/// ```
final creatorStatusProvider = StateNotifierProvider<CreatorStatusNotifier, CreatorStatus>((ref) {
  return CreatorStatusNotifier(ref);
});

class CreatorStatusNotifier extends StateNotifier<CreatorStatus> {
  static const String _statusKey = 'creator_status';
  final Ref _ref;
  final ApiClient _apiClient = ApiClient();
  
  CreatorStatusNotifier(this._ref) : super(CreatorStatus.offline) {
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isOnline = prefs.getBool(_statusKey) ?? false;
      state = isOnline ? CreatorStatus.online : CreatorStatus.offline;
    } catch (e) {
      // Default to offline if loading fails
      state = CreatorStatus.offline;
    }
  }

  Future<void> setStatus(CreatorStatus status, {bool syncToBackend = true}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_statusKey, status == CreatorStatus.online);
      state = status;
      
      // Sync to backend if user is a creator
      if (syncToBackend) {
        final authState = _ref.read(authProvider);
        final user = authState.user;
        
        if (user != null && (user.role == 'creator' || user.role == 'admin')) {
          try {
            await _apiClient.patch('/creator/status', data: {
              'isOnline': status == CreatorStatus.online,
            });
            debugPrint('✅ [CREATOR STATUS] Synced to backend: ${status == CreatorStatus.online ? "online" : "offline"}');
          } catch (e) {
            debugPrint('⚠️  [CREATOR STATUS] Failed to sync to backend: $e');
            // Don't fail the status update if backend sync fails
          }
        }
      }
    } catch (e) {
      // Handle error silently or log it
      debugPrint('❌ [CREATOR STATUS] Error saving creator status: $e');
    }
  }

  void toggleStatus() {
    final newStatus = state == CreatorStatus.online 
        ? CreatorStatus.offline 
        : CreatorStatus.online;
    setStatus(newStatus);
  }

  bool get isOnline => state == CreatorStatus.online;
}
