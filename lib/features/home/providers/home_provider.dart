import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../shared/models/creator_model.dart';
import '../../../shared/models/profile_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../admin/providers/admin_view_provider.dart';

// Provider to fetch creators (for users)
final creatorsProvider = FutureProvider<List<CreatorModel>>((ref) async {
  try {
    final apiClient = ApiClient();
    final response = await apiClient.get('/creator');
    
    if (response.statusCode == 200) {
      final creatorsData = response.data['data']['creators'] as List;
      return creatorsData
          .map((json) => CreatorModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    return [];
  }
});

// Provider to fetch users (for creators)
final usersProvider = FutureProvider<List<UserProfileModel>>((ref) async {
  try {
    final apiClient = ApiClient();
    final response = await apiClient.get('/user/list');
    
    if (response.statusCode == 200) {
      final usersData = response.data['data']['users'] as List;
      return usersData
          .map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    print('❌ [HOME] Failed to fetch users: Status ${response.statusCode}');
    print('   Response: ${response.data}');
    return [];
  } catch (e) {
    print('❌ [HOME] Error fetching users: $e');
    rethrow; // Re-throw to show error in UI
  }
});

// Provider that returns the appropriate list based on user role
final homeFeedProvider = FutureProvider<List<dynamic>>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  
  if (user == null) {
    return [];
  }
  
  // If user is an admin, check their view mode preference
  if (user.role == 'admin') {
    final adminViewMode = ref.watch(adminViewModeProvider);
    
    // Default to user view if not set
    if (adminViewMode == null || adminViewMode == AdminViewMode.user) {
      // Admin viewing as user: show creators
      final creators = await ref.watch(creatorsProvider.future);
      return creators;
    } else {
      // Admin viewing as creator: show users
      final users = await ref.watch(usersProvider.future);
      return users;
    }
  }
  
  // If user is a creator, show users
  if (user.role == 'creator') {
    final users = await ref.watch(usersProvider.future);
    return users;
  }
  
  // If user is a regular user, show creators
  final creators = await ref.watch(creatorsProvider.future);
  return creators;
});
