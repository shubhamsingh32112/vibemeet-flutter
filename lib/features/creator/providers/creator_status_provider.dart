import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  return CreatorStatusNotifier();
});

class CreatorStatusNotifier extends StateNotifier<CreatorStatus> {
  static const String _statusKey = 'creator_status';
  
  CreatorStatusNotifier() : super(CreatorStatus.offline) {
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

  Future<void> setStatus(CreatorStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_statusKey, status == CreatorStatus.online);
      state = status;
    } catch (e) {
      // Handle error silently or log it
      print('Error saving creator status: $e');
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
