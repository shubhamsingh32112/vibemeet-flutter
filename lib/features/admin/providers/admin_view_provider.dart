import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AdminViewMode {
  user,    // View as user (see creators)
  creator, // View as creator (see users)
}

// Provider to manage admin view mode
final adminViewModeProvider = StateNotifierProvider<AdminViewModeNotifier, AdminViewMode?>((ref) {
  return AdminViewModeNotifier();
});

class AdminViewModeNotifier extends StateNotifier<AdminViewMode?> {
  AdminViewModeNotifier() : super(null); // null means not an admin or not set

  void setViewMode(AdminViewMode mode) {
    state = mode;
  }

  void reset() {
    state = null;
  }
}
